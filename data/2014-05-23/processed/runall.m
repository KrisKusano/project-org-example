%% read in flight csv files
% script looks for all csv files in the directory above this and outputs a .mat
% file. The mat file contains a table with all the data from the flights
% concatenated.
%
% runs a shell script (`rm_double_quotes.sh`) to remove double quotes
%
% Future work: this is pretty clumsy, and even with just 2 csv files, it's
% already getting quite large. Maybe consider adding some pre-processing (e.g.
% removing useless entries, etc).
%
% Kristfofer D. Kusano - 5/23/14
clear all;
clc
%% run shell script to remove double quotes
flines = repmat('-', 1, 69);
fprintf([flines, '\nRemoving double quotes\n', flines]);

if exist('rm_double_quotes.sh', 'file')
  [~, cmdout] = system(['C:\cygwin\bin\bash rm_double_quotes.sh']);
  disp(cmdout);
end
%% find all CSV from data folder
save_file = 'bts_flights.mat';  % save in processed folder, all csvs combined
data_dir = dir('..');
names_dir = {data_dir.name};
idx_csv = ~cellfun(@isempty, regexp(names_dir, '\.csv.tmp$')); % only csv file names
csv_paths = names_dir(idx_csv); % path to csvs
csv_bytes = [data_dir(idx_csv).bytes];

ncsv = length(csv_paths);
if ncsv == 0
  error('No CSV files to process. exiting')
else
  fprintf('Combining %d csv files\n',...
    ncsv);
  for i = 1:ncsv
    fprintf(' %s\n', csv_paths{i});
  end
end
%% Read in, save to matfile
d_store = cell(ncsv, 1);
for i = 1:ncsv
  d_store{i} = readtable(['../', csv_paths{i}],...
        'FileType', 'text',...
        'Delimiter', ',',...
        'ReadVariableNames', true);
end
flights = vertcat(d_store{:}); % stack up all

% make all column names lower case
flights.Properties.VariableNames = ...
    cellfun(@lower, flights.Properties.VariableNames, 'uni', false);

% remove extra variable at end
flights.var22 = [];

save(save_file, 'flights'); % save in mat
%% make summary file
fid = fopen('summary', 'w'); % overwrites existing summary

% list out files
fprintf(fid, 'Input Files (%d):\n', ncsv);
for i = 1:ncsv
  fprintf(fid, '%s (%.6f MB)\n',...
      csv_paths{i}, csv_bytes(i)/1e6);
end
fprintf(fid, '\n');

% total number of rows
fprintf(fid, 'Total Rows (observations) in Dataset:\n');
fprintf(fid, '%d\n\n', size(flights, 1));
assert(size(flights, 1) == sum(cellfun(@(x) size(x, 1), d_store)),...
    'concatentae of ''d_store'' into ''flights'' went wrong.')

% hash
hash_exe = '..\..\sha1sum.exe';
if ~exist(hash_exe, 'file')
  error('%s not found - can''t make summary',...
      hash_exe);
end
[~, hash_raw] = system([hash_exe, ' ', save_file]);
fprintf(fid, 'SHA1 Sum:\n%s\n', hash_raw);

% done, close
fclose(fid);
%% clean up temps
disp('cleaning up')
for i = 1:ncsv
    fprintf(' removing %s\n', csv_paths{i});
    delete(['../', csv_paths{i}]);
end
