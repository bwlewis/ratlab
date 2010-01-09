function x = subsasgn(obj, S, value)
  switch (S.type)
    case "."
      x = builtin('subasgn',obj, S, value);
    case "{}"
      x = builtin('subsasgn',obj.data, S, value);
    case "()"
      idx = S.subs;
% R-style dataframe indexing behavior
      n = length(idx{length(idx)});
      for j=1:n
        if(length(idx)==1)
% No row indices; replace entire column(s)
          if(iscell(value)) obj.data{1,idx{1}(j)} = value{j};
          elseif(strcmp("dataframe",class(value))) 
            obj.data{1,idx{1}(j)} = value.data{j};
          else obj.data{1,idx{1}(j)} = value(:,j);
          end
        else
% Row subset specified; general replacement XXX not quite right yet
          if(iscell(value)) obj.data{1,idx{2}(j)}(idx{1}) = value{1,j};
          elseif(strcmp("dataframe",class(value))) 
            obj.data{1,idx{2}(j)}(idx{1}) = value.data{j};
          else obj.data{1,idx{2}(j)}(idx{1}) = value(:,j);
          end
        end
      end
      x = obj;
  end %switch
end %function
