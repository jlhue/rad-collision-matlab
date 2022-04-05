function distance

param=get(gcf,'UserData');

% Move Triangles
alpha_gantry = get(param.alpha_gantry_slider,'value');
alpha_couch = get(param.alpha_couch_slider,'value');
x = get(param.x_patient_slider,'value');
y = get(param.y_patient_slider,'value');
z = get(param.z_patient_slider,'value');
xb = get(param.x_couch_slider,'value');
zb = get(param.z_couch_slider,'value');

disp(' ')
disp(['Gantry angle: ',num2str(alpha_gantry)])
disp(['Couch angle: ',num2str(alpha_couch)])
disp(['Patient isocenter (x,y,z) = (',...
    deblank(num2str(x)),', ',...
    deblank(num2str(y)),', ',...
    deblank(num2str(z)),')'])
disp(['Couch position (x,z) = (',...
    deblank(num2str(xb)),', ',...
    deblank(num2str(zb)),')'])

centro  = [x,z,y];

param.Gantry_tri = move2(param.Gantry.bbtriang,[0,0,0],alpha_gantry,[0,0,0],'y');
param.Couch_tri = move2(param.Couch.bbtriang,[xb,zb,0],alpha_couch,centro,'z');
param.Patient_tri = move2(param.Patient.bbtriang,[0,0,0],alpha_couch,centro,'z');

% Join Patient and Couch
lenPatient = length(param.Patient_tri.vertices);
Object.vertices = [param.Patient_tri.vertices;param.Couch_tri.vertices];
num_tri_Couch = length(param.Couch_tri.faces);
Object.faces = [param.Patient_tri.faces;param.Couch_tri.faces+lenPatient*ones(num_tri_Couch,3)];

% Minimal distance
set(param.distance_button,'string','Computing...','callback','')
drawnow
[mindist,pointG,pointP] = trimindist(param.Gantry_tri,Object);
disp(['Distance = ',num2str(mindist)])

set(param.distance_button,'string',num2str(mindist))
set(param.Gantry_tri.patch,'Visible','on')
set(param.Couch_tri.patch,'Visible','on')
set(param.Patient_tri.patch,'Visible','on')

if mindist<10 
    set(param.traffic_light,...
        'BackgroundColor','red',...
        'String','COLLISION',...
        'FontSize',12,...
        'FontWeight','bold')
elseif mindist<80
    set(param.traffic_light,...
        'BackgroundColor',[250,150,50]/255,...
        'String','LOW COLLISION RISK')
else
    set(param.traffic_light,...
        'BackgroundColor','green',...
        'String','NO COLLISION RISK')
end
set(param.linedistPG,...
    'Xdata',[pointP(1),pointG(1)],...
    'Ydata',[pointP(2),pointG(2)],...
    'Zdata',[pointP(3),pointG(3)])
set(param.textdistPG,...
    'String',sprintf('Dist = %.2f', mindist),...
    'position',(pointP+pointG)/2)
set(gcf,'UserData',param)


function newobj = move2(obj,d,alpha,centre,ax)

newobj = obj;
switch ax
    case 'z'
        G = [cosd(alpha), -sind(alpha), 0;sind(alpha), cosd(alpha), 0; 0, 0, 1];
        
    case 'y'
        G = [cosd(alpha), 0,-sind(alpha);0 1 0; sind(alpha), 0, cosd(alpha)];
end
V = obj.vertices;
len = length(V);
V0=ones(len,1)*centre;

Vd=V-ones(len,1)*d+V0;
Vg = Vd*G';
newobj.vertices = Vg;
newobj.patch.Vertices = Vg;

function [dist,p1,p2] = trimindist(obj1,obj2)

% Mínimum distance between two sets of triangles

f1 = obj1.faces;
v1 = obj1.vertices;
f2 = obj2.faces;
v2 = obj2.vertices;

m = size(f1,1);
n = size(f2,1);
dist = Inf;
j=1;
while j<=m && dist>0
    Tri1 = v1(f1(j,:),:);
    Tri1 = reshape(Tri1',1,9);
    k=1;
    while k<=n && dist>0
        Tri2 = v2(f2(k,:),:);
        Tri2 = reshape(Tri2',1,9);
        [newdist,point1,point2] = simdTriTri2(Tri1, Tri2);
        if newdist<dist
            dist = newdist;
            p1 = point1;
            p2 = point2;
        end
        k=k+1;
    end
    j=j+1;
end
