function [ScaleFactor, varargout] = gyroChar_ScaleFactor(amp, fileNumber, freq, date, varargin)
%% gyroChar_ScaleFactor Plots rotation rate scale factor and 
%   transient rotation rate data.
% 
%   [ScaleFactor, (h)] = gyroChar_ScaleFactor(amp, fileNumber, freq, date,)
% 
%  INPUTS
%   amp - rate amplitudes vector
%   fileNumber - file number of each datafile.  The data file should be in
%    the format print_XX.csv where XX is the file number.  The fileNumbers
%    must have their index aligned with their correspomding amp
%    Accepts ASCII output files from Agilent _____ Oscilloscope
%   freq - Rotation frequency of the rate data
%   date - date data was taken - Will be used for labeling outputs
%    e.g. '11-13-14'
%  OPTIONAL INPUT PARAMETER PAIRS
%   window w -w - The data window to restrict the processing over in secs
%    Format as a matrix [window_min window_max] {default: no windowing}
%   fileNumStartIdx - File index to start procesing.  Skips the specified
%    number of amplitudes. {default: 0}
%   saveIMG - Save results to an image {default: true}
%   savePPT - Save results to a power point presentation {default: true}
%   resultsDIR - Directory in which to save the results 
%    {default: 'Rate Results'}
%   folder - data folder {default: current directory}
%   numCycles, n - number of rotation cycles {default: 12}
%   ampDetectMethod, pdm - method of finding the amplitude 
%    {default: findPeaks}
%    methods:
%    'findPeaks' - Takes the average of numCycles peaks
%    'maxs - Takes the average of the largest 2*numCycles
%   plotAmp,pa - plots the amplitude as a line on the transient figures
%    {default: true}
%   holdPPT, hPPT - hold existing power point presentation to add more
%    slides {default: false}
%   fullPlotAmp - amplitudes to plot to their own figures
%    It can be a single amplitude or a vector of amplitudes {default: []}
% 
%  OUTPUTS
%  ScaleFactor - The computed scale factor (mV/deg/s)
% 
%  EXAMPLES
%   amp = [0.8 1.6:1.6:16]; % degrees (rotation amplitude)
%   fileNumber = [0:10];
%   gyroChar_scaleFactor(amp,fileNumber,0.25,'11-12-14')
% 
% Author: Curtis Mayberry
% 
% See also gyroChar_FreqResponse gyroChar_Spectrum gyroChar_E5061B_Bode

%% Check and parse inputs
if numel(varargin)>0
    validParameters = {{'window', 'w'},{'window_max','w_max'},{'window_min','w_min'},...
                       {'saveIMG','img'},{'savePPT','ppt'},...
                       {'resultsDIR','results directory','results dir'},...
                       {'fileNumStartIdx','startIdx'}, {'folder','f'},...
                       {'numCycles','n'},{'ampDetectMethod','adm'},...
                       {'ampMeas','am'},{'plotAmp','pa'},...
                       {'plotPeaks','pp'},{'holdPPT','hPPT'},...
                       {'plotTrans','plotTransient','pt'},...
                       {'fullPlotAmp','fpa'}};
    params = validateInput(varargin, validParameters);
else
    % Just make addlParms an empty struct so that 'isfield' doesn't error
    % out.
    params=struct;
end
if(length(amp)~=length(fileNumber))
    error('gyroChar_ScaleFactor:inputs',...
          'Each amp needs a corresponding fileNumber');
end

% idx of the file number to start with (skips the first specified number of 
% data points)
if isfield(params,'fileNumStartIdx')
    fileNumStartIdx = params.fileNumStartIdx;
else
    fileNumStartIdx = 0; % Default to include all data specified
end
if ~isfield(params,'folder')
    params.folder = pwd;
else
    if(~exist(params.folder,'dir'))
        error('gyroChar_ScaleFactor:folder','folder does not exist');
    end
end
if ~isfield(params,'peakDetectMethod')
    params.peakDetectMethod = 'findPeaks';
end
if ~isfield(params,'numCycles')
    params.numCycles = 12;
end
if ~isfield(params,'ampMeas')
    params.ampMeas = 'peak-peak';
end
% SAVE OPTIONS
% Saves the figures to a .bmp picture
if ~isfield(params,'saveIMG')
    params.SaveIMG = true;
end
% Saves figure to a power point presentation
if ~isfield(params,'savePPT')
    params.savePPT = true;
end
if ~isfield(params,'holdPPT')
    params.holdPPT = false;
end
if ~isfield(params,'resultsDIR')
    params.resultsDIR = 'Rate Results';
end
if(~isfield(params,'plotAmp'))
    params.plotAmp = true;
end
if(~isfield(params,'plotPeaks'))
    params.plotPeaks = true;
end
if(~isfield(params,'holdPPT'))
    params.holdPPT = false;
end
if(~isfield(params,'plotPeaks'))
    params.holdPPT = false;
end
if(~isfield(params,'plotTrans'))
    params.plotTrans = true;
end
if(~isfield(params,'fullPlotAmp'))
params.fullPlotAmp = [];
end


% Selection window
if isfield(params,'window')
    window_min = params.window(1);
    window_max = params.window(2);
end
if isfield(params,'window_max')
    window_max = params.window_max;
end
if isfield(params,'window_min')
    window_max = params.window_min;
end

pptfile = fullfile(pwd, params.resultsDIR,...
                   ['Scale_Factor_' num2str(freq) 'Hz.ppt']);

% Setup Results Directory
if(~isdir(params.resultsDIR))
    [SUCCESS,~,~] = mkdir(params.resultsDIR);
    if(~SUCCESS) 
        disp('mkdir failed');
    end
end

if(params.savePPT && exist(pptfile,'file') && ~params.holdPPT) %Clear Previous Powerpoint Version
    delete(pptfile)
end

%% Import Data
% Imports data from CSV files.  Places the data into a matrix that has:
% # of rows = data length, # of columns = length(amp)

Rates = 2*pi*freq*amp; % degrees/sec (rotation rates)

% Import Data
t = zeros(1002,length(amp));
V = zeros(1002,length(amp));
fileName = cell(length(amp),1);
for i = 1+fileNumStartIdx:length(amp)
    if(fileNumber(i) <=9)
        fileName{i} = fullfile(params.folder,['print_0' num2str(fileNumber(i)) '.csv']);
        [t(:,i),V(:,i)] = importRateTableData(fileName{i},1, 1002);
    else
        fileName{i} = fullfile(params.folder,['print_' num2str(fileNumber(i)) '.csv']);
        [t(:,i),V(:,i)] = importRateTableData(fileName{i},1, 1002);
    end
end


t = t(31:end,:);
V = V(31:end,:);

%% Window Data
% for i = 1+fileNumStart:length(amp)
if(exist('window_min','var'))
    data_window(:,1) = t(:,1) > window_min;% min
    V_w = V(data_window,:); % windowed data
end
if(exist('window_min','var'))
    data_window(:,1) = data_window(:,1) & (t(:,1) < window_max);% max
    V_w = V(data_window,:); % windowed data
else
    data_window(:,1) = true(length(t(:,1)),1);
    V_w = V;
end

% end

%% Process Data

DC = mean(V);

% Calculate Peaks
if(strcmp(params.peakDetectMethod,'findPeaks'))
    peaks = zeros(params.numCycles,length(amp));
    peaks_idx = zeros(params.numCycles,length(amp));
    for i = 1:length(amp)
%         [peaks(:,i), peaks_idx(:,i)] = findpeaks(V_w(:,i),'NPeaks',12,'MinPeakDistance',3/(4*freq),'MinPeakHeight',DC(i)+params.noiseLevel);
        [peaks(:,i), peaks_idx(:,i)] = findpeaks(V_w(:,i),'NPeaks',params.numCycles,'MinPeakDistance',(3)/(4*freq*(t(2)-t(1))),'SortStr','descend');
    end
elseif(strcmp(params.peakDetectMethod,'maxs'))
    [peaks, peaks_idx] = maxs(V_w,2*params.numCycles);
end
peaks_idx = peaks_idx + find(data_window == 1,1);
Vpeak_plot = mean(peaks);
Vpeak = Vpeak_plot - DC;

Vpeak_data(:,1) = Rates;
Vpeak_data(:,2) = Vpeak*1000;

% Calculate Valleys
if(strcmp(params.ampMeas,'peak-peak'))
    valleys = zeros(params.numCycles,length(amp));
    valleys_idx = zeros(params.numCycles,length(amp));
    for i = 1:length(amp)
    	[valleys(:,i), valleys_idx(:,i)] = findpeaks(-V_w(:,i),'NPeaks',params.numCycles,'MinPeakDistance',(3)/(4*freq*(t(2)-t(1))),'SortStr','descend');
    end
    valleys = -valleys;
    valleys_idx = valleys_idx + find(data_window == 1,1);
    Vvalley_plot = mean(valleys);
    Vvalley = Vvalley_plot - DC;
    
    Vpeak_data(:,2) = (Vpeak-Vvalley)*1000/2;
end

%% Plot Transient Data

if(params.plotTrans)
    numFig = ceil(length(amp)/4);

    h = zeros(numFig,1);
    for figN = 1:numFig
        h(figN) = figure;

        for spN = 1:4
            pN = (figN-1)*4+spN;
            if((figN-1)*4+spN <= length(amp))

                subplot(2,2,spN);

                hold on;
                plot(t(:,pN),V(:,pN))
                if(params.plotPeaks)
                    plot(t(peaks_idx(:,pN),pN), peaks(:,pN), 'r*')
                end
                % plot(t(valleys_idx(:,5),5), valleys(:,5), 'r*')

                ax = axis;
                if(params.plotAmp)
                    hl_DC = line([ax(1) ax(2)], [DC(pN) DC(pN)],'Color',[0 0 0]);
                    hl_Vpeak = line([ax(1) ax(2)], [Vpeak_plot(pN) Vpeak_plot(pN)],'Color',[1 0 0]);
                    if(strcmp(params.ampMeas,'peak-peak'))
                        hl_Vvalley = line([ax(1) ax(2)], [Vvalley_plot(pN) Vvalley_plot(pN)],'Color',[1 0 0]);
                    end
                end
                if(exist('window_min','var'))
                    hl_Window(1) = line([window_min, window_min], [ax(3) ax(4)]   ,'Color',[0 1 0]);
                end
                if(exist('window_max','var'))
                    hl_Window(2) = line([window_max, window_max], [ax(3) ax(4)]   ,'Color',[0 1 0]);
                end
                hold off;

                axis(ax);
                title([num2str(Rates((figN-1)*4+spN)) 'deg/sec, ' num2str(Vpeak(pN)*1000) 'mv'])
                xlabel('time(s)');
                ylabel('Rate Output (V)');
            end
        end
        % Save to an image/ppt
        if(figN < numFig)
            PlotTitle = strcat('Rate_Plots_fig', num2str(get(gcf,'Number')), '_d', date);
            if(params.SaveIMG)
                print('-dbmp ',h(figN),fullfile(params.resultsDIR, PlotTitle), '-r400');
            end
            if(params.savePPT)
                saveppt(pptfile,char(PlotTitle),32, '-r400');
            end
        end
    end

    % Add Data Table to plots
    if(mod(numFig,4) == 0)
        numFig = numFig+1;
    end
    figure(numFig);
    subplot(2,2,4);
    uitable('Data',Vpeak_data,'ColumnName', {'Rate(deg/sec)', 'Amplitude'}, ...
        'Position', [285 30 230 170]);
    % Save  Last plot with data table to an image/ppt
    PlotTitle = strcat('Rate_Plots_fig',num2str(get(gcf,'Number')), '_d', date);
    if(params.SaveIMG)

        print('-dbmp ',h(figN),fullfile(params.resultsDIR, PlotTitle), '-r400');
    end
    if(params.savePPT)
        saveppt(pptfile,char(PlotTitle),32, '-r400');
    end
end

%% Plot specified amplitudes
if(~isempty(params.fullPlotAmp))
    for i=1:length(params.fullPlotAmp)
        pN = (amp == params.fullPlotAmp(i));
        figure;
        hold on;
        plot(t(:,pN),V(:,pN))
        if(params.plotPeaks)
            plot(t(peaks_idx(:,pN),pN), peaks(:,pN), 'r*')
        end
        % plot(t(valleys_idx(:,5),5), valleys(:,5), 'r*')

        ax = axis;
        if(params.plotAmp)
            hl_DC = line([ax(1) ax(2)], [DC(pN) DC(pN)],'Color',[0 0 0]);
            hl_Vpeak = line([ax(1) ax(2)], [Vpeak_plot(pN) Vpeak_plot(pN)],'Color',[1 0 0]);
            if(strcmp(params.ampMeas,'peak-peak'))
                hl_Vvalley = line([ax(1) ax(2)], [Vvalley_plot(pN) Vvalley_plot(pN)],'Color',[1 0 0]);
            end
        end
        if(exist('window_min','var'))
            hl_Window(1) = line([window_min, window_min], [ax(3) ax(4)]   ,'Color',[0 1 0]);
        end
        if(exist('window_max','var'))
            hl_Window(2) = line([window_max, window_max], [ax(3) ax(4)]   ,'Color',[0 1 0]);
        end
        hold off;

        axis(ax);
        title({'Transient Rate Response',['rate In: ' num2str(Rates(pN)) 'deg/sec   ' 'Rate Out:' num2str(Vpeak(pN)*1000) 'mv']},'FontSize',16);
        xlabel('time(s)','FontSize',13);
        ylabel('Rate Output (V)','FontSize',13);
        
        % Save  Last plot with data table to an image/ppt
        PlotTitle = strcat('Rate_Plots_fig', num2str(get(gcf,'Number')), '_d', date);
        if(params.SaveIMG)
            print('-dbmp ',gcf,fullfile(params.resultsDIR, PlotTitle), '-r400');
        end
        if(params.savePPT)
            saveppt(pptfile,char(PlotTitle),32, '-r400');
        end
    end
end

%% Single Sided Scale Factor Plot
h(end+1) = figure;
hold on;
plot(Vpeak_data(:,1),Vpeak_data(:,2));

title('Scale Factor (single Sided)','FontSize',18);
xlabel('Rotation Rate (deg/sec)','FontSize',13);
ylabel('Rate Output Amplitude (mV)','FontSize',13);

p = polyfit(Vpeak_data(:,1),Vpeak_data(:,2),1);
fit_line = p(1)* Vpeak_data(:,1) + p(2);
plot(Vpeak_data(:,1),fit_line, 'g');
hold off;
ht = text(0.1,0.8,{'Linear Fit:'; [num2str(p(1)) '*rate + ' num2str(p(2))]},'FontSize',15,'units','normalized');
% Save to a Picture/ppt
PlotTitle = strcat('Scale Factor Single Sided)', num2str(numFig), '_d', date);
if(params.SaveIMG)
    print('-dbmp ',gcf,fullfile(params.resultsDIR, PlotTitle), '-r400');
end
if(params.savePPT)
    saveppt(pptfile,char(PlotTitle),32, '-r400');
end

%% Symmetric Scale Factor Plot
Vpeak_data_sym(:,1) = [flipud(-Vpeak_data(:,1)); Vpeak_data(:,1)];
Vpeak_data_sym(:,2) = [flipud(-Vpeak_data(:,2)); Vpeak_data(:,2)];

h(end+1) = figure;
hold on;
plot(Vpeak_data_sym(:,1), Vpeak_data_sym(:,2), 'b*');

title('Scale Factor','FontSize',18);
xlabel('Rotation Rate (deg/sec)','FontSize',13);
ylabel('Rate Output Amplitude (mV)','FontSize',13);


p_sym = polyfit(Vpeak_data_sym(:,1), Vpeak_data_sym(:,2),1);
fit_line = p_sym(1)* Vpeak_data_sym(:,1) + p_sym(2);
plot(Vpeak_data_sym(:,1),fit_line, 'g');
hold off;
ht = text(0.1,0.8,{'Linear Fit:'; [num2str(p_sym(1)) '*rate']},'FontSize',15,'units','normalized');

% Save to a Picture/ppt
PlotTitle = strcat('Scale Factor', num2str(numFig), '_d', date);
if(params.SaveIMG)
    print('-dbmp ',gcf,fullfile(params.resultsDIR, PlotTitle), '-r400');
end
if(params.savePPT)
    saveppt(pptfile,char(PlotTitle),32, '-r400');
end

ScaleFactor = p_sym(1);
if(nargout == 2)
    varargout = h;
end
%% Display the scale factor information 
disp(' ');
disp(['scale factor = ' num2str(ScaleFactor) ' mV/deg/s']);

end


%% Necessary Functions
function [maxs, I] = maxs(X,k)
%UNTITLED6 Finds k maximum value in each column of X
%   Finds the largest, 2nd largest to kth largest values in each column of
%   X.
%   The first row of maxs contains the maximum value (same as max(x))
%   The second row of maxs contains the second largest value
%   I is the corresponding index for each maximum
% 
% See also max findpeaks

% Check length to ensure k < (# of cols of X)
[m,n] = size(X);
if(k > m)
    error('maxs:kTooLarge',['The choosen k is too large, choose  k < ' m],m)
end

maxs = zeros(k,n);
I = maxs;
    for kN = 1:k
        [maxs(kN,:), I(kN,:)] = max(X);
        for c = 1:n
            X(I(kN,c),c) = NaN;
        end
    end

end

function [t,V] = importRateTableData(filename, startRow, endRow)
%IMPORTFILE Import numeric data from a text file as column vectors.
%   [T,V] = importRateTableData(FILENAME) Reads data from text file FILENAME for the
%   default selection.
%
%   [T,V] = importRateTableData(FILENAME, STARTROW, ENDROW) Reads data from rows
%   STARTROW through ENDROW of text file FILENAME.
%
% Example:
%   [t,V] = importRateTableData('print_00.csv',1, 1002);
%
%    See also TEXTSCAN.

% Auto-generated by MATLAB on 2013/12/05 09:50:23

%% Initialize variables.
delimiter = ',';
if nargin<=2
    startRow = 1;
    endRow = inf;
end

%% Read columns of data as strings:
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%s%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'HeaderLines', startRow(1)-1, 'ReturnOnError', false);
for block=2:length(startRow)
    frewind(fileID);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'HeaderLines', startRow(block)-1, 'ReturnOnError', false);
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% Close the text file.
fclose(fileID);

%% Convert the contents of columns containing numeric strings to numbers.
% Replace non-numeric strings with NaN.
raw = [dataArray{:,1:end-1}];
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

for col=[1,2]
    % Converts strings in the input cell array to numbers. Replaced non-numeric
    % strings with NaN.
    rawData = dataArray{col};
    for row=1:size(rawData, 1);
        % Create a regular expression to detect and remove non-numeric prefixes and
        % suffixes.
        regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
        try
            result = regexp(rawData{row}, regexstr, 'names');
            numbers = result.numbers;
            
            % Detected commas in non-thousand locations.
            invalidThousandsSeparator = false;
            if any(numbers==',');
                thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                if isempty(regexp(thousandsRegExp, ',', 'once'));
                    numbers = NaN;
                    invalidThousandsSeparator = true;
                end
            end
            % Convert numeric strings to numbers.
            if ~invalidThousandsSeparator;
                numbers = textscan(strrep(numbers, ',', ''), '%f');
                numericData(row, col) = numbers{1};
                raw{row, col} = numbers{1};
            end
        catch me
        end
    end
end


%% Replace non-numeric cells with NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),raw); % Find non-numeric cells
raw(R) = {NaN}; % Replace non-numeric cells

%% Allocate imported array to column variable names
t = cell2mat(raw(:, 1));
V = cell2mat(raw(:, 2));
end

