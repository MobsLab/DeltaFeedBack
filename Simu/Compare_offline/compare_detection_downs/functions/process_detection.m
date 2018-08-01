function [detection,detection_matrix,detectionCenters] = process_detection (detection,delay,mergeGap)

detection = intervalSet(detection(:,1)*delay, detection(:,2)*delay);
detection = mergeCloseIntervals(detection,mergeGap);
detection = intervalSet(Start(detection)-delay, Start(detection)+delay);
detection_matrix = [Start(detection) Stop(detection)];
detectionCenters = 0.5 .* (detection_matrix(:,1)+detection_matrix(:,2));

end