function display(obj)
% XXX This is a pretty crude print method and should be improved!
% Obvious things to do:
% Limit number of printed output rows; improve lazy dimension handling
% of the data field objects (it's pretty ugly).
  m = obj.size(1);   % row count
  n = obj.size(2);   % column count
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
      if(length(obj.data{k}) == m)
        if (iscell(obj.data{k}))
          printf(obj.strformat,num2str(obj.data{k}{j}));
        else
          printf(obj.strformat,num2str(obj.data{k}(j)));
        end
      else
        printf(obj.strformat,num2str((obj.data{k}{1})(j)));
      end
    end
    printf ('\n');
  end
end %function
