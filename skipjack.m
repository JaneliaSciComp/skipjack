function skipjack()
    threshold = 0.75 ;
    threshold_sign = +1 ;  % +1 => looking for rising threshold crossings
    
    fs = 8000 ;
    bits_per_sample = 16 ;
    channel_count = 2 ;
    device_id = 0 ;
    r = audiorecorder(fs, bits_per_sample, channel_count, device_id) ;  
        % this is a scoped object, *not* a user-managed one

    bmci = bias.BiasMultipleCameraInterface() ;    
    function skipjack_callback(recorder, ~)
        x_stereo = recorder.getaudiodata() ;
        x = x_stereo(:,1) ;  % just want left channel
        if threshold_sign >= 0 ,
            if any(x>threshold) ,
                bmci.completingThenStartingSweep() ;
            end
        else
            if any(x<threshold) ,
                bmci.completingThenStartingSweep() ;
            end
        end        
    end    
    r.TimerPeriod = 0.1 ;  % s, => 10 Hz
    r.TimerFcn = @skipjack_callback ;    
    r.record() ;
end
