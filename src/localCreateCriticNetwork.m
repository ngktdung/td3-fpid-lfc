function lg = localCreateCriticNetwork(numObs, numAct)
% localCreateCriticNetwork
%   Critic Q(s,a): state path (numObs = 3) with two fully connected layers,
%   action path (numAct = 5) with one, joined by one common layer; 32 units.

    fc = 32;   % units per fully connected layer

    % state path
    statePath = [
        featureInputLayer(numObs, Normalization="none", Name="stateIn")
        fullyConnectedLayer(fc, Name="st_fc1")
        reluLayer(Name="st_relu1")
        fullyConnectedLayer(fc, Name="st_fc2")
        ];

    % action path
    actionPath = [
        featureInputLayer(numAct, Normalization="none", Name="actionIn")
        fullyConnectedLayer(fc, Name="ac_fc1")
        ];

    % common path
    commonPath = [
        concatenationLayer(1, 2, Name="concat")
        reluLayer(Name="relu0")
        fullyConnectedLayer(fc, Name="cm_fc1")
        reluLayer(Name="cm_relu1")
        fullyConnectedLayer(1, Name="QValue")
        ];

    % assemble the layer graph
    lg = layerGraph();
    lg = addLayers(lg, statePath);
    lg = addLayers(lg, actionPath);
    lg = addLayers(lg, commonPath);

    lg = connectLayers(lg, "st_fc2", "concat/in1");
    lg = connectLayers(lg, "ac_fc1", "concat/in2");
end

