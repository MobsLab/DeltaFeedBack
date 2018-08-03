%% check_Delta
%This functions determines the relative position between the two last points of
%PFCdif_temp_filtered and delta_treshold (below or above). It detects the beginning and the
%ending of potential delta waves with these two comparisons. 

%Potential Delta Waves are rejected if their durations do not respect Delta
%Duration condition


function [Data,Interface] = check_Delta (Data,Interface)
  
if get(Interface.detection_checkbox,'Value') == 1 
     %check if current point is above treshold
    if Data.S.S3.PFCdif_temp_filtered(end) - Data.delta_treshold >= 0            
        %check if last point was not above --> beginning of a potential delta wave 
        if Data.S.S3.PFCdif_temp_filtered(end-1) - Data.delta_treshold < 0      
            %start counting points 
            Data.delta_points_counter = Data.delta_points_counter+1;
            %add detection time to time detection array
            Data.delta_time_detection = [Data.delta_time_detection ; Data.t_tmp(end)];
            
        else
            %if last point was not above --> continue to count
            Data.delta_points_counter = Data.delta_points_counter+1;              
        end
    %if current point is below tresholdcheck then check if last point was above --> ending of a potential delta wave
    elseif Data.S.S3.PFCdif_temp_filtered(end-1) - Data.delta_treshold >= 0  && ~isempty(Data.delta_time_detection)
        %check if potential delta wave is longer than min_duration and
        %shorter than maxduration
        if Data.delta_points_counter * Data.dt > (Data.min_duration/1000) && Data.delta_points_counter * Data.dt < (Data.max_duration/1000)

            disp('delta wave detected (50ms < duration < 150ms');
            %add delta wave duration to delta duration array
            Data.delta_durations = [Data.delta_durations ; (Data.delta_points_counter*Data.dt)];
            %Detected indicator set to 1 for Live Snapshot 
            Interface.Detected = 1;                                         
            
            Data.delta_points_counter = 0;
            
            if size (Data.delta_time_detection,1) ~= size(Data.delta_durations,1)
            Data.delta_time_detection(end)=[];
            end
            %Saving Starting and Ending time in Delta_Detection matrix
            Data.Delta_Detection = [Data.delta_time_detection (Data.delta_time_detection + Data.delta_durations)];  
            %Refreshing PFCsup and PFCdeep mean array 
            t1 = Data.delta_time_detection(end)+Data.delta_durations(end);                                          
            Data.S.S3.PFCdeep_DeltaMean = Data.S.S3.PFCdeep_DeltaMean + Data.S.S3.PFCdeep (round(t1*Data.fs)-94 : round(t1*Data.fs)+156);
            Data.S.S3.PFCsup_DeltaMean = Data.S.S3.PFCsup_DeltaMean + Data.S.S3.PFCsup (round(t1*Data.fs)-94 : round(t1*Data.fs)+156); 
            %Refreshing Delta number in Sleep Information Panel
            set(Interface.NumDelta_rate,'String',num2str(size(Data.Delta_Detection,1)));                           
            
        else
            disp('bad delta wave rejected (duration < 50ms or > 150ms');
            Data.delta_points_counter = 0;
            %erase too short delta wave time detection
            if ~isempty(Data.delta_time_detection)
            Data.delta_time_detection (end) = [];                                
            end
        end

    end


end

end