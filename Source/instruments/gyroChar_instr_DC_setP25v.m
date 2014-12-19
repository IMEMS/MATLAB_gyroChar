%% gyroChar_instr_DC_setP25v
function OBJ = gyroChar_instr_DC_setP25v(OBJ, voltage)
%% gyroChar_instr_DC_setP25v sets the + 25v inputs immediately
% 
%  USAGE
%   gyroChar_instr_DC_setP25v(OBJ, voltage);
% 
%  INPUTS
%   OBJ - DC power supply object from gyroChar_instr_DC_init
%   voltage - +25v voltage output in volts.  Must be positive.
% 
%  OUTPUTS
%   OBJ - DC power supply object
% 
%  EXAMPLES
%   gyroChar_instr_DC_setP25v(DC, 8)
% 
% Author: Curtis Mayberry
% 
% See also gyroChar_instr_DC_init gyroChar_instr_DC_close 
% gyroChar_instr_DC_setN25v gyroChar_instr_DC_setPN25v
% gyroChar_instr_DC_setPN25vSoft gyroChar_instr_DC_script_example

if(voltage < 0)
    error('gyroChar_instr_DC_setP25v:BadInput:VoltageMustBePositive',...
          'voltage must be positive');
end

fprintf(OBJ, 'INST:SEL P25V');
fprintf(OBJ, ['SOUR:VOLT ' num2str(voltage)]);
OBJ.UserData.P25v.V = voltage;
    
end
