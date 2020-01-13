%% Analysis of the treadmill data
clear
subBW =72;
addpath('C:\Users\Daniel.Feeney\Documents\Trail Run\Run Code')
%data = importForcesTM('C:\Users\Daniel.Feeney\Dropbox (Boa)\Treadmill TMM\Data\WalkTest_30 - Report1.txt');
data = importForcesTM('C:\Users\Daniel.Feeney\Dropbox (Boa)\Endurance Protocol Trail Run\DaveLongProtocolTM\DaveSingle32min - Report1.txt');
%tmp_metadata = strsplit(convertCharsToStrings(file.name),' ');
%% Clean data for NaNs
data.ForceZ(isnan(data.ForceZ))=0;
data.ForceY(isnan(data.ForceY))=0;
data.ForceX(isnan(data.ForceX))=0;

%% Filter data
fq = 1000; %Sampling frequency
fc = 20; %Cutoff frequency

[b,a] = butter(2,fc/(fq/2),'low'); %second order BW filter, filtfilt doubles the order
filt_forceZ = filtfilt(b,a,data.ForceZ);
filt_forceY = filtfilt(b,a,data.ForceY); %This will be used for the M/L and A/P forces
filt_forceX = -1 .* filtfilt(b,a,data.ForceX); %This will be used for the M/L and A/P forces

%filt_forceZ = filt_forceZ-35;
filt_forceZ(filt_forceZ<10) = 0; %detrend the Z signals so they start at 0
%plot(filt_forceZ)
%% Find peaks in force and concatenate
[pks,locs] = findpeaks(filt_forceZ, 'minpeakdistance', 250, 'MinPeakProminence',100); %Find locations and values of peaks

%% one side
vertForce = zeros(floor(length(pks)/2),301); % preallocate
APforce = zeros(floor(length(pks)/2),301);
MLforce = zeros(floor(length(pks)/2),301);
COP_x = zeros(floor(length(pks)/2),251);
COP_y = zeros(floor(length(pks)/2),251);
for peak = 2:2:length(pks)
    tmp_location = locs(peak);
    try
        vertForce(floor(peak/2),:) = filt_forceZ(tmp_location - 150 : tmp_location +150);   
        APforce(floor(peak/2),:) = filt_forceY(tmp_location - 150 : tmp_location +150); 
        MLforce(floor(peak/2),:) = filt_forceX(tmp_location - 150 : tmp_location +150); 
        COP_x(floor(peak/2),:) = data.COPx(tmp_location - 125 : tmp_location +125); 
        COP_y(floor(peak/2),:) = data.COPy(tmp_location - 125 : tmp_location +125); 
    catch
        fprintf('Reached end of matrix on iteration %s, skipped.\n',peak)
    end
end

% figure(1)
% title('Z force')
% shadedErrorBar(1:length(vertForce), vertForce, {@mean,@std}, 'lineprops','-r');
% figure(2)
% title('AP force')
% shadedErrorBar(1:length(APforce), APforce, {@mean,@std}, 'lineprops','-r');
% figure(3)
% title('ML force')
% shadedErrorBar(1:length(MLforce), MLforce, {@mean,@std}, 'lineprops','-r');
% ylabel('Medial is negative')


%% calculate loading rates and peak force values

for step = 1:size(vertForce,1)
    tmp_step = vertForce(step,:);
    count = 1;
    for ind = 1:120
        if (tmp_step(ind) == 0 & tmp_step(ind + 1) > 0)
            trueZeros(step,count) = ind;
            count = count + 1;
        end
    end
end
trueZeros = trueZeros(:,1);

t_step = 50;
rates = zeros(1,length(trueZeros));
pks_vert = zeros(1,length(trueZeros)); pks_vert = pks_vert ./ subBW; pks_vert = pks_vert';
pks_med = zeros(1,length(trueZeros)); pks_med = pks_med';

%% heuristic for VLRis find the first impact peak (currently approximated  
% as t_step indices (set above) beyond the landing), find 20 and 80% of of that value 
% (find fxn), use those indices to calculate the forces and RFD. Could 
% automate finding first impact peak better. 

for i = 1:(length(trueZeros))
    try
        tmpIndex = trueZeros(i);
        peakTmp = vertForce(i,trueZeros(i)+t_step);
        twentyPct = find(vertForce(i,trueZeros(i):trueZeros(i)+100) > 0.2 * peakTmp ,1) + tmpIndex;
        eightyPct = find(vertForce(i,trueZeros(i):trueZeros(i)+100) > 0.8 * peakTmp ,1) + tmpIndex;
        rates(i) =  (vertForce(i,eightyPct) - vertForce(i,twentyPct)) / ((eightyPct - twentyPct)/1000);
        pks_vert(i) = max(vertForce(i,:));
        pks_med(i) = max(-1 .* MLforce(i,:));
        pks_lat(i) = max(MLforce(i,:));
        pks_brake(i) = max(-1 .* APforce(i,:));
        pks_prop(i) = max(APforce(i,:));
    end
end
rates = rates';
rates = rates ./9.81; rates = rates ./ subBW;

%A_output = [rates, pks_vert, pks_med ./ subBW, pks_lat' ./ subBW, pks_brake' ./ subBW, pks_prop' ./ subBW];
A_output = [rates, pks_vert, pks_brake' ./ subBW, pks_prop' ./ subBW];

%% histograms if needed
% histogram(rates)
% histogram(pks_vert)
% histogram(pks_lat)
% histogram(pks_med)
% histogram(pks_brake)
% histogram(pks_prop)


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
%MLforce2 = -1 .* MLforce2;
%% make plots
% figure(4)
% title('Z force')
% shadedErrorBar(1:length(vertForce2), vertForce2, {@mean,@std}, 'lineprops','-b');
% figure(5)
% title('AP force')
% shadedErrorBar(1:length(APforce2), APforce2, {@mean,@std}, 'lineprops','-b');
% figure(6)
% title('ML force')
% shadedErrorBar(1:length(MLforce2), -1 .* MLforce2, {@mean,@std}, 'lineprops','-b');


%% Symmetry plots
figure(4)
title('Z force')
shadedErrorBar(1:length(vertForce2), vertForce2, {@mean,@std}, 'lineprops','-b');
hold on
shadedErrorBar(1:length(vertForce), vertForce, {@mean,@std}, 'lineprops','-r');
figure(5)
title('AP force')
shadedErrorBar(1:length(APforce2), -1 .* APforce2, {@mean,@std}, 'lineprops','-b');
hold on
shadedErrorBar(1:length(APforce),  -1 .*  APforce, {@mean,@std}, 'lineprops','-r');
figure(6)
title('ML force')
shadedErrorBar(1:length(MLforce2), -1 .* MLforce2, {@mean,@std}, 'lineprops','-b');
hold on
shadedErrorBar(1:length(MLforce), MLforce, {@mean,@std}, 'lineprops','-r');


%%% scratch work for plotting two loading rate time series against each
%%% other
% figure; hold on;
% h(1) = shadedErrorBar(1:length(vertForce_DD), vertForce_DD, {@mean,@std}, 'lineprops','-b');
% title('Vertical force level running')
% h(2) = shadedErrorBar(1:length(vertForce_Lace), vertForce_Lace, {@mean,@std}, 'lineprops','-r');
% legend([h(1).mainLine h(2).mainLine], 'DD', 'Lace')
% xlabel('Time (1/1000)s','FontSize',14,'FontWeight','bold')
% ylabel('Force (N)','FontSize',14,'FontWeight','bold')
% 
% figure; hold on;
% h(1) = shadedErrorBar(1:length(APforce_DD), -1 .* APforce_DD, {@mean,@std}, 'lineprops','-b');
% title('AP force level running')
% h(2) = shadedErrorBar(1:length(APforce_Lace), -1 .* APforce_Lace, {@mean,@std}, 'lineprops','-r');
% legend([h(1).mainLine h(2).mainLine], 'DD', 'Lace')
% xlabel('Time (1/1000)s','FontSize',14,'FontWeight','bold')
% ylabel('Force (N)','FontSize',14,'FontWeight','bold')