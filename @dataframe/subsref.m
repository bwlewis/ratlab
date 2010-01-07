function x = subsref(obj, S)
  switch (S.type)
    case "."
      x = builtin('subsref',obj, S);
    case "{}"
      x = builtin('subsref',obj.data, S);
    case "()"
      idx = S.subs;
% R-style dataframe indexing behavior
      l = length(idx);
      n = length(idx{l});
      rownames = obj.rownames;
      data = cell(1, n);
      colnames = cell(1,n);
      for j=1:n
        if (l==1)
% No row indices; select full columns
          data{1,j} = obj.data{1,idx{1}(j)};
          colnames{1,j} = obj.colnames{1,idx{1}(j)};
        else
          data{1,j} = obj.data{1,idx{2}(j)}(idx{1});
          colnames{1,j} = obj.colnames{1,idx{2}(j)};
          rownames = obj.rownames{1,idx{1}};
        end
      end
      x = dataframe(colnames,rownames,data);
  endswitch
endfunction
