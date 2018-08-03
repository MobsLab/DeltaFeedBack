function [Data,Interface] = update_phase_space(Data,Interface)

if Data.Hilbert_counter > 1
    
    Powers = [Data.S.S1.gamma_power(2:end)' Data.S.S2.ratio_power(2:end)']; 
    
    %Plotting only the two last hours of acquisition in phase space 
    if size(Powers,1)>6400
        Powers = Powers (end-6399,:);
    end
    
    %compute distributions
    [Data.S.S1.gamma_prob,Data.S.S1.gamma_value] = ksdensity (Powers(:,1));
    [Data.S.S2.ratio_prob1,Data.S.S2.ratio_value1] = ksdensity (Powers(:,2));
    
    if ~isempty(Powers(Powers(:,1)<Data.gamma_treshold,2))
        [Data.S.S2.ratio_prob2,Data.S.S2.ratio_value2] = ksdensity (Powers(Powers(:,1)<Data.gamma_treshold,2));
    else
        Data.S.S2.ratio_prob2 = []; Data.S.S2.ratio_value2 = [];
    end
    
    %Waint surfficient points to plot the snake 
    if size(Powers,1) > 10
        %Separating dots in 4 groups (Snake,Wake,REM and NREM) 
        Snake = Powers(end-9:end,:); Powers(end-9:end,:) = []; %10 last points 
        Wake = Powers(Powers(:,1)>Data.gamma_treshold,:); Powers(Powers(:,1)>Data.gamma_treshold,:) = [];
        REM = Powers(Powers(:,2)>Data.ratio_treshold,:); Powers(Powers(:,2)>Data.ratio_treshold,:) = [];
        NREM = Powers;

        set(Interface.phase_space_plot_lines(7),'XData',Snake(end,1),'YData',Snake(end,2));
        set(Interface.phase_space_plot_lines(6),'XData',Snake(:,1),'YData',Snake(:,2));
        set(Interface.phase_space_plot_lines(4),'XData',Interface.phase_space_plot.XLim,'YData',[Data.ratio_treshold_temp Data.ratio_treshold_temp]);
        set(Interface.phase_space_plot_lines(5),'XData',[Data.gamma_treshold_temp Data.gamma_treshold_temp],'YData',Interface.phase_space_plot.YLim);
        set(Interface.phase_space_plot_lines(1),'XData',Wake(:,1),'YData',Wake(:,2));
        set(Interface.phase_space_plot_lines(2),'XData',REM(:,1),'YData',REM(:,2));
        set(Interface.phase_space_plot_lines(3),'XData',NREM(:,1),'YData',NREM(:,2));
    end

    set(Interface.gamma_distribution_plot, 'XLim', [(min(Data.S.S1.gamma_value)) (max(Data.S.S1.gamma_value))]);
    set(Interface.gamma_distribution_plot_lines(1),'XData',Data.S.S1.gamma_value,'YData',Data.S.S1.gamma_prob);
    set(Interface.gamma_distribution_plot_lines(2),'XData',[Data.gamma_treshold_temp Data.gamma_treshold_temp],'YData',Interface.gamma_distribution_plot.YLim);
    
    set(Interface.ratio_distribution_plot, 'YLim', [(min(Data.S.S2.ratio_value1)) (max(Data.S.S2.ratio_value1))]);
    set(Interface.ratio_distribution_plot_lines(1),'XData',Data.S.S2.ratio_prob1,'YData',Data.S.S2.ratio_value1);
    set(Interface.ratio_distribution_plot_lines(3),'XData',Data.S.S2.ratio_prob2,'YData',Data.S.S2.ratio_value2);
    set(Interface.ratio_distribution_plot_lines(2),'XData',Interface.ratio_distribution_plot.XLim,'YData',[Data.ratio_treshold_temp Data.ratio_treshold_temp]);
   
    set(Interface.phase_space_plot, 'XLim', [(min(Data.S.S1.gamma_value)) (max(Data.S.S1.gamma_value))]);
    set(Interface.phase_space_plot, 'YLim', [(min(Data.S.S2.ratio_value1)) (max(Data.S.S2.ratio_value1))]);
end

end