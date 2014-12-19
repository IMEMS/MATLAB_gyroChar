%% gyroChar_instr_DC_setPN25vSoft
function OBJ = gyroChar_instr_DC_setPN25vSoft(OBJ, V_P25V, V_N25V, varargin)
%% gyroChar_instr_DC_setPN25vSoft sets the +/- 25v inputs by slowly
%   increasing the output voltage
% 
%  USAGE
%   OBJ = gyroChar_instr_DC_setPN25vSoft(OBJ, V_P25V, V_N25V, ...)
% 
%  INPUTS
%   OBJ - DC power supply object from gyroChar_instr_DC_init
%   V_P25V - +25v voltage output in volts.  Must be positive.
%   V_N25V - -25v voltage output in volts.  Must be negative.
%  OPTIONAL INPUT PARAMETER PAIRS
%   stepSize step ss s - Step size in volts to increase the output during 
%    each step. {default: 0.5v}
%   stepT st stepTime - time at each step in seconds. {default: 0.25s}
%   disp d - enable the display of voltage information to the command  
%    {default: true}
%   EN enable - enables +/- 25v outputs before setting the voltage
%    {default: false}
% 
%  OUTPUTS
%   OBJ - DC power supply object
% 
%  EXAMPLES
%   DC = gyroChar_instr_DC_setPN25vSoft(DC, 8, -8, 'stepSize', 0.25);
% 
% Author: Curtis Mayberry
% 
% See also gyroChar_instr_DC_init gyroChar_instr_DC_close 
% gyroChar_instr_DC_setP25v gyroChar_instr_DC_setN25v 
% gyroChar_instr_DC_setPN25v gyroChar_instr_DC_script_example

%% Check and parse inputs
% Check Voltages
if(V_P25V < 0)
    error('gyroChar_instr_DC_setPN25vSoft:BadInput:V_P25VmustBePositive',...
          'V_P25V must be a positive voltage');
end
if(V_N25V > 0)
    error('gyroChar_instr_DC_setPN25vSoft:BadInput:V_P25VmustBeNegative',...
          'V_P25V must be a negative voltage');
end
% Parse Optional inputs
if numel(varargin)>0
    validParameters = {{'stepSize','step','ss','s'},...
                       {'stepT','st','stepTime'},{'disp','d'},...
                       {'EN','enable'}};
    params = validateInput(varargin, validParameters);
else
    % Just make addlParms an empty struct so that 'isfield' doesn't error
    % out.
    params=struct;
end
if ~isfield(params,'stepSize')
    params.stepSize = 0.5;
end
if ~isfield(params,'stepT')
    params.stepT = 0.25;
end
if ~isfield(params,'disp')
    params.disp =  true;
end
if ~isfield(params,'EN')
    params.EN =  false;
end
%% Set voltages

if(params.EN)
    OBJ = gyroChar_instr_DC_enable(OBJ, 'P25v', true);
    OBJ = gyroChar_instr_DC_enable(OBJ, 'N25v', true);
end

if((V_P25V < params.stepSize) && (abs(V_N25V) < params.stepSize))
    OBJ = gyroChar_instr_DC_setP25v(OBJ, V_P25V);% Set +25v output
    OBJ = gyroChar_instr_DC_setN25v(OBJ, V_N25V);% Set -25v output
else
    numStepsP = round(V_P25V/0.5);
    numStepsN = round(abs(V_N25V)/0.5);
    if (numStepsP > numStepsN) 
         numSteps = numStepsP;
    else numSteps = numStepsN;
    end
    for i = 1:numSteps+1
        stepV = i*params.stepSize;
        if(stepV < V_P25V)
            OBJ = gyroChar_instr_DC_setP25v(OBJ, stepV);% Set +25v output
        else
            OBJ = gyroChar_instr_DC_setP25v(OBJ, V_P25V);% Set +25v output
        end
        if(stepV < abs(V_N25V))
            OBJ = gyroChar_instr_DC_setN25v(OBJ, -stepV);% Set +25v output
        else
            OBJ = gyroChar_instr_DC_setN25v(OBJ, V_N25V);% Set +25v output
        end
        pause(params.stepT);
    end
end

OBJ.UserData.P25v.V = V_P25V;
OBJ.UserData.N25v.V = V_N25V;

if(params.disp)
    disp(['DC supply: +25v set to ' num2str(V_P25V) ' v']);
    disp(['DC supply: -25v set to ' num2str(V_N25V) ' v']);
end

end