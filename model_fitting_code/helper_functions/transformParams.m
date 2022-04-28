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