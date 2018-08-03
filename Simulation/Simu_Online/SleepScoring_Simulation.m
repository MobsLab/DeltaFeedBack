%SleepScoring_Simulation 
%22/07/2018
%Adrien Bertolo 

%This GUI simulates Intan live acquisition reading OB, dHPC, PFCsup and PFCdeep .mat files.
%It performs Sleep Scoring and Delta Waves detection.

%Timer object calls Update_Display Callback function, in which other
%Tool_Functions (see folder) are called to update data, perform treatments
%and display results.


function SleepScoring_Simulation

addpath(genpath('/home/mobsspectre/Dropbox/Mobs_member/AdrienBaptiste/Code/Delta_Detection'));
addpath(genpath('/home/mobsspectre/Dropbox/Mobs_member/AdrienBaptiste/MOBS_Code/PrgMatlab'));
addpath(genpath('/home/mobsspectre/Dropbox/Mobs_member/AdrienBaptiste/Code/Processing'));

global Interface
global AllData

%Signals properties 

AllData.Fs = [];                                       %sampling frequency of raw Signals init
AllData.DB_duration = [];                              %Signalsblock duration init 

AllData.S = struct;                                    %structure containing signals
AllData.Path = struct;                                 %structure containing signals paths

AllData.Implement_counter = 0;                         %counting Signals implementations already implemented

AllData.Hilbert_counter = 0;                           %counting hilbert transforms already computed 

AllData.T0 = [];
AllData.T = [];

AllData.delta_points_counter = 0;                      %counting current delta wave duration (in number of points)
AllData.Delta_Detection = [];                          
AllData.delta_time_detection = [];                     %times(in sec) at which delta wave are detected
AllData.delta_durations = [];                          %durations of detected delta waves
AllData.min_duration = 50;
AllData.max_duration = 150;

AllData.ratio_treshold_temp = [];
AllData.gamma_treshold_temp= [];
AllData.delta_treshold_temp= [];

AllData.sup_prefactor = 1;
AllData.deep_prefactor = 1;

AllData.filter_order = 4;
AllData.cutoff_freq = 8;

AllData.S.S1.gamma_power = [];
AllData.S.S2.theta_power = [];
AllData.S.S2.delta_power = [];
AllData.S.S2.ratio_power = [];
AllData.S.S3.PFCdeep_DeltaMean = zeros(251,1);
AllData.S.S3.PFCsup_DeltaMean = zeros(251,1);

AllData.sleep_matrix = [];                             
AllData.AllResults = [];
AllData.Wake_counter = 0;
AllData.REM_counter = 0;
AllData.NREM_counter = 0;
AllData.Wake_episodes_counter = 0;
AllData.REM_episodes_counter = 0;
AllData.NREM_episodes_counter = 0;


AllData.PreProcessed = 0;
AllData.TimeSelection = 0;

%Interface properties
Interface.time_window = 3;                              %time window for sleep scoring computations (s)

Interface.vline_gamma = [];
Interface.hline_ratio = [];
Interface.hline_delta = [];

Interface.Detected = 0;
Interface.counter_sinceDetection = 0;
Interface.Snapshot = [];
Interface.Detectionline1 = [];
Interface.Detectionline2 = [];
Interface.ActualDeltaNum = [];
Interface.Navigating_Since = 0;

Interface.offset_sup = 1;
Interface.offset_deep = 1;

%Positions
Interface.pos.window = [0 0 1 1];

Interface.pos.panel_lecture_controls = [0.4375 0.9 0.125 0.1];
Interface.pos.btn_run = [0.05 0.5 0.4 0.4];
Interface.pos.btn_stop = [0.55 0.5 0.4 0.4];
Interface.pos.slider = [0 0 1 1];

Interface.pos.panel_time_selection = [0.4375 0.8 0.125 0.1];
Interface.pos.btn_t0 = [0.05 0.6 0.4 0.3];
Interface.pos.btn_t1 = [0.55 0.6 0.4 0.3];
Interface.pos.btn_time_selection = [0.05 0.05 0.4 0.4];
Interface.pos.btn_reset = [0.55 0.05 0.4 0.4];

Interface.pos.panel_tresholds_selection = [0.4375 0.55 0.125 0.25];
Interface.pos.gamma_text = [0.025 0.85 0.5 0.1];
Interface.pos.gamma_edit = [0.7 0.85 0.25 0.1];
Interface.pos.ratio_text = [0.025 0.7 0.5 0.1];
Interface.pos.ratio_edit = [0.7 0.7 0.25 0.1];
Interface.pos.btn_apply1 = [0.25 0.55 0.5 0.1];
Interface.pos.detection_checkbox = [0.1 0.32 0.8 0.1];
Interface.pos.delta_text = [0.05 0.2 0.5 0.1];
Interface.pos.delta_edit = [0.7 0.2 0.25 0.1];
Interface.pos.btn_apply2 = [0.25 0.05 0.5 0.1];

Interface.pos.panel_sleep_informations = [0.4375 0.05 0.125 0.45];
Interface.pos.min_text = [0 0.7 0.18 0.1];
Interface.pos.perc_text = [0 0.55 0.18 0.1];
Interface.pos.num_text = [0 0.4 0.18 0.1];
Interface.pos.mean_text = [0 0.25 0.18 0.1];
Interface.pos.WAKE_text = [0.1 0.85 0.4 0.1];
Interface.pos.WAKE_rate_min = [0.2 0.7 0.25 0.1];
Interface.pos.WAKE_rate_perc = [0.2 0.55 0.25 0.1];
Interface.pos.WAKE_rate_num = [0.2 0.4 0.25 0.1];
Interface.pos.WAKE_rate_mean = [0.2 0.25 0.25 0.1];
Interface.pos.REM_text = [0.4 0.85 0.4 0.1];
Interface.pos.REM_rate_min = [0.475 0.7 0.25 0.1];
Interface.pos.REM_rate_perc = [0.475 0.55 0.25 0.1];
Interface.pos.REM_rate_num = [0.475 0.4 0.25 0.1];
Interface.pos.REM_rate_mean = [0.475 0.25 0.25 0.1];
Interface.pos.NREM_text = [0.7 0.85 0.4 0.1];
Interface.pos.NREM_rate_min = [0.775 0.7 0.2 0.1];
Interface.pos.NREM_rate_perc = [0.775 0.55 0.2 0.1];
Interface.pos.NREM_rate_num = [0.775 0.4 0.2 0.1];
Interface.pos.NREM_rate_mean= [0.775 0.25 0.2 0.1];
Interface.pos.NumDelta_text = [0 0.1 0.8 0.1];
Interface.pos.NumDelta_rate= [0.8 0.1 0.2 0.1];

Interface.pos.panel_signals_plots_delta_detection = [0.025 0.55 0.4 0.45];
Interface.pos.PFCdif_plot = [0.1 0.2 0.8 0.65];
Interface.pos.prefactors_checkbox = [0.1 0.875 0.3 0.1];
Interface.pos.Sup_prefactor_text = [0.65 0.85 0.1 0.1];
Interface.pos.Sup_prefactor_edit = [0.8 0.875 0.1 0.1];
Interface.pos.Deep_prefactor_text = [0.4 0.85 0.1 0.1];
Interface.pos.Deep_prefactor_edit = [0.5 0.875 0.1 0.1];
Interface.pos.btn_plus_sup = [0.925 0.4 0.05 0.06];
Interface.pos.btn_minus_sup = [0.925 0.3 0.05 0.06];
Interface.pos.btn_plus_deep = [0.925 0.65 0.05 0.06];
Interface.pos.btn_minus_deep = [0.925 0.55 0.05 0.06];
Interface.pos.flt_order_text = [0.05 0.0175 0.34 0.075];
Interface.pos.flt_order_edit = [0.275 0.025 0.1 0.075];
Interface.pos.cutoff_freq_text = [0.375 0.0175 0.25 0.075];
Interface.pos.cutoff_freq_edit = [0.575 0.025 0.1 0.075];
Interface.pos.btn_apply3 = [0.75 0.025 0.1 0.075];

Interface.pos.panel_signals_plots_delta_snapshots = [0.025 0.05 0.4 0.45];
Interface.pos.delta_snapshots_plot = [0.1 0.2 0.8 0.65];
Interface.pos.min_duration_text = [0.05 0.0175 0.28 0.075];
Interface.pos.min_duration_edit = [0.275 0.025 0.1 0.075];
Interface.pos.max_duration_text = [0.375 0.0175 0.23 0.075];
Interface.pos.max_duration_edit = [0.575 0.025 0.1 0.075];
Interface.pos.btn_apply4 = [0.75 0.025 0.1 0.075];
Interface.pos.actual_delta_num = [0.55 0.85 0.2 0.1];
Interface.pos.btn_previous = [0.75 0.885 0.1 0.1];
Interface.pos.btn_next = [0.85 0.885 0.1 0.1];

Interface.pos.panel_signals_plots_sleep_scoring = [0.575 0.55 0.4 0.45];
Interface.pos.signals_plot = [0.1 0.2 0.8 0.65];
Interface.pos.slider_zoom = [0.05 0.05 0.9 0.05];


Interface.pos.panel_sleep_scoring = [0.575 0.05 0.4 0.45];
Interface.pos.phase_space_plot = [0.3 0.45 0.65 0.5];
Interface.pos.gamma_distribution_plot = [0.3 0.08 0.65 0.3];
Interface.pos.ratio_distribution_plot = [0.1 0.45 0.15 0.5];
Interface.pos.sleep_stage = [0.05 0.1 0.2 0.1];

Interface.pos.slider = [0.05 0.1 0.9 0.25];

Interface.window = figure('MenuBar','none','Units','normalized','Position',Interface.pos.window);


%menu
Interface.menu.load_signals = uimenu(Interface.window,'Text','Load Signals','MenuSelectedFcn',@Load_Signals);
Interface.menu.preprocessing = uimenu(Interface.window,'Text','Pre Processing','MenuSelectedFcn',@Launch_PreProcessing);


%make interface

%panel_lecture_controls
Interface.panel_lecture_controls = uipanel('Parent',Interface.window,'Title','Lecture Controls','TitlePosition','centertop','Units','normalized','Position',Interface.pos.panel_lecture_controls);
Interface.btn_run = uicontrol('Parent',Interface.panel_lecture_controls,'Units','normalized','Style','PushButton','String','Run','Position',Interface.pos.btn_run,'Callback',@Btn_Run);
Interface.btn_stop = uicontrol('Parent',Interface.panel_lecture_controls,'Units','normalized','Style','PushButton','String','Stop','Position',Interface.pos.btn_stop,'Callback',@Btn_Stop);

%panel time_selection
Interface.panel_time_selection = uipanel('Parent',Interface.window,'Title','Time Selection (s)','TitlePosition','centertop','Units','normalized','Position',Interface.pos.panel_time_selection);
Interface.btn_t0_edit = uicontrol('Parent',Interface.panel_time_selection,'Units','normalized','Style','edit','String','t0','Position',Interface.pos.btn_t0,'Callback',@Btn_T0);
Interface.btn_t1_edit = uicontrol('Parent',Interface.panel_time_selection,'Units','normalized','Style','edit','String','t1','Position',Interface.pos.btn_t1,'Callback',@Btn_T1);
Interface.btn_time_selection = uicontrol('Parent',Interface.panel_time_selection,'Units','normalized','Style','PushButton','String','Time Selection','Position',Interface.pos.btn_time_selection,'Callback',@Btn_Time_Selection);
Interface.btn_time_selection = uicontrol('Parent',Interface.panel_time_selection,'Units','normalized','Style','PushButton','String','Reset','Position',Interface.pos.btn_reset,'Callback',@Btn_Reset);

%panel treshold_selection
Interface.panel_tresholds_selection = uipanel('Parent',Interface.window,'Title','Tresholds Settings','TitlePosition','centertop','Units','normalized','Position',Interface.pos.panel_tresholds_selection);
Interface.gamma_text = uicontrol('Parent',Interface.panel_tresholds_selection,'Style','text','String','Gamma Treshold','Units','normalized','Position',Interface.pos.gamma_text);
Interface.gamma_edit = uicontrol('Parent',Interface.panel_tresholds_selection,'Style','edit','Units','normalized','Position',Interface.pos.gamma_edit,'Callback',@Edit_Gamma);
Interface.ratio_text = uicontrol('Parent',Interface.panel_tresholds_selection,'Style','text','String','Ratio Treshold','Units','normalized','Position',Interface.pos.ratio_text);
Interface.ratio_edit = uicontrol('Parent',Interface.panel_tresholds_selection,'Style','edit','Units','normalized','Position',Interface.pos.ratio_edit,'Callback',@Edit_Ratio);
Interface.btn_apply1 = uicontrol('Parent',Interface.panel_tresholds_selection,'Style','PushButton','String','Apply','Units','normalized','Position',Interface.pos.btn_apply1,'Callback',@Btn_Apply1);
Interface.detection_checkbox = uicontrol('Parent',Interface.panel_tresholds_selection,'Style','checkbox','String','Start Detection','Units','normalized','Position',Interface.pos.detection_checkbox);
Interface.delta_text = uicontrol('Parent',Interface.panel_tresholds_selection,'Style','text','String','Delta Treshold','Units','normalized','Position',Interface.pos.delta_text);
Interface.delta_edit = uicontrol('Parent',Interface.panel_tresholds_selection,'Style','edit','Units','normalized','Position',Interface.pos.delta_edit,'Callback',@Edit_Delta);
Interface.btn_apply2 = uicontrol('Parent',Interface.panel_tresholds_selection,'Style','PushButton','String','Apply','Units','normalized','Position',Interface.pos.btn_apply2,'Callback',@Btn_Apply2);

%planel sleep informations
Interface.panel_sleep_informations = uipanel('Parent',Interface.window,'Title','Sleep Informations','TitlePosition','centertop','Units','normalized','Position',Interface.pos.panel_sleep_informations);
Interface.min_text = uicontrol('Parent',Interface.panel_sleep_informations,'Style','text','String','min','Units','normalized','Position',Interface.pos.min_text);
Interface.perc_text = uicontrol('Parent',Interface.panel_sleep_informations,'Style','text','String','%','Units','normalized','Position',Interface.pos.perc_text);
Interface.num_text = uicontrol('Parent',Interface.panel_sleep_informations,'Style','text','String','#','Units','normalized','Position',Interface.pos.num_text);
Interface.mean_text = uicontrol('Parent',Interface.panel_sleep_informations,'Style','text','String','mean','Units','normalized','Position',Interface.pos.mean_text);
Interface.WAKE_text = uicontrol('Parent',Interface.panel_sleep_informations,'Style','text','String','Wake','Units','normalized','Position',Interface.pos.WAKE_text);
Interface.WAKE_rate_min = uicontrol('Parent',Interface.panel_sleep_informations,'Style','text','String','0','Units','normalized','Position',Interface.pos.WAKE_rate_min);
Interface.WAKE_rate_perc = uicontrol('Parent',Interface.panel_sleep_informations,'Style','text','String','0','Units','normalized','Position',Interface.pos.WAKE_rate_perc);
Interface.WAKE_rate_num = uicontrol('Parent',Interface.panel_sleep_informations,'Style','text','String','0','Units','normalized','Position',Interface.pos.WAKE_rate_num);
Interface.WAKE_rate_mean = uicontrol('Parent',Interface.panel_sleep_informations,'Style','text','String','0','Units','normalized','Position',Interface.pos.WAKE_rate_mean);
Interface.REM_text = uicontrol('Parent',Interface.panel_sleep_informations,'Style','text','String','REM','Units','normalized','Position',Interface.pos.REM_text);
Interface.REM_rate_min = uicontrol('Parent',Interface.panel_sleep_informations,'Style','text','String','0','Units','normalized','Position',Interface.pos.REM_rate_min);
Interface.REM_rate_perc = uicontrol('Parent',Interface.panel_sleep_informations,'Style','text','String','0','Units','normalized','Position',Interface.pos.REM_rate_perc);
Interface.REM_rate_num = uicontrol('Parent',Interface.panel_sleep_informations,'Style','text','String','0','Units','normalized','Position',Interface.pos.REM_rate_num);
Interface.REM_rate_mean = uicontrol('Parent',Interface.panel_sleep_informations,'Style','text','String','0','Units','normalized','Position',Interface.pos.REM_rate_mean);
Interface.NREM_text = uicontrol('Parent',Interface.panel_sleep_informations,'Style','text','String','NREM','Units','normalized','Position',Interface.pos.NREM_text);
Interface.NREM_rate_min = uicontrol('Parent',Interface.panel_sleep_informations,'Style','text','String','0','Units','normalized','Position',Interface.pos.NREM_rate_min);
Interface.NREM_rate_perc = uicontrol('Parent',Interface.panel_sleep_informations,'Style','text','String','0','Units','normalized','Position',Interface.pos.NREM_rate_perc);
Interface.NREM_rate_num = uicontrol('Parent',Interface.panel_sleep_informations,'Style','text','String','0','Units','normalized','Position',Interface.pos.NREM_rate_num);
Interface.NREM_rate_mean = uicontrol('Parent',Interface.panel_sleep_informations,'Style','text','String','0','Units','normalized','Position',Interface.pos.NREM_rate_mean);
Interface.NumDelta_text = uicontrol('Parent',Interface.panel_sleep_informations,'Style','text','String','Number of Delta Detections:','Units','normalized','Position',Interface.pos.NumDelta_text);
Interface.NumDelta_rate = uicontrol('Parent',Interface.panel_sleep_informations,'Style','text','String','0','Units','normalized','Position',Interface.pos.NumDelta_rate);

%panel signals_plots_delta_detection
Interface.panel_signals_plots_delta_detection = uipanel('Parent',Interface.window,'Title','Delta Detection Signals','TitlePosition','centertop','Units','normalized','Position',Interface.pos.panel_signals_plots_delta_detection);

Interface.PFCdif_plot = axes('Parent',Interface.panel_signals_plots_delta_detection,'Units','normalized','Position',Interface.pos.PFCdif_plot,'Visible','on','HandleVisibility','on');
axes(Interface.PFCdif_plot);
Interface.PFCdif_plot_lines = plot(0,0,0,0,0,0,0,0,0,0);
set(Interface.PFCdif_plot_lines(4),'Color','black');
set(Interface.PFCdif_plot_lines(5),'Color',[0 0 0.5],'LineStyle','--');
Interface.set_prefactors_checkbox = uicontrol('Parent',Interface.panel_signals_plots_delta_detection,'Style','checkbox','String','Set Prefactors','Units','normalized','Position',Interface.pos.prefactors_checkbox);
Interface.Sup_prefactor_text = uicontrol('Parent',Interface.panel_signals_plots_delta_detection,'Style','text','String','PFC sup','Units','normalized','Position',Interface.pos.Sup_prefactor_text);
Interface.Sup_prefactor_edit = uicontrol('Parent',Interface.panel_signals_plots_delta_detection,'Style','edit','String','1','Units','normalized','Position',Interface.pos.Sup_prefactor_edit,'BackgroundColor',[1 0.15 0],'Callback',@Edit_Sup_Prefactor);
Interface.Deep_prefactor_text = uicontrol('Parent',Interface.panel_signals_plots_delta_detection,'Style','text','String','PFC deep','Units','normalized','Position',Interface.pos.Deep_prefactor_text);
Interface.Deep_prefactor_edit = uicontrol('Parent',Interface.panel_signals_plots_delta_detection,'Style','edit','String','1','Units','normalized','Position',Interface.pos.Deep_prefactor_edit,'BackgroundColor',[0 0.15 1],'Callback',@Edit_Deep_Prefactor);
Interface.btn_plus_sup = uicontrol('Parent',Interface.panel_signals_plots_delta_detection,'Style','PushButton','String','+','Units','normalized','Position',Interface.pos.btn_plus_sup,'BackgroundColor',[1 0.15 0],'Callback',@Btn_Plus_sup);
Interface.btn_minus_sup = uicontrol('Parent',Interface.panel_signals_plots_delta_detection,'Style','PushButton','String','-','Units','normalized','Position',Interface.pos.btn_minus_sup,'BackgroundColor',[1 0.15 0],'Callback',@Btn_Minus_sup);
Interface.btn_plus_sup = uicontrol('Parent',Interface.panel_signals_plots_delta_detection,'Style','PushButton','String','+','Units','normalized','Position',Interface.pos.btn_plus_deep,'BackgroundColor',[0 0.15 1],'Callback',@Btn_Plus_deep);
Interface.btn_minus_sup = uicontrol('Parent',Interface.panel_signals_plots_delta_detection,'Style','PushButton','String','-','Units','normalized','Position',Interface.pos.btn_minus_deep,'BackgroundColor',[0 0.15 1],'Callback',@Btn_Minus_deep);
Interface.flt_order_text = uicontrol('Parent',Interface.panel_signals_plots_delta_detection,'Style','text','String','Filter Order','Units','normalized','Position',Interface.pos.flt_order_text);
Interface.flt_order_edit = uicontrol('Parent',Interface.panel_signals_plots_delta_detection,'Style','edit','String','4','Units','normalized','Position',Interface.pos.flt_order_edit);
Interface.cutoff_freq_text = uicontrol('Parent',Interface.panel_signals_plots_delta_detection,'Style','text','String','Cutoff Freq (Hz)','Units','normalized','Position',Interface.pos.cutoff_freq_text);
Interface.cutoff_freq_edit = uicontrol('Parent',Interface.panel_signals_plots_delta_detection,'Style','edit','String','8','Units','normalized','Position',Interface.pos.cutoff_freq_edit);
Interface.btn_apply3 = uicontrol('Parent',Interface.panel_signals_plots_delta_detection,'Style','PushButton','String','Apply','Units','normalized','Position',Interface.pos.btn_apply3,'Callback',@Btn_Apply3);
Interface.PFCdif_plot.XLabel.String = 'Time (s)';
Interface.PFCdif_plot.YLabel.String = 'PFC Signals';
%panel_signal_plots_delta_snapshots
Interface.panel_signals_plots_delta_snapshots = uipanel('Parent',Interface.window,'Title','Delta Waves','TitlePosition','centertop','Units','normalized','Position',Interface.pos.panel_signals_plots_delta_snapshots);

Interface.PFCdif_snapshot_plot = axes('Parent',Interface.panel_signals_plots_delta_snapshots,'Units','normalized','Position',Interface.pos.delta_snapshots_plot,'Visible','on','HandleVisibility','on');
Interface.min_duration_text = uicontrol('Parent',Interface.panel_signals_plots_delta_snapshots,'Style','text','String','Min Duration (ms)','Units','normalized','Position',Interface.pos.min_duration_text);
Interface.min_duration_edit = uicontrol('Parent',Interface.panel_signals_plots_delta_snapshots,'Style','edit','String','50','Units','normalized','Position',Interface.pos.min_duration_edit);
Interface.max_duration_text = uicontrol('Parent',Interface.panel_signals_plots_delta_snapshots,'Style','text','String','Max Duration (Hz)','Units','normalized','Position',Interface.pos.max_duration_text);
Interface.max_duration_edit = uicontrol('Parent',Interface.panel_signals_plots_delta_snapshots,'Style','edit','String','150','Units','normalized','Position',Interface.pos.max_duration_edit);
Interface.btn_apply4 = uicontrol('Parent',Interface.panel_signals_plots_delta_snapshots,'Style','PushButton','String','Apply','Units','normalized','Position',Interface.pos.btn_apply4,'Callback',@Btn_Apply4);
Interface.bg = uibuttongroup('Parent',Interface.panel_signals_plots_delta_snapshots,'Title','Display Mode','Units','normalized','Position', [0.05 0.875 0.5 0.125]);
Interface.r1 = uicontrol('Parent',Interface.bg,'Style','radiobutton','String','Live','Units','normalized','Position',[0.05 0.05 0.25 0.9]);     
Interface.r2 = uicontrol('Parent',Interface.bg,'Style','radiobutton','String','Navigation','Units','normalized','Position',[0.35 0.05 0.25 0.9]);     
Interface.r3 = uicontrol('Parent',Interface.bg,'Style','radiobutton','String','Mean','Units','normalized','Position',[0.65 0.05 0.25 0.9]);     
Interface.actual_delta_num_text = uicontrol('Parent',Interface.panel_signals_plots_delta_snapshots,'Style','text','String','Delta n° ---','Units','normalized','Position',Interface.pos.actual_delta_num,'Enable','off');
Interface.btn_previous = uicontrol('Parent',Interface.panel_signals_plots_delta_snapshots,'Style','PushButton','String','Previous','Units','normalized','Position',Interface.pos.btn_previous,'Enable','off','Callback',@Btn_Previous);
Interface.btn_next = uicontrol('Parent',Interface.panel_signals_plots_delta_snapshots,'Style','PushButton','String','Next','Units','normalized','Position',Interface.pos.btn_next,'Enable','off','Callback',@Btn_Next);
axes(Interface.PFCdif_snapshot_plot);
Interface.PFCdif_snapshot_plot_lines = plot(0,0,0,0,0,0,0,0,0,0,0,0,0,0);
set(Interface.PFCdif_snapshot_plot_lines(4),'Color','black');
set(Interface.PFCdif_snapshot_plot_lines(5),'Color',[0 0 0.5],'LineStyle','--');
set(Interface.PFCdif_snapshot_plot_lines(6),'Color',[0 0 0.5],'LineStyle','--');
set(Interface.PFCdif_snapshot_plot_lines(7),'Color',[0 0 0.5],'LineStyle','--');
Interface.PFCdif_snapshot_plot.XLabel.String = 'Time (s)';
Interface.PFCdif_snapshot_plot.YLabel.String = 'PFC Signals';

%panel_signal_plots_sleep_scoring
Interface.panel_signals_plots_sleep_scoring = uipanel('Parent',Interface.window,'Title','Sleep Scoring Signals & Hypnogram','TitlePosition','centertop','Units','normalized','Position',Interface.pos.panel_signals_plots_sleep_scoring);

Interface.signals_plot = axes('Parent',Interface.panel_signals_plots_sleep_scoring,'Units','normalized','Position',Interface.pos.signals_plot,'Visible','on','HandleVisibility','on');
Interface.bg2 = uibuttongroup('Parent',Interface.panel_signals_plots_sleep_scoring,'Title','Display Mode','Units','normalized','Position', [0.05 0.875 0.9 0.125]);
Interface.r4 = uicontrol('Parent',Interface.bg2,'Style','radiobutton','String','Signals','Units','normalized','Position',[0.05 0.05 0.25 0.9],'Callback',@RB4);     
Interface.r5 = uicontrol('Parent',Interface.bg2,'Style','radiobutton','String','Hypnogram','Units','normalized','Position',[0.35 0.05 0.25 0.9],'Callback',@RB5);
Interface.slider_zoom = uicontrol('Parent',Interface.panel_signals_plots_sleep_scoring,'Units','normalized','Style','slider','Position',Interface.pos.slider_zoom,'Visible','on','HandleVisibility','on','Callback',@Slider_zoom);
set(Interface.slider_zoom,'Enable','off');
cla(Interface.signals_plot);
axes(Interface.signals_plot)
Interface.signals_plot_lines = plot (0,0,0,0,0,0,0,0,0,0,0,0);
set(Interface.signals_plot_lines(1),'Color','blue')
set(Interface.signals_plot_lines(2),'Color','black');
set(Interface.signals_plot_lines(3),'Color',[0 0.5 0]);
set(Interface.signals_plot_lines(4),'Color','black');
set(Interface.signals_plot_lines(5),'Color','red');
set(Interface.signals_plot_lines(6),'Color','black');
legend(Interface.signals_plot_lines([1 3 5]),'OB Gamma','Theta HPC','Delta HPC');
Interface.signals_plot.XLabel.String = 'Time (s)';
Interface.signals_plot.YLabel.String = '(mV)';

%panel_sleep_scoring
Interface.panel_sleep_scoring = uipanel('Parent',Interface.window,'Title','Sleep Scoring','TitlePosition','centertop','Units','normalized','Position',Interface.pos.panel_sleep_scoring);
Interface.phase_space_plot = axes('Parent',Interface.panel_sleep_scoring,'Units','normalized','Position',Interface.pos.phase_space_plot,'Visible','on','HandleVisibility','on');
axes(Interface.phase_space_plot);
Interface.phase_space_plot_lines = plot(0,0,0,0,0,0,0,0,0,0,0,0,0,0);
set(Interface.phase_space_plot,'xtick',[]);
set(Interface.phase_space_plot,'ytick',[]);
set(Interface.phase_space_plot_lines(7),'LineStyle','None','Marker','o','MarkerSize',15,'MarkerFaceColor',[0.7 1 0.2],'MarkerEdgeColor','k');
set(Interface.phase_space_plot_lines(6),'LineStyle','-','LineWidth',2.5,'Color','k');
set(Interface.phase_space_plot_lines(1),'LineStyle','None','Marker','.','MarkerSize',10,'Color',[0.8 0 0]);
set(Interface.phase_space_plot_lines(2),'LineStyle','None','Marker','.','MarkerSize',10,'Color',[0 0.8 0]);
set(Interface.phase_space_plot_lines(3),'LineStyle','None','Marker','.','MarkerSize',10,'Color',[0 0 0.8]);
set(Interface.phase_space_plot_lines(4),'Color','blue','LineStyle','--');
set(Interface.phase_space_plot_lines(5),'Color','red','LineStyle','--');

Interface.gamma_distribution_plot = axes('Parent',Interface.panel_sleep_scoring,'Units','normalized','Position',Interface.pos.gamma_distribution_plot,'Visible','on','HandleVisibility','on');
axes(Interface.gamma_distribution_plot);
Interface.gamma_distribution_plot_lines = plot(0,0,0,0);
Interface.gamma_distribution_plot.XLabel.String = 'Gamma Power';
set(Interface.gamma_distribution_plot_lines(1),'Color','blue');
set(Interface.gamma_distribution_plot_lines(2),'Color','red','LineStyle','--');

Interface.ratio_distribution_plot = axes('Parent',Interface.panel_sleep_scoring,'Units','normalized','Position',Interface.pos.ratio_distribution_plot,'Visible','on','HandleVisibility','on');
axes(Interface.ratio_distribution_plot);
Interface.ratio_distribution_plot_lines= plot(0,0,0,0,0,0);
Interface.ratio_distribution_plot.YLabel.String = 'Theta/Delta Power';
set(Interface.ratio_distribution_plot_lines(1),'Color','blue');
set(Interface.ratio_distribution_plot_lines(3),'Color','red');
set(Interface.ratio_distribution_plot_lines(2),'Color','blue','LineStyle','--');

Interface.sleep_stage = uicontrol('Parent',Interface.panel_sleep_scoring,'Style','text','String','Sleep Stage','Units','normalized','Position',Interface.pos.sleep_stage);

Interface.slider = uicontrol('Parent',Interface.panel_lecture_controls,'Units','normalized','Style','slider','Position',Interface.pos.slider,'Visible','on','HandleVisibility','on','Callback',@Slider);
set(Interface.slider, 'Min', 2);
set(Interface.slider, 'Max', 19);
set(Interface.slider, 'Value', 10);
set(Interface.slider, 'SliderStep', [1/17 1/17]);

%Create a timer object to fire at 1ms sec intervals
%Specify function update_display for its start and run callbacks

Interface.timer = timer(...
    'ExecutionMode', 'fixedRate', ...           % Run timer repeatedly
    'Period', 0.01, ...                         % Initial period is 1 ms
    'TimerFcn', {@update_display});             % Specify callback function

end


%Callbacks and functions

function Load_Signals(~,~)
global AllData
global Filter
global Interface

[AllData,Filter,Interface] = Load (AllData,Filter,Interface);

end


function Launch_PreProcessing(~,~)
global AllData
global Interface
global Filter

if isfield(AllData.S.S1,'gamma_LFP')
    AllData = PreProcessing (AllData,Interface,Filter);
else
        f = warndlg('Please push Load button before');
end

end


function Btn_T0(~,~)
global Interface
global AllData

AllData.T0 = str2double(get(Interface.btn_t0_edit,'String'));
AllData.T0 = round(AllData.T0 * AllData.fs);

end


function Btn_T1(~,~)
global Interface
global AllData

AllData.T1 = str2double(get(Interface.btn_t1_edit,'String'));
AllData.T1 = round(AllData.T1 * AllData.fs);

end


function Btn_Time_Selection(~,~)
global Interface
global AllData

if ~isempty(AllData.T0) && ~isempty(AllData.T1) && AllData.T0<AllData.T1

    if strcmp(get(Interface.timer, 'Running'), 'on')
        stop(Interface.timer);
        AllData.Implement_counter = 0;
    end

    AllData = time_selection (AllData);
else
    f = warndlg('Please enter values for t0 and t1 before');

end

end


function Btn_Reset(~,~)
global AllData
global Interface

[AllData,Interface] = Reset (AllData,Interface);

end


function Edit_Sup_Prefactor(~,~)
global AllData
global Interface

AllData.sup_prefactor = str2double(get(Interface.Sup_prefactor_edit,'String'));   


end


function Edit_Deep_Prefactor(~,~)
global AllData
global Interface

AllData.deep_prefactor = str2double(get(Interface.Deep_prefactor_edit,'String')); 

end


function Edit_Gamma(~,~)

global AllData 
global Interface

AllData.gamma_treshold_temp = str2double(get(Interface.gamma_edit,'String'));

end


function Edit_Ratio(~,~)

global AllData Interface

AllData.ratio_treshold_temp = str2double(get(Interface.ratio_edit,'String'));

end


function Btn_Apply1(~,~)
global AllData
global Interface

AllData.gamma_treshold = str2double(get(Interface.gamma_edit,'String'));
AllData.ratio_treshold = str2double(get(Interface.ratio_edit,'String')); 

end


function Edit_Delta(~,~)
global AllData
global Interface


AllData.delta_treshold_temp = str2double(get(Interface.delta_edit,'String'));


end


function Btn_Apply2(~,~)
global AllData
global Interface

AllData.delta_treshold = str2double(get(Interface.delta_edit,'String')); 

end


function Btn_Plus_sup(~,~)
global Interface

Interface.offset_sup = Interface.offset_sup + 0.025;

end

function Btn_Minus_sup(~,~)
global Interface

Interface.offset_sup = Interface.offset_sup - 0.025;

end


function Btn_Plus_deep(~,~)
global Interface

Interface.offset_deep = Interface.offset_deep + 0.025;

end

function Btn_Minus_deep(~,~)
global Interface

Interface.offset_deep = Interface.offset_deep - 0.025;

end



function Btn_Apply3(~,~)
global AllData
global Interface

AllData.filter_order = str2double(get(Interface.flt_order_edit,'String'));
AllData.cutoff_freq = str2double(get(Interface.cutoff_freq_edit,'String'));

end

function Btn_Apply4(~,~)
global AllData
global Interface

AllData.min_duration = str2double(get(Interface.min_duration_edit,'String'));
AllData.max_duration= str2double(get(Interface.max_duration_edit,'String'));

end


function Btn_Previous(~,~)
global Interface
global AllData

if Interface.ActualDeltaNum > 1
    Interface.ActualDeltaNum = Interface.ActualDeltaNum - 1;
    set(Interface.actual_delta_num_text,'String',strcat('Delta n° ',num2str(Interface.ActualDeltaNum)));
else
    set(Interface.btn_previous,'Enable','off');
end

if Interface.ActualDeltaNum < size(AllData.Delta_Detection,1) && strcmp(Interface.btn_next.Enable,'off') == 1
    set(Interface.btn_next,'Enable','on');
end

if Interface.ActualDeltaNum > 1 && strcmp(Interface.btn_previous.Enable,'off') == 1
    set(Interface.btn_previous,'Enable','on');
end

end


function Btn_Next(~,~)
global Interface
global AllData

if Interface.ActualDeltaNum < size(AllData.Delta_Detection,1)
    Interface.ActualDeltaNum = Interface.ActualDeltaNum + 1;
    set(Interface.actual_delta_num_text,'String',strcat('Delta n° ',num2str(Interface.ActualDeltaNum)));
else
    set(Interface.btn_next,'Enable','off');
end

if Interface.ActualDeltaNum < size(AllData.Delta_Detection,1) && strcmp(Interface.btn_next.Enable,'off') == 1
    set(Interface.btn_next,'Enable','on');
end

if Interface.ActualDeltaNum > 1 && strcmp(Interface.btn_previous.Enable,'off') == 1
    set(Interface.btn_previous,'Enable','on');
end

end

function RB4(~,~)
global Interface
set(Interface.slider_zoom,'Enable','off');
cla(Interface.signals_plot);
axes(Interface.signals_plot)
Interface.signals_plot_lines = plot (0,0,0,0,0,0,0,0,0,0,0,0);
set(Interface.signals_plot_lines(1),'Color','blue')
set(Interface.signals_plot_lines(2),'Color','black');
set(Interface.signals_plot_lines(3),'Color',[0 0.5 0]);
set(Interface.signals_plot_lines(4),'Color','black');
set(Interface.signals_plot_lines(5),'Color','red');
set(Interface.signals_plot_lines(6),'Color','black');
legend(Interface.signals_plot_lines([1 3 5]),'OB Gamma','Theta HPC','Delta HPC');
Interface.signals_plot.XLabel.String = 'Time (s)';
Interface.signals_plot.YLabel.String = '(mV)';

end

function RB5(~,~)
global Interface

set(Interface.slider_zoom,'Enable','on');
cla(Interface.signals_plot);
axes(Interface.signals_plot);
Interface.signals_plot_lines = plot(0,0,0,0);
Interface.signals_plot.XLabel.String = 'Time (s)';
Interface.signals_plot.XLabel.String = 'Time (s)';
set(Interface.signals_plot, 'YLim', [0 4]);
set(Interface.signals_plot, 'YTick', [1 2 3]);
set(Interface.signals_plot, 'YTickLabel', {'NREM' 'REM' 'WAKE'});
Interface.SleepStagePatches=patch(Interface.signals_plot,[0],[0],[0],'EdgeColor','flat','LineWidth',2);

end


function Btn_Run(~,~)

global AllData
global Interface

if AllData.PreProcessed == 1

    AllData = init_run (AllData,Interface);

    if strcmp(get(Interface.timer, 'Running'), 'off')
        start(Interface.timer);
    end
else
    f = warndlg('Please Push Load and Pre Processing Buttons in the top menu before Run');
end

end


function Slider(~,~)
global Interface

if strcmp(get(Interface.timer, 'Running'), 'on')
    stop(Interface.timer);
end

set(Interface.timer,'Period',round(get(Interface.slider,'value'))/1000);

start(Interface.timer);


end


function Slider_zoom(~,~)
global Interface
global AllData

AllData.AllData.max_duration= get(Interface.slider_zoom,'Value');

end


function update_display(~,~)

global AllData 
global Interface 
global Filter

if AllData.Implement_counter < AllData.N_Implement - (size(AllData.subscripts,2)) 
    
    %update Data  
    AllData = update_data(AllData,Interface,Filter);
    
    %check delta
    [AllData,Interface] = check_Delta(AllData,Interface);
    
    if Interface.Detected ==1
        Interface.counter_sinceDetection = Interface.counter_sinceDetection + 1;
    end
    
    if get(Interface.r1,'Value') == 1
        if Interface.Detected ==1
            [AllData,Interface] = update_snapshot_live(AllData,Interface);
        end
              
    elseif get(Interface.r3,'Value') == 1
        if Interface.Detected ==1
            Interface = update_snapshot_mean(AllData,Interface);
        end
    end
    
    %update plots
    update_plots(AllData,Interface);
    
    %each 312 points (each s)
    if mod(AllData.Implement_counter,312) == 0
        
        %hilebert transforms
        AllData = hilbert_process(AllData);
        
        %update sleep state and update sleep informations
        [AllData,Interface] = check_sleep_state (AllData,Interface);
        
        %update phase space
        [AllData,Interface] = update_phase_space(AllData,Interface);
        
        %update Hypnogram if activated
        if get(Interface.r5,'Value') == 1
            Interface = refresh_hypnogram(AllData,Interface);
        end
        
        %update snapshot plot during navigation mode if activated
        if get(Interface.r2,'Value') == 1
            if ~isempty(AllData.Delta_Detection)
                Interface = update_snapshot_navig(AllData,Interface);
            end
        end
        
    end
      
    %implement new cycle
    AllData.Implement_counter = AllData.Implement_counter + 1;
    AllData.subscripts = AllData.subscripts + 1;
    AllData.t_tmp = AllData.t(AllData.subscripts);
    
else
    if strcmp(get(Interface.timer, 'Running'), 'on')
    stop(Interface.timer);
    end
    detection = AllData.Delta_Detection;
    uisave(detection,strcat(AllData.dname,'/DeltaDetection/onlinedetection.mat'));
end

end


function Btn_Stop(~,~)
global Interface
global AllData

if strcmp(get(Interface.timer, 'Running'), 'on')
    stop(Interface.timer);
    if size (AllData.delta_time_detection,1) ~= size(AllData.delta_durations,1)
    AllData.delta_time_detection(end)=[];
    end

end

end

