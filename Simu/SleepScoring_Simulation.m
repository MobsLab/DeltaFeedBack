%SleepScoring_Simulation 
%22/07/2018
%Adrien Bertolo 

%This GUI simulates Intan live acquisition reading OB, dHPC, PFCsup and PFCdeep .mat files.
%It performs Sleep Scoring and Delta Waves detection.

%Timer object calls Update_Display Callback function, in which other
%Tool_Functions (see folder) are called to update data, perform treatments
%and display results.


function SleepScoring_Simulation


global Interface
global Data

addpath(genpath(pwd));

%Data properties 

Data.Fs = [];                                       %sampling frequency of raw data init
Data.DB_duration = [];                              %datablock duration init 

Data.S = struct;                                    %structure containing signals
Data.Path = struct;                                 %structure containing signals paths


Data.Implement_counter = 0;                         %counting Data implementations already implemented

Data.Hilbert_counter = 0;                           %counting hilbert transforms already computed 


Data.delta_points_counter = 0;                      %counting current delta wave duration (in number of points)
Data.Delta_Detection = [];                          
Data.delta_time_detection = [];                     %times(in sec) at which delta wave are detected
Data.delta_durations = [];                          %durations of detected delta waves

Data.sleep_state = [];                              %sleep state (SWS, REM, WAKE);

Data.ratio_treshold_temp = 0.6;
Data.gamma_treshold_temp= -1.6;
Data.delta_treshold_temp= 0.3;

Data.sup_prefactor = 1;
Data.deep_prefactor = 1;

Data.S.S1.gamma_power = [];
Data.S.S2.theta_power = [];
Data.S.S2.delta_power = [];
Data.S.S2.ratio_power = [];

%Interface properties
Interface.time_window = 3;                          %time window for sleep scoring computations (s)

Interface.vline_gamma = [];
Interface.hline_ratio = [];
Interface.hline_delta = [];
Interface.Snapshot = [];
Interface.Detectionline1 = [];
Interface.Detectionline2 = [];

Interface.offset = 1;

%Positions
Interface.pos.window = [0 0 1 1];

Interface.pos.panel_sampling = [0.4375 0.85 0.125 0.15];
Interface.pos.sampling_freq_text = [0.05 0.6 0.5 0.2];
Interface.pos.sampling_freq_edit = [0.55 0.6 0.3 0.2];
Interface.pos.datablock_size_text = [0.05 0.3 0.5 0.2];
Interface.pos.datablock_size_edit = [0.55 0.3 0.3 0.2];

Interface.pos.panel_lecture_controls = [0.4375 0.7 0.125 0.15];
Interface.pos.btn_run = [0.05 0.5 0.4 0.4];
Interface.pos.btn_stop = [0.55 0.5 0.4 0.4];
Interface.pos.slider = [0 0 1 1];

Interface.pos.panel_time_selection = [0.4375 0.55 0.125 0.15];
Interface.pos.btn_t0 = [0.05 0.6 0.4 0.3];
Interface.pos.btn_t1 = [0.55 0.6 0.4 0.3];
Interface.pos.btn_time_selection = [0.05 0.3 0.9 0.2];
Interface.pos.btn_reset = [0.05 0.05 0.9 0.2];

Interface.pos.panel_tresholds_selection = [0.4375 0.275 0.125 0.225];
Interface.pos.gamma_text = [0.025 0.85 0.5 0.1];
Interface.pos.gamma_edit = [0.7 0.85 0.25 0.1];
Interface.pos.ratio_text = [0.025 0.7 0.5 0.1];
Interface.pos.ratio_edit = [0.7 0.7 0.25 0.1];
Interface.pos.btn_apply1 = [0.25 0.55 0.5 0.1];
Interface.pos.detection_checkbox = [0.1 0.32 0.8 0.1];
Interface.pos.delta_text = [0.05 0.2 0.5 0.1];
Interface.pos.delta_edit = [0.7 0.2 0.25 0.1];
Interface.pos.btn_apply2 = [0.25 0.05 0.5 0.1];

Interface.pos.panel_sleep_informations = [0.4375 0.05 0.125 0.225];
Interface.pos.WAKE_text = [0.05 0.75 0.4 0.2];
Interface.pos.WAKE_rate = [0.55 0.75 0.4 0.2];
Interface.pos.REM_text = [0.05 0.4 0.4 0.2];
Interface.pos.REM_rate = [0.55 0.4 0.4 0.2];
Interface.pos.SWS_text = [0.05 0.05 0.4 0.2];
Interface.pos.SWS_rate = [0.55 0.05 0.4 0.2];

Interface.pos.panel_signals_plots_delta_detection = [0.025 0.55 0.4 0.45];
Interface.pos.PFCdif_plot = [0.1 0.1 0.8 0.75];
Interface.pos.prefactors_checkbox = [0.1 0.875 0.3 0.1];
Interface.pos.Sup_prefactor_text = [0.4 0.85 0.1 0.1];
Interface.pos.Sup_prefactor_edit = [0.5 0.875 0.1 0.1];
Interface.pos.Deep_prefactor_text = [0.65 0.85 0.1 0.1];
Interface.pos.Deep_prefactor_edit = [0.8 0.875 0.1 0.1];
Interface.pos.btn_plus = [0.925 0.5 0.05 0.06];
Interface.pos.btn_minus = [0.925 0.4 0.05 0.06];


Interface.pos.panel_signals_plots_delta_snapshots = [0.025 0.05 0.4 0.45];
Interface.pos.delta_snapshots_plot = [0.1 0.1 0.8 0.75];

Interface.pos.panel_signals_plots_sleep_scoring = [0.575 0.55 0.4 0.45];
Interface.pos.gamma_plot = [0.1 0.7 0.8 0.25];
Interface.pos.theta_plot = [0.1 0.4 0.8 0.25];
Interface.pos.delta_plot = [0.1 0.1 0.8 0.25];

Interface.pos.panel_sleep_scoring = [0.575 0.05 0.4 0.45];
Interface.pos.phase_space_plot = [0.3 0.45 0.65 0.5];
Interface.pos.gamma_distribution_plot = [0.3 0.08 0.65 0.3];
Interface.pos.ratio_distribution_plot = [0.1 0.45 0.15 0.5];
Interface.pos.sleep_stage = [0.05 0.1 0.2 0.1];

Interface.pos.slider = [0.05 0.1 0.9 0.25];

Interface.window = figure('MenuBar','none','Units','normalized','Position',Interface.pos.window);


%menu
Interface.menu.load_signals = uimenu(Interface.window,'Text','Load Signals','MenuSelectedFcn',@Load_Signals);
Interface.menu.preprocessing = uimenu(Interface.window,'Text','Pre Processing');
Interface.menu.prefacors = uimenu(Interface.menu.preprocessing,'Text','Determine Prefactors','MenuSelectedFcn',@Determine_Prefactors);
Interface.menu.treshold = uimenu(Interface.menu.preprocessing,'Text','Determine Delta Treshold','MenuSelectedFcn',@Determine_Delta_Treshold);

%make interface

%panel_sampling 
Interface.panel_sampling = uipanel('Parent',Interface.window,'Title','Sampling Settings','TitlePosition','centertop','Units','normalized','Position',Interface.pos.panel_sampling);
Interface.sampling_freq_text = uicontrol('Parent',Interface.panel_sampling,'Style','text','String','Samp Freq','Units','normalized','Position',Interface.pos.sampling_freq_text);
Interface.sampling_freq_edit = uicontrol('Parent',Interface.panel_sampling,'Style','edit','Units','normalized','Position',Interface.pos.sampling_freq_edit,'Callback',@Edit_Sampling_Freq);
Interface.datablock_size_text = uicontrol('Parent',Interface.panel_sampling,'Style','text','String','Datablock Size','Units','normalized','Position',Interface.pos.datablock_size_text);
Interface.datablock_size_edit = uicontrol('Parent',Interface.panel_sampling,'Style','edit','Units','normalized','Position',Interface.pos.datablock_size_edit,'Callback',@Edit_Datablock_Size);

%panel_lecture_controls
Interface.panel_lecture_controls = uipanel('Parent',Interface.window,'Title','Lecture Controls','TitlePosition','centertop','Units','normalized','Position',Interface.pos.panel_lecture_controls);
Interface.btn_run = uicontrol('Parent',Interface.panel_lecture_controls,'Units','normalized','Style','PushButton','String','Run','Position',Interface.pos.btn_run,'Callback',@Btn_Run);
Interface.btn_stop = uicontrol('Parent',Interface.panel_lecture_controls,'Units','normalized','Style','PushButton','String','Stop','Position',Interface.pos.btn_stop,'Callback',@Btn_Stop);

%panel time_selection
Interface.panel_time_selection = uipanel('Parent',Interface.window,'Title','Time Selection','TitlePosition','centertop','Units','normalized','Position',Interface.pos.panel_time_selection);
Interface.btn_t0_edit = uicontrol('Parent',Interface.panel_time_selection,'Units','normalized','Style','edit','String','t0','Position',Interface.pos.btn_t0,'Callback',@Btn_T0);
Interface.btn_t1_edit = uicontrol('Parent',Interface.panel_time_selection,'Units','normalized','Style','edit','String','t1','Position',Interface.pos.btn_t1,'Callback',@Btn_T1);
Interface.btn_time_selection = uicontrol('Parent',Interface.panel_time_selection,'Units','normalized','Style','PushButton','String','Time Selection','Position',Interface.pos.btn_time_selection,'Callback',@Btn_Time_Selection);
Interface.btn_time_selection = uicontrol('Parent',Interface.panel_time_selection,'Units','normalized','Style','PushButton','String','Reset','Position',Interface.pos.btn_reset,'Callback',@Btn_Reset);

%panel treshold_selection
Interface.panel_tresholds_selection = uipanel('Parent',Interface.window,'Title','Tresholds Settings','TitlePosition','centertop','Units','normalized','Position',Interface.pos.panel_tresholds_selection);
Interface.gamma_text = uicontrol('Parent',Interface.panel_tresholds_selection,'Style','text','String','Gamma Treshold','Units','normalized','Position',Interface.pos.gamma_text);
Interface.gamma_edit = uicontrol('Parent',Interface.panel_tresholds_selection,'Style','edit','String','-1.6','Units','normalized','Position',Interface.pos.gamma_edit,'Callback',@Edit_Gamma);
Interface.ratio_text = uicontrol('Parent',Interface.panel_tresholds_selection,'Style','text','String','Ratio Treshold','Units','normalized','Position',Interface.pos.ratio_text);
Interface.ratio_edit = uicontrol('Parent',Interface.panel_tresholds_selection,'Style','edit','String','0.6','Units','normalized','Position',Interface.pos.ratio_edit,'Callback',@Edit_Ratio);
Interface.btn_apply1 = uicontrol('Parent',Interface.panel_tresholds_selection,'Style','PushButton','String','Apply','Units','normalized','Position',Interface.pos.btn_apply1,'Callback',@Btn_Apply1);
Interface.detection_checkbox = uicontrol('Parent',Interface.panel_tresholds_selection,'Style','checkbox','String','Start Detection','Units','normalized','Position',Interface.pos.detection_checkbox);
Interface.delta_text = uicontrol('Parent',Interface.panel_tresholds_selection,'Style','text','String','Delta Treshold','Units','normalized','Position',Interface.pos.delta_text);
Interface.delta_edit = uicontrol('Parent',Interface.panel_tresholds_selection,'Style','edit','String','0.3','Units','normalized','Position',Interface.pos.delta_edit,'Callback',@Edit_Delta);
Interface.btn_apply2 = uicontrol('Parent',Interface.panel_tresholds_selection,'Style','PushButton','String','Apply','Units','normalized','Position',Interface.pos.btn_apply2,'Callback',@Btn_Apply2);

%planel sleep informations
Interface.panel_sleep_informations = uipanel('Parent',Interface.window,'Title','Sleep Informations','TitlePosition','centertop','Units','normalized','Position',Interface.pos.panel_sleep_informations);
Interface.WAKE_text = uicontrol('Parent',Interface.panel_sleep_informations,'Style','text','String','Wake (%)','Units','normalized','Position',Interface.pos.WAKE_text);
Interface.WAKE_rate = uicontrol('Parent',Interface.panel_sleep_informations,'Style','text','String','0','Units','normalized','Position',Interface.pos.WAKE_rate);
Interface.REM_text = uicontrol('Parent',Interface.panel_sleep_informations,'Style','text','String','REM (%)','Units','normalized','Position',Interface.pos.REM_text);
Interface.REM_rate = uicontrol('Parent',Interface.panel_sleep_informations,'Style','text','String','0','Units','normalized','Position',Interface.pos.REM_rate);
Interface.SWS_text = uicontrol('Parent',Interface.panel_sleep_informations,'Style','text','String','SWS (%)','Units','normalized','Position',Interface.pos.SWS_text);
Interface.SWS_rate = uicontrol('Parent',Interface.panel_sleep_informations,'Style','text','String','0','Units','normalized','Position',Interface.pos.SWS_rate);

%panel signals_plots_delta_detection
Interface.panel_signals_plots_delta_detection = uipanel('Parent',Interface.window,'Title','Delta Detection Signals','TitlePosition','centertop','Units','normalized','Position',Interface.pos.panel_signals_plots_delta_detection);

Interface.PFCdif_plot = axes('Parent',Interface.panel_signals_plots_delta_detection,'Units','normalized','Position',Interface.pos.PFCdif_plot,'Visible','on','HandleVisibility','on');
axes(Interface.PFCdif_plot);
Interface.PFCdif_plot.XLabel.String = 'Time (s)';
Interface.PFCdif_plot.YLabel.String = 'PFC Signals';
Interface.PFCdif_plot_lines = plot(0,0,0,0,0,0,0,0,0,0);
set(Interface.PFCdif_plot_lines(1),'Color','blue');
set(Interface.PFCdif_plot_lines(2),'Color',[0 0.5 0]);
set(Interface.PFCdif_plot_lines(3),'Color','red');
set(Interface.PFCdif_plot_lines(4),'Color','black');
set(Interface.PFCdif_plot_lines(5),'Color',[0 0 0.5],'LineStyle','--');
Interface.set_prefactors_checkbox = uicontrol('Parent',Interface.panel_signals_plots_delta_detection,'Style','checkbox','String','Set Prefactors','Units','normalized','Position',Interface.pos.prefactors_checkbox);
Interface.Sup_prefactor_text = uicontrol('Parent',Interface.panel_signals_plots_delta_detection,'Style','text','String','PFC sup','Units','normalized','Position',Interface.pos.Sup_prefactor_text);
Interface.Sup_prefactor_edit = uicontrol('Parent',Interface.panel_signals_plots_delta_detection,'Style','edit','String','1','Units','normalized','Position',Interface.pos.Sup_prefactor_edit,'Callback',@Edit_Sup_Prefactor);
Interface.Deep_prefactor_text = uicontrol('Parent',Interface.panel_signals_plots_delta_detection,'Style','text','String','PFC deep','Units','normalized','Position',Interface.pos.Deep_prefactor_text);
Interface.Deep_prefactor_edit = uicontrol('Parent',Interface.panel_signals_plots_delta_detection,'Style','edit','String','1','Units','normalized','Position',Interface.pos.Deep_prefactor_edit,'Callback',@Edit_Deep_Prefactor);
Interface.btn_plus = uicontrol('Parent',Interface.panel_signals_plots_delta_detection,'Style','PushButton','String','+','Units','normalized','Position',Interface.pos.btn_plus,'Callback',@Btn_Plus);
Interface.btn_minus = uicontrol('Parent',Interface.panel_signals_plots_delta_detection,'Style','PushButton','String','-','Units','normalized','Position',Interface.pos.btn_minus,'Callback',@Btn_Minus);

%panel_signal_plots_delta_snapshots
Interface.panel_signals_plots_delta_snapshots = uipanel('Parent',Interface.window,'Title','Last Delta Wave detected','TitlePosition','centertop','Units','normalized','Position',Interface.pos.panel_signals_plots_delta_snapshots);

Interface.PFCdif_snapshot_plot = axes('Parent',Interface.panel_signals_plots_delta_snapshots,'Units','normalized','Position',Interface.pos.delta_snapshots_plot,'Visible','on','HandleVisibility','on');
axes(Interface.PFCdif_snapshot_plot);
Interface.PFCdif_snapshot_plot.XLabel.String = 'Time (s)';
Interface.PFCdif_snapshot_plot.YLabel.String = 'PFC Signals';
Interface.PFCdif_snapshot_plot_lines = plot(0,0,0,0,0,0,0,0,0,0,0,0,0,0);
set(Interface.PFCdif_snapshot_plot_lines(1),'Color','blue');
set(Interface.PFCdif_snapshot_plot_lines(2),'Color',[0 0.5 0]);
set(Interface.PFCdif_snapshot_plot_lines(3),'Color','red');
set(Interface.PFCdif_snapshot_plot_lines(4),'Color','black');
set(Interface.PFCdif_snapshot_plot_lines(5),'Color',[0 0 0.5]);
set(Interface.PFCdif_snapshot_plot_lines(6),'Color',[0 0 0.5]);
set(Interface.PFCdif_snapshot_plot_lines(7),'Color',[0 0 0.5]);

%panel_signal_plots_sleep_scoring
Interface.panel_signals_plots_sleep_scoring = uipanel('Parent',Interface.window,'Title','Sleep Scoring Signals','TitlePosition','centertop','Units','normalized','Position',Interface.pos.panel_signals_plots_sleep_scoring);

Interface.gamma_plot = axes('Parent',Interface.panel_signals_plots_sleep_scoring,'Units','normalized','Position',Interface.pos.gamma_plot,'Visible','on','HandleVisibility','on');
axes(Interface.gamma_plot)
Interface.gamma_plot_lines = plot(0,0,0,0);
Interface.gamma_plot.YLabel.String = 'OB Gamma';
set(Interface.gamma_plot,'xtick',[]);
set(Interface.gamma_plot_lines(1),'Color','blue')
set(Interface.gamma_plot_lines(2),'Color','black');

Interface.theta_plot = axes('Parent',Interface.panel_signals_plots_sleep_scoring,'Units','normalized','Position',Interface.pos.theta_plot,'Visible','on','HandleVisibility','on');
axes(Interface.theta_plot)
Interface.theta_plot_lines = plot(0,0,0,0);
Interface.theta_plot.YLabel.String = 'Theta HPC';
set(Interface.theta_plot,'xtick',[]);
set(Interface.theta_plot_lines(1),'Color',[0 0.5 0]);
set(Interface.theta_plot_lines(2),'Color','black');

Interface.delta_plot = axes('Parent',Interface.panel_signals_plots_sleep_scoring,'Units','normalized','Position',Interface.pos.delta_plot,'Visible','on','HandleVisibility','on');
axes(Interface.delta_plot)
Interface.delta_plot_lines = plot(0,0,0,0);
Interface.delta_plot.YLabel.String = 'Delta HPC';
Interface.delta_plot.XLabel.String = 'Time (s)';
set(Interface.delta_plot_lines(1),'Color','red');
set(Interface.delta_plot_lines(2),'Color','black');

%panel_sleep_scoring
Interface.panel_sleep_scoring = uipanel('Parent',Interface.window,'Title','Sleep Scoring','TitlePosition','centertop','Units','normalized','Position',Interface.pos.panel_sleep_scoring);
Interface.phase_space_plot = axes('Parent',Interface.panel_sleep_scoring,'Units','normalized','Position',Interface.pos.phase_space_plot,'Visible','on','HandleVisibility','on');
axes(Interface.phase_space_plot);
Interface.phase_space_plot_lines = plot(0,0,0,0,0,0);
set(Interface.phase_space_plot_lines(1),'LineStyle','None','Marker','*');
set(Interface.phase_space_plot_lines(2),'Color','blue','LineStyle','--');
set(Interface.phase_space_plot_lines(3),'Color','red','LineStyle','--');

Interface.gamma_distribution_plot = axes('Parent',Interface.panel_sleep_scoring,'Units','normalized','Position',Interface.pos.gamma_distribution_plot,'Visible','on','HandleVisibility','on');
axes(Interface.gamma_distribution_plot);
Interface.gamma_distribution_plot_lines = plot(0,0,0,0);
Interface.gamma_distribution_plot.XLabel.String = 'Gamma Power';
set(Interface.gamma_distribution_plot_lines(1),'Color','blue');
set(Interface.gamma_distribution_plot_lines(2),'Color','red','LineStyle','--');

Interface.ratio_distribution_plot = axes('Parent',Interface.panel_sleep_scoring,'Units','normalized','Position',Interface.pos.ratio_distribution_plot,'Visible','on','HandleVisibility','on');
axes(Interface.ratio_distribution_plot);
Interface.ratio_distribution_plot_lines= plot(0,0,0,0);
Interface.ratio_distribution_plot.YLabel.String = 'Theta/Delta Power';
set(Interface.ratio_distribution_plot_lines(1),'Color','blue');
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
global Data
global Filter

Data = Load (Data,Filter);

end


function Determine_Prefactors(~,~)
global Data
global Interface

Data.deep_prefactor = 1;

sup_temp = Data.S.S3.PFCsup_raw;
deep_temp = Data.S.S3.PFCdeep_raw;

clear distance
k=1;

for i=0.1:0.1:4
    distance(k)=std(deep_temp - i * sup_temp);
    k=k+1;
end

Data.sup_prefactor = find(distance==min(distance))*0.1;

set(Interface.Sup_prefactor_edit,'String',num2str(Data.sup_prefactor));
set(Interface.Deep_prefactor_edit,'String',num2str(Data.deep_prefactor));

end


function Determine_Delta_Treshold(~,~)
global Data 
global Interface

sup_temp = Data.S.S3.PFCsup_raw;
deep_temp = Data.S.S3.PFCdeep_raw;
diff_temp = deep_temp - sup_temp;

[A, B] = butter(4, 4/(Data.fs/2));
diff_temp_filtered = filtfilt(A,B,diff_temp);

% b = fir1(1024,[1 12]*(2/Data.fs));
% diff_temp_filtered = filtfilt(b,1,diff_temp);

pos_diff_temp = max(diff_temp_filtered,0);
std_diff = std(pos_diff_temp(pos_diff_temp>0));                                 % std that determines thresholds

Data.delta_treshold_temp = 2 * std_diff;
set(Interface.delta_edit,'String',num2str(Data.delta_treshold_temp));

end


function Edit_Sampling_Freq(~,~)
global Interface
global Data

Data.Fs = str2double(get(Interface.sampling_freq_edit,'String'));               %sampling frequency raw signal
Data.Dt = 1/Data.Fs;                                                            %time between 2 samples raw signal

end

function Edit_Datablock_Size(~,~)
global Interface
global Data
global Filter 

Data.DB_duration = str2double(get(Interface.datablock_size_edit,'String'));     %duration of datablocks (points) on which we compute the mean to downsample signals
Data.fs = Data.Fs/Data.DB_duration;                                             %sampling frequency downsampled signal
Data.dt = 1/Data.fs;                                                            %time between 2 samples downsampled signal
Interface.time_implement = Data.dt;

%Fitlers definition 
Filter.gamma = designfilt('bandpassfir','FilterOrder',332,'CutoffFrequency1', 50,'CutoffFrequency2',70,'SampleRate',Data.fs); 
Filter.theta = designfilt('bandpassfir','FilterOrder',332,'CutoffFrequency1', 6,'CutoffFrequency2',12,'SampleRate',Data.fs);
Filter.delta = designfilt('bandpassfir','FilterOrder',332,'CutoffFrequency1', 1,'CutoffFrequency2',12,'SampleRate',Data.fs); 
[Filter.PFCdif_A, Filter.PFCdif_B] = butter(2, 4/(Data.fs/2));

end


function Btn_T0(~,~)
global Interface
global Data

Data.T0 = str2double(get(Interface.btn_t0_edit,'String'));
Data.T0 = round(Data.T0 * Data.fs);

end


function Btn_T1(~,~)
global Interface
global Data

Data.T1 = str2double(get(Interface.btn_t1_edit,'String'));
Data.T1 = round(Data.T1 * Data.fs);

end


function Btn_Time_Selection(~,~)
global Data
global Filter
global Interface

if strcmp(get(Interface.timer, 'Running'), 'on')
    stop(Interface.timer);
    Data.Implement_counter = 0;
end

Data = time_selection (Data,Filter,Interface);

end


function Btn_Reset(~,~)
global Data
global Interface

[Data,Interface] = Reset (Data,Interface);

end


function Edit_Sup_Prefactor(~,~)
global Data
global Interface

Data.sup_prefactor = str2double(get(Interface.Sup_prefactor_edit,'String'));   


end


function Edit_Deep_Prefactor(~,~)
global Data
global Interface

Data.deep_prefactor = str2double(get(Interface.Deep_prefactor_edit,'String')); 

end


function Edit_Gamma(~,~)

global Data 
global Interface
global Filter

Data.gamma_treshold_temp = str2double(get(Interface.gamma_edit,'String'));
Data.S.S1.gamma_filtered = filtfilt(Filter.gamma,Data.S.S1.gamma);
end


function Edit_Ratio(~,~)

global Data Interface

Data.ratio_treshold_temp = str2double(get(Interface.ratio_edit,'String'));

end


function Btn_Apply1(~,~)
global Data
global Interface

Data.gamma_treshold = str2double(get(Interface.gamma_edit,'String'));
Data.ratio_treshold = str2double(get(Interface.ratio_edit,'String')); 

end


function Edit_Delta(~,~)
global Data
global Interface


Data.delta_treshold_temp = str2double(get(Interface.delta_edit,'String'));


end


function Btn_Apply2(~,~)
global Data
global Interface

Data.delta_treshold = str2double(get(Interface.delta_edit,'String')); 

end


function Btn_Plus(~,~)
global Interface

Interface.offset = Interface.offset + 0.025;

end

function Btn_Minus(~,~)
global Interface

Interface.offset = Interface.offset - 0.025;

end


function Btn_Run(~,~)

global Data
global Interface

Data = init_run (Data,Interface);

if strcmp(get(Interface.timer, 'Running'), 'off')
    start(Interface.timer);
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


function update_display(~,~)

global Data 
global Interface 
global Filter

if Data.Implement_counter < Data.N_Implement - (size(Data.subscripts,2)) 
    
    %update Data  
    Data = update_data(Data,Interface,Filter);
    
    %check delta
    Data = check_Delta(Data,Interface);

    
    %update plots
    update_plots(Data,Interface);
    
    %each 1000 points (each 3s)
    if mod(Data.Implement_counter,1000) == 0
        
        %hilebert transforms
        Data = hilbert_process(Data);
        
        %update sleep state display
        %Data = check_sleep_state (Data);
        
        %compute distributions
        [Data.S.S1.gamma_prob,Data.S.S1.gamma_value] = ksdensity (Data.S.S1.gamma_power);
        [Data.S.S2.ratio_prob,Data.S.S2.ratio_value] = ksdensity (Data.S.S2.ratio_power);
        
        %update phase space
        update_phase_space(Data,Interface);
        
    end
    
    %update sleep infos pannel 
    
    %update_sleep_infos(Data,Interface);
    
    %implement new cycle
    Data.Implement_counter = Data.Implement_counter+1;
    Data.subscripts = Data.subscripts + Interface.time_implement * Data.fs;
    Data.t_tmp = Data.t_tmp + Interface.time_implement;
    
else
    if strcmp(get(Interface.timer, 'Running'), 'on')
    stop(Interface.timer);
    end

    if size (Data.delta_time_detection,1) ~= size(Data.delta_durations,1)
    Data.delta_time_detection(end)=[];
    end
    
    Delta_Detection = [Data.delta_time_detection (Data.delta_time_detection + Data.delta_durations)];
    save('Delta_Detection.mat','Delta_Detection');
end

end



function Btn_Stop(~,~)
global Interface
global Data
if strcmp(get(Interface.timer, 'Running'), 'on')
    stop(Interface.timer);
end

if size (Data.delta_time_detection,1) ~= size(Data.delta_durations,1)
    Data.delta_time_detection(end)=[];
end

Delta_Detection = [Data.delta_time_detection (Data.delta_time_detection + Data.delta_durations)];
save('Delta_Detection.mat','Delta_Detection');

end

