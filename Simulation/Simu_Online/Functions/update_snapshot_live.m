function [Data,Interface] = update_snapshot_live (Data,Interface)

Interface.Navigating_Since = 0;
set(Interface.actual_delta_num_text,'Enable','off');
set(Interface.btn_previous,'Enable','off');
set(Interface.btn_next,'Enable','off');

if Interface.counter_sinceDetection > round(0.51/Data.dt)

    t0 = Data.delta_time_detection(end);                                                                    %plot delta wave snapshot
%     duration = Data.delta_durations(end)/Data.dt;
    t1 = Data.delta_time_detection(end)+Data.delta_durations(end);

    t_snapshot = t1-0.3:Data.dt:t1+0.5;

    set(Interface.PFCdif_snapshot_plot, 'XLim', [t_snapshot(1) t_snapshot(end)]);
    set(Interface.PFCdif_snapshot_plot_lines(1),'XData',t_snapshot,'YData',0.5 + Data.S.S3.PFCdeep (round(t1*Data.fs)-94 : round(t1*Data.fs)+156));
    set(Interface.PFCdif_snapshot_plot_lines(2),'XData',t_snapshot,'YData',0.5 + Data.S.S3.PFCsup (round(t1*Data.fs)-94 : round(t1*Data.fs)+156));
    set(Interface.PFCdif_snapshot_plot_lines(3),'XData',t_snapshot,'YData',Data.S.S3.PFCdif (round(t1*Data.fs)-94 : round(t1*Data.fs)+156));
    set(Interface.PFCdif_snapshot_plot_lines(4),'XData',t_snapshot,'YData',Data.S.S3.PFCdif_temp_filtered (end-250 : end));
    set(Interface.PFCdif_snapshot_plot_lines(5),'XData',[t0 t0],'YData',Interface.PFCdif_snapshot_plot.YLim);
    set(Interface.PFCdif_snapshot_plot_lines(6),'XData',[t1 t1],'YData',Interface.PFCdif_snapshot_plot.YLim);
    set(Interface.PFCdif_snapshot_plot_lines(7),'XData',Interface.PFCdif_snapshot_plot.XLim,'YData',[Data.delta_treshold_temp Data.delta_treshold_temp]);
    
    Interface.Detected = 0;
    Interface.counter_sinceDetection = 0;
end

end