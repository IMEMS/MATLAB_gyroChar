%% gyroChar_instr_DC_script_example An example script 
%   for programming the DC power suppply
%
% Author: Curtis Mayberry
% 
% See also gyroChar_instr_DC_init gyroChar_instr_DC_close 
% gyroChar_instr_DC_setP25v gyroChar_instr_DC_setN25v  
% gyroChar_instr_DC_setPN25vSoft


%% Initialize connection
[DC, idn] = gyroChar_instr_DC_init('GPIB0::5::INSTR','Ilim',0.25);
disp(['Instrument: ' idn]);

% %% Set Voltages
% % Set +25v output = 1v and -25v output = -2v and wait 5sec
% disp('Test 1')
% DC = gyroChar_instr_DC_setP25v(DC, 1);
% DC = gyroChar_instr_DC_setN25v(DC, -2);
% pause(5);

% Set +25v output = 3v and -25v output = -4v and wait 5sec
disp('Test 2')
DC = gyroChar_instr_DC_setPN25v(DC, 3,-4);
pause(5);

% Set +25v output = 5v and -25v output = -6v and wait 5sec
disp('Test 3')
DC = gyroChar_instr_DC_enable(DC, 'P25v', true);
DC = gyroChar_instr_DC_enable(DC, 'N25v', true);
DC = gyroChar_instr_DC_setPN25vSoft(DC, 5,-6);
pause(5);
DC = gyroChar_instr_DC_enable(DC, 'P25v', false);
DC = gyroChar_instr_DC_enable(DC, 'N25v', false);

%% Close connection
gyroChar_instr_DC_close(DC);