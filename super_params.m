% This file defines the parameters of the composite electrode model.

%My name is Ross Drummond (ross.drummond@eng.ox.ac.uk) and I hold the MIT license for this code. 

function [Da_1,Da_2,Db,Dc_1,Dc_2,La_1,La_2,Lb,Lc_1,Lc_2,K1,K2,Kapa_solid_1,Kapa_solid_2,Kapa_elyte,sigma_1,sigma_2,epsilon_solid_1, epsilon_solid_2 ,epsilon_elyte,a_1,a_2,C,F,Na_1,Na_2,Nb,Nc_1,Nc_2] = super_params
Na_1 = 10; % Discretisation elements in electrode 1 region 1
Na_2 = Na_1; % Discretisation elements in electrode 1 region 2
Nb = 10; % Discretisation elements in the separater
Nc_1 = Na_1; % Discretisation elements in electrode 2 region 1
Nc_2 = Na_1;% Discretisation elements in electrode 2 region 2


epsilon_solid_1= 0.9;% Porosity of material 1
% epsilon_solid_1= 0.67;
epsilon_solid_2= 0.67; % Porosity of material 2
epsilon_elyte = 0.6; % Porosity of the separator

Tortuisity_solid_1 = 3.5; % Porosity of material 1
% Tortuisity_solid_1 = 2.3;
Tortuisity_solid_2 = 2.3; % Porosity of material 2
Tortuisity_elyte = 1.29; % Porosity of the separator

dqp_by_dq = -0.5;
dqn_by_dq = -0.5;

t_neg = 0.5; % Transference numbers
t_pos = 1-t_neg;

T = 298;
F = 9.64853399*10^4;
c_0 = 0.93*1000;% Initial concentration.
C = 1;
% a_1 = 42*10^6;
a_1 = 100*10^6; % Specific capacitance of material 1
a_2 = 42*10^6; % Specific capacitance of material 2

sigma_1 = 0.5; % Conductivity of material 1
% sigma_1 = 0.0521;
sigma_2 = 0.0521; % Conductivity of material 2

R = 8.314;
f = F/(R*T);

Kapa_inf = 0.67*10^-1;
Kapa_solid_1= Kapa_inf*epsilon_solid_1/Tortuisity_solid_1; % Electrolyte conductivity in material 1
Kapa_solid_2= Kapa_inf*epsilon_solid_2/Tortuisity_solid_2;%  Electrolyte conductivity in material 2
Kapa_elyte= Kapa_inf*epsilon_elyte/Tortuisity_elyte;  %Electrolyte conductivity in the separator
% Kapa_solid= 0.067; Kapa_elyte= 0.067;

K1 = (t_neg*dqp_by_dq + t_pos*dqn_by_dq);
K2 = (t_pos-t_neg)/f;

D_solid_1 = 2*Kapa_solid_1*(t_pos*t_neg/(t_neg+t_pos))*(R*T/((F^2)*c_0));% Diffusion co-ef in material 1
D_solid_2 = 2*Kapa_solid_2*(t_pos*t_neg/(t_neg+t_pos))*(R*T/((F^2)*c_0));% Diffusion co-ef in material 2
D_elyte = 2*Kapa_elyte*(t_pos*t_neg/(t_neg+t_pos))*(R*T/((F^2)*c_0)); % Diffusion co-ef in the separator

La_1 = 10*10^-6; % Length of electrode 1 region 1
La_2 = 25*10^-6; % Length of electrode 1 region 2
Lb = 25*10^-6; % Length of separator
Lc_1 = La_1; % Length of electrode 2 region 1
Lc_2 = La_2; % Length of electrode 2 region 2

Da_1 =D_solid_1;
Da_2 =D_solid_2;
Db = D_elyte;
Dc_1 = D_solid_1;
Dc_2 = D_solid_2;

% p = struct('Da_1','Da_2','Db','Dc_1','Dc_2','La_1','La_2','Lb','Lc_1','Lc_2','K1','K2','Kapa_solid_1','Kapa_solid_2','Kapa_elyte','sigma_1','sigma_2','epsilon_solid_1', 'epsilon_solid_2' ,'epsilon_elyte','a_1','a_2','C','F','Na_1','Na_2','Nb','Nc_1','Nc_2')

end













