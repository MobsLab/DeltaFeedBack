%% Reset 
%This function resets Data, Data properties and Interface porperties to
%start a new simulation session with the same mouse 

function [AllData,Interface] = Reset (AllData,Interface)

if strcmp(get(Interface.timer, 'Running'), 'on')
    stop(Interface.timer);
    AllData.Implement_counter = 0;
end

%Reset Data
AllData.S.S1.gamma = AllData.S.S1.gamma_raw;                          
AllData.S.S2.thetadelta = AllData.S.S2.thetadelta_raw;                
AllData.S.S3.PFCsup = AllData.S.S3.PFCsup_raw;                       
AllData.S.S3.PFCdeep = AllData.S.S3.PFCdeep_raw;                     
AllData.S.S3.PFCdif = AllData.S.S3.PFCdeep_raw - AllData.S.S3.PFCsup_raw;
AllData.S.S1.gamma_filtered = AllData.S.S1.gamma_filtered_raw;    
AllData.S.S2.theta_filtered = AllData.S.S2.theta_filtered_raw;
AllData.S.S2.delta_filtered = AllData.S.S2.delta_filtered_raw;
AllData.TimeSelection = 0;

%Reset Data properties 

AllData.Implement_counter = 0;                         %counting Data implementations already implemented
AllData.Hilbert_counter = 0;                           %counting hilbert transforms already computed 

AllData.Wake_counter = 0;
AllData.REM_counter = 0;
AllData.NREM_counter = 0;

AllData.delta_points_counter = 0;                      %counting current delta wave duration (in number of points)
AllData.Delta_Detection = [];                          
AllData.delta_time_detection = [];                     %times(in sec) at which delta wave are detected
AllData.delta_durations = [];                          %durations of detected delta waves

Interface.Navigating_Since = 0;

AllData.sleep_state = [];                              %sleep state (SWS, REM, WAKE);

AllData.S.S1.gamma_power = [];
AllData.S.S2.theta_power = [];
AllData.S.S2.delta_power = [];
AllData.S.S2.ratio_power = [];

%Reset Interface properties
Interface.btn_t0_edit.String = 't0';
Interface.btn_t1_edit.String = 't1';

Interface.detection_checkbox.Value = 0;
Interface.Detected = 0;
Interface.ActualDeltaNum = [];

AllData.T0 = [];
AllData.T1 = [];

Interface.vline_gamma=[];
Interface.hline_ratio=[];
Interface.hline_delta=[];

Interface.Snapshot = [];
Interface.Detectionline1 = [];
Interface.Detectionline2 = [];

set(Interface.WAKE_rate_min,'String','0');
set(Interface.WAKE_rate_perc,'String','0');
set(Interface.REM_rate_min,'String','0');
set(Interface.REM_rate_perc,'String','0');    
set(Interface.NREM_rate_min,'String','0');
set(Interface.NREM_rate_perc,'String','0');


set(Interface.phase_space_plot_lines(6),'XData',[],'YData',[]);
set(Interface.phase_space_plot_lines(7),'XData',[],'YData',[]);
set(Interface.phase_space_plot_lines(4),'XData',[],'YData',[]);
set(Interface.phase_space_plot_lines(5),'XData',[],'YData',[]);
set(Interface.phase_space_plot_lines(1),'XData',[],'YData',[]);
set(Interface.phase_space_plot_lines(2),'XData',[],'YData',[]);
set(Interface.phase_space_plot_lines(3),'XData',[],'YData',[]);

set(Interface.gamma_distribution_plot_lines(1),'XData',[],'YData',[]);
set(Interface.gamma_distribution_plot_lines(2),'XData',[],'YData',[]);

set(Interface.ratio_distribution_plot_lines(1),'XData',[],'YData',[]);
set(Interface.ratio_distribution_plot_lines(3),'XData',[],'YData',[]);
set(Interface.ratio_distribution_plot_lines(2),'XData',[],'YData',[]);

set(Interface.signals_plot_lines(1),'XData',[],'YData',[]);
set(Interface.signals_plot_lines(2),'XData',[],'YData',[]);
set(Interface.signals_plot_lines(3),'XData',[],'YData',[]);
set(Interface.signals_plot_lines(4),'XData',[],'YData',[]);
set(Interface.signals_plot_lines(5),'XData',[],'YData',[]);
set(Interface.signals_plot_lines(6),'XData',[],'YData',[]);

set(Interface.PFCdif_plot_lines(1),'XData',[],'YData',[]);
set(Interface.PFCdif_plot_lines(2),'XData',[],'YData',[]);
set(Interface.PFCdif_plot_lines(3),'XData',[],'YData',[]);
set(Interface.PFCdif_plot_lines(4),'XData',[],'YData',[]);

set(Interface.PFCdif_plot_lines(5),'XData',[],'YData',[]);

set(Interface.PFCdif_snapshot_plot_lines(1),'XData',[],'YData',[]);
set(Interface.PFCdif_snapshot_plot_lines(2),'XData',[],'YData',[]);
set(Interface.PFCdif_snapshot_plot_lines(3),'XData',[],'YData',[]);
set(Interface.PFCdif_snapshot_plot_lines(4),'XData',[],'YData',[]);
set(Interface.PFCdif_snapshot_plot_lines(5),'XData',[],'YData',[]);
set(Interface.PFCdif_snapshot_plot_lines(6),'XData',[],'YData',[]);
set(Interface.PFCdif_snapshot_plot_lines(7),'XData',[],'YData',[]);

set(Interface.sleep_stage,'String',[]);


end