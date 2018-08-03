function Interface = refresh_hypnogram (Signals,Interface)

set(Interface.slider_zoom,'Max',Signals.t_tmp(end));
if get(Interface.slider_zoom,'Value')>Signals.t_tmp(end)*0.9
    set(Interface.slider_zoom,'Value',Signals.t_tmp(end));
end
Signals.maxSleepstages = get(Interface.slider_zoom, 'Value');
if(Signals.t_tmp(end)<3600)
    set(Interface.slider_zoom,'SliderStep', [1, 1]);
else
    set(Interface.slider_zoom,'SliderStep', [3600/Signals.t_tmp(end), 3600/Signals.t_tmp(end)]);
end

time = Signals.AllResults(:,1);
time=time(time<Signals.maxSleepstages & time>(Signals.maxSleepstages-3600));
sleep = Signals.AllResults(:,2);
sleep=sleep(time<Signals.maxSleepstages & time>(Signals.maxSleepstages-3600));
time=time(sleep>0);
sleep=sleep(sleep>0);

sleep(find(time == 0)) = [];
time(find(time == 0)) = [];

if length(sleep)>1
drawHypnogram(Interface.signals_plot_lines(1),Interface.signals_plot,Interface.SleepStagePatches,time,sleep);
end
 
end