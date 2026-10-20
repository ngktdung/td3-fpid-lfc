%% run_extract_parameters.m
%  Fixed FPID parameter vector of the trained TD3 agents (Table A.4 of the paper).
%  Saves data/FPID_gains_from_TD3.mat, used by run_offline_FPID.m.
clear; clc;
root = fileparts(mfilename('fullpath'));  if isempty(root), root = pwd; end
addpath(fullfile(root,'models'), fullfile(root,'src'), fullfile(root,'data'));

%% 1) Load the trained agents
load(fullfile(root,'data','TD3_FPID_20260407_0943.mat'), ...   % reported training run
    'agent1','agent2');

numObs = 3;   % [e; integral of e; filtered e]

%% 2) Parameters at the initial state (e = 0)
obs0 = zeros(numObs,1,'single');   % e = 0, integral = 0, filtered e = 0

% observations are passed as a cell array
[a1_cell, ~] = getAction(getActor(agent1), {obs0});
[a2_cell, ~] = getAction(getActor(agent2), {obs0});

a1 = a1_cell{1};   % 5x1 raw = [KX1 KY1 Kp1 Ki1 Kd1]
a2 = a2_cell{1};   % 5x1 raw = [KX2 KY2 Kp2 Ki2 Kd2]

%% 3) Implemented (non-negative) parameters: absolute value of the raw action
KX1_RL = abs(a1(1));  KY1_RL = abs(a1(2));
Kp1_RL = abs(a1(3));  Ki1_RL = abs(a1(4));  Kd1_RL = abs(a1(5));

KX2_RL = abs(a2(1));  KY2_RL = abs(a2(2));
Kp2_RL = abs(a2(3));  Ki2_RL = abs(a2(4));  Kd2_RL = abs(a2(5));

fprintf('\n[TD3-FPID parameters: abs(raw action) at e = 0]\n');
fprintf('Area1: KX=%.4g  KY=%.4g  Kp=%.4g  Ki=%.4g  Kd=%.4g\n', ...
    KX1_RL, KY1_RL, Kp1_RL, Ki1_RL, Kd1_RL);
fprintf('Area2: KX=%.4g  KY=%.4g  Kp=%.4g  Ki=%.4g  Kd=%.4g\n', ...
    KX2_RL, KY2_RL, Kp2_RL, Ki2_RL, Kd2_RL);

%% 4) Save the parameter vector for the offline model
save(fullfile(root,'data','FPID_gains_from_TD3.mat'), ...
    'KX1_RL','KY1_RL','Kp1_RL','Ki1_RL','Kd1_RL', ...
    'KX2_RL','KY2_RL','Kp2_RL','Ki2_RL','Kd2_RL');