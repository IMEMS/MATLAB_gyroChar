%% gyroChar_instr_NA_initFreqResponse
function deviceObj = gyroChar_instr_NA_initFreqResponse(deviceObj, varargin)
%% gyroChar_instr_NA_initFreqResponse Initializes frequency response traces
% 
%  USAGE
%   deviceObj = gyroChar_instr_NA_initFreqResponse(deviceObj, ...)
% 
%  INPUTS
%   deviceObj - network analyzer instrument object
%  OPTIONAL INPUT PARAMETER PAIRS
%   magFormat mf - format of the magnitude trace
%    {default: AGNA_VAL_AGILENT_NA_MEASUREMENT_LOG_MAG}
%    Options:
%     deviceObj.UserData.AGNA_VAL_AGILENT_NA_MEASUREMENT_LOG_MAG
%     deviceObj.UserData.AGNA_VAL_AGILENT_NA_MEASUREMENT_LIN_MAG
%  OUTPUTS
%   deviceObj - network analyzer instrument object
% 
%  EXAMPLES
%   na = gyroChar_instr_NA_initFreqResponse(na);
% 
% Author: Curtis Mayberry
% 
% Tested on an Agilent E5061B Network Analyzer
% Compatible with: E5070B, E5071B, E5071C, E5072A, E5061A, E5062A, E5061B,
%  E5063A, E8361A, E8362B, E8363B, E8364B, E8361C, E8362C, E8363C, E8364C, 
%  N5230A, N5230C, N5241A, N5242A, N5244A, N5245A, N5264A, N5247A, N5221A, 
%  N5222A, N5224A, N5225A, N5227A, N5239A, N5231A, N5232A, N5234A, N5235A
% 
% see also

%% Check and parse inputs
if numel(varargin)>0
    validParameters = {{'magFormat', 'mf'}};
    params = validateInput(varargin, validParameters);
else
    % Just make addlParms an empty struct so that 'isfield' doesn't error
    % out.
    params=struct;
end
% Options
if ~isfield(params,'magFormat')
    params.magFormat = deviceObj.UserData.AGNA_VAL_AGILENT_NA_MEASUREMENT_LOG_MAG;
end
deviceObj.UserData.params.magFormat = params.magFormat;

%% Initialize measurement of magnitude
invoke(deviceObj.Channelmeasurement,...
       'channelmeasurementcreate', 'Channel1:Measurement1',0,0);
invoke(deviceObj.Attributeaccessors(1), 'setattributeviint32',...
       'Channel1:Measurement1',...
       deviceObj.UserData.AGNA_ATTR_CHANNEL_MEASUREMENT_FORMAT,...
       params.magFormat);
   
%% Initialize measurement of phase
invoke(deviceObj.Channelmeasurement,...
    'channelmeasurementcreate', 'Channel1:Measurement2',0,0);
invoke(deviceObj.Attributeaccessors(1), 'setattributeviint32',...
       'Channel1:Measurement2',...
       deviceObj.UserData.AGNA_ATTR_CHANNEL_MEASUREMENT_FORMAT,...
       deviceObj.UserData.AGNA_VAL_AGILENT_NA_MEASUREMENT_PHASE);
   
end