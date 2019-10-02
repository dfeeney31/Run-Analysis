function mult_avg = genAverageAngles(data, locs, len, conf)
% -----------------------------------------------------------------------
% Function to calculate the N x M matrices where N = cycles and M = time
% points. This will then be used to plot concept-specific averages
% -----------------------------------------------------------------------
% data: cell array with joint/segment data
% locs: locations where to start average
% len: specify the length of the slice
% ------------------------------------------------------------------------
% Output is angles_mat
% where all angles are calculated for all three planes of motion and stored in a
% tensor with order: ab/adduction, int/external rotation, flexion/extension
% Alternatively, run this code for each column and save
% -----------------------------------------------------------------------
% This Matlab code written by Dan Feeney 11/19/18
% -----------------------------------------------------------------------

% Preallocate a 3 X # locations X # length tensor to store ab, int rot,
% dorsi data
lAnkle_ab = zeros(length(locs),len+1);
rAnkle_ab = zeros(length(locs),len+1);
lKnee_ab = zeros(length(locs),len+1);
rKnee_ab = zeros(length(locs),len+1);
lHip_ab = zeros(length(locs),len+1);
rHip_ab = zeros(length(locs),len+1);

lAnkle_int = zeros(length(locs),len+1);
rAnkle_int = zeros(length(locs),len+1);
lKnee_int = zeros(length(locs),len+1);
rKnee_int = zeros(length(locs),len+1);
lHip_int = zeros(length(locs),len+1);
rHip_int = zeros(length(locs),len+1);

lAnkle_flex = zeros(length(locs),len+1);
rAnkle_flex = zeros(length(locs),len+1);
lKnee_flex = zeros(length(locs),len+1);
rKnee_flex = zeros(length(locs),len+1);
lHip_flex = zeros(length(locs),len+1);
rHip_flex = zeros(length(locs),len+1);

% Averages by motion
%Abduction
for i = 1:length(locs)
    try
        lAnkle_ab(i,:) =  data.L_ankle(1,floor(locs(i)):floor(locs(i)+len));
        rAnkle_ab(i,:) =  data.R_ankle(1,floor(locs(i)):floor(locs(i)+len));
        lKnee_ab(i,:) =  data.L_knee(1,floor(locs(i)):floor(locs(i)+len));
        rKnee_ab(i,:) =  data.R_knee(1,floor(locs(i)):floor(locs(i)+len));
        lHip_ab(i,:) =  data.L_hip(1,floor(locs(i)):floor(locs(i)+len));
        rHip_ab(i,:) =  data.R_hip(1,floor(locs(i)):floor(locs(i)+len));
        
        lAnkle_int(i,:) =  data.L_ankle(2,floor(locs(i)):floor(locs(i)+len));
        rAnkle_int(i,:) =  data.R_ankle(2,floor(locs(i)):floor(locs(i)+len));
        lKnee_int(i,:) =  data.L_knee(2,floor(locs(i)):floor(locs(i)+len));
        rKnee_int(i,:) =  data.R_knee(2,floor(locs(i)):floor(locs(i)+len));
        lHip_int(i,:) =  data.L_hip(2,floor(locs(i)):floor(locs(i)+len));
        rHip_int(i,:) =  data.R_hip(2,floor(locs(i)):floor(locs(i)+len));
        
        lAnkle_flex(i,:) =  data.L_ankle(3,floor(locs(i)):floor(locs(i)+len));
        rAnkle_flex(i,:) =  data.R_ankle(3,floor(locs(i)):floor(locs(i)+len));
        lKnee_flex(i,:) =  data.L_knee(3,floor(locs(i)):floor(locs(i)+len));
        rKnee_flex(i,:) =  data.R_knee(3,floor(locs(i)):floor(locs(i)+len));
        lHip_flex(i,:) =  data.L_hip(3,floor(locs(i)):floor(locs(i)+len));
        rHip_flex(i,:) =  data.R_hip(3,floor(locs(i)):floor(locs(i)+len));
    catch
        fprintf('Skipped.\n',i)
    end
    
end


% Generic reshape below to make each set of angles stored as a # hits x
% time points matrix

angles.lAnkle.AB = lAnkle_ab;
angles.lAnkle.INT = lAnkle_int;
angles.lAnkle.DORSI = lAnkle_flex;
angles.rAnkle.AB = rAnkle_ab;
angles.rAnkle.INT = rAnkle_int;
angles.rAnkle.DORSI = rAnkle_flex;
angles.lKnee.AB = lKnee_ab;
angles.lKnee.INT = lKnee_int;
angles.lKnee.FLEX = lKnee_flex;
angles.rKnee.AB = rKnee_ab;
angles.rKnee.INT = rKnee_int;
angles.rKnee.FLEX = rKnee_flex;
angles.lHip.AB = lHip_ab;
angles.lHip.INT = lHip_int;
angles.lHip.FLEX = lHip_flex;
angles.rHip.AB = rHip_ab;
angles.rHip.INT = rHip_int;
angles.rHip.FLEX = rHip_flex;

assignin('base',strcat('angles_',conf,'_proc'),angles);

end