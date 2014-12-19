%% gyroChar_instr_DC_close
function gyroChar_instr_DC_close(OBJ)
%% gyroChar_instr_DC_close Closes the DC power Supply connection
% 
%  USAGE
%   gyroChar_instr_DC_close(OBJ);
% 
%  INPUTS
%   OBJ - DC power supply object from gyroChar_instr_DC_init
% 
%  EXAMPLES
%   gyroChar_instr_DC_close(DC);
% 
% Author: Curtis Mayberry
% 
% See also gyroChar_instr_DC_init gyroChar_instr_DC_script_example 
% gyroChar_instr_DC_setP25v gyroChar_instr_DC_setN25v 
% gyroChar_instr_DC_setPN25v gyroChar_instr_DC_setPN25vSoft 
    fclose(OBJ);
end