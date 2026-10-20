%% run_offline_FPID.m
%  Fixed-parameter simulation of test system 2 with the TD3-learned FPID
%  parameters (frequency_FPID_offline.slx: 1% step load in Area 1 at t = 0).
%  Run run_extract_parameters.m first; it creates data/FPID_gains_from_TD3.mat.

clear; clc;
root = fileparts(mfilename('fullpath'));  if isempty(root), root = pwd; end
addpath(fullfile(root,'models'), fullfile(root,'src'), fullfile(root,'data'));
system2_parameters;                      % plant parameters of test system 2
load(fullfile(root,'data','FPID_gains_from_TD3.mat'));         % KX1_RL ... Kd2_RL, read by the FPID blocks

fprintf('Area 1: KX = %.4f  KY = %.4f  Kp = %.4f  Ki = %.4f  Kd = %.4f\n', KX1_RL, KY1_RL, Kp1_RL, Ki1_RL, Kd1_RL);
fprintf('Area 2: KX = %.4f  KY = %.4f  Kp = %.4f  Ki = %.4f  Kd = %.4f\n', KX2_RL, KY2_RL, Kp2_RL, Ki2_RL, Kd2_RL);

mdl = 'frequency_FPID_offline';
load_system(mdl);
simOut = sim(mdl, 'StopTime', '40', 'ReturnWorkspaceOutputs', 'on');

DeltaF    = simOut.get('DeltaF');        % [Delta f1, Delta f2] (Hz)
DeltaPtie = simOut.get('DeltaPtie');     % tie-line power deviation (p.u.)

figure('Color', 'w', 'Name', 'Test system 2, TD3-FPID, 1% step load in Area 1');
subplot(2, 1, 1);
plot(DeltaF.time, DeltaF.signals.values, 'LineWidth', 1.5); grid on;
ylabel('\Delta f (Hz)'); legend('\Delta f_1', '\Delta f_2', 'Location', 'best');
subplot(2, 1, 2);
plot(DeltaPtie.time, DeltaPtie.signals.values, 'LineWidth', 1.5); grid on;
ylabel('\Delta P_{tie,12} (p.u.)'); xlabel('Time (s)');
