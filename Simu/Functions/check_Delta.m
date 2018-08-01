%

function Data = check_Delta (Data,Interface)
  
if get(Interface.detection_checkbox,'Value') == 1 

    if Data.S.S3.PFCdif_temp_filtered(end) - Data.delta_treshold >= 0                                                %check if current point is above treshold

        if Data.S.S3.PFCdif_temp_filtered(end-1) - Data.delta_treshold < 0                                          %check if last point was not above --> beginning of a potential delta wave 
            
            Data.delta_points_counter = Data.delta_points_counter+1;                                                %start counting points 
            Data.delta_time_detection = [Data.delta_time_detection ; Data.t_tmp(end)];                              %add detection time to time detection array
            
        else
            Data.delta_points_counter = Data.delta_points_counter+1;                                                %if last point was not above --> continue to count
        end

    elseif Data.S.S3.PFCdif_temp_filtered(end-1) - Data.delta_treshold >= 0  && ~isempty(Data.delta_time_detection)  %if current point is below tresholdcheck then check if last point was above --> ending of a potential delta wave

        if Data.delta_points_counter * Data.dt > 0.05 && Data.delta_points_counter * Data.dt < 0.15                 %check if potential delta wave is longer than 50 ms

            disp('delta wave detected (50ms < duration < 150ms');

            Data.delta_durations = [Data.delta_durations ; (Data.delta_points_counter*Data.dt)];                    %add delta wave duration to delta duration array
            
            t0 = Data.delta_time_detection(end);                                                                    %plot delta wave snapshot
            duration = Data.delta_durations(end)/Data.dt;
            t1 = Data.delta_time_detection(end)+Data.delta_durations(end);

            t_snapshot = t0:Data.dt:t1;
            
            set(Interface.PFCdif_snapshot_plot, 'XLim', [t_snapshot(1) t_snapshot(end)]);
            set(Interface.PFCdif_snapshot_plot_lines(1),'XData',t_snapshot,'YData',0.5 + Data.S.S3.PFCsup (round(t0*Data.fs) : round(t1*Data.fs)));
            set(Interface.PFCdif_snapshot_plot_lines(2),'XData',t_snapshot,'YData',0.5 + Data.S.S3.PFCdeep (round(t0*Data.fs) : round(t1*Data.fs)));
            set(Interface.PFCdif_snapshot_plot_lines(3),'XData',t_snapshot,'YData',Data.S.S3.PFCdif (round(t0*Data.fs) : round(t1*Data.fs)));
            set(Interface.PFCdif_snapshot_plot_lines(4),'XData',t_snapshot,'YData',Data.S.S3.PFCdif_temp_filtered (end-duration : end));
            set(Interface.PFCdif_snapshot_plot_lines(5),'XData',[t0 t0],'YData',Interface.PFCdif_snapshot_plot.YLim);
            set(Interface.PFCdif_snapshot_plot_lines(6),'XData',[t1 t1],'YData',Interface.PFCdif_snapshot_plot.YLim);
            set(Interface.PFCdif_snapshot_plot_lines(7),'XData',Interface.PFCdif_snapshot_plot.XLim,'YData',[Data.delta_treshold_temp Data.delta_treshold_temp]);

            Data.delta_points_counter = 0;

        else
            disp('bad delta wave rejected (duration < 50ms or > 150ms');
            Data.delta_points_counter = 0;

            if ~isempty(Data.delta_time_detection)
            Data.delta_time_detection (end) = [];                                                                   %erase too short delta wave time detection
            end
        end

    end


end

end