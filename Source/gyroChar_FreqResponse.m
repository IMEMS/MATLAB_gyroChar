function [freqs, mag, phase, h]= gyroChar_FreqResponse(filename,date,span,varargin)
% gyroChar_Spectrum Generates the frequency response from an Agilent E5061B
%  network analyzer gain-phase port sweep
% 
% [freqs, mag, phase, h]= gyroChar_FreqResponse(filename,date,span);
% 
%  INPUTS
%   filename - base name of the files.  The files must be named with the
%    following convention:
%    {filename}_NP_MAG.csv
%    {filename}_NP_PHASE.csv
%    {filename}_AP_MAG.csv
%    {filename}_AP_PHASE.csv
%   date - date data was taken
%   span - span of the data
%  OPTIONAL INPUT PARAMETER PAIRS
%   plot, p - enable data plotting {default: true}
%   folder, f - folder containing the data files {default:current directory}
%   saveIMG, img - Enable saving to a .bmp image {default:true}
%   savePPT, ppt - Enable saving to a power point presentation 
%    {default: false}
%   resultsDIR - name of the directory to save the results
%    {default: 'Frequency Response Results'}
% 
% OUTPUTS
%  freqs - frequencies wt which the magnitude and phase are measured
%   freqs(:,1) = NP freqs    freqs(:,2) = AP freqs 
%  mag - magnitude of response
%   mag(:,1) = NP mag    mag(:,2) = AP mag 
%  phase - phase of response
%   phase(:,1) = NP phase    mag(:,2) = AP phase 
%  h - figure handles
%   h(1) - NP figure   h(2) - AP figure   h(3) - NP and AP figure
% 
% Author: Curtis Mayberry
% 
% See also gyroChar_ScaleFactor gyroChar_Spectrum gyroChar_E5061B_Bode
% 

%% Check and parse inputs
if numel(varargin)>0
    validParameters = {{'plot', 'p'},{'folder','f'}...
                       {'saveIMG','img'},{'savePPT','ppt'},...
                       {'resultsDIR','results directory','results dir'}};
    params = validateInput(varargin, validParameters);
else
    % Just make addlParms an empty struct so that 'isfield' doesn't error
    % out.
    params=struct;
end
% Options
if ~isfield(params,'folder')
params.folder = pwd;
end
% Plottting Options
if ~isfield(params,'plot')
    params.plot = true;
else h = [];
end
% SAVE OPTIONS
% Saves the figures to a .bmp picture
if ~isfield(params,'saveIMG')
    params.saveIMG = true;
end
% Saves figure to a power point presentation
if ~isfield(params,'savePPT')
    params.savePPT = false;
end
if ~isfield(params,'resultsDIR')
    params.resultsDIR = 'Frequency Response Results';
end

FILE_NAME_NP = fullfile(params.folder, [filename '_NP']); % Frequency data from nodal pickoff
FILE_NAME_AP = fullfile(params.folder, [filename '_AP']); % Frequency data from antinodal pickoff
pptfile = fullfile(params.resultsDIR, ['FreqResponse_' num2str(span) 'HzSpan_d' date '.ppt']);

%% Check Inputs
% if(length(amp) ~= length(fileNumber))
%     error('RateTableDataAnalysis:BadInput', 'Each amplitude must have a corresponding file number.  They are not the same length currently');
% end

%% Open data and plot individually

% Setup Results Directory
if(~isdir(params.resultsDIR))
    [SUCCESS,~,~] = mkdir(params.resultsDIR);
    if(~SUCCESS) disp('mkdir failed');
    end
end

% Initialize ppt file for batch processing
if(params.savePPT)
    ppt_obj = saveppt2(pptfile,'init');
end

% Plot Nodal Data
[freqs(:,1), mag(:,1), phase(:,1), h(1)] = E5061B_Bode(FILE_NAME_NP, 'Nodal Pickoff Bode');
PlotTitle = strcat('NP_Spectrum_d', date);
if(params.saveIMG)
    print('-dbmp ',gcf,fullfile(params.resultsDIR, PlotTitle), '-r400');
end
if(params.savePPT)
    saveppt2('ppt', ppt_obj);
%     saveppt(pptfile,char(PlotTitle),32, '-r400');
end

% Antinodal
[freqs(:,2), mag(:,2), phase(:,2), h(2)] = E5061B_Bode(FILE_NAME_AP, 'Antinodal Pickoff Bode');
PlotTitle = strcat('AP_Spectrum', '_d', date);
if(params.saveIMG)
    print('-dbmp ',gcf,fullfile(params.resultsDIR, PlotTitle), '-r400');
end
if(params.savePPT)
     saveppt2('ppt', ppt_obj);
%     saveppt(pptfile,char(PlotTitle),32, '-r400');
end

%% Plot
if(params.plot)
    if(params.savePPT && exist(pptfile,'file')) %Clear Previous Powerpoint Version
        delete(pptfile)
    end

    % Find Resonant peaks
    [~,NP_res_i] = max(mag(:,1));
    NP_res = freqs(NP_res_i,1);
    NP_res_mag = mag(NP_res_i,1);
    NP_res_pha = phase(NP_res_i,1);
    disp(' ');
    disp(['NP Resonant Frequency: ' num2str(NP_res/1000) ' kHz']);
    disp(['NP Magnitude @ F_res: ' num2str(NP_res_mag) ' dB']);
    disp(['NP Phase @ F_res: ' num2str(NP_res_pha) ' deg']);

    [~,AP_res_i] = max(mag(:,2));
    AP_res = freqs(AP_res_i,2);
    AP_res_mag = mag(AP_res_i,2);
    AP_res_pha = phase(AP_res_i,2);
    disp(' ');
    disp(['AP Resonant Frequency: ' num2str(AP_res/1000) ' kHz']);
    disp(['AP Magnitude @ F_res: ' num2str(AP_res_mag) ' dB']);
    disp(['AP Phase @ F_res: ' num2str(AP_res_pha) ' deg']);

    %% Plot both NP and AP Bodes together
    h(3) = figure;
    subplot(2,1,1);
    hold on;
    semilogx(freqs(:,1),mag(:,1),freqs(:,2),mag(:,2));
    YlimsMag = get(gca,'YLim');
    line([NP_res NP_res], [YlimsMag(1) YlimsMag(2)],'Color', 'r','LineStyle','--');
    hold off;
    axis([min(freqs(:,1)) max(freqs(:,1)) YlimsMag(1) YlimsMag(2)]);
    title('AFE Anti-nodal and Nodal Pickoff Spectrums','FontSize',14);
    % title('Magnitude','FontSize',14);
    xlabel('Frequency (Hz)','FontSize',12);
    ylabel('Mag(dB)','FontSize',12);
    legend('Nodal Pickoff', 'Antinodal Pickoff','Location','SouthEast');
    text(6708,-32,['f_r_e_s = ' num2str(NP_res/1000,4) 'kHz']);
    text(6708,-10,['IL = ' num2str(NP_res_mag,3) 'dB']);

    subplot(2,1,2);
    hold on;
    semilogx(freqs(:,1),phase(:,1),freqs(:,2),phase(:,2));
    line([min(freqs(:,1)) NP_res], [NP_res_pha NP_res_pha],'Color', 'r','LineStyle','--');
    hold off;
    YlimsPhase = get(gca,'YLim');
    axis([min(freqs(:,1)) max(freqs(:,1)) YlimsPhase(1) YlimsPhase(2)]);
    % title('Phase','FontSize',14);
    xlabel('Frequency (Hz)','FontSize',12);
    ylabel('Phase(deg)','FontSize',12);
    text(6708,25,['\Phi(f_r_e_s) = ' num2str(NP_res_pha,3) '^o']);


    %% Save figure
    PlotTitle = strcat('NP_AP_Spectrum', '_d', date);
    if(params.saveIMG)
        print('-dbmp ',gcf,fullfile(params.resultsDIR, PlotTitle), '-r400');
    end
    if(params.savePPT)
        saveppt2('ppt', ppt_obj);
    %     saveppt(pptfile,char(PlotTitle),32, '-r400');
    end

    if(params.savePPT)
        saveppt2(pptfile,'ppt',ppt_obj,'close');
    end
end
end
