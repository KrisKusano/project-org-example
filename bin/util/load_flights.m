function flights = load_flights(fname)
%% load flight data
% Kristofer D. Kusano
if ~exist(fname, 'file')
  error('load_flights:FileNotFound',...
        'flights file %s does not exist', fname);
end

s = load(fname);
if ~isfield(s, 'flights')
  error('load_flights:InvalidSave',...
        'flights file %s does not contain flight data', fname);
end

flights = s.flights;
