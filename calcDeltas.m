function deltas = calcDeltas(x, w)
%    Calculate the deltas (derivatives) of a sequence
%    Use a W-point window (W odd, default 9) to calculate deltas using a
%    simple linear slope.  Each row of X is filtered separately.


if nargin < 2
  w = 9;
end

[nr,nc] = size(x);

if nc == 0
  % empty vector passed in; return empty vector
  deltas = x;

else

  % Define window shape
  h_len = floor(w/2);
  filter_window = h_len:-1:-h_len;

  % pad data by repeating first and last columns
  xx = [repmat(x(:,1),1,h_len), x, repmat(x(:,end),1,h_len)];

  % Apply the delta filter
  deltas = filter(filter_window, 1, xx, [], 2);  % filter along dim 2 (rows)

  % Trim edges
  deltas = deltas(:, 2*h_len + [1:nc]);

end
