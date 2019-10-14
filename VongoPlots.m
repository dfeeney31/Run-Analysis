%% Make plots for Vongo project 
clear
% %% AP forces
load('C:\Users\Daniel.Feeney\Dropbox (Boa)\Vongo\Russell\Russell_A_AP.mat')
load('C:\Users\Daniel.Feeney\Dropbox (Boa)\Vongo\Russell\Russell_B_AP.mat')
load('C:\Users\Daniel.Feeney\Dropbox (Boa)\Vongo\Russell\Russell_C_AP.mat')
load('C:\Users\Daniel.Feeney\Dropbox (Boa)\Vongo\Russell\Russell_D_AP.mat')

%% ML forces
load('C:\Users\Daniel.Feeney\Dropbox (Boa)\Vongo\Russell\Russell_A_ML.mat')
load('C:\Users\Daniel.Feeney\Dropbox (Boa)\Vongo\Russell\Russell_B_ML.mat')
load('C:\Users\Daniel.Feeney\Dropbox (Boa)\Vongo\Russell\Russell_C_ML.mat')
load('C:\Users\Daniel.Feeney\Dropbox (Boa)\Vongo\Russell\Russell_D_ML.mat')

%% Z forces
load('C:\Users\Daniel.Feeney\Dropbox (Boa)\Vongo\Russell\Russell_A_Z.mat')
load('C:\Users\Daniel.Feeney\Dropbox (Boa)\Vongo\Russell\Russell_B_Z.mat')
load('C:\Users\Daniel.Feeney\Dropbox (Boa)\Vongo\Russell\Russell_C_Z.mat')
load('C:\Users\Daniel.Feeney\Dropbox (Boa)\Vongo\Russell\Russell_D_Z.mat')

%% ML forces Jesse
load('C:\Users\Daniel.Feeney\Dropbox (Boa)\Vongo\Jesse\JesseMLA.mat')
load('C:\Users\Daniel.Feeney\Dropbox (Boa)\Vongo\Jesse\JesseMLB.mat')
load('C:\Users\Daniel.Feeney\Dropbox (Boa)\Vongo\Jesse\JesseMLC.mat')
load('C:\Users\Daniel.Feeney\Dropbox (Boa)\Vongo\Jesse\JesseMLD.mat')

%% Z forces
load('C:\Users\Daniel.Feeney\Dropbox (Boa)\Vongo\Jesse\JesseVertA.mat')
load('C:\Users\Daniel.Feeney\Dropbox (Boa)\Vongo\Jesse\JesseVertB.mat')
load('C:\Users\Daniel.Feeney\Dropbox (Boa)\Vongo\Jesse\JesseVertC.mat')
load('C:\Users\Daniel.Feeney\Dropbox (Boa)\Vongo\Jesse\JesseVertD.mat')

%% ML forces Josh
load('C:\Users\Daniel.Feeney\Dropbox (Boa)\Vongo\Josh\JoshMLA.mat')
load('C:\Users\Daniel.Feeney\Dropbox (Boa)\Vongo\Josh\JoshMLB.mat')
load('C:\Users\Daniel.Feeney\Dropbox (Boa)\Vongo\Josh\JoshMLC.mat')
load('C:\Users\Daniel.Feeney\Dropbox (Boa)\Vongo\Josh\JoshMLD.mat')

%% Z forces
load('C:\Users\Daniel.Feeney\Dropbox (Boa)\Vongo\Josh\JoshVertA.mat')
load('C:\Users\Daniel.Feeney\Dropbox (Boa)\Vongo\Josh\JoshVertB.mat')
load('C:\Users\Daniel.Feeney\Dropbox (Boa)\Vongo\Josh\JoshVertC.mat')
load('C:\Users\Daniel.Feeney\Dropbox (Boa)\Vongo\Josh\JoshVertD.mat')

%% Adjust Josh's forces due to treadmill drift
%vertForce_B(:,76:256) = vertForce_B(:,76:256) + 300;
%% make plots
figure(1)
title('Z force')
h(1) = shadedErrorBar(1:length(vertForceA), vertForceA, {@mean,@std}, 'lineprops','-r');
hold on
h(2) = shadedErrorBar(1:length(vertForce_B), vertForce_B, {@mean,@std}, 'lineprops','-b'); %Boa
h(3) = shadedErrorBar(1:length(vertForce_C), vertForce_C, {@mean,@std}, 'lineprops','-g');
h(4) = shadedErrorBar(1:length(vertForce_D), vertForce_D, {@mean,@std}, 'lineprops','-k'); %Boa
legend([h(1).mainLine h(2).mainLine h(3).mainLine h(4).mainLine], 'A', 'B', 'C', 'D')
xlabel('Time (ms)')
ylabel('Vertical GRF (N)')

figure(2)
title('AP force')
h(1) = shadedErrorBar(1:length(APforce), APforce, {@mean,@std}, 'lineprops','-r');
hold on
h(2) = shadedErrorBar(1:length(APforce_B), APforce_B, {@mean,@std}, 'lineprops','-b'); %Boa
h(3) = shadedErrorBar(1:length(APforce_C), APforce_C, {@mean,@std}, 'lineprops','-g');
h(4) = shadedErrorBar(1:length(APforce_D), APforce_D, {@mean,@std}, 'lineprops','-k'); %Boa
legend([h(1).mainLine h(2).mainLine h(3).mainLine h(4).mainLine], 'Laced', 'Boa', 'Laced diff', 'Boa diff')


figure(3)
title('ML force')
h(1) = shadedErrorBar(1:length(MLforce), MLforce, {@mean,@std}, 'lineprops','-r');
hold on
h(2) = shadedErrorBar(1:length(MLforce_B), -1 .* (MLforce_B), {@mean,@std}, 'lineprops','-g'); %Boa
h(3) = shadedErrorBar(1:length(MLforce_C),-1 .*  MLforce_C, {@mean,@std}, 'lineprops','-b');
h(4) = shadedErrorBar(1:length(MLforce_D),MLforce_D, {@mean,@std}, 'lineprops','k'); %Boa
legend([h(1).mainLine h(2).mainLine h(3).mainLine h(4).mainLine], 'A', 'B', 'C', 'D')
xlabel('Time (ms)')
ylabel('Medial (+) / Lateral (-) GRF (N)')

%% find maxes


[max(MLforceA,[],2), max(-1 .*MLforceA,[],2), max(vertForceA,[],2)]
[max(MLforce_B,[],2), max(-1.* MLforce_B,[],2), max(vertForce_B,[],2)]
[max(MLforce_C,[],2), max(-1 .*MLforce_C,[],2), max(vertForce_C,[],2)]
[max(MLforce_D,[],2), max(-1 .*MLforce_D,[],2), max(vertForce_D,[],2)]


%% Calcualte vertical loading rates
vertForce = vertForce_D;


trueZeros = zeros(1,90);
for step = 1:size(vertForce,1)
    tmp_step = vertForce(step,:);
    count = 1;
    for ind = 1:100
        if (tmp_step(ind) == 0 & tmp_step(ind + 1) > 0)
            trueZeros(step,count) = ind;
            count = count + 1;
        end
    end
end
trueZeros = trueZeros(:,1);

t_step = 100;
rates = zeros(1,90);
for i = 1:(length(trueZeros))
    rates(i) = vertForce(i,trueZeros(i)+t_step) / 0.1;
end
rates = rates';
