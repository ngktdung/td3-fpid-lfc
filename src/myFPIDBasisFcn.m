function B = myFPIDBasisFcn(varargin)
% myFPIDBasisFcn
% Basis of the linear actor of the comparative TD3-FPID agents.
%
% Two calling forms:
%   1) B = myFPIDBasisFcn(obs)
%        obs: [3x1] or [3x1xN], obs = [ACE; intACE; dACE]
%        (controller error e = -ACE, its integral, and filtered e)
%
%   2) B = myFPIDBasisFcn(ACE,intACE,dACE)
%        each input is a scalar or [1x1xN].
%
% Output:
%   B : [4 x 1 x N]
%       B = [ACE; intACE; dACE; 1]

    if nargin == 1
        % one input: obs = [3 x 1] or [3 x 1 x N]
        obs = varargin{1};
        % shape 3 x 1 x N
        obs = reshape(obs, 3, 1, []);

        ACE    = obs(1,1,:);   % 1 x 1 x N
        intACE = obs(2,1,:);   % 1 x 1 x N
        dACE   = obs(3,1,:);   % 1 x 1 x N

    elseif nargin == 3
        % three separate channels
        ACE    = varargin{1};
        intACE = varargin{2};
        dACE   = varargin{3};

        % N x 1 vectors -> 1 x 1 x N
        if ismatrix(ACE)
            ACE    = reshape(ACE,1,1,[]);
            intACE = reshape(intACE,1,1,[]);
            dACE   = reshape(dACE,1,1,[]);
        end

    else
        error('myFPIDBasisFcn:BadInput', ...
            'Expected 1 or 3 inputs, got %d.', nargin);
    end

    % bias term
    bias = ones(size(ACE), 'like', ACE);

    % B = [ACE; intACE; dACE; 1], size 4 x 1 x N
    B = cat(1, ACE, intACE, dACE, bias);
end
