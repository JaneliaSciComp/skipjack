function result = nSamplesHigh(x, result0)
    result = zeros(size(x)) ;
    n = length(x) ;            
    lastResult = result0 ;
    for i = 1:n ,
        if x(i) ,
            thisResult = lastResult + 1 ;
        else
            thisResult = 0 ;
        end
        result(i) = thisResult ;
        % Setup for next iteration
        lastResult = thisResult ;
    end
end
