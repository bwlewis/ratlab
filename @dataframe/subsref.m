function x = subsref(obj, S)
  switch (S.type)
    case "."
      x = builtin('subsref',obj, S);
    case "{}"
      x = builtin('subsref',obj.data, S);
    case "()"
      idx = S.subs;
% R-style dataframe indexing behavior
      n = length(idx{length(idx)});
      data = cell(1, n);
      colnames = cell(1,n);
      for j=1:n
        if (length(idx)==1)
% No row indices; select full columns
          data{1,j} = obj.data{1,idx{1}(j)};
          colnames{1,j} = obj.colnames{1,idx{1}(j)};
        else
          data{1,j} = obj.data{1,idx{2}(j)}(idx{1});
          colnames{1,j} = obj.colnames{1,idx{2}(j)};
        end
      end
      x = dataframe(colnames,data);
  endswitch
endfunction
