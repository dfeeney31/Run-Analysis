%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5%%%
% This file will loop through all .csv files in a directory, run a peak
% detection algorithm on it and calcualte metrics relevent to the force
% signal. 
% Notes for Saucony trials 3/1: DG config L needed to be run with 
% 'edgecase.m' because there was some baseline noise during flight. DG X
% had the same thing and altering line 22 to a smaller interval (50) fixed
% it. JZ had the same issue with laces but had more false positives. The
% interval was reduced to 25. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
files = dir('*.csv');
VLR = zeros(1,12);
pk_force = zeros(1,12);
prop_pk_force = zeros(1,12);
break_pk_force = zeros(1,12);
lat_pk_force = zeros(1,12);
med_pk_force = zeros(1,12);

%SS = 3;  %number of elements
longdata(1,3) = struct();
%longdata(1)

counter = 1;

joe_bw = 72.5;
john_bw = 71.2;
dave_bw = 72.5;

for file = files'
    M = csvread(file.name, 1, 0);
    % Do some stuff
    clear counter_var filt_force locs pks zeros_1 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    fq = 1000; %Sampling frequency
    fc = 20; %Cutoff frequency
    
    [b,a] = butter(2,fc/(fq/2),'low'); %second order BW filter, filtfilt doubles the order
    filt_force = filtfilt(b,a,M);
    filt_force2 = filtfilt(b,a,M); %This will be used for the M/L and A/P forces
    filt_force(filt_force<0) = 0; %detrend the Z signals so they start at 0
     
    [pks,locs] = findpeaks(filt_force(:,3), 'minpeakdistance', 250, 'MinPeakProminence',100); %Find locations and values of peaks
    [pks_prop,locs_prop] = findpeaks(filt_force2(:,2), 'minpeakdistance', 250, 'MinPeakProminence',100); %Find locations and values of peaks
    [pks_break,locs_break] = findpeaks((-1 * filt_force2(:,2)), 'minpeakdistance', 250, 'MinPeakProminence',100); %Find locations and values of peaks

    [pks_lat,locs_lat] = findpeaks(filt_force2(:,1), 'minpeakdistance', 250, 'MinPeakProminence',100); %Find locations and values of peaks
    [pks_med,locs_med] = findpeaks((-1 * filt_force2(:,1)), 'minpeakdistance', 250, 'MinPeakProminence',100); %Find locations and values of peaks
    pks_lat = pks_lat(pks_lat > 115);
    pks_med = pks_med(pks_med > 50);
    
    zeros_1 = find(filt_force(:,3)); %find all instances where the force signal is 0
    counter_var = 1; %initialize a counter variable to be used as an index below
    zero_loc = 0;
    for n = 1:(length(zeros_1) - 1)
        if (zeros_1(n + 1) - zeros_1(n) > 20) %if the difference between two zero locations is large enough, set that value to be a strike
            zero_loc(counter_var) = zeros_1(n + 1); %put this location into the zeros
            counter_var = counter_var +1; %Update this index
        end
    end
    
    epoch = 0.03; %set length of loading rate vec
    epoch_2 = epoch * 1000;
    rates = zeros(1,(length(zero_loc) - 2));
    
    for i = 1:(length(zero_loc) - 2)
        t_step = zero_loc(i) + epoch_2;
        rates(i) = ((filt_force(t_step,3) - filt_force(zero_loc(i),3))) / epoch;
    end
    rates = rates(rates>1500); %Drop any false positive strikes from average
    

    VLR(counter) = mean(rates);
    pk_force(counter) = mean(pks);
    prop_pk_force(counter) = mean(pks_prop);
    break_pk_force(counter) = mean(pks_break);
    lat_pk_force(counter) = mean(pks_lat);
    med_pk_force(counter) = mean(pks_med);
    
    longdata(1).VLR{counter} = rates;
    longdata(1).med{counter} = pks_med;
    longdata(1).lat{counter} = pks_lat;
    longdata(1).pkloc{counter} = locs;
    longdata(1).breaking{counter} = pks_break;
    longdata(1).prop{counter} = pks_prop;
    longdata(1).zforce{counter} = filt_force(:,3)
    longdata(1).yforce{counter} = filt_force2(:,2)
    longdata(1).xforce{counter} = filt_force2(:,1)
    
    counter = counter +1;

    
end

%% Normalize to body wmass 
VLR(1:4) = VLR(1:4) / (dave_bw * 9.81); %BW/s conversion
VLR(5:8) = VLR(5:8) / (joe_bw* 9.81);
VLR(9:12) = VLR(9:12) / (john_bw* 9.81);
longdata(1).VLR{:,1} = longdata(1).VLR{:,1} ./ (dave_bw*9.81);
longdata(1).VLR{:,2} = longdata(1).VLR{:,2} ./ (dave_bw*9.81);
longdata(1).VLR{:,3} = longdata(1).VLR{:,3} ./ (dave_bw*9.81);
longdata(1).VLR{:,4} = longdata(1).VLR{:,4} ./ (dave_bw*9.81);
longdata(1).VLR{:,5} = longdata(1).VLR{:,5} / (joe_bw*9.81);
longdata(1).VLR{:,6} = longdata(1).VLR{:,6} / (joe_bw*9.81);
longdata(1).VLR{:,7} = longdata(1).VLR{:,7} / (joe_bw*9.81);
longdata(1).VLR{:,8} = longdata(1).VLR{:,8} / (joe_bw*9.81);
longdata(1).VLR{:,9} = longdata(1).VLR{:,9} / (john_bw*9.81);
longdata(1).VLR{:,10} = longdata(1).VLR{:,10} / (john_bw*9.81);
longdata(1).VLR{:,11} = longdata(1).VLR{:,11} / (john_bw*9.81);
longdata(1).VLR{:,12} = longdata(1).VLR{:,12} / (john_bw*9.81);
pk_force(1:4) = pk_force(1:4);% / dave_bw;
pk_force(5:8) = pk_force(5:8);% / john_bw;
pk_force(9:12) = pk_force(9:12);% / joe_bw;
prop_pk_force(1:4) = prop_pk_force(1:4);% / dave_bw;
prop_pk_force(5:8) = prop_pk_force(5:8);% / john_bw;
prop_pk_force(9:12) = prop_pk_force(9:12);% / joe_bw;
break_pk_force(1:4) = break_pk_force(1:4);% / dave_bw;
break_pk_force(5:8) = break_pk_force(5:8);% / john_bw;
break_pk_force(9:12) = break_pk_force(9:12);% / joe_bw;
lat_pk_force(1:4) = lat_pk_force(1:4);% / dave_bw;
lat_pk_force(5:8) = lat_pk_force(5:8);% / john_bw;
lat_pk_force(9:12) = lat_pk_force(9:12);% / joe_bw;
med_pk_force(1:4) = med_pk_force(1:4);% / dave_bw;
med_pk_force(5:8) = med_pk_force(5:8);% / john_bw;
med_pk_force(9:12) = med_pk_force(9:12);% / joe_bw;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Plotting 
%%%%% Histograms %%%%
%% VLR
sub_pick = 2; %0 for Joe, 1 for Dave, 2 for John
h1 = longdata(1).VLR{:,(sub_pick*4)+1}; %L
h2 = longdata(1).VLR{:,(sub_pick*4)+2}; %R
h3 = longdata(1).VLR{:,(sub_pick*4)+3}; %T
h4 = longdata(1).VLR{:,(sub_pick*4)+4}; %X
%%% Requires brewermap and histf (modified on line 112) in same folder
map = brewermap(3,'Set1'); 
figure(1)
histf(h1,mean(h1)-4*std(h1):100:mean(h1)+4*std(h1),'facecolor',map(1,:),'facealpha',.5,'edgecolor','none')
hold on
histf(h2,mean(h1)-4*std(h1):100:mean(h1)+4*std(h1),'facecolor',map(2,:),'facealpha',.5,'edgecolor','none')
histf(h3,mean(h1)-4*std(h1):100:mean(h1)+4*std(h1),'facecolor',map(3,:),'facealpha',.5,'edgecolor','none')
histf(h4,mean(h1)-4*std(h1):100:mean(h1)+4*std(h1),'facecolor',map(3,:),'facealpha',.5,'edgecolor','none')
box off
axis tight
legend1 = sprintf('Lace mu = %.3f', mean(h1));
legend2 = sprintf('LR mu = %.3f', mean(h2));
legend3 = sprintf('Tri mu = %.3f', mean(h3));
legend4 = sprintf('X mu = %.3f', mean(h4));
legend({legend1, legend2, legend3, legend4});

%%% Breaking peak
sub_pick = 0; %0 for Joe, 1 for Dave, 2 for John
h1 = longdata(1).breaking{:,(sub_pick*4)+1}; %L
h2 = longdata(1).breaking{:,(sub_pick*4)+2}; %R
h3 = longdata(1).breaking{:,(sub_pick*4)+3}; %T
h4 = longdata(1).breaking{:,(sub_pick*4)+4}; %X
%%% Requires brewermap and histf (modified on line 112) in same folder
map = brewermap(3,'Set1'); 
figure(2)
histf(h1,mean(h1)-3*std(h1):mean(h1)+3*std(h1),'facecolor',map(1,:),'facealpha',.5,'edgecolor','none')
hold on
histf(h2,mean(h1)-3*std(h1):mean(h1)+3*std(h1),'facecolor',map(2,:),'facealpha',.5,'edgecolor','none')
histf(h3,mean(h1)-3*std(h1):mean(h1)+3*std(h1),'facecolor',map(3,:),'facealpha',.5,'edgecolor','none')
histf(h4,mean(h1)-3*std(h1):mean(h1)+3*std(h1),'facecolor',map(3,:),'facealpha',.5,'edgecolor','none')
box off
axis tight
legend1 = sprintf('Lace mu = %.3f', mean(h1));
legend2 = sprintf('LR mu = %.3f', mean(h2));
legend3 = sprintf('Tri mu = %.3f', mean(h3));
legend4 = sprintf('X mu = %.3f', mean(h4));
legend({legend1, legend2, legend3, legend4});

