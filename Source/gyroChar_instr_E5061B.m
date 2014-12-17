function [Freqs, MAG, Phase] = gyroChar_instr_E5061B(HWOBJ)
% E5061B Instrument Control Script
%  Under Development 12-16-14
% 
% Author: Curtis Mayberry

% Attribute IDs
% AGNA_ATTR_CHANNEL_NUMBER = 1150006;
AGNA_ATTR_CHANNEL_POINTS = 1150007;
% Constants
AGNA_VAL_AGILENT_NA_MEASUREMENT_LOG_MAG = 0;
AGNA_VAL_AGILENT_NA_MEASUREMENT_PHASE = 2;

%% Check and parse inputs
if numel(varargin)>0
    validParameters = {{'folder','f'},{'saveCSV'}...
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
if ~isfield(params,'folder')
params.saveCSV = false;
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
invoke(deviceObj, 'initwithoptions', 'USB0::0x0957::0x1309::MY49204103::0::INSTR', true,false,'');

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
       'Channel1',7000, 100);

% Set Number of Points
invoke(deviceObj.Attributeaccessors(1), 'setattributeviint32', 'Channel1',AGNA_ATTR_CHANNEL_POINTS,1601);
nPts = invoke(deviceObj.Attributeaccessors(1),...
'getattributeviint32', 'Channel1',AGNA_ATTR_CHANNEL_POINTS);
if(nPts ~= 1601)
warning('Number of points not set correctly');
end

%% Measure Frequency Response

% Measure Magnitude
invoke(deviceObj.Channelmeasurement,...
    'channelmeasurementcreate', 'Channel1:Measurement1',0,1);
invoke(deviceObj.Attributeaccessors(1), 'setattributeviint32', 'Channel1:Measurement1',1150014,AGNA_VAL_AGILENT_NA_MEASUREMENT_LOG_MAG);
invoke(deviceObj.Channelmeasurement,...
 'channelmeasurementdatatomemory','Channel1:Measurement1');
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
    'channelmeasurementcreate', 'Channel1:Measurement2',0,1);
invoke(deviceObj.Attributeaccessors(1), 'setattributeviint32', 'Channel1:Measurement2',1150014,AGNA_VAL_AGILENT_NA_MEASUREMENT_PHASE);
invoke(deviceObj.Channelmeasurement,...
 'channelmeasurementdatatomemory','Channel1:Measurement2');
invoke(deviceObj.Channelmeasurement,...
 'channelmeasurementdatatomemory','Channel1:Measurement2');
Phase = zeros(1,1601);
[Phase, ~] = invoke(deviceObj.Channelmeasurement,...
'channelmeasurementfetchformatted','Channel1:Measurement2',...
1601,Phase);
Freqs = zeros(1,1601);
[Freqs, ~] = invoke(deviceObj.Channelmeasurement,...
    'channelmeasurementfetchx','Channel1:Measurement2',1601,Freqs);

%% Save data
if(params.saveCSV)
    csvwrite(CSVname,[Freqs MAG],,);
end

% Report
disp(' ');
disp('Setup Complete');
disp(['Number of points: ' num2str(nPts)]);


% % Close device
% groupObj = get(deviceObj, 'Channel');
% groupObj = groupObj(1);
% invoke(deviceObj,'Close');

disconnect(deviceObj);

end