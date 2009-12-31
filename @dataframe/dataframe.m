function df = dataframe(colnames, data)
  df = struct;
  df.strformat = "%13.13s";    % for formatting output (see display.m)
  df.colnames = colnames;
  df.data = data;
  df = class(df, 'dataframe');
endfunction
