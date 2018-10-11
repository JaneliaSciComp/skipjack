function result = computeIsTriggered(isDefinitelyTriggered, isDefinitelyNotTriggered, result0)
    result = zeros(size(isDefinitelyTriggered)) ;
    n = length(isDefinitelyTriggered) ;            
    lastResult = result0 ;
    for i = 1:n ,
        if isDefinitelyTriggered(i) ,
            thisResult = 1 ;
        elseif isDefinitelyNotTriggered(i) ,
            thisResult = 0 ;
        else
            thisResult = lastResult ;
        end
        result(i) = thisResult ;
        % Setup for next iteration
        lastResult = thisResult ;
    end
end
