function display(obj)
% XXX This is a pretty crude print method and should be improved!
% Obvious things to do:
% Limit number of printed output rows
% Vectorize?
  m = length(obj.data{1});
  n = length(obj.data);
  for j = 1:n
    printf (obj.strformat, obj.colnames{j});
  end
  printf ("\n");
  for j=1:m
    for k = 1:n
      if(iscell(obj.data{k})) printf(obj.strformat,obj.data{k}{j});
      else 
        printf(obj.strformat,num2str(obj.data{k}(j)));
      end
    end
    printf ("\n");
  end
%  disp(struct(obj))
endfunction
