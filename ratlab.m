function ret = ratlab(varNames, data, cmd)
  % I still have no idea how to access members of an octave class.  So,
  % I'm going to typecast dataframes to structs.  It would be nice if there
  % was some documentation on getting class members.

  % Go through each of the cell elements.  If its a data frame, typecast
  % it to a struct.
  for i=1:length(data)
    if strcmp(class(data{i}), 'dataframe')
      data{i} = struct(data{i});
    end
  end

  switch class(data)
    case 'cell'
      ret = ratlab_internal(varNames, data, cmd);
    otherwise
      error('unknown data type')
  end
end
