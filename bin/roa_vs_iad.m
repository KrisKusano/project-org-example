%% Flight delays for ROA vs IAD
% Kristofer D. Kusano - 5/24/14
%% Load data
clear all;
clc;

addpath('./util');
flights = load_flights('../data/2014-05-23/processed/bts_flights.mat');
%% Select out flights originating from ROA and IAD

