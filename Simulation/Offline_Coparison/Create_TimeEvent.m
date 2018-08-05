%time_event
time_event = offlinedetection(:,2);
%time_event = detections(:,2);

%extension evt
extens = 'end'; %detection

%filename
filename = 'deltaEnd_off';

%evt
%evt.time = time_event / 1e4; %in sec
evt.time = time_event ; %in sec
for i=1:length(evt.time)
    evt.description{i}= 'deltaStart_on';
end

%create file
CreateEvent(evt, filename, extens);