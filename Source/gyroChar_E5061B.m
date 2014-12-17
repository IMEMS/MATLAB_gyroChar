% E5061B Instrument Control Script
%  Under Development 12-16-14
% 
% Author: Curtis Mayberry


% Attribute IDs
AGNA_ATTR_CHANNEL_NUMBER = 1150006;
AGNA_ATTR_CHANNEL_POINTS = 1150007;
% Constants
AGNA_VAL_AGILENT_NA_MEASUREMENT_LOG_MAG = 0;
AGNA_VAL_AGILENT_NA_MEASUREMENT_PHASE = 2;

% Create a device object. 
deviceObj = icdevice('AgNA.mdd', 'USB0::0x0957::0x1309::MY49204103::0::INSTR');

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
CHname = invoke(deviceObj.Channel, 'getchannelname', 1, 20);
CHnumber = invoke(deviceObj.Attributeaccessors(1),...
'getattributeviint32', 'Channel1',AGNA_ATTR_CHANNEL_NUMBER);

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

% Measure Magnitude
invoke(deviceObj.Channelmeasurement,...
    'channelmeasurementcreate', 'Channel1:Measurement1',0,1);
invoke(deviceObj.Attributeaccessors(1), 'setattributeviint32', 'Channel1:Measurement1',1150014,AGNA_VAL_AGILENT_NA_MEASUREMENT_LOG_MAG);
invoke(deviceObj.Channelmeasurement,...
 'channelmeasurementdatatomemory','Channel1:Measurement1');
MAG = zeros(1,1601);
[MAG, MAG_Size] = invoke(deviceObj.Channelmeasurement,...
'channelmeasurementfetchformatted','Channel1:Measurement1',...
1601,MAG);
Freqs = zeros(1,1601);
[Freqs, Freqs_Size] = invoke(deviceObj.Channelmeasurement,...
    'channelmeasurementfetchx','Channel1:Measurement1',1601,Freqs);
MeasNameMag = invoke(deviceObj.Channelmeasurement,'getchannelmeasurementname','Channel1',1,20);
figure;
plot(Freqs,MAG)

% Measure Phase
invoke(deviceObj.Channelmeasurement,...
    'channelmeasurementcreate', 'Channel1:Measurement2',0,1);
invoke(deviceObj.Attributeaccessors(1), 'setattributeviint32', 'Channel1:Measurement2',1150014,AGNA_VAL_AGILENT_NA_MEASUREMENT_PHASE);
invoke(deviceObj.Channelmeasurement,...
 'channelmeasurementdatatomemory','Channel1:Measurement2');
invoke(deviceObj.Channelmeasurement,...
 'channelmeasurementdatatomemory','Channel1:Measurement2');
Phase = zeros(1,1601);
[Phase, MAG_Size] = invoke(deviceObj.Channelmeasurement,...
'channelmeasurementfetchformatted','Channel1:Measurement2',...
1601,Phase);
Freqs = zeros(1,1601);
[Freqs, Freqs_Size] = invoke(deviceObj.Channelmeasurement,...
    'channelmeasurementfetchx','Channel1:Measurement2',1601,Freqs);
figure;
plot(Freqs,Phase)

% Report
disp(' ');
disp('Setup Complete');
disp(['Number of points: ' num2str(nPts)]);
disp(['Number of points: ' num2str(nPts)]);


% % Close device
% groupObj = get(deviceObj, 'Channel');
% groupObj = groupObj(1);
% invoke(deviceObj,'Close');

disconnect(deviceObj);
