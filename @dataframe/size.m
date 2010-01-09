function varargout = size(obj)
  m = obj.size(1);
  n = obj.size(2);
  varargout = {[m, n]};
  if (nargout == 2)
    varargout(1) = {m};
    varargout(2) = {n};
  end
end %function
