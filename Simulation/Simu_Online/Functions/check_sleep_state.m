%% check_sleep_state 
%This function checks the sleepstate (Wake, NREM, REM) regarding the
%position of the last point in the phase space. 

%It saves this sleep state in AllResults matrix (used for Hypnogram plot), 
%refreshes the SleepState in the phase space panel.

%It also counts episodes total and mean durations, percentages of total 
%time and occurencies to refresh sleep information panel.

function [Data,Interface] = check_sleep_state (Data,Interface)

if ~isempty(Data.gamma_treshold) && ~isempty(Data.ratio_treshold)
    %Checking Wake Stage 
    if Data.S.S1.gamma_power (end) > Data.gamma_treshold
        
        Data.sleep_matrix = [Data.sleep_matrix 3];
        if Data.Hilbert_counter == 1
            Data.AllResults(Data.Hilbert_counter,:) = [round(Data.t_tmp(end)) 3];
        else
            Data.AllResults(Data.Hilbert_counter,:) = [Data.AllResults(Data.Hilbert_counter-1,1)+1 3];
        end
        Data.Wake_counter = Data.Wake_counter +1;
        set(Interface.sleep_stage,'String','WAKE','FontSize',22,'ForegroundColor',[0.8 0 0]);
        if size(Data.sleep_matrix,2)>1
            if Data.sleep_matrix(end) - Data.sleep_matrix(end-1) ~= 0
                Data.Wake_episodes_counter = Data.Wake_episodes_counter + 1;
            end
        end
    %Checking REM Stage
    elseif Data.S.S2.ratio_power (end) > Data.ratio_treshold
        Data.sleep_matrix = [Data.sleep_matrix 2];
        if Data.Hilbert_counter == 1
            Data.AllResults(Data.Hilbert_counter,:) = [round(Data.t_tmp(end)) 2];
        else
            Data.AllResults(Data.Hilbert_counter,:) = [Data.AllResults(Data.Hilbert_counter-1,1)+1 2];
        end
        Data.REM_counter = Data.REM_counter +1;
        set(Interface.sleep_stage,'String','REM','FontSize',22,'ForegroundColor',[0 0.8 0]);
        if size(Data.sleep_matrix,2)>1
            if Data.sleep_matrix(end) - Data.sleep_matrix(end-1) ~= 0
                Data.REM_episodes_counter = Data.REM_episodes_counter + 1;
            end
        end
    %NREM Stage case  
    else 
        Data.sleep_matrix= [Data.sleep_matrix 1];
        if Data.Hilbert_counter == 1
            Data.AllResults(Data.Hilbert_counter,:) = [round(Data.t_tmp(end)) 1];
        else
            Data.AllResults(Data.Hilbert_counter,:) = [Data.AllResults(Data.Hilbert_counter-1,1)+1 1];
        end
        Data.NREM_counter = Data.NREM_counter +1;
        set(Interface.sleep_stage,'String','NREM','FontSize',22,'ForegroundColor',[0 0 0.8]);
        if size(Data.sleep_matrix,2)>1 
            if Data.sleep_matrix(end) - Data.sleep_matrix(end-1) ~= 0
                Data.NREM_episodes_counter = Data.NREM_episodes_counter + 1;
            end
        end
    end
    
    %Computing Statistics 
    
    %Total Stages Durations
    Wake_min = round(Data.Wake_counter * 311 * Data.dt/60,0);
    REM_min = round(Data.REM_counter * 311 * Data.dt/60,0);
    NREM_min = round(Data.NREM_counter * 311 * Data.dt/60,0);
    
    %Reltative percentage over total acquisition time 
    Wake_perc = round(Data.Wake_counter/(Data.Wake_counter+Data.REM_counter+Data.NREM_counter)*100,1);
    REM_perc = round(Data.REM_counter/(Data.Wake_counter+Data.REM_counter+Data.NREM_counter)*100,1);
    NREM_perc = round(Data.NREM_counter/(Data.Wake_counter+Data.REM_counter+Data.NREM_counter)*100,1);
    
    %Refresh Sleep Informations panel
    set(Interface.WAKE_rate_min,'String',num2str(Wake_min));
    set(Interface.WAKE_rate_perc,'String',num2str(Wake_perc));
    set(Interface.WAKE_rate_num,'String',num2str(Data.Wake_episodes_counter));
    set(Interface.WAKE_rate_mean,'String',num2str(round(size(Data.sleep_matrix == 3,2)*311*Data.dt/Data.Wake_episodes_counter)/60,2));
    set(Interface.REM_rate_min,'String',num2str(REM_min));
    set(Interface.REM_rate_perc,'String',num2str(REM_perc));
    set(Interface.REM_rate_num,'String',num2str(Data.REM_episodes_counter));
    set(Interface.REM_rate_mean,'String',num2str(round(size(Data.sleep_matrix == 2,2)*311*Data.dt/Data.REM_episodes_counter)/60,2));
    set(Interface.NREM_rate_min,'String',num2str(NREM_min));
    set(Interface.NREM_rate_perc,'String',num2str(NREM_perc));
    set(Interface.NREM_rate_num,'String',num2str(Data.NREM_episodes_counter));
    set(Interface.NREM_rate_mean,'String',num2str(round(size(Data.sleep_matrix == 1,2)*311*Data.dt/Data.NREM_episodes_counter)/60,2));
    
    
    
end
    
end





