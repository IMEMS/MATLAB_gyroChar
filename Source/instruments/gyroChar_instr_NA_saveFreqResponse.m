%% gyroChar_instr_NA_save
function deviceObj = gyroChar_instr_NA_saveFreqResponse(deviceObj, varargin)
%% gyroChar_instr_NA_save Save data in a variety of formats
% 
%  USAGE
%   deviceObj = gyroChar_instr_NA_saveFreqResponse(deviceObj, ...)
% 
%  INPUTS
%   deviceObj - 
%  OPTIONAL INPUT PARAMETER PAIRS
% 
%  OUTPUTS
% 
%  EXAMPLES
% 
% Author: Curtis Mayberry
% 
% see also

%% Check and parse inputs
% if numel(varargin)>0
%     validParameters = {{'params','p'},{'folder','f'},...
%                        {'fh','figureHandle'},...
%                        {'saveIMG','img'},{'savePPT','ppt'},...
%                        {'pptFile','pptf'},...
%                        {'saveCSV'},{'saveMfile','saveM','sm'},...
%                        {'dataDIR','data directory','data dir'},...
%                        {'resultsDIR','results directory','results dir'}};
%     params = validateInput(varargin, validParameters);
% else
%     % Just make addlParms an empty struct so that 'isfield' doesn't error
%     % out.
%     params=struct;
% end
% % Options
% if isfield(params,'params')
%     params = updateParams(params,params.params);
% end
% if ~isfield(params,'folder')
%     params.folder = pwd;
% end
% if ~isfield(params,'fh')
%     params.fh = [];
% end
% if ~isfield(params,'saveIMG')
%     params.saveIMG = false;
% end
% if ~isfield(params,'saveCSV')
%     params.saveCSV = false;
% end
% if ~isfield(params,'savePPT')
%     params.savePPT = false;
% end
% if ~isfield(params,'pptFile')
%     params.pptFile = 'Frequency Response.ppt';
% end
% if ~isfield(params,'resultsDIR')
%     params.resultsDIR = 'Frequency Response Results';
% end



validParameters = {{{'params','p'},[]},{{'folder','f'},pwd},...
                   {{'fh','figureHandle'}, []},...
                   {{'saveIMG','img'},false},...
                   {{'savePPT','ppt'},false},...
                   {{'pptFile','pptf'},'Frequency Response.ppt'},...
                   {{'saveCSV'},false},...
                   {{'saveMfile','saveM','sm'},false},...
                   {{'dataDIR','data directory','data dir'},...
                    'Frequency Response Data'},...
                   {{'resultsDIR','results directory','results dir'},...
                    'Frequency Response Results'},...
                   {{'date','d'},datestr(now,'dd-mmm-yy')}};
if numel(varargin)>0
    params = validateInputDefault(varargin, validParameters);
else
    % Just make addlParms an empty struct so that 'isfield' doesn't error
    % out.
%     params=struct;
    params = validateInputDefault(cell(0,0), validParameters);
end

PlotTitle = ['Frequency Response ' params.date];

%% Save figure
if(~isempty(params.fh))
    if(params.saveIMG)
        print('-dbmp ',params.fh,fullfile(params.folder, params.resultsDIR, PlotTitle), '-r400');
    end
    if(params.savePPT)
        pptfile = fullfile(params.folder, params.resultsDIR, params.pptFile);
        saveppt(pptfile,char(PlotTitle),32, '-r400');
    end
else
    warning('figure not saved because no figure handle was given');
end

%% Save CSV
if(params.saveCSV)
    % Save Magnitude
    fid = fopen(params.CSVfile,'w');
    fprintf(fid,'# Channel 1\n');
    fprintf(fid,'# Trace 1\n');
    fprintf(fid,'Frequency, Formatted Data, Formatted Data\n');
    fclose(fid);
    dlmwrite(params.CSVname,[Freqs MAG],',',3,1,'-append','precision',11);
    % Save Phase
    fid = fopen(params.CSVfile,'w');
    fprintf(fid,'# Channel 1\n');
    fprintf(fid,'# Trace 2\n');
    fprintf(fid,'Frequency, Formatted Data, Formatted Data\n');
    fclose(fid);
    dlmwrite(params.CSVname,[Freqs MAG],',',3,1,'-append','precision',11);
end

%% Save M-file
if(params.saveM)
    save(params.mFile, deviceObj.UserData);
end

end
