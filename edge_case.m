% Do some stuff
clear 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
joe_bw = 72.5;
john_bw = 71.2;
dave_bw = 72.5;
M = csvread('EH_BOA_concept_T_3_8_ms_processed.csv', 1,0);

fq = 1000; %Sampling frequency
fc = 20; %Cutoff frequency

[b,a] = butter(2,fc/(fq/2),'low'); %second order BW filter, filtfilt doubles the order
filt_force = filtfilt(b,a,M);
filt_force2 = filtfilt(b,a,M); %This will be used for the M/L and A/P forces
filt_force(filt_force<0) = 0; %detrend the signals so they start at 0

[pks,locs] = findpeaks(filt_force(:,3), 'minpeakdistance', 250, 'MinPeakProminence',100); %Find locations and values of peaks
[pks_p,locs_p] = findpeaks(filt_force2(:,2), 'minpeakdistance', 250, 'MinPeakProminence',100); %Find locations and values of peaks
[pks_b,locs_b] = findpeaks((-1 * filt_force2(:,2)), 'minpeakdistance', 250, 'MinPeakProminence',100); %Find locations and values of peaks
[pks_lat,locs_lat] = findpeaks(filt_force2(:,1), 'minpeakdistance', 250, 'MinPeakProminence',100); %Find locations and values of peaks
[pks_med,locs_med] = findpeaks((-1 * filt_force2(:,1)), 'minpeakdistance', 250, 'MinPeakProminence',100);

zeros_1 = find(filt_force(:,3)); %find all instances where the force signal is 0
counter_var = 1; %initialize a counter variable to be used as an index below
zero_loc = 0;

for n = 1:(length(zeros_1) - 1)
    if (zeros_1(n + 1) - zeros_1(n) > 19) %if the difference between two zero locations is large enough, set that value to be a strike
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
rates = rates(rates>1200);
%rates = rates / BW; %Divide this by body weight

% epoch = 0.3
% epoch_2 = epoch * 1000;
% t_step = zero_loc(2) + epoch_2;
% ((filt_force(t_step,3) - filt_force(zero_loc(2),3))) / epoch

figure(1)
histogram(rates);

% counter = counter +1;
mean(rates)/(9.81*72.4)
figure(2)
plot(filt_force(:,3));
for mn = 1:length(zero_loc)
    line([zero_loc(mn) zero_loc(mn)], get(gca, 'ylim'),'color','k')
    line([zero_loc(mn) + epoch_2 zero_loc(mn) + epoch_2], get(gca, 'ylim'),'color','r')
end
xlim([0 1000])

%%%%%%%%%% A/P and M/L %%%%%%%%%%%%
%%% Anterior/posterior %%%
figure(3)
plot(filt_force2(:,2))
for mn = 1:length(zero_loc)
    line([zero_loc(mn) zero_loc(mn)], get(gca, 'ylim'),'color','k')
    line([zero_loc(mn) + epoch_2 zero_loc(mn) + epoch_2], get(gca, 'ylim'),'color','r')
end
%%% medial/lateral %%%
figure(4)
plot(filt_force2(:,1))
for mn = 1:length(zero_loc)
    line([zero_loc(mn) zero_loc(mn)], get(gca, 'ylim'),'color','k')
    line([zero_loc(mn) + epoch_2 zero_loc(mn) + epoch_2], get(gca, 'ylim'),'color','r')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Histogram work %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
map = brewermap(3,'Set1'); 
figure
histf(h1,1540:10:1750,'facecolor',map(1,:),'facealpha',.5,'edgecolor','none')
hold on
histf(h2,1540:10:1750,'facecolor',map(2,:),'facealpha',.5,'edgecolor','none')
histf(h3,1540:10:1750,'facecolor',map(3,:),'facealpha',.5,'edgecolor','none')
histf(h4,1540:10:1750,'facecolor',map(3,:),'facealpha',.5,'edgecolor','none')
box off
axis tight
legend1 = sprintf('Lace mu = %.3f', mean(h1));
legend2 = sprintf('LR mu = %.3f', mean(h2));


%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Time series plots %%%
makePlots(longdata,125,1)
