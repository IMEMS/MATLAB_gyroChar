%% gyroChar_instr_DC_init
function [OBJ, idn] = gyroChar_instr_DC_init(RSRCNAME, varargin)
%% gyroChar_instr_DC_init Initializes the DC power Supply
% 
%  USAGE
%   gyroChar_instr_DC_init('RSRCNAME', ...)
% 
%  INPUTS
%   RSRCNAME - Visa resources name of the hardware DC power supply
%    Currently only tested with an Agilent E3631A DC power supply
%  OPTIONAL INPUT PARAMETER PAIRS
%   Ilim I - Current limit for all outputs {default: 1A}
%   P25vIlim - Current limit in amps for +25v output (supercedes Ilim) 
%    {default: 1A}
%   N25vIlim - Current limit in amps for -25v output (supercedes Ilim) 
%    {default: 1A}
%   P6vIlim - Current limit in amps for +6v output (supercedes Ilim) 
%    {default: 1A}
% 
%  OUTPUTS
%   OBJ - DC power supply object
%   idn - identification string read from the connected hardware
% 
%  EXAMPLES
%   [DC, idn] = gyroChar_instr_DC_init('GPIB0::5::INSTR');
% 
% Author: Curtis Mayberry
% 
% See also 

%% Check and parse inputs
if numel(varargin)>0
    validParameters = {{'Ilim','I'},{'P25vIlim'},{'N25vIlim'},{'P6vIlim'}};
    params = validateInput(varargin, validParameters);
else
    % Just make addlParms an empty struct so that 'isfield' doesn't error
    % out.
    params=struct;
end
if ~isfield(params,'Ilim')
    params.Ilim = 1;
end
if ~isfield(params,'P25vIlim')
    params.P25vIlim = params.Ilim;
end
if ~isfield(params,'N25vIlim')
    params.N25vIlim = params.Ilim;
end
if ~isfield(params,'P6vIlim')
    params.P6vIlim = params.Ilim;
end
%% Open Visa connection to hardware
OBJ = visa('agilent', RSRCNAME);
fopen(OBJ);

%% Get Hardware ID
fprintf(OBJ, '*IDN?');
idn = fscanf(OBJ);

%% Set and Query Current State
% +25v Output
fprintf(OBJ, 'INST:SEL P25V');
fprintf(OBJ, 'SOUR:VOLT?');
OBJ.UserData.P25v.V = str2double(fscanf(OBJ));
if(params.Ilim ~= 1 && params.P25vIlim == params.Ilim) 
    fprintf(OBJ, ['SOUR:CURR ' num2str(params.Ilim)]);
elseif(params.Ilim ~= 1 && params.P25vIlim ~= params.Ilim) 
    fprintf(OBJ, ['SOUR:CURR ' num2str(params.P25vIlim)]);
end
fprintf(OBJ, 'SOUR:CURR?');
OBJ.UserData.P25v.Ilim = fscanf(OBJ);
fprintf(OBJ, 'OUTP:STAT?');
OBJ.UserData.P25v.EN = fscanf(OBJ);

% -25v Output
fprintf(OBJ, 'INST:SEL N25V');
fprintf(OBJ, 'SOUR:VOLT?');
OBJ.UserData.N25v.V = str2double(fscanf(OBJ));
if(params.Ilim ~= 1 && params.N25vIlim == params.Ilim) 
    fprintf(OBJ, ['SOUR:CURR ' num2str(params.Ilim)]);
elseif(params.Ilim ~= 1 && params.N25vIlim ~= params.Ilim) 
    fprintf(OBJ, ['SOUR:CURR ' num2str(params.N25vIlim)]);
end
fprintf(OBJ, 'SOUR:CURR?');
OBJ.UserData.N25v.Ilim = fscanf(OBJ);
fprintf(OBJ, 'OUTP:STAT?');
OBJ.UserData.N25v.EN = fscanf(OBJ);

% +6v Output
fprintf(OBJ, 'INST:SEL P6V');
fprintf(OBJ, 'SOUR:VOLT?');
OBJ.UserData.P6v.V = fscanf(OBJ);
if(params.Ilim ~= 1 && params.P6vIlim == params.Ilim) 
    fprintf(OBJ, ['SOUR:CURR ' num2str(params.Ilim)]);
elseif(params.Ilim ~= 1 && params.P6vIlim ~= params.Ilim) 
    fprintf(OBJ, ['SOUR:CURR ' num2str(params.P6vIlim)]);
end
fprintf(OBJ, 'SOUR:CURR?');
OBJ.UserData.P6v.Ilim = fscanf(OBJ);
fprintf(OBJ, 'OUTP:STAT?');
OBJ.UserData.P6v.EN = fscanf(OBJ);

end