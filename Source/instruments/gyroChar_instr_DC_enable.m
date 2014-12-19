%% gyroChar_instr_DC_enable
function OBJ = gyroChar_instr_DC_enable(OBJ, output, enable)
%% gyroChar_instr_DC_enable Enables or disables an output
% 
%  USAGE
%   OBJ = gyroChar_instr_DC_enable(OBJ, output, enable)
% 
%  INPUTS
%   OBJ - DC power supply object from gyroChar_instr_DC_init
%   output - The ouput to enable ['P25v', 'N25v', 'P6v']
%   enable - true to enable, false to disable (booolean)
% 
%  OUTPUTS
%   OBJ - DC power supply object
% 
%  EXAMPLES
%   DC = gyroChar_instr_DC_enable(DC, 'P25v', true);
% 
% Author: Curtis Mayberry
% 
% See also gyroChar_instr_DC_init gyroChar_instr_DC_close 
% gyroChar_instr_DC_setP25v gyroChar_instr_DC_setN25v 
% gyroChar_instr_DC_setPN25v gyroChar_instr_DC_script_example

fprintf(OBJ, ['INST:SEL ' output]);
if(enable)
    fprintf(OBJ, 'OUTP:STAT ON');
else
    fprintf(OBJ, 'OUTP:STAT OFF');
end

if(strcmp(output,'P25v'))
    OBJ.UserData.P25v.EN = enable;
elseif(strcmp(output,'N25v'))
	OBJ.UserData.N25v.EN = enable;
elseif(strcmp(output,'P6v'))
	OBJ.UserData.P6v.EN = enable;
end

end
