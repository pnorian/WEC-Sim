%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%                        Pitch Decay                               %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Simulation Data
simu=simulationClass();
simu.simMechanicsFile = 'FOSWEC_Pitch.slx';
simu.rampT = 0;
simu.endTime = 25;
simu.dt = 0.05;
simu.mode = 'normal';
simu.explorer = 'on';
simu.domainSize = 2;
simu.CITime = 10;
simu.mcrCaseFile = 'pitchDecayCase.mat';

%% Wave Information
waves = waveClass('noWaveCIC');

%% Body Data
ic = [0 0 -0.366]; 
try phi = mcr.cases(imcr,1); catch phi=0; end

%% Body 1: Back Flap
body(1) = bodyClass('../../../hydroData/Analysis.h5',1);                     
body(1).geometryFile = '../../../geometry/flap.stl';
body(1).mass = 23.1;      %[kg] from Hinsdale
body(1).momOfInertia = [1.58 1.62 1.25];  %[kg-m^2] from Hinsdale

body(1).setInitDisp(ic, [0 1 0], phi*pi/180, [0 0 0]);

%% Body 2: Front Flap
body(2) = bodyClass('../../../hydroData/Analysis.h5',2);                     
body(2).geometryFile = '../../../geometry/flap.stl';
body(2).mass = 23.1;      %[kg] from Hinsdale
body(2).momOfInertia = [1.42 1.19 1.99];  %[kg-m^2] from Hinsdale

body(2).setInitDisp(ic, [0 1 0], phi*pi/180, [0 0 0]);

%% Body 3: WEC - Platform
body(3) = bodyClass('../../../hydroData/Analysis.h5',3);                     
body(3).geometryFile = '../../../geometry/platform.stl';
body(3).mass = 153.8;   %[kg] from Hinsdale
body(3).momOfInertia = [37.88 29.63 66.2529];  %[kg-m^2] from Hinsdale - UPDATE Izz
body(3).viz.color = [1 1 1];
body(3).viz.opacity = 0.25;

body(3).setInitDisp(ic, [0 1 0], phi*pi/180, [0 0 0]);
body(3).viscDrag.cd(5) = 0;
body(3).viscDrag.characteristicArea(5) = 0;
body(3).linearDamping(5) = 50;  

%% Arm Mass Properties 
%% Body 4: Arm - Rectangle Frame (attached to FOSWEC)
body(4) = bodyClass('',[]);
body(4).nhBody = 1;
body(4).name = 'arm_rectangle';
body(4).mass = 47.7; %[kg] (from Pedro)
body(4).momOfInertia = [1.44 2.21 3.57]; %[kg-m^2]      %UPDATE THIS
body(4).cg = [0 0 -0.366]; %[m]                         %UPDATE THIS
body(4).dispVol = 0;
body(4).geometryFile = '../../../geometry/rectangle.stl';
body(4).viz.color = [1 0 0];
body(4).viz.opacity = 1;

body(4).setInitDisp(ic, [0 1 0], phi*pi/180, [0 0 0]);

%% Body 5: Arm - Pitching Squares
body(5) = bodyClass('',[]);
body(5).nhBody = 1;
body(5).name = 'arm_squares';
body(5).mass = 4.47;  %[kg]                             %UPDATE THIS
body(5).momOfInertia = [0.29, 0.02, 0.30]; %[kg-m^2]    %UPDATE THIS
body(5).cg = [0 0 -0.366]; %[m]                         %UPDATE THIS
body(5).dispVol = 0;
body(5).geometryFile = '../../../geometry/squares.stl';
body(5).viz.color = [0 1 0];
body(5).viz.opacity = 1;
   
body(5).setInitDisp(ic, [0 1 0], phi*pi/180, [0 0 0]);

%% Body 6: Arm - Heaving Cylinder
body(6) = bodyClass('',[]);
body(6).nhBody = 1;
body(6).name = 'arm_cylinder';
body(6).mass = 23.84;   %[kg] (from Pedro)
body(6).momOfInertia = [2.19 2.15 0.28]; %[kg-m^2]      %UPDATE THIS
body(6).cg = [0 0 -0.782]; %[m]                         %UPDATE THIS
body(6).dispVol = 0.009782;
body(6).geometryFile = '../../../geometry/cylinder.stl';
body(6).viz.color = [0 0 1];
body(6).viz.opacity = 1;

%% Body 7: Arm - Fixed Cylinder (attached to seafloor)
body(7) = bodyClass('',[]);
body(7).nhBody = 1;
body(7).name = 'arm_cylinderFixed';
body(7).mass = 1;
body(7).momOfInertia = [1 1 1];
body(7).cg = [0 0 -1.1];
body(7).dispVol = 1/1000;
body(7).initDisp.initLinDisp = [0 0 0];
body(7).initDisp.initAngularDispAxis = [0 1 0];
body(7).initDisp.initAngularDispAngle = 0;
body(7).geometryFile = '../../../geometry/cylinder_fixed.stl';
body(7).viz.color = [0 0 1];
body(7).viz.opacity = 0.25;


%% PTO and Constraint Parameters
%% Constraint 1
constraint(1)= constraintClass('arm_wec');
init_loc = [0 0 -0.366];

constraint(1).setInitLoc(init_loc, ic, [0 1 0], phi*pi/180, [0 0 0]);

%% Constraint 2
constraint(2)= constraintClass('arm_surge');
init_loc = [0 0 -0.366];

constraint(2).setInitLoc(init_loc, ic, [0 1 0], phi*pi/180, [0 0 0]);

%% Constraint 3
constraint(3)= constraintClass('arm_pitch');
init_loc = [0 0 -0.366];

constraint(3).setInitLoc(init_loc, ic, [0 1 0], phi*pi/180, [0 0 0]);

%% Constraint 4
constraint(4)= constraintClass('arm_heave');
constraint(4).loc = [0 0 -1.36];

%% Constraint 5
constraint(5)= constraintClass('arm_floor');
constraint(5).loc = [0 0 -1.36];

%% PTO 1 - Fixed
constraint(6)= constraintClass('PTO_flap1');
init_loc = [-0.65 0 -0.5];

constraint(6).setInitLoc(init_loc, ic, [0 1 0], phi*pi/180, [0 0 0]);

%% PTO 2 - Fixed
constraint(7)= constraintClass('PTO_flap2');
init_loc = [0.65 0 -0.5];

constraint(7).setInitLoc(init_loc, ic, [0 1 0], phi*pi/180, [0 0 0]);

%%
clear ic phi init_loc