function [negLLE, fitData] = getLLE_nInit_uUtil(params, data, fitOpts)
    % stucture to hold fit resulst
    fitData = struct();
    
    % transform the parameters
    fitData.transParams = transformParams(params, fitOpts);
    
    maxHorizon  = max(double(data.trialID));
    % softmax beta
    smB         = fitData.transParams(1);  
    % 'learning rate' parameter. Determins decay rate of weighting given to previous observations
    rlP         = fitData.transParams(2);
    % novelty initialization intercept, and terminal value
    nL          = fitData.transParams(3);
    nU          = fitData.transParams(4);
    nE          = fitData.transParams(5);
    % uncertainty utility intercept, terminal, blending
    uL          = fitData.transParams(6);
    uU          = fitData.transParams(7);
    uE          = fitData.transParams(8);
    % binary flag: use familiarity gate?
    uGate       = fitData.transParams(9);
    
    
    % learned stimulus value (left/right options)
    fitData.qVals       = zeros(length(data.trialID), 2);
    % q-values absent any novelty bonus
    fitData.qVals_raw   = zeros(length(data.trialID), 2);
    % RPE associated with the chosen option
    fitData.RPE         = nan(length(data.trialID), 1);
    % reward prediction error from raw q-values
    fitData.RPE_raw     = nan(length(data.trialID), 1);
    % probability of each option
    fitData.pOption     = nan(length(data.trialID), 2);
    % probability of the chosen option
    fitData.pChoice     = nan(length(data.trialID), 1);
    % uncertainty and novelty feature values
    fitData.uVal        = nan(length(data.trialID), 2);
    fitData.nVal        = nan(length(data.trialID), 2);
    fitData.isNovel     = nan(length(data.trialID), 2);
    % flag noting if the same action was repeated or not
    fitData.prevResp    = zeros(length(data.trialID), 2);
    % number of times each stimulus has been selelected
    fitData.selectHist  = nan(length(data.trialID), 2);
    fitData.rejectHist  = nan(length(data.trialID), 2);
    
    % trajectory across trials for the novelty bias initiation
    nS          = (nU - nL)/maxHorizon;
    fitData.wN  = nL + nS*(data.trialID - 1);
    
    % trajectory across trials for the utility of uncertainty
    uS          = (uU - uL)/maxHorizon;
    fitData.wU  = uL + uS*(data.trialID - 1);
    
    % longest set of trials (for use in computing outcome history weighting)
    maxStimID = max(data.trialStimID(:));
    wWin = (1-abs(rlP)) .^ ((0:(maxHorizon-1)))';
    if isnan(rlP)
        wWin = zeros(size(wWin));
    end
    
    % track history of wins and losses for each stimulus
    winHist     = zeros( maxHorizon, maxStimID );
    lossHist    = zeros( maxHorizon, maxStimID );
    % track novelty bias as stimuli are presented
    exposeHist  = zeros( maxHorizon, maxStimID );
    % track exposure history
    numExp      = zeros( 1, maxStimID );
    
    % loop through all trials
    for tI = 1 : length(data.trialID)
        % re-initialize expected values at the start of each block
        if data.trialID(tI) == 1   
            % reset outcome and exposure history
            winHist(:)      = 0;
            lossHist(:)     = 0;
            exposeHist(:)   = 0;
        end
        
        % was a response made (i.e. valid trial)
        if ~isnan(data.selectedStimID(tI))
            
            % weighting history for all previously observed outcomes
            wOutcome = flip(wWin(1:data.trialID(tI)-1)); %recency weights
            
            % weighting history for all observed stimuli
            wExpose = flip(wWin(1:data.trialID(tI))); %recency weights
            
            % extract win/loss history from previous trials for each stimulus on offer
            winHistStim = winHist(1:data.trialID(tI)-1, data.trialStimID(tI,:)); 
            lossHistStim = lossHist(1:data.trialID(tI)-1, data.trialStimID(tI,:));
            
            % graft in the exposure point for first stimulus exposure.
            % KN notes: fitData.wN is the novelty bias on a given trial
            % (constant if no slope). This code will first find the row of 
            % the relevant trial ID (1 - 15) and then find the column that
            % corresponds to the stimulus ID. If that stimulus has never
            % been presented, the zero value gets replaced with fitData.wN.
            exposeHist( data.trialID(tI), data.trialStimID(tI, numExp(data.trialStimID(tI,:)) == 0) ) = fitData.wN(tI);
            
            %KN notes: exposeHistStim is a 2-column matrix that
            % represents the exposure history of the two stimuli presented
            % on every trial within the block
            % If both are familiar, should be [0 0]
            exposeHistStim = exposeHist(1:data.trialID(tI), data.trialStimID(tI,:));
            
            % compute beta parameters as win/loss history (KN note: weighted by
            % recency)
            alpha   = wOutcome' * winHistStim + 1;
            beta    = wOutcome' * lossHistStim + 1;
            
            % derive non-novelty biased values
            fitData.qVals_raw(tI,:) = alpha ./ (alpha + beta);
            
            % graft in decayed novelty bias
            wExposeHistStim = wExpose' * exposeHistStim; %KN: multiply recency weights by exposeHistStim
            
            %KN: Add recency-weighted novelty initialization to either alpha or beta
            alpha(wExposeHistStim > 0)  = alpha(wExposeHistStim > 0) + wExposeHistStim(wExposeHistStim > 0); %find non-zero values
            beta(wExposeHistStim < 0)   = beta(wExposeHistStim < 0) + abs(wExposeHistStim(wExposeHistStim < 0));
            
            fitData.qVals(tI,:) = alpha ./ (alpha + beta);
            
            % compute uncertainty using weighted sampling history (normalized to be max of zero)
            if isnan(uE)
                normTerm = (1/12); 
                fitData.uVal(tI,:) = (alpha .* beta) ./ ( (alpha+beta).^2 .* (alpha + beta + 1) ) / normTerm; %uncertainty
            else
                % derive uncertainty using exponential decay
                numSamples = sum(winHistStim,1) + sum(lossHistStim,1);
                fitData.uVal(tI,:) = uE .^ numSamples;
            end
            
            % flag indicating if this is the first exposure to a stimulus
            fitData.isNovel(tI,:)   = numExp(data.trialStimID(tI, :)) == 0;
            if isnan(nE)
                alpha                   = numExp(data.trialStimID(tI, :)) + 1;
                beta                    = 1;
                fitData.nVal(tI,:)      = (alpha .* beta) ./ ( (alpha+beta).^2 .* (alpha + beta + 1) ) / normTerm; %novelty
            else
                % derive uncertainty using exponential decay
                fitData.nVal(tI,:)  = nE .^ numExp(data.trialStimID(tI,:));
            end
            
            % compute stimulus RPE
            resp    = data.selectedStimID(tI) == data.trialStimID(tI,:);
            reward  = data.outcome(tI);
            % non-novelty biased RPE
            fitData.RPE_raw(tI) = reward - fitData.qVals_raw(tI, resp);
            % novelty biased RPE
            fitData.RPE(tI) = reward - fitData.qVals(tI, resp);

            % update exposure counts
            numExp(data.trialStimID(tI,:)) = numExp(data.trialStimID(tI,:)) + 1;
            
            % update win/loss counts
            winHist(data.trialID(tI), data.selectedStimID(tI))    = reward == 1;
            lossHist(data.trialID(tI), data.selectedStimID(tI))   = reward ~= 1;
        end
    end % for each trial
    
    % familiarity gate (if in use)
    if uGate == 0
        fitData.fGate = ones(size(fitData.nVal));
    else
        fitData.fGate = 1 - fitData.nVal; % 1 - stimulus novelty. More novel stimuli are less influenced by uncertainty.
    end
    
    % utility of stimulus uncertainty, as gated by familiarity
    fitData.uUtil       = fitData.fGate .* fitData.wU .* fitData.uVal;
    
    % combine utilities across features
    fitData.stimUtil    = fitData.qVals + fitData.uUtil;
    
    % softmax choice probability
    fitData.pOption(:,1)    = 1 ./ (1 + exp(smB .* (fitData.stimUtil(:,2) - fitData.stimUtil(:,1))));
    fitData.pOption(:,2)    = 1-fitData.pOption(:,1);
    
    % probability of selecting the chosen option
    fitData.pChoice = fitData.pOption(:,1);
    fitData.pChoice(data.trialStimID(:,2) == data.selectedStimID) = fitData.pOption(data.trialStimID(:,2) == data.selectedStimID,2);
    
    % determine which trials should be included in the fit
    isValidTrial = ~isnan(data.selectedStimID);
    % adjust 0 probability trials
    fitData.pChoice(fitData.pChoice < eps | isnan(fitData.pChoice) | isinf(fitData.pChoice)) = eps;
    % compute null model negLLE
    fitData.null_negLLE = sum(isValidTrial) * log(0.5);
    fitData.negLLE = sum(log(fitData.pChoice(isValidTrial)));
    fitData.pseudoR = 1 - (fitData.negLLE/fitData.null_negLLE);
    % compute the negative log-like
    negLLE = fitData.negLLE;
end

function transParams = transformParams(params,fitOpts)
    defaults = fitOpts.defParamVals;
    doFit = fitOpts.doFit;
    
    % holds the transformed parameters
    transParams = defaults;
    % graft raw parameters into place for those being fit in prep for transformations
    transParams(doFit) = params;
    
    % softmax beta: [0-->inf]
    transParams(1) = 20/(1+exp(-transParams(1)));
    
    %%%%%%%%%%%%%%%
    % learning rate [0 --> 1]
    transParams(2) = 1./(1+exp(-transParams(2)));
    
    %%%%%%%%%%%%%%%%
    % novelty bias intercept and terminal
    % if not fit, match terminal to novelty intercept (i.e. no slope)
    if ~doFit(4)
        defaults(4) = transParams(3);
    end
    
    %%%%%%%%%%%%%%%%
    % uncertainty intercept and terminal
    % if not fit, match terminal to intercept
    if ~doFit(7)
        defaults(7) = transParams(6);
    end
    
    %%%%%%%%%%%%%%%%
    % graft in default values for non-fit parameters
    transParams(~doFit) = defaults(~doFit);
end % function