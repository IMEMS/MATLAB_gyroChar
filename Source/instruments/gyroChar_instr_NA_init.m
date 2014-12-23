%% gyroChar_instr_NA_init
function [deviceObj] = gyroChar_instr_NA_init(HWOBJ, varargin)
% gyroChar_instr_NA_init Initializes network analyzer instrument control 
%  Also initializes usefult constants in deviceObj.UserData
% 
%  USAGE
%   gyroChar_instr_NA_init(HWOBJ, ...)
% 
%  INPUTS
%   HWOBJ - Visa resources name of the hardware network analyzer
%    Currently only tested with an Agilent E5061B Network Analyzer
%  OPTIONAL INPUT PARAMETER PAIRS
%   pwr RFpwr p - Output power (dBm) {default: -45dBm}
%   numPts npts - number of points to plot {default: 1601 (E5061B MAX)}
%   ifbw - IF bandwidth (Hz) {default: 15Hz}
%   centerFreq cf - center frequency (Hz) {default: 6700Hz}
%   span s - span (Hz) {default: 100Hz}
%   triggerMode TrigMode - Trigger mode
%    0 = AGNA_VAL_TRIGGER_MODE_CONTINUOUS
%    1 = AGNA_VAL_TRIGGER_MODE_HOLD
% 
%  OUTPUTS
%   deviceObj - network analyzer instrument object
% 
%  EXAMPLES
%   na = gyroChar_instr_NA_init('USB0::0x0957::0x1309::MY49204103::0::INSTR');
% 
% Author: Curtis Mayberry
% 
% Tested on an Agilent E5061B Network Analyzer
% Compatible with: E5070B, E5071B, E5071C, E5072A, E5061A, E5062A, E5061B,
%  E5063A, E8361A, E8362B, E8363B, E8364B, E8361C, E8362C, E8363C, E8364C, 
%  N5230A, N5230C, N5241A, N5242A, N5244A, N5245A, N5264A, N5247A, N5221A, 
%  N5222A, N5224A, N5225A, N5227A, N5239A, N5231A, N5232A, N5234A, N5235A

%% Check and parse inputs
if numel(varargin)>0
    validParameters = {{'ifbw'},{'numPts','npts'},{'pwr', 'RFpwr', 'p'},...
                       {'triggerMode','TrigMode'},{'centerFreq','cf'},...
                       {'span','s'}};
    params = validateInput(varargin, validParameters);
else
    % Just make addlParms an empty struct so that 'isfield' doesn't error
    % out.
    params=struct;
end
% Options
if ~isfield(params,'pwr')
    params.pwr = -45; % dBm
end
if ~isfield(params,'ifbw')
    params.ifbw = 15; % IF bandwidth in Hz
end
if ~isfield(params,'numPts')
    params.numPts = 1601; % Number of points
end
if ~isfield(params,'triggerMode')
    params.triggerMode = 0; % 0 = AGNA_VAL_TRIGGER_MODE_CONTINUOUS
                            % 1 = AGNA_VAL_TRIGGER_MODE_HOLD
end
if ~isfield(params,'centerFreq')
    params.centerFreq = 6700; % Hz
end
if ~isfield(params,'span')
    params.span = 100; % Hz
end
%% Connect to the network analyzer
% Create a device object. 
deviceObj = icdevice('AgNA.mdd', HWOBJ);

% Connect device object to hardware.
connect(deviceObj);

% Check Instrument Model
if(~strcmp(get(deviceObj, 'InstrumentModel'),...
           'Agilent Technologies E5061B'))
   error('gyroChar:fyroChar_FreqResponseAuto','Wrong Instrument');
end

% Initialize
invoke(deviceObj, 'initwithoptions', HWOBJ, true, false, '');

%% Constants from AgNA.h
% Attribute IDs
deviceObj.UserData.AGNA_ATTR_CHANNEL_IF_BANDWIDTH        = 1150005;
deviceObj.UserData.AGNA_ATTR_CHANNEL_NUMBER              = 1150006;
deviceObj.UserData.AGNA_ATTR_CHANNEL_POINTS              = 1150007;
deviceObj.UserData.AGNA_ATTR_CHANNEL_TRIGGER_MODE        = 1150013;
deviceObj.UserData.AGNA_ATTR_CHANNEL_MEASUREMENT_FORMAT  = 1150014;
deviceObj.UserData.AGNA_ATTR_TRIGGER_SOURCE              = 1150042;
% Constants
deviceObj.UserData.AGNA_VAL_AGILENT_NA_MEASUREMENT_LOG_MAG = 0;
deviceObj.UserData.AGNA_VAL_AGILENT_NA_MEASUREMENT_PHASE   = 2;
% Marker Search Type Enum AgNA_ChannelMeasurementMarkerSearch
deviceObj.UserData.AGNA_VAL_AGILENT_NA_MARKER_SEARCH_TYPE_TARGET       = 0;
deviceObj.UserData.AGNA_VAL_AGILENT_NA_MARKER_SEARCH_TYPE_TARGET_LEFT  = 1;
deviceObj.UserData.AGNA_VAL_AGILENT_NA_MARKER_SEARCH_TYPE_TARGET_RIGHT = 2;
deviceObj.UserData.AGNA_VAL_AGILENT_NA_MARKER_SEARCH_TYPE_MAX          = 3;
deviceObj.UserData.AGNA_VAL_AGILENT_NA_MARKER_SEARCH_TYPE_MIN          = 4;
deviceObj.UserData.AGNA_VAL_AGILENT_NA_MARKER_SEARCH_TYPE_PEAK         = 5;
deviceObj.UserData.AGNA_VAL_AGILENT_NA_MARKER_SEARCH_TYPE_PEAK_LEFT    = 6;
deviceObj.UserData.AGNA_VAL_AGILENT_NA_MARKER_SEARCH_TYPE_PEAK_RIGHT   = 7;
% attribute AGNA_ATTR_CHANNEL_TRIGGER_MODE
deviceObj.UserData.AGNA_VAL_TRIGGER_MODE_HOLD                          = 1;
deviceObj.UserData.AGNA_VAL_TRIGGER_MODE_CONTINUOUS                    = 0;
% attribute AGNA_ATTR_TRIGGER_SOURCE
deviceObj.UserData.AGNA_VAL_AGILENT_NA_TRIGGER_SOURCE_INTERNAL         = 0;
deviceObj.UserData.AGNA_VAL_AGILENT_NA_TRIGGER_SOURCE_EXTERNAL         = 1;
deviceObj.UserData.AGNA_VAL_AGILENT_NA_TRIGGER_SOURCE_BUS              = 2;
deviceObj.UserData.AGNA_VAL_AGILENT_NA_TRIGGER_SOURCE_MANUAL           = 3;

% Save Parameters in deviceObj
deviceObj.UserData.params = params;

%% Configure the network analyzer

% Set RF Power Level
invoke(deviceObj.Channelsourcepower(1),...
       'channelsourcepowersetlevel', 'Channel1',0,params.pwr);

% Set Frequency Range
invoke(deviceObj.Channelstimulusrange(1),...
       'channelstimulusrangeconfigurecenterspan',...
       'Channel1', params.centerFreq, params.span);
   
% Set IF Bandwidth
invoke(deviceObj.Attributeaccessors(1), 'setattributevireal64',...
       'Channel1', deviceObj.UserData.AGNA_ATTR_CHANNEL_IF_BANDWIDTH, params.ifbw);
   
   
% Set Number of Points
invoke(deviceObj.Attributeaccessors(1), 'setattributeviint32',...
       'Channel1',deviceObj.UserData.AGNA_ATTR_CHANNEL_POINTS,params.numPts);
if(invoke(deviceObj.Attributeaccessors(1), 'getattributeviint32', 'Channel1',...
          deviceObj.UserData.AGNA_ATTR_CHANNEL_POINTS) ~= params.numPts)
    warning('Number of points not set correctly');
end

%% Report
disp(' ');
disp('Setup Complete');
disp(['Number of points: ' num2str(params.numPts)]);
disp(['IF bandwidth: ' num2str(params.ifbw)]);
disp(['Power: ' num2str(params.pwr)]);
disp(['Center Freq: ' num2str(params.centerFreq)]);
disp(['Span: ' num2str(params.span)]);

end