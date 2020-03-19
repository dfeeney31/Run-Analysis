%%% Dual-belt treadmill hike looping through directory %%
clear
addpath('C:\Users\Daniel.Feeney\Dropbox (Boa)\TMM Files') % add path to source code
subBW = 70;

% The files should be named sub_balance_Config_trialNo - Forces.txt
input_dir = 'C:\Users\Daniel.Feeney\Dropbox (Boa)\Hike Work Research\Data\TMHike';% Change to correct filepath

cd(input_dir)
files = dir('*.txt');
dataList = {files.name};
dataList = sort(dataList);
[f,~] = listdlg('PromptString','Select data files for all subjects in group','SelectionMode','multiple','ListString',dataList);
NumbFiles = length(f);

outputAllConfigs = {'SubName','Config','TrialNo','StepLen','vertImpulse', 'brakeImpulse', 'propImpulse', 'LoadRate'};

%Define constants
fThresh = 40; %below this value will be set to 0.

for s = 1:NumbFiles
    %dat = importDualBelt('C:\Users\Daniel.Feeney\Dropbox (Boa)\Hike Work Research\Data\TMHike\Dan_up_DD - Forces.txt');
    
    fileName = dataList{f(s)};
    fileLoc = [input_dir '\' fileName];
    dat = importDualBelt(fileLoc);
    
    splitFName = strsplit(fileName,'_'); subName = splitFName{1};
    configName = splitFName{3}(1:2);
    upDown = splitFName{2};
   
    
    % Clean data for NaNs
    dat.LForceZ(isnan(dat.LForceZ))=0;
    dat.LForceY(isnan(dat.LForceY))=0;
    dat.LForceX(isnan(dat.LForceX))=0;
    
    dat.RForceZ(isnan(dat.RForceZ))=0;
    dat.RForceY(isnan(dat.RForceY))=0;
    dat.RForceX(isnan(dat.RForceX))=0;
    
    % Filter data and make left vertical forces positive
    fq = 1000; %Sampling frequency
    fc = 20; %Cutoff frequency
    
    [b,a] = butter(2,fc/(fq/2),'low'); %second order BW filter, filtfilt doubles the order
    filt_forceZ = -1 .* filtfilt(b,a,dat.LForceZ);
    filt_forceY = -1 .* filtfilt(b,a,dat.LForceY); %This will be used for the M/L and A/P forces
    filt_forceX = -1 .* filtfilt(b,a,dat.LForceX); %This will be used for the M/L and A/P forces
    
    filt_forceZ(filt_forceZ<fThresh) = 0; %detrend the Z signals so they start at 0
    
    % delimit steps
    ic = zeros(60,1);
    count = 1;
    for step = 1:length(filt_forceZ)-1
        if (filt_forceZ(step) == 0 & filt_forceZ(step + 1) > 30)
            ic(count) = step;
            count = count + 1;
        end
    end
    
    to = zeros(60,1);
    count = 1;
    for step = 1:length(filt_forceZ)-1
        if (filt_forceZ(step) > 30 & filt_forceZ(step + 1) == 0)
            to(count) = step;
            count = count + 1;
        end
    end
    % trim first contact/toe off if not a full step
    if (ic(1) > to(1))
        to(1) = [];
    end
    ic(ic == 0) = []; to(to == 0) = [];
    
    if (ic(end) > to(end))
        ic(end) = [];
    end
    % Calculate step lengths
    stepLens = to - ic;
    
    
    t_step = 150; %set ms to look forward for impact peak
    vertImpulse = zeros(1,length(stepLens)); brakeImpulse = zeros(1,length(stepLens)); 
    propImpulse = zeros(1,length(stepLens)); rate = zeros(1,length(stepLens));
    
    for step = 1:length(stepLens)
        %Vertical impulse
        vertImpulse(step) = sum(filt_forceZ(ic(step):to(step)));
        %braking impulse
        tmp_yBrake = filt_forceY(ic(step):to(step));
        tmp_yBrake(tmp_yBrake>0) = 0;
        brakeImpulse(step) = sum(tmp_yBrake);
        %Propulsive impulse
        tmp_yProp = filt_forceY(ic(step):to(step));
        tmp_yProp(tmp_yProp<0) = 0;
        propImpulse(step) = sum(tmp_yProp);
        
        %loading rates calcualted as the slope over the first t_step indices of
        %each step
        peakTmp = max(filt_forceZ(ic(step):ic(step)+t_step));
        rate(step) = peakTmp / (t_step/1000);
        
    end
    
    KinData = [stepLens, vertImpulse', abs(brakeImpulse'), propImpulse', rate'/subBW];
    
    subNameTmp = cell(length(stepLens),1); configNameTmp = cell(length(stepLens),1); upDownTmp = cell(length(stepLens),1);
    for i = 1:length(stepLens)
        subNameTmp(i) = {subName};
        configNameTmp(i) = {configName};
        upDownTmp(i) = {upDown};
    end
    
    % Tidy up and add to previous data
    KinData = num2cell(KinData);
    KinData = horzcat(subNameTmp,configNameTmp,upDownTmp, KinData); %modulate this to subject name and config
    outputAllConfigs = vertcat(outputAllConfigs, KinData);
    
end

% Convert cell to a table and use first row as variable names
T = cell2table(outputAllConfigs(2:end,:),'VariableNames',outputAllConfigs(1,:))
% Write the table to a CSV file
writetable(T,'testFile.csv')
