function Interface = update_phase_space(Data,Interface)

set(Interface.phase_space_plot, 'XLim', [(min(Data.S.S1.gamma_value)-1) (max(Data.S.S1.gamma_value)+1)]);
set(Interface.phase_space_plot, 'YLim', [(min(Data.S.S2.ratio_value)-1) (max(Data.S.S2.ratio_value)+1)]);
set(Interface.phase_space_plot_lines(1),'XData',Data.S.S1.gamma_power,'YData',Data.S.S2.ratio_power);


set(Interface.gamma_distribution_plot, 'XLim', [(min(Data.S.S1.gamma_value)-1) (max(Data.S.S1.gamma_value)+1)]);
set(Interface.gamma_distribution_plot_lines(1),'XData',Data.S.S1.gamma_value,'YData',Data.S.S1.gamma_prob);


set(Interface.ratio_distribution_plot, 'YLim', [(min(Data.S.S2.ratio_value)-1) (max(Data.S.S2.ratio_value)+1)]);
set(Interface.ratio_distribution_plot_lines(1),'XData',Data.S.S2.ratio_prob,'YData',Data.S.S2.ratio_value);


Data.Hilbert_counter = Data.Hilbert_counter + 1;

end