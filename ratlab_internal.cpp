#include <string>
using namespace std;
#include <string.h>
#include <math.h>
#include "mex.h"
#include <R.h>
#include <Rembedded.h>
#include <Rdefines.h>
#include <Rinternals.h>
#include <R_ext/Parse.h>

#include <stdio.h>
#include <stdlib.h>

// TODO: Currently, tight coupling is only going to be possible with 
//       Numeric types.  Should we create an analogous factor?
extern int R_running_as_main_program;

static int R_is_running = 0;

extern "C"
{

  SEXP RExecuteString (const char *s)
  {
    ParseStatus status;
    SEXP cmdSexp, cmdExpr, ret;
      PROTECT (cmdSexp = allocVector (STRSXP, 1));
      SET_STRING_ELT (cmdSexp, 0, mkChar (s));
      cmdExpr = PROTECT (R_ParseVector (cmdSexp, -1, &status, R_NilValue));
    if (status != PARSE_OK)
      {
	ret = R_NilValue;
	UNPROTECT (2);
      }
    else
      {
	ret = PROTECT (eval (VECTOR_ELT (cmdExpr, 0), R_GlobalEnv));
	UNPROTECT (3);
      }
    return (ret);
  }

// Does Matlab/Octave hold floats or integers?
// Yes, both. -bwl
  SEXP MexDoubleMatrix2SexpVector (const mxArray * pMexMat)
  {
    if (!mxIsNumeric (pMexMat))
      {
	Rf_endEmbeddedR (0);
	printf ("MexDoubleMatrix2SexpVector takes a matrix parameter.");
	return (R_NilValue);
      }
    size_t N, M;
    N = mxGetN (pMexMat);
    M = mxGetM (pMexMat);
    if (N > 1 && M > 1)
      warning ("Both N and M are greater than 1.");
    SEXP numericVals = PROTECT (NEW_NUMERIC (N * M));
    memcpy (NUMERIC_DATA (numericVals), mxGetPr (pMexMat),
	    N * M * sizeof (double));
    UNPROTECT (1);
    return (numericVals);
  }

  SEXP MexDoubleCellArray2SexpVector (const mxArray * pMexMat)
  {
    if (!mxIsCell (pMexMat))
      {
	Rf_endEmbeddedR (0);
	printf ("MexDoubleCellArray2SexpVector takes cell array parameter.");
	return (R_NilValue);
      }
    int nVals = mxGetNumberOfElements (pMexMat);
    SEXP numericVals = PROTECT (NEW_NUMERIC (nVals));
    double *pVals = NUMERIC_DATA (numericVals);
    int i;
    const mxArray *pElem;
    for (i = 0; i < nVals; ++i)
      {
	pElem = mxGetCell (pMexMat, i);
	if (!mxIsNumeric (pElem))
	  {
	    Rf_endEmbeddedR (0);
	    printf ("Cell values must be numeric");
	    UNPROTECT (1);
	    return (R_NilValue);
	  }
	if (mxGetNumberOfElements (pElem) != 1)
	  {
	    Rf_endEmbeddedR (0);
	    printf ("Only one value per cell is currently supported.\n");
	    UNPROTECT (1);
	    return (R_NilValue);
	  }
	pVals[i] = *mxGetPr (pElem);
      }
    UNPROTECT (1);
    return (numericVals);
  }

  SEXP MexStringCellArray2SexpVector (const mxArray * pMexMat)
  {
    if (!mxIsCell (pMexMat))
      {
	Rf_endEmbeddedR (0);
	printf
	  ("MexStringCellArray2SexpVector takes cell array parameter.\n");
	return (R_NilValue);
      }
    int nStrings = mxGetNumberOfElements (pMexMat);
    SEXP stringVals = PROTECT (allocVector (STRSXP, nStrings));
    int i;
    for (i = 0; i < nStrings; ++i)
      {
	mxArray *pElem = mxGetCell (pMexMat, i);
	if (mxIsChar (pElem))
	  {
	    int nchar = mxGetNumberOfElements (pElem) + 1;
	    char *pNewString = (char *) malloc (nchar * sizeof (char));
	    mxGetString (pElem, pNewString, nchar);
	    SET_STRING_ELT (stringVals, i, mkChar (pNewString));
	    free (pNewString);
	  }
	else
	  {
	    Rf_endEmbeddedR (0);
	    printf ("Element %d must be a string\n", i);
	    UNPROTECT (1);
	    return (R_NilValue);
	  }
      }
    UNPROTECT (1);
    return (stringVals);
  }

  char **MexStringCellArray2StringVector (const mxArray * pMexMat)
  {
    if (!mxIsCell (pMexMat))
      {
	Rf_endEmbeddedR (0);
	printf
	  ("MexStringCellArray2SexpVector takes cell array parameter.\n");
	return (NULL);
      }
    int nStrings = mxGetNumberOfElements (pMexMat);
    // See if any of the cell array elements are not strings.
    int i;
    for (i = 0; i < nStrings; ++i)
      {
	if (!mxIsChar (mxGetCell (pMexMat, i)))
	  return NULL;
      }
    char **pStrings = (char **) malloc (sizeof (char *) * nStrings);
    for (i = 0; i < nStrings; ++i)
      {
	mxArray *pElem = mxGetCell (pMexMat, i);
	int nchar = mxGetNumberOfElements (pElem) + 1;
	char *pNewString = (char *) malloc (nchar * sizeof (char));
	mxGetString (pElem, pNewString, nchar);
	pStrings[i] = pNewString;
      }
    return (pStrings);
  }

// This function will take our matlab dataframe class and 
// create a data frame.
  SEXP CreateDataFrame (const mxArray * pColNames, const mxArray * pData)
  {
    // Let's make sure the lengths of each of the cell array elements
    // is the same.
    size_t i, firstLength, ncols;
    ncols = mxGetNumberOfElements (pData);
    firstLength =
      ncols > 0 ? mxGetNumberOfElements (mxGetCell (pData, 0)) : 0;
    for (i = 1; i < ncols; ++i)
      {
	if (mxGetNumberOfElements (mxGetCell (pData, i)) != firstLength)
	  {
	    Rf_endEmbeddedR (0);
	    printf ("Cell array elements are not of the same length.\n");
	    return (R_NilValue);
	  }
      }
    // There must be a column name for each column.
    unsigned int ncolNames = mxGetNumberOfElements (pColNames);
    if (!(ncolNames == ncols))
      {
	Rf_endEmbeddedR (0);
	printf ("There must be one column name for each column.\n");
	return (R_NilValue);
      }
    // Now, let's try to create the data frame
    SEXP ret = PROTECT (NEW_LIST (ncols));
    int protectCount = 1;

    // Fill in the list with columns.
    const mxArray *pElem;
    for (i = 0; i < ncols; ++i)
      {
	pElem = mxGetCell (pData, i);
	if (mxIsNumeric (pElem))
	  {
	    SET_VECTOR_ELT (ret, i,
			    PROTECT (MexDoubleMatrix2SexpVector (pElem)));
	    ++protectCount;
	  }
	else if (mxIsCell (pElem))
	  {
	    if (mxGetNumberOfElements (pElem) == 0)
	      {
		SET_VECTOR_ELT (ret, i, PROTECT (NEW_NUMERIC (0)));
	      }
	    else
	      {
		const mxArray *first = mxGetCell (pElem, 0);
		if (mxIsChar (first))
		  {
		    SET_VECTOR_ELT (ret, i,
				    PROTECT (MexStringCellArray2SexpVector
					     (pElem)));
		  }
		else
		  {
		    SET_VECTOR_ELT (ret, i,
				    PROTECT (MexDoubleCellArray2SexpVector
					     (pElem)));
		  }
	      }
	    ++protectCount;
	  }
      }
    SEXP colNames = PROTECT (MexStringCellArray2SexpVector (pColNames));
    ++protectCount;
    SEXP dataFrameString = PROTECT (allocVector (STRSXP, 1));
    SET_STRING_ELT (dataFrameString, 0, mkChar ("data.frame"));
    ++protectCount;
    setAttrib (ret, R_NamesSymbol, colNames);
    setAttrib (ret, R_ClassSymbol, dataFrameString);
    UNPROTECT (protectCount);
    return (ret);
  }

// XXX XXX XXX XXX XXX
  SEXP *CreateSexps (const mxArray * pMexMat)
  {
    int nVectors = mxGetNumberOfElements (pMexMat);
    if (nVectors == 0)
      return NULL;
    int i;
    // TODO: Add code to see if we have something of the dataframe class!
    //       return the R object as a...
    // Use 2 passes.  One to figure out if the cell array elements are
    // valid; one to create the SEXPs.
    mxArray *pElem;
    for (i = 0; i < nVectors; ++i)
      {
	pElem = mxGetCell (pMexMat, i);
	if (mxIsCell (pElem))
	  {
	    if (mxGetNumberOfElements (pElem) > 0)
	      {
		mxArray *first = mxGetCell (pElem, 0);
		if (!mxIsChar (first) && !mxIsNumeric (first))
		  {
		    Rf_endEmbeddedR (0);
		    printf ("Cell %d contains an unsupported type: %s\n", i,
			    mxGetClassName (first));
		    return (NULL);
		  }
	      }
	  }
//	else if (mxIsClass (pElem, "struct"))
//	  {
	    // Let's just make sure it looks like a dataframe struct.
//	    if (mxGetNumberOfFields (pElem) != 4)
//	      {
//		Rf_endEmbeddedR (0);
//		printf ("Bad struct passed to ratlab_internal\n");
//		return (NULL);
//	      }
//	  }
	else if (!mxIsNumeric (pElem))
	  {
	    printf ("Cell %d contains an unsupported type: %s\n", i,
		    mxGetClassName (pElem));
	    return (NULL);
	  }
      }
    SEXP *pSexps = (SEXP *) malloc (sizeof (SEXP) * nVectors);
    for (i = 0; i < nVectors; ++i)
      {
	pElem = mxGetCell (pMexMat, i);
	if (mxIsNumeric (pElem))
	  {
	    pSexps[i] = MexDoubleMatrix2SexpVector (pElem);
	  }
	else if (mxIsCell (pElem))
	  {
	    if (mxGetNumberOfElements (pElem) == 0)
	      {
		pSexps[i] = NEW_NUMERIC (0);
	      }
	    else
	      {
		const mxArray *first = mxGetCell (pElem, 0);
		if (mxIsChar (first))
		  {
		    pSexps[i] = MexStringCellArray2SexpVector (pElem);
		  }
		else
		  {
		    pSexps[i] = MexDoubleCellArray2SexpVector (pElem);
		  }
	      }
	  }
	else if (mxIsClass (pElem, "struct"))
	  {
	    pSexps[i] = CreateDataFrame (mxGetField (pElem, 0, "colnames"),
					 mxGetField (pElem, 0, "data"));
	  }
	else
	  return (NULL);
      }
    return (pSexps);
  }

  void FreeStrings (char **pStrings, const int numStrings)
  {
    int i;
    for (i = 0; i < numStrings; ++i)
      {
	free (pStrings[i]);
      }
    free (pStrings);
  }

//  The R command to run.
  void mexFunction (int nlhs, mxArray * plhs[], int nrhs,
		    const mxArray * prhs[])
  {
    // Argument checking...
    // Make sure we have the correct number of arguments.
    if (nrhs != 3)
      {
	printf ("The ratlab function takes 3 arguements.\n");
	return;
      }

    // Make sure we have a variable name for each data cell array element.
    if (mxGetNumberOfElements (prhs[0]) != mxGetNumberOfElements (prhs[1]))
      {
	printf ("There are %ld variable names and %ld data vectors!\n",
		mxGetNumberOfElements (prhs[0]),
		mxGetNumberOfElements (prhs[1]));
	return;
      }

    // Make sure the third parameter is a string.
    if (!mxIsChar (prhs[2]))
      {
	printf ("The third parameter must be an R command.\n");
	return;
      }

    // Create a new R instance if one has not been created... 
    if (!R_is_running)
      {
	R_running_as_main_program = 1;
	char *argv[] = { (char *) "REmbedded", (char *) "--slave" };
	Rf_initEmbeddedR (2, argv);
	R_is_running = 1;
      }

    // Get the R variable names.
    char **pVariableNames = MexStringCellArray2StringVector (prhs[0]);
    size_t nVariables = mxGetNumberOfElements (prhs[0]);
    // Create the SEXPs.  This is the only function that will change
    // with the tight coupling.
    SEXP *pSexps;
    if ((pSexps = CreateSexps (prhs[1])) == NULL)
      {
	printf ("Problem in CreateSexps.\n");
	return;
      }
    // Get the R command.
    int commandLength = mxGetNumberOfElements (prhs[2]) + 1;
    char *pCommand = (char *) malloc (commandLength * sizeof (char));
    mxGetString (prhs[2], pCommand, commandLength);
    // Create the variables in R.
    size_t i = 0;
    for (i = 0; i < nVariables; ++i)
      {
	defineVar (install (pVariableNames[i]), pSexps[i], R_GlobalEnv);
      }

    // Now, let's run the command in R.
    RExecuteString ((string ("ratlabReturn=") + pCommand).c_str ());
    // ratlabReturn holds the return of the command.  Try to typecast it
    // to a matrix.
    RExecuteString
      ("ratlabReturn = matrix(as.double(ratlabReturn), nrow=nrow(ratlabReturn), ncol=ncol(ratlabReturn), dimnames=dimnames(ratlabReturn))");

    // Now get the R matrix and return it as a struct.
    // TODO: How do we create an octave dataframe directly?
    SEXP ratlabRet = findVar (install ("ratlabReturn"), R_GlobalEnv);
    SEXP rDimNames = getAttrib (ratlabRet, R_DimNamesSymbol);
    SEXP rRowNames = VECTOR_ELT (rDimNames, 0);
    SEXP rColNames = VECTOR_ELT (rDimNames, 1);
    int pCaDims[3];
    pCaDims[0] = GET_LENGTH (rRowNames);
    pCaDims[1] = GET_LENGTH (rColNames);
    pCaDims[2] = 1;
    const char *fieldNames[] =
      { (char *) "colnames", (char *) "rownames", (char *) "data" };
//  plhs[0] = mxCreateStructArray(3, pCaDims, 3, fieldNames);
    plhs[0] = mxCreateStructMatrix (1, 1, 3, fieldNames);
    mxArray *pColNameCells = mxCreateCellArray (1, &pCaDims[1]);
    for (i = 0; i < (size_t) GET_LENGTH (rColNames); ++i)
      {
	mxSetCell (pColNameCells, i,
		   mxCreateString (CHAR (STRING_ELT (rColNames, i))));
	// TODO: mxSetFieldByNumber will be more efficient.
//    mxSetField(plhs[0], i, "colnames", 
//      mxCreateString(CHAR(STRING_ELT(rColNames, i))));
      }
    mxSetField (plhs[0], 0, "colnames", pColNameCells);

    mxArray *pRowNameCells = mxCreateCellArray (1, &pCaDims[0]);
    for (i = 0; i < (size_t) GET_LENGTH (rRowNames); ++i)
      {
	mxSetCell (pRowNameCells, i,
		   mxCreateString (CHAR (STRING_ELT (rRowNames, i))));
	// TODO: mxSetFieldByNumber will be more efficient.
//    mxSetField(plhs[0], i, "rownames", 
//      mxCreateString(CHAR(STRING_ELT(rRowNames, i))));
      }
    mxSetField (plhs[0], 0, "rownames", pRowNameCells);

    int matrixDims[2];
    matrixDims[0] = ncols (ratlabRet);
    matrixDims[1] = nrows (ratlabRet);
    mxArray *pRetMat =
      mxCreateNumericArray (2, matrixDims, mxDOUBLE_CLASS, mxREAL);
    double *pm = mxGetPr (pRetMat);
    memcpy (pm, NUMERIC_DATA (ratlabRet),
	    sizeof (double) * matrixDims[0] * matrixDims[1]);
    mxSetField (plhs[0], 0, "data", pRetMat);
    // Clean up.
    RExecuteString ("rm(ratabReturn)");
    FreeStrings (pVariableNames, nVariables);
    free (pSexps);
    free (pCommand);
//  Rf_endEmbeddedR(0);
    return;
  }

}				// extern "C"
