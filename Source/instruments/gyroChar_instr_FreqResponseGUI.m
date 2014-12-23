function varargout = gyroChar_instr_FreqResponseGUI(varargin)
% GYROCHAR_INSTR_FREQRESPONSEGUI MATLAB code for gyroChar_instr_FreqResponseGUI.fig
%      GYROCHAR_INSTR_FREQRESPONSEGUI, by itself, creates a new GYROCHAR_INSTR_FREQRESPONSEGUI or raises the existing
%      singleton*.
%
%      H = GYROCHAR_INSTR_FREQRESPONSEGUI returns the handle to a new GYROCHAR_INSTR_FREQRESPONSEGUI or the handle to
%      the existing singleton*.
%
%      GYROCHAR_INSTR_FREQRESPONSEGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GYROCHAR_INSTR_FREQRESPONSEGUI.M with the given input arguments.
%
%      GYROCHAR_INSTR_FREQRESPONSEGUI('Property','Value',...) creates a new GYROCHAR_INSTR_FREQRESPONSEGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gyroChar_instr_FreqResponseGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gyroChar_instr_FreqResponseGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gyroChar_instr_FreqResponseGUI

% Last Modified by GUIDE v2.5 23-Dec-2014 01:17:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gyroChar_instr_FreqResponseGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @gyroChar_instr_FreqResponseGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before gyroChar_instr_FreqResponseGUI is made visible.
function gyroChar_instr_FreqResponseGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gyroChar_instr_FreqResponseGUI (see VARARGIN)

% Choose default command line output for gyroChar_instr_FreqResponseGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using gyroChar_instr_FreqResponseGUI.
if strcmp(get(hObject,'Visible'),'off')
%     plot(rand(5));
end

% UIWAIT makes gyroChar_instr_FreqResponseGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gyroChar_instr_FreqResponseGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in togglebutton_connect.
function togglebutton_connect_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton_connect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(get(hObject,'Value') == 1)
    handles.na = gyroChar_instr_NA_init(get(handles.edit1_resource,'String'),...
                  'pwr',  str2double(get(handles.edit_pwr,'String')),...
                  'ifbw', str2double(get(handles.edit_ifbw,'String')),...
                  'npts', str2double(get(handles.edit_npts,'String')),...
                  'centerFreq', str2double(get(handles.edit_centerFreq,'String')),...
                  'span', str2double(get(handles.edit_span,'String')));
    set(hObject,'String','Disconnect');
    set(handles.text_connect,'String','Connected');
    set(handles.text_connect,'BackgroundColor','green');
else
    gyroChar_instr_NA_close(handles.na);
    set(hObject,'String','Connect');
    set(handles.text_connect,'String','Not Connected');
    set(handles.text_connect,'BackgroundColor','red');
end



% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
     set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', {'plot(rand(5))', 'plot(sin(1:0.01:25))', 'bar(1:.5:10)', 'plot(membrane)', 'surf(peaks)'});


% --- Executes on button press in pushbutton_sweep.
function pushbutton_sweep_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_sweep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(get(handles.togglebutton_connect,'Value'))
    [handles.na, Freqs, MAG, Phase, M1] = gyroChar_instr_NA_measFreqResponse(handles.na);
    guidata(hObject,handles);
    plot(handles.axes_mag, Freqs, MAG);
    plot(handles.axes2, Freqs, MAG);
end

function edit1_resource_Callback(hObject, eventdata, handles)
% hObject    handle to edit1_resource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1_resource as text
%        str2double(get(hObject,'String')) returns contents of edit1_resource as a double


% --- Executes during object creation, after setting all properties.
function edit1_resource_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1_resource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_centerFreq_Callback(hObject, eventdata, handles)
% hObject    handle to edit_centerFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_centerFreq as text
%        str2double(get(hObject,'String')) returns contents of edit_centerFreq as a double


% --- Executes during object creation, after setting all properties.
function edit_centerFreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_centerFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_span_Callback(hObject, eventdata, handles)
% hObject    handle to edit_span (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_span as text
%        str2double(get(hObject,'String')) returns contents of edit_span as a double


% --- Executes during object creation, after setting all properties.
function edit_span_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_span (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_ifbw_Callback(hObject, eventdata, handles)
% hObject    handle to edit_ifbw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_ifbw as text
%        str2double(get(hObject,'String')) returns contents of edit_ifbw as a double


% --- Executes during object creation, after setting all properties.
function edit_ifbw_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_ifbw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_npts_Callback(hObject, eventdata, handles)
% hObject    handle to edit_npts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_npts as text
%        str2double(get(hObject,'String')) returns contents of edit_npts as a double


% --- Executes during object creation, after setting all properties.
function edit_npts_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_npts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_save.
function pushbutton_save_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit_pwr_Callback(hObject, eventdata, handles)
% hObject    handle to edit_pwr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_pwr as text
%        str2double(get(hObject,'String')) returns contents of edit_pwr as a double


% --- Executes during object creation, after setting all properties.
function edit_pwr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_pwr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on button press in checkbox_saveCSV.
function checkbox_saveCSV_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_saveCSV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_saveCSV


% --- Executes on button press in checkbox_saveIMG.
function checkbox_saveIMG_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_saveIMG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_saveIMG


% --- Executes on button press in checkbox_saveM.
function checkbox_saveM_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_saveM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_saveM


% --- Executes on button press in checkbox_savePPT.
function checkbox_savePPT_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_savePPT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_savePPT



function edit_folder_Callback(hObject, eventdata, handles)
% hObject    handle to edit_folder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_folder as text
%        str2double(get(hObject,'String')) returns contents of edit_folder as a double


% --- Executes during object creation, after setting all properties.
function edit_folder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_folder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object deletion, before destroying properties.
function text_connect_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to text_connect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(get(hObject,'Value'))
    gyroChar_instr_NA_close(handles.na);
end
