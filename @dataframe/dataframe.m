function df = dataframe(varargin)
%
% A dataframe class for Matlab and Octave.
% The dataframe class represents a two-dimensional array of uniformly-
% typed columns. The columns may be of distinct types, however. Columns
% must be labeled with unique names. Row labels are optional.
% 
% A = dataframe(data)
% A = dataframe(data, colnames)
% A = dataframe(data, colnames, rownames)
% XXX TODO: Change colnames, rownames to struct options XXX
%
  if (nargin == 0), help dataframe, return, end
  df = struct;
  df.colnames = {};
  df.colidx = NA;
  df.rownames = {};
  df.rowidx = NA;
  df.strformat = "%13.13s";    % for formatting output (see display.m)
  if (iscell(varargin{1}))
    if (iscell((varargin{1}){1}))
      df.data = varargin{1};
    else
      df.data = {varargin{1}};
    end
  elseif (ismatrix(varargin{1}))
    [m,n] = size(varargin{1});
    df.data = mat2cell(varargin{1},m,ones(1,n));
  else
    error('Data must be either cell or matrix format.');
  end
  n = length(df.data);
  if (nargin > 1) 
% Record provided column names and index them.
    df.colnames = varargin{2};
  else
% Make column names up
    df.colnames = cell(1,n);
    for j = 1:n
      df.colnames(1,j) = strcat('X',num2str(j));
    end
  end
  cl = length(df.colnames);
%    if (cl != n)
%      error('Number of column labels does not match number of columns.');
%    end
  df.colidx = cell2struct(mat2cell(1:cl,1,ones(cl,1)),df.colnames,2);
  if(length(fieldnames(df.colidx)) != cl)
    error('Column labels must be unique.');
  end
% XXX 
% df.colidx.<column name> now maps to the integer column index.
% However, Matlab won't allow struct identifiers to begin with a non-alpha
% character, so that means column names are less general than in R. We could
% fix this by prepending an alpha character in the index?
  if (nargin > 2)
    df.rownames = varargin{3};
    rl = length(df.rownames);
    if (rl>0)
      df.rowidx = cell2struct(mat2cell(1:rl,1,ones(rl,1)),df.rownames,2);
% XXX See note above for column names.
      if(length(fieldnames(df.rowidx)) != rl)
        error('Row names must be unique.');
      end
    end
  end
  df = class(df, 'dataframe');
endfunction
