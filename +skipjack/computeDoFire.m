function [doFire, nextInitialNSamplesAboveThreshold, nextInitialNSamplesBelowThreshold, nextInitialIsTriggered] = ...
        computeDoFire(fs, ...
                      x, ...
                      threshold, ...
                      minimumSuperThresholdDuration, ...
                      initialNSamplesAboveThreshold, ...
                      initialNSamplesBelowThreshold, ...
                      initialIsTriggered)

    mininumSuperThresholdSampleCount = round(minimumSuperThresholdDuration*fs) ;            
    isBelowThreshold = (x <  threshold) ;
    n = length(x) ;
    if all(isBelowThreshold) ,
        % This should be a common case, so make it faster.
        doFire = false ;
        if n>0 ,
            nextInitialNSamplesAboveThreshold = 0 ;
            nextInitialNSamplesBelowThreshold = initialNSamplesBelowThreshold + n ;
            nextInitialIsTriggered = false ;
        else
            % probably never happens, but just in case...
            nextInitialNSamplesAboveThreshold = initialNSamplesAboveThreshold ;
            nextInitialNSamplesBelowThreshold = initialNSamplesBelowThreshold ;
            nextInitialIsTriggered = initialIsTriggered ;
        end
    else
        isAboveThreshold = ~isBelowThreshold ;
        nSamplesAboveThreshold = skipjack.nSamplesHigh(isAboveThreshold, initialNSamplesAboveThreshold) ;
        nSamplesBelowThreshold = skipjack.nSamplesHigh(isBelowThreshold, initialNSamplesBelowThreshold) ;
        isDefinitelyTriggered = (nSamplesAboveThreshold >= mininumSuperThresholdSampleCount) ;
        isDefinitelyNotTriggered = (nSamplesBelowThreshold >= mininumSuperThresholdSampleCount) ;
        isTriggered =  skipjack.computeIsTriggered(isDefinitelyTriggered, isDefinitelyNotTriggered, initialIsTriggered) ;
        isRisingEdgeOfIsTriggered = isTriggered & ~vertcat(initialIsTriggered, isTriggered(1:end-1)) ;
        doFire = any(isRisingEdgeOfIsTriggered) ;
        nextInitialNSamplesAboveThreshold = nSamplesAboveThreshold(end) ;
        nextInitialNSamplesBelowThreshold = nSamplesBelowThreshold(end) ;
        nextInitialIsTriggered = isTriggered(end) ;
    end
end
