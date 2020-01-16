%% Analysis of the treadmill data\
clear
addpath('C:\Users\Daniel.Feeney\Documents\Trail Run\Run Code')
files = dir('*.txt');
subBW = 70;

longdata(1,3) = struct();
counter = 1;
for file = files'
    clearvars pks pks_brake pks_lat pks_prop pks_vert impulse 
    
    data = importForcesTM(file.name);
    tmp_metadata = strsplit(convertCharsToStrings(file.name),' ')
    fname = tmp_metadata(1);
    cond = tmp_metadata(2);
    trialNo = strsplit(tmp_metadata(3),'.'); trialNo = trialNo(1);
    
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
    %% Calculate end of steps
    truePushoff = zeros(1,length(trueZeros));
    for step2 = 1:size(vertForce,1)
        tmp_step = vertForce(step2,60:end);
        count = 1;
        for ind = 1:300
            try
                if (tmp_step(ind) > 0 & tmp_step(ind + 1)== 0)
                    truePushoff(step2,count) = ind + 60;
                    count = count + 1;
                else
                    truePushoff(step2,count) = 0;
                    count = count +1;
                end
            end
        end
    end
    truePushoff = truePushoff(:,1);
    for ind = 1:length(truePushoff)
        if truePushoff(ind) == 0
            truePushoff(ind) = length(vertForce(ind,:));
        end
    end
    
    %% Calculate end of braking phase
    brakeEnd = zeros(1,length(trueZeros));
    for step3 = 1:size(APforce,1)
        tmp_step = APforce(step3,60:end);
        count = 1;
        for ind = 1:200
                if (tmp_step(ind) > 0) && (tmp_step(ind + 1) < 0)
                    brakeEnd(step3,count) = ind + 60;
                    count = count + 1;
                end

        end
    end
    brakeEnd = brakeEnd(:,1);
    
    %% end braking phase calc

    
    rates = zeros(1,length(trueZeros));
    pks_vert = zeros(1,length(trueZeros)); pks_vert = pks_vert ./ subBW; pks_vert = pks_vert';
    pks_med = zeros(1,length(trueZeros)); pks_med = pks_med';
    
    %% heuristic for VLRis find the first impact peak (currently approximated
    % as t_step indices (set above) beyond the landing), find 20 and 80% of of that value
    % (find fxn), use those indices to calculate the forces and RFD. Could
    % automate finding first impact peak better.
    t_step = 50; %time step for VLR calculations 
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
            impulse(i) = sum(APforce(i,trueZeros(i):brakeEnd(i)));
        end
    end
    rates = rates';
    rates = rates ./9.81; rates = rates ./ subBW;
    
    output = [rates(1:58), pks_vert(1:58), pks_brake(1:58)' ./ subBW, pks_prop(1:58)' ./ subBW, impulse(1:58)'];
    
    longdata(1).vals{counter} = [output, repmat(fname,length(output),1), repmat(cond,length(output),1), repmat(trialNo, length(output),1)];

    counter = counter +1;

    
end  
    
final_output = [longdata(1).vals{1,1};longdata(1).vals{1,2};longdata(1).vals{1,3};longdata(1).vals{1,4};longdata(1).vals{1,5};longdata(1).vals{1,6};longdata(1).vals{1,7};longdata(1).vals{1,8};...
    longdata(1).vals{1,9};longdata(1).vals{1,10};longdata(1).vals{1,11};longdata(1).vals{1,12}]


