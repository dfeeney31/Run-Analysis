%% Analysis of the treadmill data
clear
addpath('C:\Users\Daniel.Feeney\Documents\Trail Run\Run Code')
data = importForcesTM('C:\Users\Daniel.Feeney\Dropbox (Boa)\Treadmill TMM\Data\WalkTest_15 - Report1.txt');

%% Clean data for NaNs
data.ForceZ(isnan(data.ForceZ))=0;
data.ForceY(isnan(data.ForceY))=0;
data.ForceX(isnan(data.ForceX))=0;
%% Filter data
fq = 1000; %Sampling frequency
fc = 20; %Cutoff frequency

[b,a] = butter(2,fc/(fq/2),'low'); %second order BW filter, filtfilt doubles the order
filt_forceZ = filtfilt(b,a,data.ForceZ);
filt_forceY = -1 .* filtfilt(b,a,data.ForceY); %This will be used for the M/L and A/P forces
filt_forceX = filtfilt(b,a,data.ForceX); %This will be used for the M/L and A/P forces

filt_forceZ(filt_forceZ<0) = 0; %detrend the Z signals so they start at 0

%% 
% Need to take every other foot step to demark left and right separately. 
%% make plots
% figure
% plot(filt_forceZ)
% title('Z Force')
% 
% figure
% plot(filt_forceY)
% title('Y Force')
% 
% figure
% plot(filt_forceX)
% title('X Force')

%% Find peaks in force and concatenate
[pks,locs] = findpeaks(filt_forceZ, 'minpeakdistance', 250, 'MinPeakProminence',100); %Find locations and values of peaks

%% one side
vertForce = zeros(floor(length(pks)/2),301); % preallocate
APforce = zeros(floor(length(pks)/2),301);
MLforce = zeros(floor(length(pks)/2),301);
for peak = 2:2:length(pks)
    tmp_location = locs(peak);
    vertForce(floor(peak/2),:) = filt_forceZ(tmp_location - 150 : tmp_location +150);   
    APforce(floor(peak/2),:) = filt_forceY(tmp_location - 150 : tmp_location +150); 
    MLforce(floor(peak/2),:) = filt_forceX(tmp_location - 150 : tmp_location +150); 
end

figure(1)
title('Z force')
shadedErrorBar(1:length(vertForce), vertForce, {@mean,@std}, 'lineprops','-r');
figure(2)
title('AP force')
shadedErrorBar(1:length(APforce), APforce, {@mean,@std}, 'lineprops','-r');
figure(3)
title('ML force')
shadedErrorBar(1:length(MLforce), MLforce, {@mean,@std}, 'lineprops','-r');

%% Other side
vertForce2 = zeros(floor(length(pks)/2),301); % preallocate
APforce2 = zeros(floor(length(pks)/2),301);
MLforce2 = zeros(floor(length(pks)/2),301);
for peak = 3:2:length(pks)
    tmp_location = locs(peak);
    tmp2 = floor(peak/2);
    try
        vertForce2(tmp2,:) = filt_forceZ(tmp_location - 150 : tmp_location +150);   
        APforce2(tmp2,:) = filt_forceY(tmp_location - 150 : tmp_location +150); 
        MLforce2(tmp2,:) = filt_forceX(tmp_location - 150 : tmp_location +150); 
    catch
        fprintf('Reached end of matrix on iteration %s, skipped.\n',peak)
    end
end
%% remove last row of 0's
vertForce2(size(vertForce2,1),:) = [];
MLforce2(size(MLforce2,1),:) = [];
APforce2(size(APforce2,1),:) = [];
% Change ML forces to respective side
MLforce2 = -1 .* MLforce2;
%% make plots
figure(4)
title('Z force')
shadedErrorBar(1:length(vertForce2), vertForce2, {@mean,@std}, 'lineprops','-b');
figure(5)
title('AP force')
shadedErrorBar(1:length(APforce2), APforce2, {@mean,@std}, 'lineprops','-b');
figure(6)
title('ML force')
shadedErrorBar(1:length(MLforce2), MLforce2, {@mean,@std}, 'lineprops','-b');

