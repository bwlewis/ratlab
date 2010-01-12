function display(obj)
% XXX This is a pretty crude print method and should be improved!
% Obvious things to do:
% Limit number of printed output rows; improve lazy dimension handling
% of the data field objects (it's pretty ugly).
  m = obj.size(1);   % row count
  n = obj.size(2);   % column count
  l = length(obj.rownames);
  if (l==m) 
    fprintf(1,obj.strformat, '');
  end
  for j = 1:n
    fprintf (1,obj.strformat, obj.colnames{j});
  end
  fprintf (1,'\n');
  for j=1:m
    if (l==m) 
      fprintf(1,obj.strformat, obj.rownames{j});
    end
    for k = 1:n
      if(length(obj.data{k}) == m)
        if (iscell(obj.data{k}))
          fprintf(1,obj.strformat,num2str(obj.data{k}{j}));
        else
          fprintf(1,obj.strformat,num2str(obj.data{k}(j)));
        end
      else
        fprintf(1,obj.strformat,num2str(obj.data{k}{1}(j)));
      end
    end
    fprintf (1,'\n');
  end
end %function
