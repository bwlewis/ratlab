function inds = stringfind( s, slist )

  inds = [];
  if iscell(slist)
    j=1;
    for i = 1:length(slist)
      if (sum( s == slist{i} ) == length(s)) & (length(s) == length(slist{i}))
        inds(1,j) = i;
        j = j+1;
      end %if
    end %for
  else
    inds = (sum( s == slist ) == length(s)) & (length(s) == length(slist))
  end %if
end %function
