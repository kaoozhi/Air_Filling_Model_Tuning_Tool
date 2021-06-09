function Vcyl = Volume_HR12(angle)

%% CARACTERISTIQUES MOTEUR
epsilon = 12;                 % Rapport volum?trique
alesage = 75.5e-3;                % alesage (m)
course = 89.26e-3;               % course (m)
lbielle = 136.5e-3;            % longueur de bielle (m)
Rm = course/2;                  % Rayon maneton (m)
Apiston = pi*alesage^2/4;       % Aire du piston (m?)
Cyl_1 = Apiston*course;         % Cylindr?e unitaire (m3)
Vmin = Cyl_1/(epsilon-1);       % Volume mini du cylindre (m3)

%% Volume computation
AngRad = angle*pi/180;

%calculate eq. for piston movement
R = lbielle/Rm;                 % Rapport bielle / manivelle

interm = R+1-cos(AngRad)-(R^2-(sin(AngRad)).^2).^0.5;

Vcyl=Vmin*(1+0.5*(epsilon-1)*interm);