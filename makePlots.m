function makePlots = makePlots(data,len,sub)
% makePlot Builds a shaded error plot for each subject (1,2,3 for Dave,
% Joe, John, respectively). Len is the length of the slice you'd like. 
% Len = 125works well. 

locs = data(1).pkloc{:,sub};
locs2 = data(1).pkloc{:,sub+1};
locs3 = data(1).pkloc{:,sub+2};
locs4 = data(1).pkloc{:,sub+3};

force_z_l = zeros(length(data(1).pkloc{:,1}),(len*2)+1);
force_z_lr = zeros(length(data(1).pkloc{:,2}),(len*2)+1);
force_z_t = zeros(length(data(1).pkloc{:,3}),(len*2)+1);
force_z_x = zeros(length(data(1).pkloc{:,4}),(len*2)+1);

force_y_l = zeros(length(data(1).pkloc{:,1}),(len*2)+1);
force_y_lr = zeros(length(data(1).pkloc{:,2}),(len*2)+1);
force_y_t = zeros(length(data(1).pkloc{:,3}),(len*2)+1);
force_y_x = zeros(length(data(1).pkloc{:,4}),(len*2)+1);

force_y_l = zeros(length(data(1).pkloc{:,1}),(len*2)+1);
force_y_lr = zeros(length(data(1).pkloc{:,2}),(len*2)+1);
force_y_t = zeros(length(data(1).pkloc{:,3}),(len*2)+1);
force_y_x = zeros(length(data(1).pkloc{:,4}),(len*2)+1);


for i = 2:(length(locs)-5)
   force_z(i,:) =  data(1).zforce{1,sub}(floor(locs(i)-len):floor(locs(i)+len));
   force_z_lr(i,:) =  data(1).zforce{1,sub+1}(floor(locs2(i)-len):floor(locs2(i)+len));
   force_z_t(i,:) =  data(1).zforce{1,sub+2}(floor(locs3(i)-len):floor(locs3(i)+len));
   force_z_x(i,:) =  data(1).zforce{1,sub+3}(floor(locs4(i)-len):floor(locs4(i)+len));

   force_y(i,:) =  data(1).yforce{1,sub}(floor(locs(i)-len):floor(locs(i)+len));
   force_y_lr(i,:) =  data(1).yforce{1,sub+1}(floor(locs2(i)-len):floor(locs2(i)+len));
   force_y_t(i,:) =  data(1).yforce{1,sub+2}(floor(locs3(i)-len):floor(locs3(i)+len));
   force_y_x(i,:) =  data(1).yforce{1,sub+3}(floor(locs4(i)-len):floor(locs4(i)+len));
   
   force_x(i,:) =  data(1).xforce{1,sub}(floor(locs(i)-len):floor(locs(i)+len));
   force_x_lr(i,:) =  data(1).xforce{1,sub+1}(floor(locs2(i)-len):floor(locs2(i)+len));
   force_x_t(i,:) =  data(1).xforce{1,sub+2}(floor(locs3(i)-len):floor(locs3(i)+len));
   force_x_x(i,:) =  data(1).xforce{1,sub+3}(floor(locs4(i)-len):floor(locs4(i)+len));
end

figure(1)
title('Z force')
shadedErrorBar(1:length(force_z), force_z, {@mean,@std}, 'lineprops','-r');
hold on
shadedErrorBar(1:length(force_z_lr), force_z_lr, {@mean,@std}, 'lineprops','-b');
shadedErrorBar(1:length(force_z_t), force_z_t, {@mean,@std}, 'lineprops','-g');
shadedErrorBar(1:length(force_z_x), force_z_x, {@mean,@std}, 'lineprops','-k');
xlabel('Time (ms)','FontSize',14,'FontWeight','bold')
ylabel('Force (N)','FontSize',14,'FontWeight','bold')

figure(2)
title('Y force')
shadedErrorBar(1:length(force_y), force_y, {@mean,@std}, 'lineprops','-r');
hold on
shadedErrorBar(1:length(force_y_lr), force_y_lr, {@mean,@std}, 'lineprops','-b');
shadedErrorBar(1:length(force_y_t), force_y_t, {@mean,@std}, 'lineprops','-g');
shadedErrorBar(1:length(force_y_x), force_y_x, {@mean,@std}, 'lineprops','-k');
xlabel('Time (ms)','FontSize',14,'FontWeight','bold')
ylabel('Force (N)','FontSize',14,'FontWeight','bold')

figure(3)
title('X force')
shadedErrorBar(1:length(force_x), force_x, {@mean,@std}, 'lineprops','-r');
hold on
shadedErrorBar(1:length(force_x_lr), force_x_lr, {@mean,@std}, 'lineprops','-b');
shadedErrorBar(1:length(force_x_t), force_x_t, {@mean,@std}, 'lineprops','-g');
shadedErrorBar(1:length(force_x_x), force_x_x, {@mean,@std}, 'lineprops','-k');
xlabel('Time (ms)','FontSize',14,'FontWeight','bold')
ylabel('Force (N)','FontSize',14,'FontWeight','bold')

end

