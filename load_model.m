function load_model

% load_model loads stl files for the gantry, couch and patient geometries
%     and generates simpler models in order to compute distances and
%     analyse collisions. Each object in the model is embedded in an axis
%     aligned bounding box. The resulting boxes are structured in a tree
%     and only the leafs are considered. The maximal number of boxes, nobj,
%     in a leaf is a key parameter of the algorithm. The higher this parameter
%     is, the less leaf boxes are obtained. The computational cost for
%     obtaining the distance is proportional to the square of the number of
%     boxes.


param = get(gcf,'UserData');

%% Gantry
disp(' ')
disp('Loading Gantry...')

[param.Gantry.faces,param.Gantry.vertices] = read_binary_stl_file(param.Gantry_filename);
param.Gantry.vertices = param.Gantry.vertices(:,[1 3 2]); % Changes axis orientation
param.Gantry.patch = patch( ...
    'Faces',param.Gantry.faces,...
    'Vertices',param.Gantry.vertices,...
    'FaceColor', [0.1 0.5 0.2], ...
    'FaceLighting', 'gouraud', ...
    'EdgeColor', 'none', ...
    'AmbientStrength', 0.15);

param.Gantry.nobj = param.nobj;
[vv,ff] = reduce(param.Gantry);

param.Gantry.bbtriang.patch = patch( ...
    'faces',ff,...
    'vertices',vv,...
    'facecolor',[.95,.95,.55],...
    'edgecolor',[.15,.15,.15],...
    'facealpha',0.2,...
    'visible','off');
param.Gantry.bbtriang.faces = ff;
param.Gantry.bbtriang.vertices = vv;
disp(['Gantry vertices: ',num2str(3*size(vv,1))])

%% Patient
disp(' ')
disp('Loading Patient...')
[param.Patient.faces,param.Patient.vertices] = read_binary_stl_file(param.Patient_filename);
param.Patient.vertices = param.Patient.vertices(:,[1 3 2]); % Changes axis orientation
param.Patient.patch = patch( ...
    'Faces',param.Patient.faces,...
    'Vertices',param.Patient.vertices,...
    'FaceColor', [0.6 0.5 0.1], ...
    'FaceLighting', 'gouraud', ...
    'EdgeColor', 'none', ...
    'AmbientStrength', 0.15);

param.Patient.nobj = param.nobj;

[vv,ff] = reduce(param.Patient);

param.Patient.bbtriang.patch = patch( ...
    'faces',ff,...
    'vertices',vv,...
    'facecolor',[.95,.95,.55],...
    'edgecolor',[.15,.15,.15],...
    'facealpha',0.2,...
    'visible','off');
param.Patient.bbtriang.faces = ff;
param.Patient.bbtriang.vertices = vv;
disp(['Patient vertices: ',num2str(3*size(vv,1))])

%% Couch
disp(' ')
disp('Loading Couch...')
[param.Couch.faces,param.Couch.vertices] = read_binary_stl_file(param.Couch_filename);
param.Couch.vertices = param.Couch.vertices(:,[1 3 2]); % Changes axis orientation
% Couch fitting
maxC = max(param.Couch.vertices);
minC = min(param.Couch.vertices);
maxP = max(param.Patient.vertices);
minP = min(param.Patient.vertices);
fit = [(maxP(1:2)+minP(1:2))/2-(maxC(1:2)+minC(1:2))/2,minP(3)-maxC(3)];
nc = size(param.Couch.vertices,1);
param.Couch.vertices = param.Couch.vertices + ones(nc,1)*fit;

param.meanCouch = mean(param.Couch.vertices);

param.Couch.patch = patch( ...
    'Faces',param.Couch.faces,...
    'Vertices',param.Couch.vertices,...
    'FaceColor', [0.5 0.5 1], ...
    'FaceLighting', 'gouraud', ...
    'EdgeColor', 'none', ...
    'AmbientStrength', 0.15);

param.Couch.nobj = param.nobj;

[vv,ff] = reduce(param.Couch);

param.Couch.bbtriang.patch = patch( ...
    'faces',ff,...
    'vertices',vv,...
    'facecolor',[.95,.95,.55],...
    'edgecolor',[.15,.15,.15],...
    'facealpha',0.2,...
    'visible','off');
param.Couch.bbtriang.faces = ff;
param.Couch.bbtriang.vertices = vv;
disp(['Couch vertices: ',num2str(3*size(vv,1))])

%% Store data in the figure
set(gcf,'UserData',param)


function [vv,ff] = reduce(geom)%,nobj)
% Reduce the number of elements in GEOM in order to make feasible the
% distance calculations

% Find axis aligned bounding boxes BB for the triangles in GEOM
f = geom.faces;
v = geom.vertices;
nf = size(f,1);
bb = zeros(nf,6);
for k=1:nf
    bb(k,:) = [min(v(f(k,:),:)),max(v(f(k,:),:))];
end
options.nobj = geom.nobj;
bbtree = maketree(bb,options);

% Bounding boxes triangularization
[vv,ff] = bb2triang(bbtree);


function [vv,ff] = bb2triang(tr)
% Decompose in triangles the faces of the leaf boxes of TR

lf = ~cellfun('isempty', tr.ll);
np = numel(find(lf));
% Vertices
vv = [tr.xx(lf,1),tr.xx(lf,2),tr.xx(lf,3)
    tr.xx(lf,4),tr.xx(lf,2),tr.xx(lf,3)
    tr.xx(lf,4),tr.xx(lf,5),tr.xx(lf,3)
    tr.xx(lf,1),tr.xx(lf,5),tr.xx(lf,3)
    tr.xx(lf,1),tr.xx(lf,2),tr.xx(lf,6)
    tr.xx(lf,4),tr.xx(lf,2),tr.xx(lf,6)
    tr.xx(lf,4),tr.xx(lf,5),tr.xx(lf,6)
    tr.xx(lf,1),tr.xx(lf,5),tr.xx(lf,6)
    ] ;
% Rectangular faces
f4 = [(1:np)'+np*0,(1:np)'+np*1,...
    (1:np)'+np*2,(1:np)'+np*3
    (1:np)'+np*4,(1:np)'+np*5,...
    (1:np)'+np*6,(1:np)'+np*7
    (1:np)'+np*0,(1:np)'+np*3,...
    (1:np)'+np*7,(1:np)'+np*4
    (1:np)'+np*3,(1:np)'+np*2,...
    (1:np)'+np*6,(1:np)'+np*7
    (1:np)'+np*2,(1:np)'+np*1,...
    (1:np)'+np*5,(1:np)'+np*6
    (1:np)'+np*1,(1:np)'+np*0,...
    (1:np)'+np*4,(1:np)'+np*5
    ] ;
% Triangular faces
ff = [f4(:,[1 2 3]);f4(:,[1 3 4])];

