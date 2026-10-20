%% plot_training_curves.m
%  Training curves of the TD3-FPID agents (Fig. 9(b) of the paper), re-plotted
%  from the training statistics stored in data/TD3_FPID_20260407_0943.mat.

clear; clc; close all;

%% ===== User settings =====
matFile = fullfile("data","TD3_FPID_20260407_0943.mat");   % stored training statistics
zoomRange = [];        % [] = auto, or set manually, e.g. [100 300]
showQ0 = false;        % false = hide Episode Q0 for a cleaner journal-style figure
maxAgentsToPlot = 2;   % two-area LFC => 2 agents

%% ===== Folder setup =====
thisFile = mfilename('fullpath');
if ~isempty(thisFile)
    cd(fileparts(thisFile));
end
addpath(pwd);

%% ===== Load training stats =====
if ~isfile(matFile)
    error("Cannot find MAT file: %s", matFile);
end

S = load(matFile);
if ~isfield(S,"stats")
    error(["The MAT file does not contain variable 'stats'.\n" + ...
           "The original RL training monitor cannot be reconstructed.\n" + ...
           "You need the output returned by train(...), usually saved as 'stats'."]);
end

stats = S.stats;
D = localExtractTrainingStats(stats);
if isempty(D)
    error("Could not extract EpisodeReward/AverageReward from stats.");
end
numAgents = min(numel(D), maxAgentsToPlot);

%% ===== Figure style =====
cEpisode = [0.55 0.78 0.95];   % light blue
cAverage = [0.00 0.35 0.75];   % deep blue
cQ0      = [0.93 0.60 0.00];   % orange/yellow

fig = figure('Color','w', 'Units','centimeters', 'Position',[2 2 18 16]);
tl = tiledlayout(numAgents,1, 'TileSpacing','compact', 'Padding','compact');

for ia = 1:numAgents
    ax = nexttile(tl, ia);
    hold(ax,'on'); box(ax,'on'); grid(ax,'off');

    ep  = D(ia).EpisodeIndex(:);
    er  = D(ia).EpisodeReward(:);
    avg = D(ia).AverageReward(:);
    q0  = D(ia).EpisodeQ0(:);

    valid = isfinite(ep) & isfinite(er);
    ep = ep(valid); er = er(valid);
    if numel(avg) == numel(valid), avg = avg(valid); end
    if numel(q0)  == numel(valid), q0  = q0(valid);  end

    h1 = plot(ax, ep, er, '-', 'Color', cEpisode, 'LineWidth',0.8);
    h2 = plot(ax, ep, avg, '-', 'Color', cAverage, 'LineWidth',1.6);

    hasQ0 = showQ0 && ~isempty(q0) && numel(q0)==numel(ep) && any(isfinite(q0));
    if hasQ0
        h3 = plot(ax, ep, q0, '-', 'Color', cQ0, 'LineWidth',1.6);
        legHandles = [h1 h2 h3];
        legNames = {'Episode reward','Average reward','Episode Q0'};
    else
        legHandles = [h1 h2];
        legNames = {'Episode reward','Average reward'};
    end

    ylabel(ax, sprintf('Episode Reward (Area-%d)', ia), 'FontName','Times New Roman', 'FontSize',12);
    set(ax, 'FontName','Times New Roman', 'FontSize',11, 'LineWidth',0.9);
    xlim(ax, [min(ep) max(ep)]);

    if ia == numAgents
        xlabel(ax, 'Episode Number', 'FontName','Times New Roman', 'FontSize',13);
    end

    lgd = legend(ax, legHandles, legNames, 'Location','southeast');
    set(lgd, 'FontName','Times New Roman', 'FontSize',10, 'Box','on');

    %% ===== Zoom inset =====
    N = numel(ep);
    if isempty(zoomRange)
        z1 = ep(max(1, round(0.18*N)));
        z2 = ep(min(N, round(0.70*N)));
    else
        z1 = zoomRange(1);
        z2 = zoomRange(2);
    end
    zidx = ep >= z1 & ep <= z2;

    if nnz(zidx) > 5
        yZoomData = [er(zidx); avg(zidx)];
        if hasQ0, yZoomData = [yZoomData; q0(zidx)]; end
        yMinZ = min(yZoomData,[],'omitnan');
        yMaxZ = max(yZoomData,[],'omitnan');
        yPadZ = 0.08 * max(1, abs(yMaxZ-yMinZ));

        rectangle(ax, 'Position',[z1, yMinZ-yPadZ, z2-z1, (yMaxZ-yMinZ)+2*yPadZ], ...
            'EdgeColor','k', 'LineWidth',1.0);

        oldUnits = ax.Units;
        ax.Units = 'normalized';
        axPos = ax.Position;
        ax.Units = oldUnits;

        insetPos = [axPos(1)+0.30*axPos(3), axPos(2)+0.14*axPos(4), 0.38*axPos(3), 0.48*axPos(4)];
        axInset = axes('Position', insetPos);
        hold(axInset,'on'); box(axInset,'on'); grid(axInset,'off');
        plot(axInset, ep(zidx), er(zidx), '-', 'Color', cEpisode, 'LineWidth',0.55);
        plot(axInset, ep(zidx), avg(zidx), '-', 'Color', cAverage, 'LineWidth',1.0);
        if hasQ0
            plot(axInset, ep(zidx), q0(zidx), '-', 'Color', cQ0, 'LineWidth',1.0);
        end
        xlim(axInset,[z1 z2]);
        ylim(axInset,[yMinZ-yPadZ, yMaxZ+yPadZ]);
        set(axInset, 'FontName','Times New Roman', 'FontSize',7.5, 'LineWidth',0.7, ...
            'XTickLabel',[], 'YTickLabel',[]);

        annotation(fig, 'arrow', ...
            [axPos(1)+0.22*axPos(3), insetPos(1)], ...
            [axPos(2)+0.70*axPos(4), insetPos(2)+0.55*insetPos(4)], ...
            'Color','k', 'LineWidth',0.8);
    end
end

%% ===== Export =====
[~, baseName, ~] = fileparts(matFile);
outPrefix = baseName + "_nonlinear_RL_training_article_style_noQ0";
exportgraphics(fig, outPrefix + ".pdf", 'ContentType','vector');
exportgraphics(fig, outPrefix + ".png", 'Resolution',600);
savefig(fig, outPrefix + ".fig");

fprintf('\nSaved files:\n');
fprintf('  %s.pdf\n', outPrefix);
fprintf('  %s.png\n', outPrefix);
fprintf('  %s.fig\n', outPrefix);

%% ========================================================================
%% Local functions
%% ========================================================================
function D = localExtractTrainingStats(stats)
    D = struct('EpisodeIndex',{},'EpisodeReward',{},'AverageReward',{},'EpisodeQ0',{});

    if (isstruct(stats) || isobject(stats)) && numel(stats) > 1
        for k = 1:numel(stats)
            one = localExtractOne(stats(k));
            if ~isempty(one.EpisodeReward)
                D(end+1) = one; %#ok<AGROW>
            end
        end
        if ~isempty(D), return; end
    end

    one = localExtractOne(stats);
    if isempty(one.EpisodeReward), return; end

    ER  = localToNumeric(one.EpisodeReward);
    AVG = localToNumeric(one.AverageReward);
    Q0  = localToNumeric(one.EpisodeQ0);
    EP  = localToNumeric(one.EpisodeIndex);

    if isempty(EP), EP = (1:size(ER,1)).'; end

    if ismatrix(ER) && size(ER,2) > 1
        nAgent = size(ER,2);
        for k = 1:nAgent
            D(k).EpisodeIndex = EP(:);
            D(k).EpisodeReward = ER(:,k);
            if ~isempty(AVG) && size(AVG,2) >= k
                D(k).AverageReward = AVG(:,k);
            else
                D(k).AverageReward = movmean(ER(:,k), min(20,size(ER,1)));
            end
            if ~isempty(Q0) && size(Q0,2) >= k
                D(k).EpisodeQ0 = Q0(:,k);
            else
                D(k).EpisodeQ0 = [];
            end
        end
    else
        D = one;
        D.EpisodeIndex = EP(:);
        D.EpisodeReward = ER(:);
        if isempty(AVG)
            D.AverageReward = movmean(D.EpisodeReward, min(20,numel(D.EpisodeReward)));
        else
            D.AverageReward = AVG(:);
        end
        if isempty(Q0)
            D.EpisodeQ0 = [];
        else
            D.EpisodeQ0 = Q0(:);
        end
    end
end

function one = localExtractOne(st)
    one = struct('EpisodeIndex',[],'EpisodeReward',[],'AverageReward',[],'EpisodeQ0',[]);
    one.EpisodeIndex  = localToNumeric(localGetByNames(st, {"EpisodeIndex","EpisodeNumber","Episode","EpisodeCount"}));
    one.EpisodeReward = localToNumeric(localGetByNames(st, {"EpisodeReward","Reward"}));
    one.AverageReward = localToNumeric(localGetByNames(st, {"AverageReward","MovingAverageReward","AveragedReward"}));
    one.EpisodeQ0     = localToNumeric(localGetByNames(st, {"EpisodeQ0","InitialQ0","Q0"}));
end

function val = localGetByNames(x, names)
    val = [];
    if istable(x)
        vars = string(x.Properties.VariableNames);
        for i = 1:numel(names)
            idx = find(strcmpi(vars, names{i}),1);
            if ~isempty(idx), val = x.(vars(idx)); return; end
        end
    end
    if isstruct(x)
        f = string(fieldnames(x));
        for i = 1:numel(names)
            idx = find(strcmpi(f, names{i}),1);
            if ~isempty(idx), val = x.(f(idx)); return; end
        end
    end
    if isobject(x)
        try
            p = string(properties(x));
            for i = 1:numel(names)
                idx = find(strcmpi(p, names{i}),1);
                if ~isempty(idx), val = x.(p(idx)); return; end
            end
        catch
        end
    end
end

function y = localToNumeric(x)
    y = [];
    if isempty(x), return; end
    if isnumeric(x), y = double(x); return; end
    if iscell(x)
        try, y = double(cell2mat(x)); return; catch, end
        try, y = double([x{:}]); return; catch, y = []; return; end
    end
    if istimetable(x) || istable(x)
        try, y = double(table2array(x)); return; catch, y = []; return; end
    end
    try, y = double(x); catch, y = []; end
end
