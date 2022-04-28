function flatData = flattenTaskData(taskStruct)
    
    % trials with valid response
    isValidTrial = ~isnan(taskStruct.allTrials.respKey);
    
    % mark rejected stimulus, and loss trials
    taskStruct.allTrials.isRejected = ~taskStruct.allTrials.isSelected & taskStruct.allTrials.isTrialStim;
    taskStruct.allTrials.isSelectedLoss = ~taskStruct.allTrials.isSelectedWin & taskStruct.allTrials.isSelected;
    
    % account for trials with no response made
    taskStruct.allTrials.isRejected(~isValidTrial,:) = 0;
    taskStruct.allTrials.isSelectedLoss(~isValidTrial,:) = 0;
    
    % extract ID of rejected stimulus
    taskStruct.allTrials.rejectedStimID = nan(size(isValidTrial));
    [taskStruct.allTrials.rejectedStimID(isValidTrial), ~] = find( (taskStruct.allTrials.isRejected & isValidTrial)' );
    
    % stimulus features with task-level scope
    pad = zeros(1, taskStruct.numStims);
    selectHistory_t = cumsum([pad; taskStruct.allTrials.isSelected(1:end-1,:)]);
    rejectHistory_t = cumsum([pad; taskStruct.allTrials.isRejected(1:end-1,:)]);
    winHistory_t = cumsum([pad; taskStruct.allTrials.isSelectedWin(1:end-1,:)]);
    lossHistory_t = cumsum([pad; taskStruct.allTrials.isSelectedLoss(1:end-1,:)]);
    exposureHistory_t = cumsum([pad; taskStruct.allTrials.isTrialStim(1:end-1,:)]);
    
    % accumulate stimulus features at the block level
    winHistory_b = nan(size(taskStruct.allTrials.isSelectedWin));
    lossHistory_b = nan(size(taskStruct.allTrials.isSelectedWin));
    selectHistory_b = nan(size(taskStruct.allTrials.isSelectedWin));
    rejectHistory_b = nan(size(taskStruct.allTrials.isSelectedWin));
    exposureHistory_b = nan(size(taskStruct.allTrials.isSelectedWin));
    hasBeenOffered_b = false(size(taskStruct.allTrials.isSelectedWin));
    
    % loop through all blocks to accumulate block-level stimulus features
    blockIDs = unique(taskStruct.allTrials.blockID);
    for bI = 1 : length(blockIDs)
        blockTrials = find(taskStruct.allTrials.blockID == blockIDs(bI));
        % accumulate wins/loss/exposure within the block at trial onset, not end as is done in the data
        
        % accumulate number of win/loss/samples/exposure within the block
        winHistory_b(blockTrials,:) = cumsum([pad; taskStruct.allTrials.isSelectedWin(blockTrials(1:end-1), :)]);
        lossHistory_b(blockTrials,:) = cumsum([pad; taskStruct.allTrials.isSelectedLoss(blockTrials(1:end-1), :)]);
        selectHistory_b(blockTrials,:) = cumsum([pad; taskStruct.allTrials.isSelected(blockTrials(1:end-1), :)]);
        rejectHistory_b(blockTrials,:) = cumsum([pad; taskStruct.allTrials.isRejected(blockTrials(1:end-1), :)]);
        exposureHistory_b(blockTrials,:) = cumsum([pad; taskStruct.allTrials.isTrialStim(blockTrials(1:end-1), :)]);
        
        %compute reward probabilities 
        reward_probs(blockTrials, :) = repmat(mean(taskStruct.allTrials.isWin(blockTrials(1:end-1),:)), length(blockTrials), 1);

        % loop through each stimulus in the block to identify when it was first offered
        trialStimID = find(any( taskStruct.allTrials.isTrialStim(blockTrials, :) ));
        for stimI = trialStimID
            % identify the first trial a stimulus is offered
            firstTrial = find(taskStruct.allTrials.isTrialStim(:, stimI) & taskStruct.allTrials.blockID == blockIDs(bI),1);
            hasBeenOffered_b(firstTrial:blockTrials(end), stimI) = 1;
        end
    end
    
    % sum the number of stimuli in the current working set
    taskStruct.allTrials.numStimsInSet = sum( hasBeenOffered_b, 2);
    
    % extract and vectorize relevant task features
    flatData = struct();
    flatData.subID = repmat(str2num(taskStruct.subID), size(taskStruct.allTrials,1), 1);
    flatData.blockID = taskStruct.allTrials.blockID;
    flatData.trialID = taskStruct.allTrials.trialID;
    flatData.reward_probs = reward_probs;
    
    % stimulus id
    flatData.trialStimID = taskStruct.allTrials.trialStimID;
    flatData.selectedStimID = taskStruct.allTrials.selectedStimID;
    flatData.rejectedStimID = taskStruct.allTrials.rejectedStimID;
    flatData.RT = taskStruct.allTrials.RT;
    flatData.reward = taskStruct.allTrials.outcome;
    flatData.numBlockStims = taskStruct.allTrials.numStimsInSet;
    
    
    % accumulate values for left/right stimulus
    for sideI = 1 : 2
        rowI = (1:size(flatData.trialStimID,1))';
        colI = flatData.trialStimID(:, sideI);
        % for block level accumulation
        flatData.selectHistory_b(:,sideI) = selectHistory_b( sub2ind( size(selectHistory_b),  rowI, colI) );
        flatData.rejectHistory_b(:,sideI) = rejectHistory_b( sub2ind( size(rejectHistory_b),  rowI, colI) );
        flatData.winHistory_b(:,sideI) = winHistory_b( sub2ind( size(winHistory_b),  rowI, colI) );
        flatData.lossHistory_b(:,sideI) = lossHistory_b( sub2ind( size(lossHistory_b),  rowI, colI) );
        flatData.exposureHistory_b(:,sideI) = exposureHistory_b( sub2ind( size(exposureHistory_b), rowI, colI) );
        % for task level accumulation
        flatData.selectHistory_t(:,sideI) = selectHistory_t( sub2ind( size(selectHistory_t), rowI, colI) );
        flatData.rejectHistory_t(:,sideI) = rejectHistory_t( sub2ind( size(rejectHistory_t), rowI, colI) );
        flatData.winHistory_t(:,sideI) = winHistory_t( sub2ind( size(winHistory_t), rowI, colI) );
        flatData.lossHistory_t(:,sideI) = lossHistory_t( sub2ind( size(lossHistory_t), rowI, colI) );
        flatData.exposureHistory_t(:,sideI) = exposureHistory_t( sub2ind( size(exposureHistory_t), rowI, colI) );
    end
end