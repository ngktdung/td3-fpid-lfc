function [env, obsInfos, actInfos] = localCreateFPIDEnv_2area(mdl, agentBlks, Ts)
% localCreateFPIDEnv_2area
%   - Creates the two-area multi-agent environment.
%   - Observation: 3x1 = [ACE; intACE; dACE]
%     (channel names in the code; in the model they are the controller error
%      e = -ACE, its integral, and its low-pass-filtered value e/(s+1), Eqs. (16)-(17))
%   - Action:      5x1 = [KX; KY; Kp; Ki; Kd]
%
% mdl       : Simulink model name (rlfrequencyFPIDTune)
% agentBlks : ["mdl/Agent_Area1", "mdl/Agent_Area2"]
% Ts        : agent sample time

    %% Observation spec
    obsInfo = rlNumericSpec([3 1], ...
        'LowerLimit', -inf(3,1), ...
        'UpperLimit',  inf(3,1));
    obsInfo.Name        = "observations";
    obsInfo.Description = "obs = [ACE; intACE; dACE]";

    %% Action spec: raw FPID parameters; the model applies abs() to obtain
    % the implemented (non-negative) parameters, as does the offline extraction.
    actInfo = rlNumericSpec([5 1], ...
        'LowerLimit', [-5; -5; -5; -5; -5], ...  % bounds: KY in [-0.03, 0.03], others in [-5, 5]
        'UpperLimit', [5; 5; 5; 5; 5]);
    actInfo.Name        = "fpid_gains";
    actInfo.Description = "[KX KY Kp Ki Kd] (raw)";

    obsInfos = {obsInfo, obsInfo};
    actInfos = {actInfo, actInfo};

    %% Simulink environment with two agents
    env = rlSimulinkEnv(mdl, agentBlks, obsInfos, actInfos);

    % episode reset function (see the note in localResetFcn_LFC2Area.m)
    env.ResetFcn = @(in)localResetFcn_LFC2Area(in, mdl, Ts);
end
