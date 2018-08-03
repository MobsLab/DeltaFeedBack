function Interface = update_snapshot_navig (Data,Interface)

if Interface.Navigating_Since == 0
    Interface.ActualDeltaNum = size(Data.Delta_Detection,1);
    set(Interface.actual_delta_num_text,'Enable','on');
    set(Interface.btn_previous,'Enable','on');
    set(Interface.btn_next,'Enable','off');
end

t1 = Data.delta_time_detection(Interface.ActualDeltaNum)+Data.delta_durations(Interface.ActualDeltaNum);

t_snapshot = t1-0.3:Data.dt:t1+0.5;

set(Interface.PFCdif_snapshot_plot, 'XLim', [t_snapshot(1) t_snapshot(end)]);
set(Interface.PFCdif_snapshot_plot_lines(1),'XData',t_snapshot,'YData',0.5 + Data.S.S3.PFCdeep (round(t1*Data.fs)-94 : round(t1*Data.fs)+156));
set(Interface.PFCdif_snapshot_plot_lines(2),'XData',t_snapshot,'YData',0.5 + Data.S.S3.PFCsup (round(t1*Data.fs)-94 : round(t1*Data.fs)+156));
set(Interface.PFCdif_snapshot_plot_lines(3),'XData',t_snapshot,'YData',Data.S.S3.PFCdif (round(t1*Data.fs)-94 : round(t1*Data.fs)+156));
set(Interface.PFCdif_snapshot_plot_lines(6),'XData',[t1 t1],'YData',Interface.PFCdif_snapshot_plot.YLim);
set(Interface.PFCdif_snapshot_plot_lines(7),'XData',Interface.PFCdif_snapshot_plot.XLim,'YData',[Data.delta_treshold_temp Data.delta_treshold_temp]);

Interface.Navigating_Since = Interface.Navigating_Since +1;

if Interface.Detected == 1    
    Interface.Detected = 0;
    Interface.counter_sinceDetection = 0;
end

end