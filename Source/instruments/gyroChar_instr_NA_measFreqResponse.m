%% gyroChar_instr_NA_MeasFreqResponse
function [deviceObj, Freqs, MAG, Phase, M1] = gyroChar_instr_NA_measFreqResponse(deviceObj, varargin)
% gyroChar_instr_NA_MeasFreqResponse Measures frequency response of the 
%  gain-phase port
% 
%  USAGE
%   [deviceObj, Freqs, MAG, Phase, M1] = gyroChar_instr_NA_MeasFreqResponse(deviceObj, ...)
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

%% Measure Frequency Response

% invoke(deviceObj.Attributeaccessors(1), 'setattributeviint32',...
%        'Channel1:Measurement2',...
%        deviceObj.UserData.AGNA_ATTR_CHANNEL_TRIGGER_MODE,...
%        deviceObj.UserData.AGNA_VAL_TRIGGER_MODE_HOLD);

%% Trigger a sweep

% Set to manual trigger
invoke(deviceObj.Attributeaccessors(1), 'setattributeviint32',...
 'Channel1:Measurement2',deviceObj.UserData.AGNA_ATTR_TRIGGER_SOURCE,...
 deviceObj.UserData.AGNA_VAL_AGILENT_NA_TRIGGER_SOURCE_MANUAL);
invoke(deviceObj.Attributeaccessors(1), 'setattributeviint32',...
 'Channel1:Measurement2', deviceObj.UserData.AGNA_ATTR_CHANNEL_TRIGGER_MODE,...
 deviceObj.UserData.AGNA_VAL_TRIGGER_MODE_CONTINUOUS);
% Trigger
invoke(deviceObj.Channel(1),'channeltriggersweep',...
       'Channel1',100000000);
% invoke(deviceObj.Channel(1),'channelasynchronoustriggersweep',...
%        'Channel1');

%% Measure Magnitude
MAG = zeros(1,1601);
[MAG, ~] = invoke(deviceObj.Channelmeasurement,...
'channelmeasurementfetchformatted','Channel1:Measurement1',...
1601,MAG);
% Freqs = zeros(1,1601);
% [Freqs, ~] = invoke(deviceObj.Channelmeasurement,...
%     'channelmeasurementfetchx','Channel1:Measurement1',1601,Freqs);
% MeasNameMag = invoke(deviceObj.Channelmeasurement,'getchannelmeasurementname','Channel1',1,20);

% Autoscale
invoke(deviceObj.Channelmeasurementtrace(1),...
'channelmeasurementtraceautoscale','Channel1:Measurement1');

%% Measure Phase
Phase = zeros(1,1601);
[Phase, ~] = invoke(deviceObj.Channelmeasurement,...
 'channelmeasurementfetchformatted','Channel1:Measurement2',...
 1601,Phase);
Freqs = zeros(1,1601);
[Freqs, ~] = invoke(deviceObj.Channelmeasurement,...
 'channelmeasurementfetchx','Channel1:Measurement2',1601,Freqs);

% Autoscale
invoke(deviceObj.Channelmeasurementtrace(1),...
'channelmeasurementtraceautoscale','Channel1:Measurement2');

%% Measure Peak

% Marker 1
invoke(deviceObj.Channelmeasurementmarker,'channelmeasurementmarkeractivate',...
       'Channel1:Measurement1:Marker1');
invoke(deviceObj.Channelmeasurementmarker,'channelmeasurementmarkersearch',...
       'Channel1:Measurement1:Marker1',...
       deviceObj.UserData.AGNA_VAL_AGILENT_NA_MARKER_SEARCH_TYPE_MAX);
[M1.Real,M1.Imag] = invoke(deviceObj.Channelmeasurementmarker,...
                           'channelmeasurementmarkerqueryvalue',...
                           'Channel1:Measurement1:Marker1');
M1.mag = abs(M1.Real+1i*M1.Imag);
M1.phase = angle(M1.Real+1i*M1.Imag);
[M1.bandwidth,M1.CenterFreq,M1.Q,M1.IL] = invoke(deviceObj.Channelmeasurementmarker,...
 'channelmeasurementmarkerquerybandwidth','Channel1:Measurement1:Marker1');

%% Clean up, report, and save
% Set to continuos trigger
invoke(deviceObj.Attributeaccessors(1), 'setattributeviint32',...
'Channel1:Measurement2',deviceObj.UserData.AGNA_ATTR_TRIGGER_SOURCE,...
deviceObj.UserData.AGNA_VAL_AGILENT_NA_TRIGGER_SOURCE_INTERNAL);

end
