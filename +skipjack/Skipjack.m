classdef Skipjack < handle
    properties
        Threshold = +1  % V, roughly
        ThresholdCrossingSign = +1
        MinimumSuperThresholdDuration = 0.001  % s
        SamplingRate = 8000 
        MaximumBufferDuration = 20  % s
    end
    
    properties (Access=public, Transient)
        Interface_
        Recorder_
        %Figure_
        %Axes_
        NSamplesAboveThreshold_ = 0 
        NSamplesBelowThreshold_ = 0 
        IsTriggered_ = false
        NSamplesSinceLastBufferClear_ = 0
    end
    
    methods
        function self = Skipjack()
            bits_per_sample = 16 ;
            channel_count = 2 ;
            device_id = -1 ;  % use default device
            self.Recorder_ = audiorecorder(self.SamplingRate, bits_per_sample, channel_count, device_id) ;  
                % audiorecorder is a scoped object, *not* a user-managed one

            self.Interface_ = skipjack.bias.BiasMultipleCameraInterface() ;    
            self.Interface_.startingRun() ;
            self.Interface_.startingSweep() ;
            
            self.Recorder_.TimerPeriod = 0.1 ;  % s, => 10 Hz
            self.Recorder_.TimerFcn = @(source, event)(self.callback(source,event)) ; 
            self.Recorder_.record() ;
            
            %self.Figure_ = figure('color', 'w') ;
            %self.Axes_ = axes('Parent', self.Figure_) ;
            fprintf('Skipjack started.') ;
        end
        
        function delete(self)
            self.Recorder_.stop() ;
            %delete(self.Figure_) ;
            self.Interface_.stoppingSweep() ;
            self.Interface_.stoppingRun() ;            
            fprintf('Skipjack stopped.') ;
        end
        
        function callback(self, ~, ~)
            x_stereo_in_counts_as_int16 = self.Recorder_.getaudiodata('int16') ;
            x_stereo_in_counts = double(x_stereo_in_counts_as_int16) ;
            x_left_in_counts = x_stereo_in_counts(:,1) ;  % just want left channel
            x_left_in_volts = 2.2/2^15 * x_left_in_counts ; 
                % Assumes digital full scale is 2.2 V, which it is for a 1 kHz sine wave
                % injected into the audio line-in on my PC.  In theory, it should be close
                % to 2*sqrt(2)~=2.8 V, given the "unwritten standard" that digital full
                % scale is 2 Vrms.  
            x = self.ThresholdCrossingSign * x_left_in_volts ;  % just want left channel
            threshold = self.ThresholdCrossingSign * self.Threshold ;
            %plot(self.Axes_, x)
            [doFire, nextInitialNSamplesAboveThreshold, nextInitialNSamplesBelowThreshold, nextInitialIsTriggered] = ...
                skipjack.computeDoFire(self.SamplingRate, ...
                                       x, ...
                                       threshold, ...
                                       self.MinimumSuperThresholdDuration, ...
                                       self.NSamplesAboveThreshold_, ...
                                       self.NSamplesBelowThreshold_, ...
                                       self.IsTriggered_) ;
            if doFire ,
                fprintf('stop/starting BIAS\n') ;
                self.Recorder_.stop() ;
                self.Recorder_.record() ;
                nextNSamplesSinceLastBufferClear = 0 ;
                self.Interface_.completingThenStartingSweep() ;
            elseif self.NSamplesSinceLastBufferClear_ > self.MaximumBufferDuration * self.SamplingRate ,
                self.Recorder_.stop() ;
                self.Recorder_.record() ;
                nextNSamplesSinceLastBufferClear = 0 ;
            else
                nextNSamplesSinceLastBufferClear = self.NSamplesSinceLastBufferClear_ + length(x) ;
            end                    
            
            % Store things for next callback
            self.NSamplesAboveThreshold_ = nextInitialNSamplesAboveThreshold ;
            self.NSamplesBelowThreshold_ = nextInitialNSamplesBelowThreshold ;
            self.IsTriggered_ = nextInitialIsTriggered ;    
            self.NSamplesSinceLastBufferClear_ = nextNSamplesSinceLastBufferClear ;
        end  % function
    end  % methods
end  % classdef
