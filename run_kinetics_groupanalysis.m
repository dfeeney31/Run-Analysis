clear
clc
clf

subject = {'MK'}; % Change to Subject Name
% Data files should be named SubjectNameMovementShoe - Report
%input_dir = 'C:\Users\Daniel.Feeney\Dropbox (Boa)\Endurance Protocol Trail Run\Michel_LaSportiva\RunData';% Change to correct filepath
input_dir = 'C:\Users\Daniel.Feeney\Desktop\DanTest';
direction = 1; % If level or uphill = 1 (forwards); If downhill = 2 (backwards)

shoes = {'DD','SD','SL'}; %Shoe names, in ALPHABETICAL ORDER. Remember to change legend at bottom to correct number of shoes.
line = {'-k','-g', '-b'}; % Add enough line colors for each shoe.

cd(input_dir)
files = dir('*.txt');
dataList = {files.name};
dataList = sort(dataList);
[f,~] = listdlg('PromptString','Select data files for all subjects in group','SelectionMode','multiple','ListString',dataList);
NumbFiles = length(f);

KinDataAllShoes = {'Subject','Shoe','VLR2', 'VLR', 'pBF', 'pPF', 'pVGRF', 'pMF', 'pLF', 'Bimp', 'Pimp', 'Mimp', 'Limp'};

for s = 1:NumbFiles

    fileName = dataList{f(s)};
    fileLoc = [input_dir '\' fileName]; 
    M = dlmread(fileLoc, '\t', 9, 0);
    M(isnan(M)) = 0;
    
    Fz = M(100:40000,4);%vertical
    
    
    if direction == 1
    Fy = -1.*M(100:40000,5);%antero-posterior
    Fx = -1.*M(100:40000,6);%mediolateral
    else
    Fy = M(100:40000,5);%antero-posterior
    Fx = M(100:40000,6);%mediolateral
    end
    
    
    fq = 1000; %Sampling frequency
    fc = 50; %Cutoff frequency
    
    [b,a] = butter(2,fc/(fq/2),'low'); %second order BW filter, filtfilt doubles the order
    Fz = filtfilt(b,a,Fz); Fz = Fz * -1;
    Fy = filtfilt(b,a,Fy); 
    Fx = filtfilt(b,a,Fx);
    
    Fz(Fz<80) = 0;
    Fy(Fz<80) = 0;
    Fx(Fz<80) = 0;
   
    
    contact = zeros(length(Fz),1);
    off = zeros(length(Fz),1);
    for i = 2:length(Fz)
        if (Fz(i-1)<80) && (Fz(i)>80)
            contact(i)=1;
        end
  
    end
    
    for i = 1:length(Fz)-1
        if (Fz(i)>80) && (Fz(i+1)<80)
            off(i) = 1;
        end
    end
    
    
    ic = find(contact==1);
    to = find(off==1);
    
    if to(1)<ic(1)
        to = to(2:end); % remove any toe off before first IC
    end
    
    ic = ic(1:length(to)); % make sure there is a toe off for every ic
    
    % Is first step right or left?
    
    footLoc1 = mean(M(ic(1):to(1),2));
    footLoc2 = mean(M(ic(2):to(2),2));
   
    if footLoc1 > footLoc2
        idx = 2:2:length(ic);
        Ric = ic(idx);
        Rto = to(idx);
    else 
        idx = 1:2:length(ic);
        Ric = ic(idx);
        Rto = to(idx);
    end
    
    FzInt = zeros(length(Ric),101);
    FyInt = zeros(length(Ric),101);
    FxInt = zeros(length(Ric),101);
    
    intframes = 0:100;

    for i = 1:length(Ric)
        
        frames = length(Ric(i):Rto(i));
        vq = intframes * (frames/101);
        FzInt(i,:) = interp1(1:frames, Fz(Ric(i):Rto(i)), vq, 'spline');
        FyInt(i,:) = interp1(1:frames, Fy(Ric(i):Rto(i)), vq, 'spline');
        FxInt(i,:) = interp1(1:frames, Fx(Ric(i):Rto(i)), vq, 'spline');
    end
    
    figure(1)
    hold on
    z(s) = shadedErrorBar(0:100, FzInt, {@mean, @std}, 'lineprops', line{s});
    title('Vertical Force')
    
    
    figure(2)
    hold on
    y(s) = shadedErrorBar(0:100, FyInt, {@mean, @std}, 'lineprops', line{s});
    title('Anteroposterior Force')
    
    figure(3)
    hold on
    x(s) = shadedErrorBar(0:100, FxInt, {@mean, @std}, 'lineprops', line{s});
    title('Mediolateral Force (Lateral positive)')
    
  


  dFz = diff(Fz);
 
  
  rate = dFz./0.001;
  
  VLR = zeros(length(Ric),1);
  VLR2 = zeros(length(Ric),1);
  pBF = zeros(length(Ric),1);
  pPF = zeros(length(Ric),1);
  pVGRF = zeros(length(Ric),1);
  pLF = zeros(length(Ric),1);
  pMF = zeros(length(Ric),1);
  
  for i=1:length(Ric)
      %%%% Heuristic to get 80% 20% force for VLR %%%
      forceTmp = Fz(Ric(i):Ric(i)+200);
      [MaxVal MaxI] = max(forceTmp);
      twentyPct = find(forceTmp > 0.2 * MaxVal ,1);
      eightyPct = find(forceTmp > 0.8 * MaxVal ,1);
     
      VLR2(i) =  (forceTmp(eightyPct) - forceTmp(twentyPct)) / ((eightyPct - twentyPct)/1000);
      VLR(i) = max(rate(Ric(i):Rto(i)));
      pBF(i) = max(-1*Fy(Ric(i):Rto(i)));
      pPF(i) = max(Fy(Ric(i):Rto(i)));
      pVGRF(i) = max(Fz(Ric(i):Rto(i)));
      pLF(i) = max(Fx(Ric(i):Rto(i)));
      pMF(i) = max(-1*Fx(Ric(i):Rto(i)));
  end
  
  BFy = Fy;
  BFy(BFy>0) = 0;
  PFy = Fy;
  PFy(PFy<0) = 0;
  LFx = Fx;
  LFx(LFx<0) = 0;
  MFx = Fx;
  MFx(MFx>0) = 0;
  
  Bimp = BFy.*0.001;
  Pimp = PFy.*0.001;
  Mimp = MFx.*0.001;
  Limp = LFx.*0.001;
  
  BimpTot = zeros(length(Ric),1);
  PimpTot = zeros(length(Ric),1);
  MimpTot = zeros(length(Ric),1);
  LimpTot = zeros(length(Ric),1);
  
  for i = 1:length(Ric)
      
      BimpTot(i) = sum(Bimp(Ric(i):Rto(i)));
      PimpTot(i) = sum(Pimp(Ric(i):Rto(i)));
      MimpTot(i) = sum(Mimp(Ric(i):Rto(i)));
      LimpTot(i) = sum(Limp(Ric(i):Rto(i)));


  end
  
  shoe = cell(length(Ric),1);
  sub = cell(length(Ric),1);
  for i = 1:length(Ric)
      shoe(i) = shoes(s);
      sub(i) = subject;
  end
  
  KinData = horzcat(VLR2, VLR, pBF, pPF, pVGRF, pMF, pLF, BimpTot, PimpTot, MimpTot, LimpTot);
  KinData = num2cell(KinData);
  KinData = horzcat(sub,shoe,KinData);
  KinDataAllShoes = vertcat(KinDataAllShoes, KinData);
  
end

figure(1)
legend([z(1).mainLine z(2).mainLine z(3).mainLine], shoes{1}, shoes{2}, shoes{3})

figure(2)
legend([y(1).mainLine y(2).mainLine y(3).mainLine], shoes{1}, shoes{2}, shoes{3})

figure(3)
legend([x(1).mainLine x(2).mainLine x(3).mainLine], shoes{1}, shoes{2}, shoes{3})