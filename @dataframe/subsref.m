function x = subsref(obj, S)
  switch (S.type)
    case '{}'
% Index directly into the data field
      x = builtin('subsref',obj.data, S);
    case '.'
% Address columns by name (like R's $ indexing and Matlab dataset)
      colidx = obj.colidx;
      idx = eval(strcat('colidx.',S.subs));
      data = cell(1, 1);
      data{1,1} = obj.data{1,idx};
      x = dataframe(data,obj.colnames(idx),obj.rownames);
    case '()'
% Address by numeric or labeled indicies
      idx = S.subs;
      l = length(idx);
      n = length(idx{l});
      if (idx{l} == ':') 
        n = obj.size(2);
        idx{l} = 1:n;
      end
      data = cell(1, n);
      colnames = cell(1,n);
      rownames = obj.rownames;
      if(l>1 && length(rownames)>0)
        rownames = obj.rownames(idx{1});
      end
      for j=1:n
        if (l==1)
% No row indices; select full columns
          data{1,j} = obj.data{1,idx{1}(j)};
          colnames{1,j} = obj.colnames{1,idx{1}(j)};
        else
          data{1,j} = obj.data{1,idx{2}(j)}(idx{1});
          colnames{1,j} = obj.colnames{1,idx{2}(j)};
        end %if
      end %for
      x = dataframe(data,colnames,rownames);
  end %switch
end %function
