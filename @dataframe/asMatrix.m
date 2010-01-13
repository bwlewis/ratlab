function dfm = asMatrix(df)
% asMatrix: turns a dataframe object into a matrix.
% If there are multiple classes of values in the dataframe,
% they will be converted according to the following precedence:
% 0 - logical
% 1 - single
% 2 - double
% 3 - char
% This means that if your dataframe holds a column of chars,
% the matrix returned from asmatrix will be a char-based
% representation of the dataframe.
% TODO:
% - There are a number of optimizations that can be done here
%   to minimize the number of conversions occuring
% - The conversion to char should work better, but the vectorized
%   num2str doesn't naievely do what we want.

  classdf = cellfun(@class, df.data,'UniformOutput',false);
  % Classes: 0 - logical, 1 - single, 2 - double, 3 - char
  setClass = classSwitch(classdf{1});

  for i = 1:length(classdf),
    caseClass = classSwitch(classdf{i});
    if setClass < caseClass
      setClass = caseClass;
    end
  end
  
  newData = {};
  switch setClass
      case 1
	newData = cellfun(@single, df.data, 'UniformOutput', false);
      case 2
	newData = cellfun(@double, df.data, 'UniformOutput', false);
      case 3
	newData = cellfun(@char, df.data, 'UniformOutput', false);
      otherwise
	disp('Error in class setting')
    end

  lendf = length(newData);
  widdf = length(newData{1});
  dfm = reshape(cell2mat(newData), widdf, lendf);
end

function caseClass = classSwitch(classStr)
  switch classStr
    case 'logical'
      caseClass = 0;
    case 'single'
      caseClass = 1;
    case 'double'
      caseClass = 2;
    case 'char'
      caseClass = 3;
    otherwise
      disp('Error is class detection');
  end
end
