function updt

% Read controls and move the objects accordlingly

param = get(gcf,'UserData');

if isfield(param,'Gantry_tri')
    set(param.Gantry_tri.patch,'visible','off')
    set(param.Couch_tri.patch,'Visible','off')
    set(param.Patient_tri.patch,'Visible','off')
end
% 
set(param.distance_button,'string','DISTANCE','callback','distance')
set(param.linedistPG,'XData',[0,0],'YData',[0,0],'ZData',[0,0]);
set(param.textdistPG,'string','')
set(param.traffic_light,...
    'backgroundColor',[0.8 0.8 0.8],...
    'String','COLLISION RISK',...
    'FontSize',10)
alpha_gantry = get(param.alpha_gantry_slider,'value');
alpha_couch = get(param.alpha_couch_slider,'value');
x = get(param.x_patient_slider,'value');
y = get(param.y_patient_slider,'value');
z = get(param.z_patient_slider,'value');
xb = get(param.x_couch_slider,'value');
zb = get(param.z_couch_slider,'value');
centro  = [x,z,y];
 
move(param.Gantry,[0,0,0],alpha_gantry,[0,0,0],'y');
move(param.Couch,[xb,zb,0],alpha_couch,centro,'z');
move(param.Patient,[0,0,0],alpha_couch,centro,'z');

set(gcf,'UserData',param)


function  move(obj,d,alpha,centre,ax)

switch ax
    case 'z'
        G = [cosd(alpha), -sind(alpha), 0;sind(alpha), cosd(alpha), 0; 0, 0, 1];
    case 'y'
        G = [cosd(alpha), 0,-sind(alpha);0 1 0; sind(alpha), 0, cosd(alpha)];
end
V = obj.vertices;
len = length(V);
V0 = ones(len,1)*centre;

Vd = V-ones(len,1)*d+V0;
Vg = Vd*G';
obj.patch.Vertices = Vg;

