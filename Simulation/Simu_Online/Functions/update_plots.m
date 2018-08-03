function update_plots(Data,Interface)

%initialisation
if Data.Implement_counter == 0

    set(Interface.signals_plot, 'XLim', [Data.t_tmp(1) Data.t_tmp(end)]);
    set(Interface.signals_plot_lines(1),'XData',Data.t_tmp,'YData',Data.S.S1.gamma_temp);
    set(Interface.signals_plot_lines(2),'XData',Data.t_tmp,'YData',Data.S.S1.gamma_temp_filtered);
    set(Interface.signals_plot_lines(3),'XData',Data.t_tmp,'YData',Data.S.S2.thetadelta_temp+0.5);
    set(Interface.signals_plot_lines(4),'XData',Data.t_tmp,'YData',Data.S.S2.theta_temp_filtered+0.5);
    set(Interface.signals_plot_lines(5),'XData',Data.t_tmp,'YData',Data.S.S2.thetadelta_temp+1);
    set(Interface.signals_plot_lines(6),'XData',Data.t_tmp,'YData',Data.S.S2.delta_temp_filtered+1);
    
    set(Interface.PFCdif_plot, 'XLim', [Data.t_tmp(1) Data.t_tmp(end)]);
    set(Interface.PFCdif_plot_lines(1),'XData',Data.t_tmp,'YData',Data.S.S3.PFCdeep_temp + 0.5 + Interface.offset_deep);
    set(Interface.PFCdif_plot_lines(2),'XData',Data.t_tmp,'YData',Data.S.S3.PFCsup_temp + Interface.offset_sup);
    set(Interface.PFCdif_plot_lines(3),'XData',Data.t_tmp,'YData',Data.S.S3.PFCdif_temp);
    set(Interface.PFCdif_plot_lines(4),'XData',Data.t_tmp,'YData',Data.S.S3.PFCdif_temp_filtered);

    set(Interface.PFCdif_plot_lines(5),'XData',Interface.PFCdif_plot.XLim,'YData',[Data.delta_treshold_temp Data.delta_treshold_temp]);
    
end

%update plots each 100 points (each 0.3s)
if mod(Data.Implement_counter,100) == 0
    
    if get(Interface.r4,'Value') == 1
        set(Interface.signals_plot, 'XLim', [Data.t_tmp(1) Data.t_tmp(end)]);
        set(Interface.signals_plot_lines(1),'XData',Data.t_tmp,'YData',Data.S.S1.gamma_temp+3);
        set(Interface.signals_plot_lines(2),'XData',Data.t_tmp,'YData',Data.S.S1.gamma_temp_filtered+3);
        set(Interface.signals_plot_lines(3),'XData',Data.t_tmp,'YData',Data.S.S2.thetadelta_temp+1.5);
        set(Interface.signals_plot_lines(4),'XData',Data.t_tmp,'YData',Data.S.S2.theta_temp_filtered+1.5);
        set(Interface.signals_plot_lines(5),'XData',Data.t_tmp,'YData',Data.S.S2.thetadelta_temp);
        set(Interface.signals_plot_lines(6),'XData',Data.t_tmp,'YData',Data.S.S2.delta_temp_filtered);
    end

    set(Interface.PFCdif_plot, 'XLim', [Data.t_tmp(1) Data.t_tmp(end)]);
    set(Interface.PFCdif_plot_lines(1),'XData',Data.t_tmp,'YData',Data.S.S3.PFCdeep_temp + 0.5 + Interface.offset_deep);
    set(Interface.PFCdif_plot_lines(2),'XData',Data.t_tmp,'YData',Data.S.S3.PFCsup_temp + Interface.offset_sup);
    set(Interface.PFCdif_plot_lines(3),'XData',Data.t_tmp,'YData',Data.S.S3.PFCdif_temp);
    set(Interface.PFCdif_plot_lines(4),'XData',Data.t_tmp,'YData',Data.S.S3.PFCdif_temp_filtered);

    set(Interface.PFCdif_plot_lines(5),'XData',Interface.PFCdif_plot.XLim,'YData',[Data.delta_treshold_temp Data.delta_treshold_temp]);

end

end