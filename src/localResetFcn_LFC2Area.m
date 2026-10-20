function in = localResetFcn_LFC2Area(in, mdl, Ts) %#ok<INUSD>
% localResetFcn_LFC2Area  Episode reset function of the fixed-design comparative agents.
%
%   The function looks for Step blocks whose names contain one of the
%   patterns listed below and, if found, sets a random step time in [1,10] s
%   and amplitude in [-0.01,0.01] p.u.
%
%   NOTE: in rlfrequencyFPIDTune.slx the load blocks are named
%   "Step change in Load Demand Pd1", which matches none of the patterns.
%   The function therefore changes no block parameter, and every training
%   episode uses the constant load steps stored in the model:
%   0.003 p.u. in Area 1 and 0.002 p.u. in Area 2, applied from t = 0
%   (Table D.2 of the paper).
%
%   in  : Simulink.SimulationInput
%   mdl : model name
%   Ts  : agent sample time (kept for a uniform interface)

    rng("shuffle");

    % step time in [1, 10] s
    tStep = 1 + 9*rand();

    % step amplitude in [-0.01, 0.01] p.u.
    amp = (2*rand() - 1) * 0.01;

    % helper: set the Step parameters if the block exists
    function in2 = setStepIfExist(in2, blkPath)
        if ~isempty(blkPath)
            in2 = setBlockParameter(in2, blkPath, ...
                "Time",   num2str(tStep), ...
                "Before", "0", ...
                "After",  num2str(amp));
        end
    end

    % all Step blocks of the model
    stepBlks = find_system(mdl, "BlockType", "Step");

    % block-name patterns (none matches the load blocks of rlfrequencyFPIDTune.slx)
    pat = ["Step_Pload", "Step_Pphi", "Step_Load", "Step_Dist"];

    for p = pat
        idx  = contains(stepBlks, p);
        hits = stepBlks(idx);
        for k = 1:numel(hits)
            in = setStepIfExist(in, string(hits{k}));
        end
    end
end
