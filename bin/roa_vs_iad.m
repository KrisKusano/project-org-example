%% Flight delays for ROA vs IAD
%
% Future Improvements:
%   * keeping those 30 that belong to both airports
%
% Kristofer D. Kusano - 5/24/14
%% Load data
clear all;
clc;

addpath('./util');
flights = load_flights('../data/2014-05-23/processed/bts_flights.mat');
%% Select out flights originating from ROA and IAD
origin = flights.origin;
dest = flights.dest;

% flights to/from ROA or IAD
idx_roa = strcmp(origin, 'ROA') | strcmp(dest, 'ROA');
idx_iad = strcmp(origin, 'IAD') | strcmp(dest, 'IAD');
nflights = size(idx_roa | idx_iad, 1);

% mark destination
flights.roa = false(nflights, 1);
flights.roa(idx_roa) = true;
flights.iad = false(nflights, 1);
flights.iad(idx_iad) = true;

% copy data
f_roa_iad = flights(idx_roa | idx_iad, :);
nf = size(f_roa_iad, 1);

% summarize
nroa = sum(idx_roa);
niad = sum(idx_iad);
fprintf('Flights to/from ROA and IAD:\n')
fprintf(' ROA         : %10.0f\n IAD         : %10.0f\n ROA and IAD : %10.0f\n\n',...
    nroa, niad, sum(idx_iad & idx_roa));
fprintf(' Either      : %10.0f\n\n', nf);

assert(sum(idx_iad) == sum(f_roa_iad.iad),...
    'copy didn''t go right');
%% canceled flights
disp('canceled flights')
disp('ROA')
tabulate(f_roa_iad.cancelled(f_roa_iad.roa))
disp('IAD')
tabulate(f_roa_iad.cancelled(f_roa_iad.iad))
disp(' ')
%% Cancel Codes
figure(1); clf
cc = f_roa_iad(:, {'roa', 'iad', 'cancelled', 'cancellation_code'});
cc(strcmp(cc.cancellation_code, ''), :) = []; % rm empty

cc_roa = cc.cancellation_code(cc.roa);
cc_iad = cc.cancellation_code(cc.iad);

ccboth = {cc_roa, cc_iad};
cs = hsv(2);
counts = cell(2, 1);
for i = 1:2
    ccsort = sort(ccboth{i});
    [uni, ia] = unique(ccsort);
    
    counts{i} = diff([ia; length(ccsort)]);
    
    [~, iaa] = setdiff({'A','B','C','D'}, uni);
    counts{i}(iaa) = 0;
end

counts = horzcat(counts{:}); % collapse
counts = bsxfun(@rdivide, counts, sum(counts)); % make percent

% plot
bh = barh(counts*100);

% text
ytl = {'Carrier', 'Weather', 'National Air System', 'Security'};
set(gca, 'yticklabel', ytl);
xt = get(gca, 'xtick');
xtl = strcat(cellstr(num2str(xt')), '%');
set(gca, 'xtick', xt, 'xticklabel', xtl);

th = [gca;
    legend('ROA', 'IAD')];
set(th, 'fontsize', 14);

% colors
set(bh(1), 'facecolor', 'b');
set(bh(2), 'facecolor', 'r');
%% Cumulative dist of delays
[f1, x1] = ecdf(f_roa_iad.dep_delay(f_roa_iad.roa));
[f2, x2] = ecdf(f_roa_iad.dep_delay(f_roa_iad.iad));

plot(x1, f1, '-b',...
    x2, f2, '-r',...
    'linewidth', 2);

% text
th = [gca;
    xlabel('Delay Time (min)');
    ylabel('Cumulative %');
    legend('ROA', 'IAD')];
set(th, 'fontsize', 14);

% limits
set(gca,...
    'xlim', [-30, 120]);