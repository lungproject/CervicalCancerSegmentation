function varargout = SliceBrowser(varargin)
% SLICEBROWSER M-file for SliceBrowser.fig
%      SLICEBROWSER, by itself, creates a new SLICEBROWSER or raises the existing
%      singleton*.
%
%      H = SLICEBROWSER returns the handle to a new SLICEBROWSER or the handle to
%      the existing singleton*.
%
%      SLICEBROWSER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SLICEBROWSER.M with the given input arguments.
%
%      SLICEBROWSER('Property','Value',...) creates a new SLICEBROWSER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SliceBrowser_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SliceBrowser_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SliceBrowser

% Last Modified by GUIDE v2.5 24-Feb-2014 16:41:39

global RECT_POS  % select the rectangle ROIs
global Seed
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SliceBrowser_OpeningFcn, ...
                   'gui_OutputFcn',  @SliceBrowser_OutputFcn, ...
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


% --- Executes just before SliceBrowser is made visible.
function SliceBrowser_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SliceBrowser (see VARARGIN)

% Choose default command line output for SliceBrowser
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SliceBrowser wait for user response (see UIRESUME)
% uiwait(handles.SliceBrowserFigure);

if (length(varargin) <=0)
    error('Input volume has not been specified.');
end;
volume = varargin{1};%%%%%%%%%%%%%%获取输入图像
if (ndims(volume) ~=2 && ndims(volume) ~= 3 && ndims(volume) ~= 4)
    error('Input volume must have 2 or 3 or 4 dimensions.');
end;
handles.volume = volume;

if (length(varargin) >= 3)
    vol_spacing = varargin{3};
    if (length(vol_spacing) ~= ndims(volume))
        error('Input spcacing numbers must equal to the dimensions of input volume.');
    end
else
    vol_spacing = [1.0 1.0 1.0];
end
handles.vol_spacing = vol_spacing;

% set main wnd title
set(gcf, 'Name', varargin{2})

% init 3D pointer
vol_sz = size(volume); 
if (ndims(volume) == 2)
    vol_sz(3) = 1;
    vol_sz(4) = 1;
end;
if (ndims(volume) == 3)
    vol_sz(4) = 1;
end;
pointer3dt = floor(vol_sz/2)+1;
handles.pointer3dt = pointer3dt;
handles.vol_sz = vol_sz;

plot3slices(hObject, handles);

% stores ID of last axis window 
% (0 means that no axis was clicked yet)
handles.last_axis_id = 0;

set(handles.slicebrowser_slider1,'Max', max(vol_sz(3)-1,1), 'SliderStep',[1./(vol_sz(3)),5./(vol_sz(3))])
set(handles.slicebrowser_slider2,'Max', max(vol_sz(2)-1,1), 'SliderStep',[1./(vol_sz(2)),5./(vol_sz(2))])
set(handles.slicebrowser_slider3,'Max', max(vol_sz(1)-1,1), 'SliderStep',[1./(vol_sz(1)),5./(vol_sz(1))])

set(handles.slicebrowser_slider1,'Value',pointer3dt(3)-1);
set(handles.slicebrowser_slider2,'Value',pointer3dt(2)-1);
set(handles.slicebrowser_slider3,'Value',pointer3dt(1)-1);

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = SliceBrowser_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if nargout
    uiwait(gcf);
    maskImage = getappdata(0,'maskImage');
    RECT_POS = getappdata(0,'RECT_POS');
    Seed = getappdata(0,'Seed');
    varargout{1} = maskImage;
    varargout{2} = RECT_POS;
    varargout{3} = Seed;
    vol_sz = handles.vol_sz;
    vol = handles.volume;

    for p = 1:vol_sz(3)
        slice_outline = bwperim(maskImage(:,:,p),8);
        for f = 1:vol_sz(4)
            slice_temp = vol(:,:,p,f);
            slice_temp(slice_outline) = max(slice_temp(:));
            vol(:,:,p,f) = slice_temp;
        end
    end
    
    SliceBrowser(vol,'segmented volume');
end



% --- Executes on mouse press over axes background.
function Subplot1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to Subplot1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pt=get(gca,'currentpoint');
xpos=round(pt(1,2)); ypos=round(pt(1,1));
zpos = handles.pointer3dt(3);
tpos = handles.pointer3dt(4);
handles.pointer3dt = [xpos ypos zpos tpos];
handles.pointer3dt = clipointer3d(handles.pointer3dt,handles.vol_sz);
plot3slices(hObject, handles);
% store this axis as last clicked region
handles.last_axis_id = 1;
% Update handles structure
guidata(hObject, handles);


% --- Executes on mouse press over axes background.
function Subplot2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to Subplot2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pt=get(gca,'currentpoint');
xpos=round(pt(1,2)); zpos=round(pt(1,1));
ypos = handles.pointer3dt(2);
tpos = handles.pointer3dt(4);
handles.pointer3dt = [xpos ypos zpos tpos];
handles.pointer3dt = clipointer3d(handles.pointer3dt,handles.vol_sz);
plot3slices(hObject, handles);
% store this axis as last clicked region
handles.last_axis_id = 2;
% Update handles structure
guidata(hObject, handles);


% --- Executes on mouse press over axes background.
function Subplot3_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to Subplot3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pt=get(gca,'currentpoint');
zpos=round(pt(1,2)); ypos=round(pt(1,1));
xpos = handles.pointer3dt(1);
tpos = handles.pointer3dt(4);
handles.pointer3dt = [xpos ypos zpos tpos];
handles.pointer3dt = clipointer3d(handles.pointer3dt,handles.vol_sz);
plot3slices(hObject, handles);
% store this axis as last clicked region
handles.last_axis_id = 3;
% Update handles structure
guidata(hObject, handles);



% --- Executes on key press with focus on SliceBrowserFigure and none of its controls.
function SliceBrowserFigure_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to SliceBrowserFigure (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
curr_char = int8(get(gcf,'CurrentCharacter'));
if isempty(curr_char)
    return;
end;

xpos = handles.pointer3dt(1);
ypos = handles.pointer3dt(2);
zpos = handles.pointer3dt(3); 
tpos = handles.pointer3dt(4); 
% Keys:
% - up:   30
% - down:   31
% - left:   28
% - right:   29
% - '1': 49
% - '2': 50
% - '3': 51
% - 'e': 101
% - plus:  43 / 61
% - minus:  45 / 
switch curr_char
    case 30
        switch handles.last_axis_id
            case 1
                xpos = xpos -1;
            case 2
                xpos = xpos -1;
            case 3
                zpos = zpos -1;
            case 0
        end;
    case 31
        switch handles.last_axis_id
            case 1
                xpos = xpos +1;
            case 2
                xpos = xpos +1;
            case 3
                zpos = zpos +1;
            case 0
        end;
    case 28
        switch handles.last_axis_id
            case 1
                ypos = ypos -1;
            case 2
                zpos = zpos -1;
            case 3
                ypos = ypos -1;
            case 0
        end;
    case 29
        switch handles.last_axis_id
            case 1
                ypos = ypos +1;
            case 2
                zpos = zpos +1;
            case 3
                ypos = ypos +1;
            case 0
        end;
    case {43, 61}
        % plus key
        tpos = tpos+1;
    case 45
        % minus key
        tpos = tpos-1;
    case 49
        % key 1
        handles.last_axis_id = 1;
    case 50
        % key 2
        handles.last_axis_id = 2;
    case 51
        % key 3
        handles.last_axis_id = 3;
    case 101
        disp(['[' num2str(xpos) ' ' num2str(ypos) ' ' num2str(zpos) ' ' num2str(tpos) ']']);
    otherwise
        return
end;
handles.pointer3dt = [xpos ypos zpos tpos];
handles.pointer3dt = clipointer3d(handles.pointer3dt,handles.vol_sz);
plot3slices(hObject, handles);
% Update handles structure
guidata(hObject, handles);



% --- Plots all 3 slices XY, YZ, XZ into 3 subplots
function [sp1,sp2,sp3] = plot3slices(hObject, handles)
% pointer3d     3D coordinates in volume matrix (integers)

handles.pointer3dt;
size(handles.volume);
value3dt = handles.volume(handles.pointer3dt(1), handles.pointer3dt(2), handles.pointer3dt(3), handles.pointer3dt(4));

text_str = ['[X:' int2str(handles.pointer3dt(1)) ...
           ', Y:' int2str(handles.pointer3dt(2)) ...
           ', Z:' int2str(handles.pointer3dt(3)) ...
           ', Time:' int2str(handles.pointer3dt(4)) '/' int2str(handles.vol_sz(4)) ...
           '], value:' num2str(value3dt)];
set(handles.pointer3d_info, 'String', text_str);
guidata(hObject, handles);

spacingX = handles.vol_spacing(1);
spacingY = handles.vol_spacing(2);
spacingZ = handles.vol_spacing(3);

sliceXY = squeeze(handles.volume(:,:,handles.pointer3dt(3),handles.pointer3dt(4)));
sliceYZ = squeeze(handles.volume(handles.pointer3dt(1),:,:,handles.pointer3dt(4)));
sliceXZ = squeeze(handles.volume(:,handles.pointer3dt(2),:,handles.pointer3dt(4)));

% max_xyz, min_xyz选择当前三个slice的最大值和最小值
max_xyz = max([ max(sliceXY(:)) max(sliceYZ(:)) max(sliceXZ(:)) ]);
min_xyz = min([ min(sliceXY(:)) min(sliceYZ(:)) min(sliceXZ(:)) ]);
% max_xyz, min_xyz选择当前整个volume的最大值和最小值
% max_xyz = max(handles.volume(:));
% min_xyz = min(handles.volume(:));

clims = [ min_xyz max_xyz];

sp1 = subplot(2,2,1);
%colorbar;
 colormap('jet');
% colormap('Gray');
max_xyz = max(sliceXY(:));
min_xyz = min(sliceXY(:));
% clims = [min_xyz max(max_xyz,min_xyz+1e-4)];
imagesc(sliceXY, clims);
title('Slice XY');
axis equal;
set(gca,'DataAspectRatio',[spacingX spacingY 1]);
ylabel('X');xlabel('Y');
line([handles.pointer3dt(2) handles.pointer3dt(2)], [0 size(handles.volume,1)]);
line([0 size(handles.volume,2)], [handles.pointer3dt(1) handles.pointer3dt(1)]);
%set((gca),'ButtonDownFcn',@Subplot1_ButtonDownFcn);
set(allchild(gca),'ButtonDownFcn','SliceBrowser(''Subplot1_ButtonDownFcn'',gca,[],guidata(gcbo))');

max_xyz = max(sliceXZ(:));
min_xyz = min(sliceXZ(:));
% clims = [min_xyz max(max_xyz,min_xyz+1e-4)];
sp2 = subplot(2,2,2);
imagesc(sliceXZ, clims);
title('Slice XZ');
axis equal;
set(gca,'DataAspectRatio',[spacingX spacingZ 1]);
ylabel('X');xlabel('Z');
line([handles.pointer3dt(3) handles.pointer3dt(3)], [0 size(handles.volume,1)]);
line([0 size(handles.volume,3)], [handles.pointer3dt(1) handles.pointer3dt(1)]);
%set(allchild(gca),'ButtonDownFcn',@Subplot2_ButtonDownFcn);
set(allchild(gca),'ButtonDownFcn','SliceBrowser(''Subplot2_ButtonDownFcn'',gca,[],guidata(gcbo))');

max_xyz = max(sliceYZ(:));
min_xyz = min(sliceYZ(:));
% clims = [min_xyz max(max_xyz,min_xyz+1e-4)];
sp3 = subplot(2,2,3);
imagesc(sliceYZ', clims);
title('Slice ZY');
axis equal;
set(gca,'DataAspectRatio',[spacingZ spacingY 1]);
ylabel('Z');xlabel('Y');
line([0 size(handles.volume,2)], [handles.pointer3dt(3) handles.pointer3dt(3)]);
line([handles.pointer3dt(2) handles.pointer3dt(2)], [0 size(handles.volume,3)]);
%set(allchild(gca),'ButtonDownFcn',@Subplot3_ButtonDownFcn);
set(allchild(gca),'ButtonDownFcn','SliceBrowser(''Subplot3_ButtonDownFcn'',gca,[],guidata(gcbo))');

function pointer3d_out = clipointer3d(pointer3d_in,vol_size)
pointer3d_out = pointer3d_in;
for p_id=1:4
    if (pointer3d_in(p_id) > vol_size(p_id))
        pointer3d_out(p_id) = vol_size(p_id);
    end;
    if (pointer3d_in(p_id) < 1)
        pointer3d_out(p_id) = 1;
    end;
end;


% --- Executes on slider movement.
function slicebrowser_slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slicebrowser_slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
SliceNum = round(get(hObject,'Value'));
xpos = handles.pointer3dt(1);
ypos = handles.pointer3dt(2);
zpos = SliceNum+1;
tpos = handles.pointer3dt(4);

handles.pointer3dt = [xpos ypos zpos tpos];
handles.pointer3dt = clipointer3d(handles.pointer3dt,handles.vol_sz);
plot3slices(hObject, handles);
% store this axis as last clicked region
handles.last_axis_id = 1;
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slicebrowser_slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slicebrowser_slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slicebrowser_slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slicebrowser_slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
SliceNum = round(get(hObject,'Value'));
xpos = handles.pointer3dt(1);
ypos = SliceNum+1;
zpos = handles.pointer3dt(3);
tpos = handles.pointer3dt(4);

handles.pointer3dt = [xpos ypos zpos tpos];
handles.pointer3dt = clipointer3d(handles.pointer3dt,handles.vol_sz);
plot3slices(hObject, handles);
% store this axis as last clicked region
handles.last_axis_id = 1;
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slicebrowser_slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slicebrowser_slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slicebrowser_slider3_Callback(hObject, eventdata, handles)
% hObject    handle to slicebrowser_slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
SliceNum = round(get(hObject,'Value'));
xpos = SliceNum+1;
ypos = handles.pointer3dt(1);
zpos = handles.pointer3dt(3);
tpos = handles.pointer3dt(4);

handles.pointer3dt = [xpos ypos zpos tpos];
handles.pointer3dt = clipointer3d(handles.pointer3dt,handles.vol_sz);
plot3slices(hObject, handles);
% store this axis as last clicked region
handles.last_axis_id = 1;
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slicebrowser_slider3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slicebrowser_slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function spacingX_edit_Callback(hObject, eventdata, handles)
% hObject    handle to spacingX_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of spacingX_edit as text
%        str2double(get(hObject,'String')) returns contents of spacingX_edit as a double


% --- Executes during object creation, after setting all properties.
function spacingX_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spacingX_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function spacingY_edit_Callback(hObject, eventdata, handles)
% hObject    handle to spacingY_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of spacingY_edit as text
%        str2double(get(hObject,'String')) returns contents of spacingY_edit as a double


% --- Executes during object creation, after setting all properties.
function spacingY_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spacingY_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function spacingZ_edit_Callback(hObject, eventdata, handles)
% hObject    handle to spacingZ_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of spacingZ_edit as text
%        str2double(get(hObject,'String')) returns contents of spacingZ_edit as a double


% --- Executes during object creation, after setting all properties.
function spacingZ_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spacingZ_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ok_button.
function ok_button_Callback(hObject, eventdata, handles)
% hObject    handle to ok_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
spacingX = str2double(get(handles.spacingX_edit, 'String'));
spacingY = str2double(get(handles.spacingY_edit, 'String'));
spacingZ = str2double(get(handles.spacingZ_edit, 'String'));
handles.vol_spacing = [spacingX spacingY spacingZ];
guidata(hObject,handles);
plot3slices(hObject, handles);


% --------------------------------------------------------------------
function tool_menu_Callback(hObject, eventdata, handles)
% hObject    handle to tool_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function select_ROI_Callback(hObject, eventdata, handles)
% hObject    handle to select_ROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global RECT_POS;
sp1 = subplot(2,2,1);
rect = getrect(sp1);
%data = ROI_select(handles.SliceBrowserFigure,handles.volume,handles.pointer3dt);
handles.pos = rect;
% guidata(hObject,handles);
% 
RECT_POS = struct('pos',[],'plane',[],'frame',[]);
RECT_POS.pos = handles.pos;
% RECT_POS.pos_origin = data.pos_origin;
RECT_POS.plane = handles.pointer3dt(3);
RECT_POS.frame = handles.pointer3dt(4);

setappdata(0,'RECT_POS',RECT_POS);
guidata(hObject,handles);


% --- Executes on button press in roi_button.
function roi_button_Callback(hObject, eventdata, handles)
% hObject    handle to roi_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

sp1 = subplot(2,2,1);
pt=get(sp1,'currentpoint');
xpos=round(pt(1,2)); ypos=round(pt(1,1));
zpos = handles.pointer3dt(3);
tpos = handles.pointer3dt(4);
handles.pointer3dt = [xpos ypos zpos tpos];
handles.pointer3dt = clipointer3d(handles.pointer3dt,handles.vol_sz);

vol = handles.volume(:,:,:,tpos);  % 第tpos个frame
vol_siz  = handles.vol_sz;
vol_value = vol(xpos,ypos,zpos);

maskImage = zeros(size(vol));
for p = 1:vol_siz(3)  % for each plane
    temp = maskImage(:,:,p);
    temp(vol(:,:,p)>=vol_value) = 1;
    temp = imfill(temp,'holes');
    maskImage(:,:,p) = temp;
end

% 处理掉不连通的部分
[L,num] = bwlabeln(maskImage,18);
% 属于心脏mask的部分必定是像素数最多的部分
count = length(L(L==1));
index = 1;
for i = 2:num
    if length(L(L==i)) > count
        count = length(L(L==i));
        index = i;
    end
end
% 将其他部分的mask置为0
maskImage(find(L~=index)) = 0;


setappdata(0,'maskImage',maskImage);
guidata(hObject,handles);

SliceBrowser(maskImage,'maskImage');



% --- Executes on button press in analyze_roi_button.
function analyze_roi_button_Callback(hObject, eventdata, handles)
% hObject    handle to analyze_roi_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in clear_button.
function clear_button_Callback(hObject, eventdata, handles)
% hObject    handle to clear_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in return_button.
function return_button_Callback(hObject, eventdata, handles)
% hObject    handle to return_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(gcf);


% --------------------------------------------------------------------
function select_Seed_Callback(hObject, eventdata, handles)
% hObject    handle to select_Seed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Seed;
sp1 = subplot(2,2,1);
% rect = getrect(sp1);
[x y] = ginput(1);
z = handles.pointer3dt(3);
%data = ROI_select(handles.SliceBrowserFigure,handles.volume,handles.pointer3dt);
handles.seed = [x y z];
% guidata(hObject,handles);
Seed = [x y z];

setappdata(0,'Seed',Seed);
guidata(hObject,handles);
