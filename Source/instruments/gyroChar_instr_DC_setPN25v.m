%% gyroChar_instr_DC_setPN25v
function OBJ = gyroChar_instr_DC_setPN25v(OBJ,V_P25V,V_N25V, varargin)
%% gyroChar_instr_DC_setPN25v sets the +/- 25v inputs immediately
% 
%  USAGE
%   gyroChar_instr_DC_setPN25v(DC, V_P25V, V_N25V, ...)
% 
%  INPUTS
%   OBJ - DC power supply object from gyroChar_instr_DC_init
%   V_P25V - +25v voltage output in volts.  Must be positive.
%   V_N25V - -25v voltage output in volts.  Must be negative.
%  OPTIONAL INPUT PARAMETER PAIRS
%   disp d - enable the display of voltage information to the command  
%    {default: true}
% 
%  OUTPUTS
%   OBJ - DC power supply object
% 
%  EXAMPLES
%   gyroChar_instr_DC_setPN25v(DC, 8, -8, 'disp', false)
% 
% Author: Curtis Mayberry
% 
% See also gyroChar_instr_DC_init gyroChar_instr_DC_close 
% gyroChar_instr_DC_setP25v gyroChar_instr_DC_setN25v 
% gyroChar_instr_DC_setPN25vSoft gyroChar_instr_DC_script_example

%% Check and parse inputs
% Check Voltages
if(V_P25V < 0)
    error('gyroChar_instr_DC_setPN25v:BadInput:V_P25VmustBePositive',...
          'V_P25V must be a positive voltage');
end
if(V_N25V > 0)
    error('gyroChar_instr_DC_setPN25v:BadInput:V_P25VmustBeNegative',...
          'V_P25V must be a negative voltage');
end
% Parse Optional inputs
if numel(varargin)>0
    validParameters = {{'disp','d'}};
    params = validateInput(varargin, validParameters);
else
    % Just make addlParms an empty struct so that 'isfield' doesn't error
    % out.
    params=struct;
end
if ~isfield(params,'disp')
    params.disp = true;
end

%% Set +25v output
fprintf(OBJ, 'INST:SEL P25V');
fprintf(OBJ, ['SOUR:VOLT ' num2str(V_P25V)]);

%% set -25v output
fprintf(OBJ, 'INST:SEL N25V');
fprintf(OBJ, ['SOUR:VOLT ' num2str(V_N25V)]);

OBJ.UserData.P25v.V = V_P25V;
OBJ.UserData.N25v.V = V_N25V;

%% Display output information
if(params.disp)
    disp(['DC supply: +25v set to ' num2str(V_P25V) ' v']);
    disp(['DC supply: -25v set to ' num2str(V_N25V) ' v']);
end
end
