function DFuphillpilot092619 = importMetabolics(workbookFile, sheetName, dataLines)
%IMPORTFILE Import data from a spreadsheet
%  DFUPHILLPILOT092619 = IMPORTFILE(FILE) reads data from the first
%  worksheet in the Microsoft Excel spreadsheet file named FILE.
%  Returns the data as a table.
%
%  DFUPHILLPILOT092619 = IMPORTFILE(FILE, SHEET) reads from the
%  specified worksheet.
%
%  DFUPHILLPILOT092619 = IMPORTFILE(FILE, SHEET, DATALINES) reads from
%  the specified worksheet for the specified row interval(s). Specify
%  DATALINES as a positive scalar integer or a N-by-2 array of positive
%  scalar integers for dis-contiguous row intervals.
%
%  Example:
%  DFuphillpilot092619 = importfile("C:\Users\Daniel.Feeney\Dropbox (Boa)\Treadmill TMM\DF_uphill_pilot_092619.xlsx", "Data", [1, 1068]);
%
%  See also READTABLE.
%
% Auto-generated by MATLAB on 26-Sep-2019 12:51:57

%% Input handling

% If no sheet is specified, read first sheet
if nargin == 1 || isempty(sheetName)
    sheetName = 1;
end

% If row start and end points are not specified, define defaults
if nargin <= 2
    dataLines = [1, 1068];
end

%% Setup the Import Options
opts = spreadsheetImportOptions("NumVariables", 29);

% Specify sheet and range
opts.Sheet = sheetName;
opts.DataRange = "J" + dataLines(1, 1) + ":AL" + dataLines(1, 2);

% Specify column names and types
opts.VariableNames = ["t", "Rf", "VT", "VE", "IV", "VO2", "VCO2", "RQ", "O2exp", "CO2exp", "VEVO2", "VEVCO2", "VO2Kg", "METS", "HR", "VO2HR", "FeO2", "FeCO2", "FetO2", "FetCO2", "FiO2", "FiCO2", "PeO2", "PeCO2", "PetO2", "PetCO2", "SpO2", "Phase", "Marker"];
opts.SelectedVariableNames = ["t", "Rf", "VT", "VE", "IV", "VO2", "VCO2", "RQ", "O2exp", "CO2exp", "VEVO2", "VEVCO2", "VO2Kg", "METS", "HR", "VO2HR", "FeO2", "FeCO2", "FetO2", "FetCO2", "FiO2", "FiCO2", "PeO2", "PeCO2", "PetO2", "PetCO2", "SpO2", "Phase", "Marker"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "categorical", "string"];
opts = setvaropts(opts, 29, "WhitespaceRule", "preserve");
opts = setvaropts(opts, [28, 29], "EmptyFieldRule", "auto");

% Import the data
DFuphillpilot092619 = readtable(workbookFile, opts, "UseExcel", false);

for idx = 2:size(dataLines, 1)
    opts.DataRange = "J" + dataLines(idx, 1) + ":AL" + dataLines(idx, 2);
    tb = readtable(workbookFile, opts, "UseExcel", false);
    DFuphillpilot092619 = [DFuphillpilot092619; tb]; %#ok<AGROW>
end

end