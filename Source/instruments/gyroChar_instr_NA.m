function [Freqs, MAG, Phase, M1] = gyroChar_instr_NA(HWOBJ, date, centerFreq, span, varargin)
% Network Analyzer Instrument Control function
% 
% 
% 
% Author: Curtis Mayberry
% 
% Tested on an Agilent E5061B Network Analyzer
% Compatible with: E5070B, E5071B, E5071C, E5072A, E5061A, E5062A, E5061B,
%  E5063A, E8361A, E8362B, E8363B, E8364B, E8361C, E8362C, E8363C, E8364C, 
%  N5230A, N5230C, N5241A, N5242A, N5244A, N5245A, N5264A, N5247A, N5221A, 
%  N5222A, N5224A, N5225A, N5227A, N5239A, N5231A, N5232A, N5234A, N5235A

%% Constants from AgNA.h
% Attribute IDs
AGNA_ATTR_CHANNEL_IF_BANDWIDTH        = 1150005;
% AGNA_ATTR_CHANNEL_NUMBER              = 1150006;
AGNA_ATTR_CHANNEL_POINTS              = 1150007;
AGNA_ATTR_CHANNEL_TRIGGER_MODE        = 1150013;
AGNA_ATTR_CHANNEL_MEASUREMENT_FORMAT  = 1150014;
% Constants
AGNA_VAL_AGILENT_NA_MEASUREMENT_LOG_MAG = 0;
AGNA_VAL_AGILENT_NA_MEASUREMENT_PHASE = 2;
% Marker Search Type Enum AgNA_ChannelMeasurementMarkerSearch
% AGNA_VAL_AGILENT_NA_MARKER_SEARCH_TYPE_TARGET       = 0;
% AGNA_VAL_AGILENT_NA_MARKER_SEARCH_TYPE_TARGET_LEFT  = 1;
% AGNA_VAL_AGILENT_NA_MARKER_SEARCH_TYPE_TARGET_RIGHT = 2;
AGNA_VAL_AGILENT_NA_MARKER_SEARCH_TYPE_MAX          = 3;
% AGNA_VAL_AGILENT_NA_MARKER_SEARCH_TYPE_MIN          = 4;
% AGNA_VAL_AGILENT_NA_MARKER_SEARCH_TYPE_PEAK         = 5;
% AGNA_VAL_AGILENT_NA_MARKER_SEARCH_TYPE_PEAK_LEFT    = 6;
% AGNA_VAL_AGILENT_NA_MARKER_SEARCH_TYPE_PEAK_RIGHT   = 7;
% attribute AGNA_ATTR_CHANNEL_TRIGGER_MODE
AGNA_VAL_TRIGGER_MODE_HOLD                            = 1;
AGNA_VAL_TRIGGER_MODE_CONTINUOUS                      = 0;

%% Check and parse inputs
if numel(varargin)>0
    validParameters = {{'ifbw'},{'numPts','npts'},...
                       {'triggerMode','TrigMode'},...
                       {'folder','f'},{'saveCSV'},...
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
if ~isfield(params,'saveCSV')
params.saveCSV = false;
end
if ~isfield(params,'ifbw')
params.ifbw = 15; % IF bandwidth in Hz
end
if ~isfield(params,'numPts')
params.numPts = 1601; % Number of points
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

% Check Channel Information
% CHname = invoke(deviceObj.Channel, 'getchannelname', 1, 20);
% CHnumber = invoke(deviceObj.Attributeaccessors(1),...
% 'getattributeviint32', 'Channel1',AGNA_ATTR_CHANNEL_NUMBER);

%% Configure the network analyzer

% Set RF Power Level
invoke(deviceObj.Channelsourcepower(1),...
       'channelsourcepowersetlevel', 'Channel1',0,-45);

% Set Frequency Range
invoke(deviceObj.Channelstimulusrange(1),...
       'channelstimulusrangeconfigurecenterspan',...
       'Channel1',centerFreq, span);
   
% Set IF Bandwidth
invoke(deviceObj.Attributeaccessors(1), 'getattributevireal64',...
       'Channel1',AGNA_ATTR_CHANNEL_IF_BANDWIDTH,params.ifbw);
   
   
% Set Number of Points
invoke(deviceObj.Attributeaccessors(1), 'setattributeviint32',...
       'Channel1',AGNA_ATTR_CHANNEL_POINTS,1601);
nPts = invoke(deviceObj.Attributeaccessors(1),...
              'getattributeviint32', 'Channel1',AGNA_ATTR_CHANNEL_POINTS);
if(nPts ~= 1601)
warning('Number of points not set correctly');
end

%% Measure Frequency Response

invoke(deviceObj.Attributeaccessors(1), 'setattributeviint32',...
       'Channel1:Measurement2',AGNA_ATTR_CHANNEL_TRIGGER_MODE,...
       AGNA_VAL_TRIGGER_MODE_CONTINUOUS);
invoke(deviceObj.Channel(1),'channeltriggersweep',...
       'Channel1',100);
% invoke(deviceObj.Channel(1),'channelasynchronoustriggersweep',...
%        'Channel1');

invoke(deviceObj.Attributeaccessors(1), 'setattributeviint32',...
       'Channel1:Measurement2',AGNA_ATTR_CHANNEL_TRIGGER_MODE,...
       AGNA_VAL_TRIGGER_MODE_HOLD);

% Measure Magnitude
invoke(deviceObj.Channelmeasurement,...
    'channelmeasurementcreate', 'Channel1:Measurement1',1,2);
invoke(deviceObj.Attributeaccessors(1), 'setattributeviint32',...
       'Channel1:Measurement1',AGNA_ATTR_CHANNEL_MEASUREMENT_FORMAT,...
       AGNA_VAL_AGILENT_NA_MEASUREMENT_LOG_MAG);
% invoke(deviceObj.Channelmeasurement,...
%  'channelmeasurementdatatomemory','Channel1:Measurement1');
MAG = zeros(1,1601);
[MAG, ~] = invoke(deviceObj.Channelmeasurement,...
'channelmeasurementfetchformatted','Channel1:Measurement1',...
1601,MAG);
% Freqs = zeros(1,1601);
% [Freqs, ~] = invoke(deviceObj.Channelmeasurement,...
%     'channelmeasurementfetchx','Channel1:Measurement1',1601,Freqs);
% MeasNameMag = invoke(deviceObj.Channelmeasurement,'getchannelmeasurementname','Channel1',1,20);

% Measure Phase
invoke(deviceObj.Channelmeasurement,...
    'channelmeasurementcreate', 'Channel1:Measurement2',1,2);
invoke(deviceObj.Attributeaccessors(1), 'setattributeviint32',...
       'Channel1:Measurement2',AGNA_ATTR_CHANNEL_MEASUREMENT_FORMAT,...
       AGNA_VAL_AGILENT_NA_MEASUREMENT_PHASE);
Phase = zeros(1,1601);
[Phase, ~] = invoke(deviceObj.Channelmeasurement,...
'channelmeasurementfetchformatted','Channel1:Measurement2',...
1601,Phase);
Freqs = zeros(1,1601);
[Freqs, ~] = invoke(deviceObj.Channelmeasurement,...
    'channelmeasurementfetchx','Channel1:Measurement2',1601,Freqs);

%% Measure Peak

% Marker 1
invoke(deviceObj.Channelmeasurementmarker,'channelmeasurementmarkeractivate',...
       'Channel1:Measurement1:Marker1');
invoke(deviceObj.Channelmeasurementmarker,'channelmeasurementmarkersearch',...
       'Channel1:Measurement1:Marker1',AGNA_VAL_AGILENT_NA_MARKER_SEARCH_TYPE_MAX);
[M1.Real,M1.Imag] = invoke(deviceObj.Channelmeasurementmarker,...
                           'channelmeasurementmarkerqueryvalue',...
                           'Channel1:Measurement1:Marker1');
M1.mag = abs(M1.Real+1i*M1.Imag);
M1.phase = angle(M1.Real+1i*M1.Imag);
[M1.bandwidth,M1.CenterFreq,M1.Q,M1.IL] = invoke(deviceObj.Channelmeasurementmarker,...
 'channelmeasurementmarkerquerybandwidth','Channel1:Measurement1:Marker1');

%% Save data
if(params.saveCSV)
%     csvwrite(CSVname,[Freqs MAG],,);
end

% Report
disp(' ');
disp('Setup Complete');
disp(['Number of points: ' num2str(nPts)]);
disp(['Peak Frequency: ' num2str(M1.CenterFreq)]);
disp(['Peak Q: ' num2str(M1.CenterFreq)]);
disp(['Peak IL: ' num2str(M1.IL)]);
% % Close device
% groupObj = get(deviceObj, 'Channel');
% groupObj = groupObj(1);
% invoke(deviceObj,'Close');

disconnect(deviceObj);
delete(deviceObj);
clear deviceObj;

end