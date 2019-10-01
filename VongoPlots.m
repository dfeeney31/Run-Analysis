%% Make plots for Vongo project 

%% AP forces
load('C:\Users\Daniel.Feeney\Dropbox (Boa)\Vongo\Russell_A_AP.mat')
load('C:\Users\Daniel.Feeney\Dropbox (Boa)\Vongo\Russell_B_AP.mat')
load('C:\Users\Daniel.Feeney\Dropbox (Boa)\Vongo\Russell_C_AP.mat')
load('C:\Users\Daniel.Feeney\Dropbox (Boa)\Vongo\Russell_D_AP.mat')

%% ML forces
load('C:\Users\Daniel.Feeney\Dropbox (Boa)\Vongo\Russell_A_ML.mat')
load('C:\Users\Daniel.Feeney\Dropbox (Boa)\Vongo\Russell_B_ML.mat')
load('C:\Users\Daniel.Feeney\Dropbox (Boa)\Vongo\Russell_C_ML.mat')
load('C:\Users\Daniel.Feeney\Dropbox (Boa)\Vongo\Russell_D_ML.mat')

%% Z forces
load('C:\Users\Daniel.Feeney\Dropbox (Boa)\Vongo\Russell_A_Z.mat')
load('C:\Users\Daniel.Feeney\Dropbox (Boa)\Vongo\Russell_B_Z.mat')
load('C:\Users\Daniel.Feeney\Dropbox (Boa)\Vongo\Russell_C_Z.mat')
load('C:\Users\Daniel.Feeney\Dropbox (Boa)\Vongo\Russell_D_Z.mat')

%% make plots
figure(1)
title('Z force')
h(1) = shadedErrorBar(1:length(vertForce), vertForce, {@mean,@std}, 'lineprops','-r');
hold on
h(2) = shadedErrorBar(1:length(vertForceB), vertForceB, {@mean,@std}, 'lineprops','-b'); %Boa
h(3) = shadedErrorBar(1:length(vertForce_C), vertForce_C, {@mean,@std}, 'lineprops','-g');
h(4) = shadedErrorBar(1:length(vertForce_D), vertForce_D, {@mean,@std}, 'lineprops','-k'); %Boa
legend([h(1).mainLine h(2).mainLine h(3).mainLine h(4).mainLine], 'Laced', 'Boa', 'Laced diff', 'Boa diff')


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
h(2) = shadedErrorBar(1:length(MLforceB), MLforceB, {@mean,@std}, 'lineprops','-b'); %Boa
h(3) = shadedErrorBar(1:length(MLforce_C), MLforce_C, {@mean,@std}, 'lineprops','-g');
h(4) = shadedErrorBar(1:length(MLforce_D), MLforce_D, {@mean,@std}, 'lineprops','-k'); %Boa
legend([h(1).mainLine h(2).mainLine h(3).mainLine h(4).mainLine], 'Laced', 'Boa', 'Laced diff', 'Boa diff')

