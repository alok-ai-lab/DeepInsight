% SMOTE: Synthetic Minority Over-sampling Technique
% This function is based on the paper referenced below - with a few
% additional optional functionalities.
% DOI: https://doi.org/10.1613/jair.953 
%
% This function synthesizes new observations based on existing (input)
% data, and a k-nearest neighbor approach. If multiple classes are given as
% input, only neighbors within the same class are considered.
% This function can be used to over-sample minority classes in a dataset.
%
%   Use:
%       [X,C,Xn,Cn] = smote(X, [N, k], {options}) 
%
%   Input:
%       X: Original dataset. Each row is an observation, and each column a
%          different feature.
%       N: Amount of oversampling (Default: 1 = 100% doubles the observations)
%          If 'Class' is set, then N can be a vector with number of
%          elements equal to the number of classes. Elements of N should be
%          sorted according to the sorted unique classes.
%          If N is empty, then 'balancing' will occur, synthesizing
%          minority classes to the same number as the majority class.
%       k: Number of nearest neighbors to consider (Default: 5)
%          If 'Class' is set, then k can be a vector with number of
%          elements equal to the number of classes. Elements of k should be
%          sorted according to the sorted unique classes.
%          Note that number of nearest neighbors to consider must be equal
%          to or greater than the number of times an observation is used
%          for synthesizing a new observation: N or SynthObs (if set).
%   Options:
%       SynthObs: Overrides N, and sets the amount of synthesization for 
%                 each observation directly. If SynthObs is set, no
%                 balancing will occur, regardless of N being empty.
%       Class:    Sets the class for each observation. Nearest neighbors 
%                 are only found within the same class.
% 
%   Output:
%       X: Complete dataset (original and synthesized)
%       C: Classes of complete dataset
%       Xn: Synthesized observations
%       Cn: Classes of synthesized observations
%   
%   Examples:
%       X = smote(X, 1.5, 4) 
%       Synthesizes 150% new observations using a randomly picked of the 4
%       nearest neighbors and the observation itself. In this case each
%       observation is used as basis 1-2 times. Which is used 1 and which 2
%       times are chosen at random.
%
%       [X,C] = smote(X, [], 'Class', C)
%       Synthesizes new observations of minority classes, so number of
%       observations for each class matches the number of observations of
%       the majority class. Using the default 5 nearest neighbors in this
%       example.
%
% Author: Bjarke Skogstad Larsen <bjarke.skogstad@acarix.com>
% Updated: 2020-05-07
%
function [X,C,Xn,Cn] = smote(X, N, k, options)
    arguments
        X (:,:) % Observation Matrix
        N (:,1) double {mustBeNonnegative} = 1 % Amount of synthesization
        k (:,1) double {mustBePositive,mustBeInteger} = 5 % Number of nearest neighbors to consider
        options.Class (:,1) {mustBeSameSize(options.Class,X)} % Class vector: Determines the class of each observation
        options.SynthObs (:,1) {mustBeSameSize(options.SynthObs,X)} % Synthesization vector. Determines how many times each observation is used as a base for synthesization
    end
    
    % Handle optional Class vector
    if isfield(options,'Class')
        C = options.Class;
    else
        C = ones(size(X,1),1); % If no Class vector is given, default all observations to the same class: [1]
    end
    uC = unique(C); % Class list
    nC = groupcounts(C); % Number of observations of each class
    
    % Handle N - must have one number for each class
    if isempty(N) % Do balancing if N is empty
        if numel(uC)<2 % Class vector must contain at least two classes to balance
            error('Class vector must contain at least 2 classes to balance.');
        end
        N = max(nC)./nC-1; % Calculate over-sampling percentage for each class to attain equal number of observations as majority class
    elseif isscalar(N)
        N = repmat(N,numel(uC),1); 
    elseif ~isvector(N) || numel(N)~=numel(uC)
        error('N must either be empty, a scalar, or a vector with same number of elements as unique classes.');
    end
    
    % Handle k - must have one number for each class
    if isscalar(k)
        k = repmat(k,numel(uC),1); 
    elseif ~isvector(k) || numel(k)~=numel(uC)
        error('k must either be a scalar or a vector with same number of elements as unique classes.');
    end
    
    % Decide on how many of each observation (in case of non-integer,
    % 'extras' will be chosen at random). Vector J determines how many of
    % each observation is used as a base for synthesization.
    if isfield(options,'SynthObs')
        J = options.SynthObs;
    else
        J = nan(size(X,1),1); % Synthesization vector
        for ii=1:numel(uC) % Iterate through the classes
            iC = find(C==uC(ii));
            P = randperm(nC(ii),round(rem(N(ii),1)*nC(ii))); % Randomly pick indexes of 'extras'
            J(iC) = ones(nC(ii),1)*floor(N(ii)); % First distribute evenly
            J(iC(P)) = J(iC(P))+1; % Then assign the 'extras'
        end
    end
    
    % Synthesize observations
    Xn = []; % TODO: Consider pre-allocating memory
    Cn = []; % TODO: Consider pre-allocating memory
    for ii=1:numel(uC)
        iC = C==uC(ii);
        if sum(J(iC))>0 % Skip synthesization attempt if no observations are synthesized for this class (for speed)
            Xnn = simpleSMOTE(X(iC,:),J(iC),k(ii));
            Xn = [Xn;Xnn]; % TODO: Consider pre-allocating memory
            Cn = [Cn;repmat(uC(ii),size(Xnn,1),1)]; % TODO: Consider pre-allocating memory
        end
    end
    % Set output
    X = [X;Xn];
    C = [C;Cn];
end

% This is where the magic happens ;-)
%   X : Observational matrix (rows are observations, columns are variables)
%   J : Synthesization vector. It has the same length as the number of
%       observations (rows) in X. J determines how many times each 
%       observation is used as a base for synthesization.
%   k : Number of nearest neighbors to consider when synthesizing.
function Xn = simpleSMOTE(X,J,k)
    [idx, ~] = knnsearch(X,X,'k',k+1); % Find nearest neighbors (add one to the number of neighbors to find, as observations are their own nearest neighbor)
    Xn = nan(sum(J),size(X,2)); % Pre-allocate memory for synthesized observations
    % Iterate through observations to create to synthesize new observations
    for ii=1:numel(J)
        P = randperm(k,J(ii))+1; % Randomize nearest neighbor pick (never pick first nearest neighbor as this is the observation itself)
        for jj=1:J(ii)
            x = X(idx(ii,1),:); % Observation
            xk = X(idx(ii,P(jj)),:); % Nearest neighbor
            Xn(sum(J(1:ii-1))+jj,:) = (xk-x)*rand+x; % Synthesize observation
        end
    end
end

% Argument validation
function mustBeSameSize(a,b)
    if ~isequal(size(a,1),size(b,1))
        error('Must have the same number of elements as number of observations (rows) in X.');
    end
end
