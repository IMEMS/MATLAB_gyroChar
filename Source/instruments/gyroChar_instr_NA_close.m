function gyroChar_instr_NA_close(deviceObj)
% Network Analyzer Instrument Control function
% 
%  USAGE
%   gyroChar_instr_NA_close(deviceObj);
% 
%  INPUTS
%   deviceObj - Network analyzer instrument object from 
%    gyroChar_instr_NA_init
% 
%  EXAMPLES
%   gyroChar_instr_NA_close(deviceObj);
% 
% Tested on an Agilent E5061B Network Analyzer
% Compatible with: E5070B, E5071B, E5071C, E5072A, E5061A, E5062A, E5061B,
%  E5063A, E8361A, E8362B, E8363B, E8364B, E8361C, E8362C, E8363C, E8364C, 
%  N5230A, N5230C, N5241A, N5242A, N5244A, N5245A, N5264A, N5247A, N5221A, 
%  N5222A, N5224A, N5225A, N5227A, N5239A, N5231A, N5232A, N5234A, N5235A
% 
% Author: Curtis Mayberry
% 
% See also 

disconnect(deviceObj);
delete(deviceObj);
clear deviceObj;
end
