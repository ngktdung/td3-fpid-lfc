%% system2_parameters.m
%  Plant parameters of test system 2 (nonlinear renewable-integrated two-area
%  system; Section 4 and Table 3 of the paper). Called by run_offline_FPID.m.
%  The values are identical to those defined in train_TD3_FPID_2area.mlx.

% Hydro, Area 1
Th1=48.7; Trs1=0.513; Trh1=10; Tpt1=1; KH1=0.45;
R1=2.4;
GRCU1=0.045; GRCD1=0.06;
DBH1=0.012;                                            % hydro governor dead-band

% Hydro Area 2 (same as Area 1)
Th2=Th1; Trs2=Trs1; Trh2=Trh1; Tpt2=Tpt1; KH2=KH1;
R2=R1; GRCU2=GRCU1; GRCD2=GRCD1; DBH2=DBH1;
%% ===== Area dynamics =====
H1 = 5;  H2 = 5;  % inertia constant
D1 = 0.00833; D2 = 0.00833;

% Droop
R1 = 2.4;  R2 = 2.4;

% Area frequency bias
B1 = 0.425;   B2 = 0.425;

% Power system block: KPi / (1 + s*Tpi)
% Set directly: KP = 120, TP = 20 s
KP1 = 120;   KP2 = 120;
TP1 = 20;    TP2 = 20;


% Tie-line gain
% Tie-line block (2*pi*T12)/s with 2*pi*T12 = 0.545
T12 = 0.545;      % value of 2*pi*T12

%% ===== THERMAL (Area1) =====
TG1 = 0.08;      % = Tgr
Tr1 = 10;        % = Tre
Kr1 = 0.33;      % = Kre
TT1 = 0.3;       % = Ttr
KT1 = 0.45;      % apf

% GRC thermal: ±3%/min  => 0.03/60 pu/s
GRCT1 = 0.03/60; % = 0.0005 pu/s

% thermal governor dead-band (describing-function coefficients)
N1 = 0.8; N2 = -0.2; w0 = pi;
% thermal GRC loop
Tt1 = 1;   % servo/tracking time constant (selected for this study)
% ===== DIESEL (Area1) =====
KDeng = 16.5;              % diesel dynamic gain
Td0 = 1; Td1 = 2; Td2 = 0.025; Td3 = 3;
KD1  = 0.1;                % diesel apf (Area1)
%% ===== WIND (Area2) - Parameters =====
Tw1 = 6;        % s
Tw2 = 0.041;    % s
Kw1 = 1.25;
Kw2 = 1.4;
Kpc = 0.8;
KW  = 0.25;     % apf
%% ===== PV (Area2) =====
KPV1 = -18;
KPV2 = 900;
TPV1 = 100;
TPV2 = 50;
KP   = 0.2;     % PV participation factor
%% ===== base =====
f0  = 60;            % Hz
Rev  = 2.4;           % Hz/p.u.MW

%% ===== EV fleet (Table 3) =====
Kev = 1;
Tev = 1;             % s
Ke  = 0.1;           % participation factor

%% ===== EV frequency deadband =====
dbHz = 0.01;                 % the model applies +/-dbpu to the Area-2 frequency deviation (Table 3: +/-1.67e-4 Hz)
dbpu = dbHz / f0;            % = 1.6667e-4

%% ===== auxiliary variable (not used by the Simulink models) =====
Gdroop = -(f0/R2);           % = -25

%% ===== EV fleet limits (selected for this study) =====
Nev   = 1;        % aggregate EV fleet (value selected for this study)
PAGmax = 0.20;    % EV output limit (before Ke)
PAGmin = -0.20;
% ===== BESS =====
KBESS = -0.0033;
TBESS = 0.1;
