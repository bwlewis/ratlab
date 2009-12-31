function x = subsasgn(obj, S, value)
  switch (S.type)
    case "."
      x = builtin('subasgn',obj, S, value);
    case "{}"
      x = builtin('subsasgn',obj.data, S, value);
    case "()"
      idx = S.subs;
% R-style dataframe indexing behavior
      n = length(idx{length(idx)})
      for j=1:n
        if (length(idx)==1)
% No row indices; replace a full column
          obj.data{1,j} = value;
        else
% XXX
          obj.data{1,idx{2}(j)}(idx{1})=value{1,j};
        end
      end
      x = data;
  endswitch
endfunction

endfunction
