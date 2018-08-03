function Interface = update_snapshot_mean (Data,Interface)

Interface.Navigating_Since = 0;
set(Interface.actual_delta_num_text,'Enable','off');
set(Interface.btn_previous,'Enable','off');
set(Interface.btn_next,'Enable','off');

set(Interface.PFCdif_snapshot_plot, 'XLim', [-0.3 0.5]);
set(Interface.PFCdif_snapshot_plot_lines(1),'XData',-0.3:(1/312.5):0.5,'YData',Data.S.S3.PFCdeep_DeltaMean/size(Data.Delta_Detection,1));
set(Interface.PFCdif_snapshot_plot_lines(2),'XData',-0.3:(1/312.5):0.5,'YData',Data.S.S3.PFCsup_DeltaMean/size(Data.Delta_Detection,1));

Interface.Detected = 0;
Interface.counter_sinceDetection = 0;

end