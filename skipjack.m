function skipjack(command)
    % Frontend for managing a single Skipjack obbject.
    
    persistent sj
    
    if nargin<1 || isempty(command) ,
        command = 'toggle' ;
    end       
    
    if isequal(command, 'start') ,
        sj = skipjack.Skipjack() ;
    elseif isequal(command, 'stop') ,
        sj = [] ;
    elseif isequal(command, 'toggle') ,
        if isempty(sj) ,
            sj = skipjack.Skipjack() ;
        else
            sj = [] ;
        end
    else
        error('Unknown command ''%s''.  Accepted commands are ''start'', ''stop'', and ''toggle''.  If no argument is given, ''toggle'' is assumed.') ;
    end
end
