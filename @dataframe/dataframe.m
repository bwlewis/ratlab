function df = dataframe(colnames, rownames, data)
  df = struct;
  df.strformat = "%13.13s";    % for formatting output (see display.m)
  df.colnames = colnames;
  df.rownames = rownames;
  df.data = data;
  df = class(df, 'dataframe');
endfunction
