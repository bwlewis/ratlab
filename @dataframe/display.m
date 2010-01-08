function display(obj)
% XXX This is a pretty crude print method and should be improved!
% Obvious things to do:
% Limit number of printed output rows; improve lazy dimension handling
% of the data field objects (it's pretty ugly).
% Vectorize?
obj.data
  m = length(obj.data{1})
  n = length(obj.data)
  if (~iscell(obj.data{1}))
    m = length(obj.data);
    n = 1;
  end
  l = length(obj.rownames);
  if (l==m) 
    printf(obj.strformat, '');
  end
  for j = 1:n
    printf (obj.strformat, obj.colnames{j});
  end
  printf ("\n");
  for j=1:m
    if (l==m) 
      printf(obj.strformat, obj.rownames{j});
    end
    for k = 1:n
      if(iscell(obj.data{k})) printf(obj.strformat,obj.data{k}{j});
      else 
        if (n ==1 )
          printf(obj.strformat,num2str(obj.data{j}));
        else
          printf(obj.strformat,num2str(obj.data{k}(j)));
        end
      end
    end
    printf ('\n');
  end
endfunction
