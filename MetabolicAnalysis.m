%%%%%%% Metabolic data processing %%%%%%%
%% import data with custom function
MetData = importMetabolics('DF_uphill_pilot_092619.xlsx')
% Find when marker data was not empty
trials = find(MetData.Marker(4:end) ~= "")
subWt = 69;
%% Plot data
plot(MetData.VO2Kg(trials(3):trials(4))) %LR
hold on
plot(MetData.VO2Kg(trials(6):trials(7))) %Standard lace
plot(MetData.VO2Kg(trials(8):trials(9))) % overlapping panels
plot(MetData.VO2Kg(trials(10):trials(11))) % Tri Panel
plot(MetData.VO2Kg(trials(12):trials(13))) % X 
plot(MetData.VO2Kg(trials(14):trials(15))) % Hierro
legend('LR','Lace','OP','Tri','X','Hierro')

%% Calculate metabolic rate with Brockway equation
LR = ((16.58 * mean(MetData.VO2(trials(3):trials(3)+20))) + (4.51 * mean(MetData.VCO2(trials(3):trials(3)+20)))) / subWt;
Lace = ((16.58 * mean(MetData.VO2(trials(7) - 20:trials(7)))) + (4.51 * mean(MetData.VCO2(trials(7)-20:trials(7))))) / subWt;
OP = ((16.58 * mean(MetData.VO2(trials(9) - 20:trials(9)))) + (4.51 * mean(MetData.VCO2(trials(9)-20:trials(9))))) / subWt;
Tri = ((16.58 * mean(MetData.VO2(trials(11) - 20:trials(11)))) + (4.51 * mean(MetData.VCO2(trials(11)-20:trials(11))))) / subWt;
X = ((16.58 * mean(MetData.VO2(trials(13) - 20:trials(13)))) + (4.51 * mean(MetData.VCO2(trials(13)-20:trials(13))))) / subWt;
results.Lace = Lace; results.LR = LR; results.OP = OP; results.Tri = Tri; results.X = X;
%% Calc percent differences and store 
pctDiff.LR = ((results.LR - results.Lace) / results.Lace) * 100;
pctDiff.OP = ((results.OP - results.Lace) / results.Lace) * 100;
pctDiff.Tri = ((results.Tri - results.Lace) / results.Lace) * 100;
pctDiff.X = ((results.X - results.Lace) / results.Lace) * 100;