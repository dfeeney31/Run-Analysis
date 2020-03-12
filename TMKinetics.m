%% TM with kinetics 
clear
subBW = 80;
addpath('C:\Users\Daniel.Feeney\Documents\Trail Run\Run Code')
kinData = importTMKinetics('C:\Users\Daniel.Feeney\Dropbox (Boa)\Hike Work Research\Data\TMHike\brett_up_SD - Kinetics.txt');
%forceData = importForcesTM('C:\Users\Daniel.Feeney\Dropbox (Boa)\Hike Work Research\Data\TMHike\Dan_uphill_1min - Forces.txt');
%tmp_metadata = strsplit(convertCharsToStrings(file.name),' ');
%step_length = 401; %not used yet, but will allow to make window longer



%% Kinetics and zero'ing all kinetics when left foot is not on belt
% first, remove low Z force values
%filt_forceZ = filt_forceZ-35;
filt_forceZ = kinData.LeftZForce * -1;
filt_forceZ(filt_forceZ<30) = 0; %detrend the Z signals so they start at 0

% delimt when there is force on the left side
leftStrike = zeros(length(filt_forceZ),1);
leftStrike(find(filt_forceZ)) = 1;
% element-wise multiple binary leftStrike vector with each joint
% Powers
LAnklePower = leftStrike .* kinData.LAnklePower;
LKneePower = leftStrike .* kinData.LKneePower;
LHipPower = leftStrike .* kinData.LHipPower;
% Moments
LAnkleMomX = leftStrike .* kinData.LAnkleMomentx; LAnkleMomY = leftStrike .* kinData.LAnkleMomenty; LAnkleMomZ = leftStrike .* kinData.LAnkleMomentz;
LKneeMomX = leftStrike .* kinData.LKneeMomentX; LKneeMomY = leftStrike .* kinData.LKneeMomentY; LKneeMomZ = leftStrike .* kinData.LKneeMomentZ;
LHipMomX = leftStrike .* kinData.LHipMomentx; LHipMomY = leftStrike .* kinData.LHipMomenty; LHipMomZ = leftStrike .* kinData.LHipMomentz;

% plots to visualize.
figure
plot(filt_forceZ)
hold on
plot(LAnklePower)
plot(LKneePower)
plot(LHipPower)
ylabel('Joint Power (W)')
title('Joint Powers')
legend('Force','Ankle','Knee','Hip')
xlim([200 600])

%% Ankle moments
yyaxis left
plot(LAnkleMomX)
hold on
plot(LAnkleMomY)
plot(LAnkleMomZ)
yyaxis right
plot(filt_forceZ)
title('Ankle Moments')
ylabel('Joint Moment (Nm)')
legend('X','Y','Z','Force')
xlim([200 600])
%% Knee moments
yyaxis left
plot(LKneeMomX)
hold on
plot(LKneeMomY)
plot(LKneeMomZ)
yyaxis right
plot(filt_forceZ)
title('Knee Moments')
ylabel('Joint Moment (Nm)')
legend('X','Y','Z','Force')
xlim([200 600])

%% Hip moments
yyaxis left
plot(LHipMomX)
hold on
plot(LHipMomY)
plot(LHipMomZ)
yyaxis right
plot(filt_forceZ)
title('Hip Moments')
ylabel('Joint Moment (Nm)')
legend('X','Y','Z','Force')
xlim([200 600])

%% WHICH SIDE IS WHICH
%plot(forceData.COPx);
forceData.ForceZ = forceData.ForceZ + 1260; %remove offset
%% Clean data for NaNs
forceData.ForceZ(isnan(forceData.ForceZ))=0;
forceData.ForceY(isnan(forceData.ForceY))=0;
forceData.ForceX(isnan(forceData.ForceX))=0;

%% Filter data
fq = 1000; %Sampling frequency
fc = 20; %Cutoff frequency

[b,a] = butter(2,fc/(fq/2),'low'); %second order BW filter, filtfilt doubles the order
filt_forceZ = filtfilt(b,a,forceData.ForceZ);
filt_forceY = filtfilt(b,a,forceData.ForceY); %This will be used for the M/L and A/P forces
filt_forceX = filtfilt(b,a,forceData.ForceX); %This will be used for the M/L and A/P forces

%filt_forceZ = filt_forceZ-35;
filt_forceZ(filt_forceZ<10) = 0; %detrend the Z signals so they start at 0
%plot(filt_forceZ)



