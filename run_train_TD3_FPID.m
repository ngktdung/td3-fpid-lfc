%% run_train_TD3_FPID.m
%  Trains the TD3-FPID agents of test system 2 with src/train_TD3_FPID_2area.mlx
%  (500 episodes of 40 s). The live script defines the plant parameters,
%  creates the environment and the agents, and saves the trained agents.
%  The agents used in the paper are provided in data/TD3_FPID_20260407_0943.mat;
%  a new run gives different agents because exploration is random.

root = fileparts(mfilename('fullpath'));  if isempty(root), root = pwd; end
addpath(fullfile(root,'models'), fullfile(root,'src'), fullfile(root,'data'));
cd(fullfile(root,'data'));               % new training results are saved here

mdl       = "rlfrequencyFPIDTune";
agentBlks = [mdl + "/Agent_Area1", mdl + "/Agent_Area2"];
train_TD3_FPID_2area;
