clc; clear; close all

% This files runs a constant current simulation with a compostie electrode supercapacitor. The model input is the current and the
% output is the voltage. The model parameters are set up in super_params.m
% and are defined there. The initial condition x0 of the simulation as well
% as the charging current i is specified in intitial_cons_current.m.

%My name is Ross Drummond (ross.drummond@eng.ox.ac.uk) and I hold the MIT license for this code. 

%% Supercap Setup - Centemeters
[Da_1,Da_2,Db,Dc_1,Dc_2,La_1,La_2,Lb,Lc_1,Lc_2,K1,K2,Kapa_solid_1,Kapa_solid_2,Kapa_elyte,sigma_1,sigma_2,epsilon_solid_1, epsilon_solid_2 ,epsilon_elyte,a_1,a_2,C,F,Na_1,Na_2,Nb,Nc_1,Nc_2] = super_params;
[x0,i] = intitial_cons_current(Na_1,Na_2,Nb,Nc_1,Nc_2,sigma_1,sigma_2,La_1,La_2,Lb,Lc_1,Lc_2);

N = Na_1+Na_2+Nb+Nc_1+Nc_2-5;
N2 = Na_1+Na_2+Nc_1+Nc_2-4;

tf = 5;
%% DIFFERENTIATION MATRICES
[D_cheba_1,x_CHEBa_1] = cheb(Na_1);
[D_cheba_2,x_CHEBa_2] = cheb(Na_2);
[D_chebb,x_CHEBb] = cheb(Nb);
[D_chebc_1,x_CHEBc_1] = cheb(Nc_1);
[D_chebc_2,x_CHEBc_2] = cheb(Nc_2);

D_cheba_1= -D_cheba_1;
D_cheba_2= -D_cheba_2;
D_chebb= -D_chebb;
D_chebc_1= -D_chebc_1;
D_chebc_2= -D_chebc_2;

%% INTERIOR AND EXTERIOR MATRICES
D_cheba_1_in = D_cheba_1(2:Na_1,2:Na_1);
D_cheba_2_in = D_cheba_2(2:Na_2,2:Na_2);
D_chebb_in = D_chebb(2:Nb,2:Nb);
D_chebc_1_in = D_chebc_1(2:Nc_1,2:Nc_1);
D_chebc_2_in = D_chebc_2(2:Nc_2,2:Nc_2);

DD_cheba_1 = D_cheba_1^2;
DD_cheba_2 = D_cheba_2^2;
DD_chebb = D_chebb^2;
DD_chebc_1 = D_chebc_1^2;
DD_chebc_2 = D_chebc_2^2;

DD_cheba_1_in = DD_cheba_1(2:Na_1,2:Na_1);
DD_cheba_2_in = DD_cheba_2(2:Na_2,2:Na_2);
DD_chebb_in = DD_chebb(2:Nb,2:Nb);
DD_chebc_1_in = DD_chebc_1(2:Nc_1,2:Nc_1);
DD_chebc_2_in = DD_chebc_2(2:Nc_2,2:Nc_2);


%% BOUNDARY CONDITION MATRICES
% Concentration
Dc_a = [(2/La_1)*D_cheba_1(1,1),(2/La_1)*D_cheba_1(1,Na_1+1), 0,0,0, 0;
    (2*Da_1/La_1)*D_cheba_1(Na_1+1,1), -(2*Da_2/La_2)*D_cheba_2(1,1)+(2*Da_1/La_1)*D_cheba_1(Na_1+1,Na_1+1), -(2*Da_2/La_2)*D_cheba_2(1,Na_2+1), 0,0,0;
    0,(2*Da_2/La_2)*D_cheba_2(Na_2+1,1), -(2*Db/Lb)*D_chebb(1,1)+(2*Da_2/La_2)*D_cheba_2(Na_2+1,Na_2+1), -(2*Db/Lb)*D_chebb(1,Nb+1), 0,0;
    0, 0,(2*Db/Lb)*D_chebb(Nb+1,1), -(2*Dc_2/Lc_2)*D_chebc_2(1,1)+(2*Db/Lb)*D_chebb(Nb+1,Nb+1),-(2*Dc_2/Lc_2)*D_chebc_2(1,Nc_2+1),0;
    0,0, 0,(2*Dc_2/Lc_2)*D_chebc_2(Nc_2+1,1), -(2*Dc_1/Lc_1)*D_chebc_1(1,1)+(2*Dc_2/Lc_2)*D_chebc_2(Nc_2+1,Nc_2+1),-(2*Dc_1/Lc_1)*D_chebc_1(1,Nc_1+1);
    0,0,0,0,(2/Lc_1)*D_chebc_1(Nc_1+1,1),(2/Lc_1)*D_chebc_1(Nc_1+1,Nc_1+1)];

Dc_b = [-(2/La_1)*D_cheba_1(1,2:Na_1),zeros(1,Na_2-1),zeros(1,Nb-1), zeros(1,Nc_2-1), zeros(1,Nc_1-1);
    -(2*Da_1/La_1)*D_cheba_1(Na_1+1,2:Na_1),(2*Da_2/La_2)*D_cheba_2(1,2:Na_2),zeros(1,Nb-1), zeros(1,Nc_2-1), zeros(1,Nc_1-1);
    zeros(1,Na_1-1),-(2*Da_2/La_2)*D_cheba_2(Na_2+1,2:Na_2),(2*Db/Lb)*D_chebb(1,2:Nb),zeros(1,Nc_2-1), zeros(1,Nc_1-1);
    zeros(1,Na_1-1),zeros(1,Na_2-1),-(2*Db/Lb)*D_chebb(Nb+1,2:Nb),(2*Dc_2/Lc_2)*D_chebc_2(1,2:Nc_2), zeros(1,Nc_1-1);
    zeros(1,Na_1-1), zeros(1,Na_2-1),zeros(1,Nb-1),-(2*Dc_2/Lc_2)*D_chebc_2(Nc_2+1,2:Nc_2), (2*Dc_1/Lc_1)*D_chebc_1(1,2:Nc_1);
    zeros(1,Na_1-1), zeros(1,Na_2-1),zeros(1,Nb-1), zeros(1,Nc_2-1),-(2/Lc_1)*D_chebc_1(Nc_1+1,2:Nc_1)];

Dc_A = Dc_a\Dc_b;


%% Phi1
D_volt1_a = [(2/La_1)*D_cheba_1(1,1),(2/La_1)*D_cheba_1(1,Na_1+1), 0,0,0,0;
    (2*sigma_1/La_1)*D_cheba_1(Na_1+1,1), -(2*sigma_2/La_2)*D_cheba_2(1,1)+(2*sigma_1/La_1)*D_cheba_1(Na_1+1,Na_1+1), -(2*sigma_2/La_2)*D_cheba_2(1,Na_2+1), 0,0,0;
    0,(2/La_2)*D_cheba_2(Na_2+1,1), (2/La_2)*D_cheba_2(Na_2+1,Na_2+1),0,0,0;
    0,0,0, (2/Lc_2)*D_chebc_2(1,1),(2/Lc_2)*D_chebc_2(1,Nc_2+1),0;
    0,0, 0,(2*sigma_2/Lc_2)*D_chebc_2(Nc_2+1,1), -(2*sigma_1/Lc_1)*D_chebc_1(1,1)+(2*sigma_2/Lc_2)*D_chebc_2(Nc_2+1,Nc_2+1),-(2*sigma_1/Lc_1)*D_chebc_1(1,Nc_1+1);
    0,0,0,0,(2/Lc_1)*D_chebc_1(Nc_1+1,1),(2/Lc_1)*D_chebc_1(Nc_1+1,Nc_1+1)];

D_volt1_b = [-(2/La_1)*D_cheba_1(1,2:Na_1),zeros(1,Na_2-1), zeros(1,Nb-1),zeros(1,Nc_2-1),zeros(1,Nc_1-1);
    -(2*sigma_1/La_1)*D_cheba_1(Na_1+1,2:Na_1),(2*sigma_2/La_2)*D_cheba_2(1,2:Na_2),zeros(1,Nb-1), zeros(1,Nc_2-1), zeros(1,Nc_1-1);
    zeros(1,Na_1-1),-(2/La_2)*D_cheba_2(Na_2+1,2:Na_2),zeros(1,Nb-1), zeros(1,Nc_2-1),zeros(1,Nc_1-1);
    zeros(1,Na_1-1),zeros(1,Na_2-1),zeros(1,Nb-1), -(2/Lc_2)*D_chebc_2(1,2:Nc_2),zeros(1,Nc_1-1);
    zeros(1,Na_1-1), zeros(1,Na_2-1),zeros(1,Nb-1),-(2*sigma_2/Lc_2)*D_chebc_2(Nc_2+1,2:Nc_2), (2*sigma_1/Lc_1)*D_chebc_1(1,2:Nc_1);
    zeros(1,Na_1-1),zeros(1,Na_2-1), zeros(1,Nb-1),zeros(1,Nc_2-1),-(2/Lc_1)*D_chebc_1(Nc_1+1,2:Nc_1)];

D_volt1_c = [-1/sigma_1;0; 0;0;0 ; -1/sigma_1];

% D_volt1_b(1,:) = 0;
% D_volt1_c(1,:) = 0;

D_volt1_A = D_volt1_a\D_volt1_b;
D_volt1_B = D_volt1_a\D_volt1_c;


D_volt1_A(1,:) = 0;
D_volt1_B(1,:) = 0;

%% Phi2
D_volt2_a = [(2/La_1)*D_cheba_1(1,1),(2/La_1)*D_cheba_1(1,Na_1+1), 0,0,0, 0;
    (2* Kapa_solid_1/La_1)*D_cheba_1(Na_1+1,1), -(2* Kapa_solid_2/La_2)*D_cheba_2(1,1)+(2* Kapa_solid_1/La_1)*D_cheba_1(Na_1+1,Na_1+1), -(2* Kapa_solid_2/La_2)*D_cheba_2(1,Na_2+1), 0,0,0;
    0,(2* Kapa_solid_2/La_2)*D_cheba_2(Na_2+1,1), -(2*Kapa_elyte/Lb)*D_chebb(1,1)+(2*Kapa_solid_2/La_2)*D_cheba_2(Na_2+1,Na_2+1), -(2*Kapa_elyte/Lb)*D_chebb(1,Nb+1), 0,0;
    0, 0,(2*Kapa_elyte/Lb)*D_chebb(Nb+1,1), -(2*Kapa_solid_2/Lc_2)*D_chebc_2(1,1)+(2*Kapa_elyte/Lb)*D_chebb(Nb+1,Nb+1),-(2*Kapa_solid_2/Lc_2)*D_chebc_2(1,Nc_2+1),0;
    0,0, 0,(2*Kapa_solid_2/Lc_2)*D_chebc_2(Nc_2+1,1), -(2*Kapa_solid_1/Lc_1)*D_chebc_1(1,1)+(2*Kapa_solid_2/Lc_2)*D_chebc_2(Nc_2+1,Nc_2+1),-(2*Kapa_solid_1/Lc_1)*D_chebc_1(1,Nc_1+1);
    0,0,0,0,(2/Lc_1)*D_chebc_1(Nc_1+1,1),(2/Lc_1)*D_chebc_1(Nc_1+1,Nc_1+1)];

D_volt2_b = K2*[0,0, 0,0,0, 0;
    (2* Kapa_solid_1/La_1)*D_cheba_1(Na_1+1,1), -(2* Kapa_solid_2/La_2)*D_cheba_2(1,1)+(2* Kapa_solid_1/La_1)*D_cheba_1(Na_1+1,Na_1+1), -(2* Kapa_solid_2/La_2)*D_cheba_2(1,Na_2+1), 0,0,0;
    0,(2* Kapa_solid_2/La_2)*D_cheba_2(Na_2+1,1), -(2*Kapa_elyte/Lb)*D_chebb(1,1)+(2*Kapa_solid_2/La_2)*D_cheba_2(Na_2+1,Na_2+1), -(2*Kapa_elyte/Lb)*D_chebb(1,Nb+1), 0,0;
    0, 0,(2*Kapa_elyte/Lb)*D_chebb(Nb+1,1), -(2*Kapa_solid_2/Lc_2)*D_chebc_2(1,1)+(2*Kapa_elyte/Lb)*D_chebb(Nb+1,Nb+1),-(2*Kapa_solid_2/Lc_2)*D_chebc_2(1,Nc_2+1),0;
    0,0, 0,(2*Kapa_solid_2/Lc_2)*D_chebc_2(Nc_2+1,1), -(2*Kapa_solid_1/Lc_1)*D_chebc_1(1,1)+(2*Kapa_solid_2/Lc_2)*D_chebc_2(Nc_2+1,Nc_2+1),-(2*Kapa_solid_1/Lc_1)*D_chebc_1(1,Nc_1+1);
    0,0,0,0,0,0];

D_volt2_c = [-(2/La_1)*D_cheba_1(1,2:Na_1),zeros(1,Na_2-1),zeros(1,Nb-1), zeros(1,Nc_2-1), zeros(1,Nc_1-1);
    -(2*Kapa_solid_1/La_1)*D_cheba_1(Na_1+1,2:Na_1),(2*Kapa_solid_2/La_2)*D_cheba_2(1,2:Na_2),zeros(1,Nb-1), zeros(1,Nc_2-1), zeros(1,Nc_1-1);
    zeros(1,Na_1-1),-(2*Kapa_solid_2/La_2)*D_cheba_2(Na_2+1,2:Na_2),(2*Kapa_elyte/Lb)*D_chebb(1,2:Nb),zeros(1,Nc_2-1), zeros(1,Nc_1-1);
    zeros(1,Na_1-1),zeros(1,Na_2-1),-(2*Kapa_elyte/Lb)*D_chebb(Nb+1,2:Nb),(2*Kapa_solid_2/Lc_2)*D_chebc_2(1,2:Nc_2), zeros(1,Nc_1-1);
    zeros(1,Na_1-1), zeros(1,Na_2-1),zeros(1,Nb-1),-(2*Kapa_solid_2/Lc_2)*D_chebc_2(Nc_2+1,2:Nc_2), (2*Kapa_solid_1/Lc_1)*D_chebc_1(1,2:Nc_1);
    zeros(1,Na_1-1), zeros(1,Na_2-1),zeros(1,Nb-1), zeros(1,Nc_2-1),-(2/Lc_1)*D_chebc_1(Nc_1+1,2:Nc_1)];

D_volt2_d = K2*[zeros(1,Na_1-1),zeros(1,Na_2-1),zeros(1,Nb-1), zeros(1,Nc_2-1), zeros(1,Nc_1-1);
    -(2*Kapa_solid_1/La_1)*D_cheba_1(Na_1+1,2:Na_1),(2*Kapa_solid_2/La_2)*D_cheba_2(1,2:Na_2),zeros(1,Nb-1), zeros(1,Nc_2-1), zeros(1,Nc_1-1);
    zeros(1,Na_1-1),-(2*Kapa_solid_2/La_2)*D_cheba_2(Na_2+1,2:Na_2),(2*Kapa_elyte/Lb)*D_chebb(1,2:Nb),zeros(1,Nc_2-1), zeros(1,Nc_1-1);
    zeros(1,Na_1-1),zeros(1,Na_2-1),-(2*Kapa_elyte/Lb)*D_chebb(Nb+1,2:Nb),(2*Kapa_solid_2/Lc_2)*D_chebc_2(1,2:Nc_2), zeros(1,Nc_1-1);
    zeros(1,Na_1-1), zeros(1,Na_2-1),zeros(1,Nb-1),-(2*Kapa_solid_2/Lc_2)*D_chebc_2(Nc_2+1,2:Nc_2), (2*Kapa_solid_1/Lc_1)*D_chebc_1(1,2:Nc_1);
    zeros(1,Na_1-1), zeros(1,Na_2-1),zeros(1,Nb-1), zeros(1,Nc_2-1),zeros(1,Nc_1-1)];

D_volt2_A= D_volt2_a\D_volt2_b;
D_volt2_B = D_volt2_a\D_volt2_c;
D_volt2_C = D_volt2_a\D_volt2_d;

% D_volt2_A(1,:) = 0;
% D_volt2_B(1,:) = 0;

%% EQUATION 1- Diffusion Equation
DD_in_eqn1 = zeros(N,N);
DD_in_eqn1(1:Na_1-1,1:Na_1-1) = (4*Da_1/La_1^2)*DD_cheba_1_in;
DD_in_eqn1(Na_1:Na_1+Na_2-2,Na_1:Na_1+Na_2-2) = (4*Da_2/La_2^2)*DD_cheba_2_in;
DD_in_eqn1(Na_1+Na_2-1:Na_1+Na_2+Nb-3,Na_1+Na_2-1:Na_1+Na_2+Nb-3) = (4*Db/Lb^2)*DD_chebb_in;
DD_in_eqn1(Na_1+Na_2+Nb-2:Na_1+Na_2+Nb+Nc_2-4,Na_1+Na_2+Nb-2:Na_1+Na_2+Nb+Nc_2-4) = (4*Dc_2/Lc_2^2)*DD_chebc_2_in;
DD_in_eqn1(Na_1+Na_2+Nb+Nc_2-3:N,Na_1+Na_2+Nb+Nc_2-3:N) = (4*Dc_1/Lc_1^2)*DD_chebc_1_in;

DD_ex_eqn1 = zeros(N,6);
DD_ex_eqn1(1:Na_1-1,1) = (4*Da_1/La_1^2)*DD_cheba_1(2:Na_1,1);
DD_ex_eqn1(1:Na_1-1,2) = (4*Da_1/La_1^2)*DD_cheba_1(2:Na_1,Na_1+1);
DD_ex_eqn1(Na_1:Na_1+Na_2-2,2) = (4*Da_2/La_2^2)*DD_cheba_2(2:Na_2,1);
DD_ex_eqn1(Na_1:Na_1+Na_2-2,3) = (4*Da_2/La_2^2)*DD_cheba_2(2:Na_2,Na_2+1);
DD_ex_eqn1(Na_1+Na_2-1:Na_1+Na_2+Nb-3,3) = (4*Db/Lb^2)*DD_chebb(2:Nb,1);
DD_ex_eqn1(Na_1+Na_2-1:Na_1+Na_2+Nb-3,4) = (4*Db/Lb^2)*DD_chebb(2:Nb,Nb+1);
DD_ex_eqn1(Na_1+Na_2+Nb-2:Na_1+Na_2+Nb+Nc_2-4,4) = (4*Dc_2/Lc_2^2)*DD_chebc_2(2:Nc_2,1);
DD_ex_eqn1(Na_1+Na_2+Nb-2:Na_1+Na_2+Nb+Nc_2-4,5) = (4*Dc_2/Lc_2^2)*DD_chebc_2(2:Nc_2,Nc_2+1);
DD_ex_eqn1(Na_1+Na_2+Nb+Nc_2-3:Na_1+Na_2+Nb+Nc_1+Nc_2-5,5) = (4*Dc_1/Lc_1^2)*DD_chebc_1(2:Nc_1,1);
DD_ex_eqn1(Na_1+Na_2+Nb+Nc_2-3:Na_1+Na_2+Nb+Nc_1+Nc_2-5,6) = (4*Dc_1/Lc_1^2)*DD_chebc_1(2:Nc_1,Nc_1+1);

D_star = Dc_a\Dc_b;
DD_ex_star = DD_ex_eqn1*D_star;

% symetric = issymmetric(abs(DD_in_eqn1)) 

A_1 = [DD_in_eqn1+DD_ex_star,zeros(N,N),zeros(N,N)];
B_1 = zeros(N,1);

%% EQUATION 2- Reformulated Ohm's Law
DD_ex_eqn2 = zeros(N,6);
DD_ex_eqn2(1:Na_1-1,1) = (4*sigma_1/La_1^2)*DD_cheba_1(2:Na_1,1);
DD_ex_eqn2(1:Na_1-1,2) = (4*sigma_1/La_1^2)*DD_cheba_1(2:Na_1,Na_1+1);
DD_ex_eqn2(Na_1:Na_1+Na_2-2,2) = (4*sigma_2/La_2^2)*DD_cheba_2(2:Na_2,1);
DD_ex_eqn2(Na_1:Na_1+Na_2-2,3) = (4*sigma_2/La_2^2)*DD_cheba_2(2:Na_2,Na_2+1);
DD_ex_eqn2(Na_1+Na_2-1:Na_1+Na_2+Nb-3,3) = 0*(4/Lb^2)*DD_chebb(2:Nb,1);
DD_ex_eqn2(Na_1+Na_2-1:Na_1+Na_2+Nb-3,4) = 0*(4/Lb^2)*DD_chebb(2:Nb,Nb+1);
DD_ex_eqn2(Na_1+Na_2+Nb-2:Na_1+Na_2+Nb+Nc_2-4,4) = (4*sigma_2/Lc_2^2)*DD_chebc_2(2:Nc_2,1);
DD_ex_eqn2(Na_1+Na_2+Nb-2:Na_1+Na_2+Nb+Nc_2-4,5) = (4*sigma_2/Lc_2^2)*DD_chebc_2(2:Nc_2,Nc_2+1);
DD_ex_eqn2(Na_1+Na_2+Nb+Nc_2-3:Na_1+Na_2+Nb+Nc_2+Nc_1-5,5) = (4*sigma_1/Lc_1^2)*DD_chebc_1(2:Nc_1,1);
DD_ex_eqn2(Na_1+Na_2+Nb+Nc_2-3:Na_1+Na_2+Nb+Nc_2+Nc_1-5,6) = (4*sigma_1/Lc_1^2)*DD_chebc_1(2:Nc_1,Nc_1+1);

DD_in_eqn2 = zeros(N,N);
DD_in_eqn2(1:Na_1-1,1:Na_1-1) = (4*sigma_1/La_1^2)*DD_cheba_1_in;
DD_in_eqn2(Na_1:Na_1+Na_2-2,Na_1:Na_1+Na_2-2) = (4*sigma_2/La_2^2)*DD_cheba_2_in;
DD_in_eqn2(Na_1+Na_2-1:Na_1+Na_2+Nb-3,Na_1+Na_2-1:Na_1+Na_2+Nb-3) = 0*(4/Lb^2)*DD_chebb_in;
DD_in_eqn2(Na_1+Na_2+Nb-2:Na_1+Na_2+Nb+Nc_2-4,Na_1+Na_2+Nb-2:Na_1+Na_2+Nb+Nc_2-4) = (4*sigma_2/Lc_2^2)*DD_chebc_2_in;
DD_in_eqn2(Na_1+Na_2+Nb+Nc_2-3:N,Na_1+Na_2+Nb+Nc_2-3:N) = (4*sigma_1/Lc_1^2)*DD_chebc_1_in;


% symetric = issymmetric(DD_in_eqn2)

A_in_2 = [zeros(N,N),DD_in_eqn2,zeros(N,N)];
B_in_2 = zeros(N,1);

A_ex_2 = [zeros(N,N),DD_ex_eqn2*D_volt1_A ,zeros(N,N)];
B_ex_2 = DD_ex_eqn2*D_volt1_B;

A_2 = A_in_2+A_ex_2;
B_2 = B_in_2+B_ex_2;

%% EQUATION 3- Algebraic Constaint
D_ex_eqn3_volt1 = zeros(N,6);
D_ex_eqn3_volt1(1:Na_1-1,1) = (2*sigma_1/La_1)*D_cheba_1(2:Na_1,1);
D_ex_eqn3_volt1(1:Na_1-1,2) = (2*sigma_1/La_1)*D_cheba_1(2:Na_1,Na_1+1);
D_ex_eqn3_volt1(Na_1:Na_1+Na_2-2,2) = (2*sigma_2/La_2)*D_cheba_2(2:Na_2,1);
D_ex_eqn3_volt1(Na_1:Na_1+Na_2-2,3) = (2*sigma_2/La_2)*D_cheba_2(2:Na_2,Na_2+1);
D_ex_eqn3_volt1(Na_1+Na_2+Nb-2:Na_1+Na_2+Nb+Nc_2-4,4) = (2*sigma_2/Lc_2)*D_chebc_2(2:Nc_2,1);
D_ex_eqn3_volt1(Na_1+Na_2+Nb-2:Na_1+Na_2+Nb+Nc_2-4,5) = (2*sigma_2/Lc_2)*D_chebc_2(2:Nc_2,Nc_2+1);
D_ex_eqn3_volt1(Na_1+Na_2+Nb+Nc_2-3:Na_1+Na_2+Nb+Nc_2+Nc_1-5,5) = (2*sigma_1/Lc_1)*D_chebc_1(2:Nc_1,1);
D_ex_eqn3_volt1(Na_1+Na_2+Nb+Nc_2-3:Na_1+Na_2+Nb+Nc_2+Nc_1-5,6) = (2*sigma_1/Lc_1)*D_chebc_1(2:Nc_1,Nc_1+1);

D_in_eqn3_volt1 = zeros(N,N);
D_in_eqn3_volt1(1:Na_1-1,1:Na_1-1) = (2*sigma_1/La_1)*D_cheba_1_in;
D_in_eqn3_volt1(Na_1:Na_1+Na_2-2,Na_1:Na_1+Na_2-2) = (2*sigma_2/La_2)*D_cheba_2_in;
D_in_eqn3_volt1(Na_1+Na_2-1:Na_1+Na_2+Nb-3,Na_1+Na_2-1:Na_1+Na_2+Nb-3) = 0*(2/Lb)*D_chebb_in;
D_in_eqn3_volt1(Na_1+Na_2+Nb-2:Na_1+Na_2+Nb+Nc_2-4,Na_1+Na_2+Nb-2:Na_1+Na_2+Nb+Nc_2-4) = (2*sigma_2/Lc_2)*D_chebc_2_in;
D_in_eqn3_volt1(Na_1+Na_2+Nb+Nc_2-3:N,Na_1+Na_2+Nb+Nc_2-3:N) = (2*sigma_1/Lc_1)*D_chebc_1_in;

D_ex_eqn3_volt2 = [Kapa_solid_1*(2/La_1)*D_cheba_1(2:Na_1,1), Kapa_solid_1*(2/La_1)*D_cheba_1(2:Na_1,Na_1+1), zeros(Na_1-1,1),zeros(Na_1-1,1),zeros(Na_1-1,1), zeros(Na_1-1,1);
    zeros(Na_2-1,1),Kapa_solid_2*(2/La_2)*D_cheba_2(2:Na_2,1), Kapa_solid_2*(2/La_2)*D_cheba_2(2:Na_2,Na_2+1),zeros(Na_2-1,1), zeros(Na_2-1,1), zeros(Na_2-1,1);
    zeros(Nb-1,1),zeros(Nb-1,1), Kapa_elyte*(2/Lb)*D_chebb(2:Nb,1), Kapa_elyte*(2/Lb)*D_chebb(2:Nb,Nb+1), zeros(Nb-1,1), zeros(Nb-1,1);
    zeros(Nc_2-1,1), zeros(Nc_2-1,1),zeros(Nc_2-1,1),Kapa_solid_2*(2/Lc_2)*D_chebc_2(2:Nc_2,1), Kapa_solid_2*(2/Lc_2)*D_chebc_2(2:Nc_2,Nc_2+1),zeros(Nc_2-1,1);
    zeros(Nc_1-1,1), zeros(Nc_1-1,1),zeros(Nc_1-1,1),zeros(Nc_1-1,1),Kapa_solid_1*(2/Lc_1)*D_chebc_1(2:Nc_1,1), Kapa_solid_1*(2/Lc_1)*D_chebc_1(2:Nc_1,Nc_1+1)];

D_in_eqn3_volt2 = zeros(N,N);
D_in_eqn3_volt2(1:Na_1-1,1:Na_1-1) = (2*Kapa_solid_1/La_1)*D_cheba_1_in;
D_in_eqn3_volt2(Na_1:Na_1+Na_2-2,Na_1:Na_1+Na_2-2) = (2*Kapa_solid_2/La_2)*D_cheba_2_in;
D_in_eqn3_volt2(Na_1+Na_2-1:Na_1+Na_2+Nb-3,Na_1+Na_2-1:Na_1+Na_2+Nb-3) = (2*Kapa_elyte/Lb)*D_chebb_in;
D_in_eqn3_volt2(Na_1+Na_2+Nb-2:Na_1+Na_2+Nb+Nc_2-4,Na_1+Na_2+Nb-2:Na_1+Na_2+Nb+Nc_2-4) = (2*Kapa_solid_2/Lc_2)*D_chebc_2_in;
D_in_eqn3_volt2(Na_1+Na_2+Nb+Nc_2-3:N,Na_1+Na_2+Nb+Nc_2-3:N) = (2*Kapa_solid_1/Lc_1)*D_chebc_1_in;

D_ex_eqn3_lnc = K2*D_ex_eqn3_volt2;
D_in_eqn3_lnc= K2*D_in_eqn3_volt2;

A_in_3 = [zeros(N,N),D_in_eqn3_volt1,D_in_eqn3_volt2];
A_in_lnc = D_in_eqn3_lnc;
B_in_3 = [ones(Na_1-1,1);ones(Na_2-1,1);ones(Nb-1,1);ones(Nc_2-1,1);ones(Nc_1-1,1)];

A_ex_3 = [zeros(N,N),D_ex_eqn3_volt1*D_volt1_A ,D_ex_eqn3_volt2*D_volt2_B];
A_ex_lnc = D_ex_eqn3_volt2*D_volt2_C;
A_ex_lnc_ex_BC = -D_ex_eqn3_volt2*D_volt2_A;
A_ex_lnc_ex = D_ex_eqn3_lnc;
B_ex_3 = D_ex_eqn3_volt1*D_volt1_B;

A_3= A_in_3+A_ex_3;
A_lnc_3 = A_in_lnc +A_ex_lnc;
A_lnextc_3 = A_ex_lnc_ex_BC+A_ex_lnc_ex;

B_3= B_in_3+B_ex_3;

%% A MATRIX
A = zeros(3*N,3*N);
A(1:N,:) = A_1;
A(N+1:2*N,:) = A_2;
A(2*N+1:3*N,:) = A_3;

A2 = zeros(3*N-Nb+1,3*N-Nb+1);
A2(1:N+Na_1+Na_2-2,1:N+Na_1+Na_2-2) = A(1:N+Na_1+Na_2-2,1:N+Na_1+Na_2-2);
A2(N+Na_1+Na_2-2+1:end,1:N+Na_1+Na_2-2) = A(N+Na_1+Na_2-2+1+Nb-1:end,1:N+Na_1+Na_2-2);
A2(1:N+Na_1+Na_2-2,N+Na_1+Na_2-2+1:end) = A(1:N+Na_1+Na_2-2,N+Na_1+Na_2-2+1+Nb-1:end);
A2(N+Na_1+Na_2-2+1:end,N+Na_1+Na_2-2+1:N+N+N2) = A(N+Na_1+Na_2-2+1+Nb-1:end,N+Na_1+Na_2-2+1+Nb-1:end);
A = A2;

%% A LOG MATRIX
A_lnc = zeros(3*N,N);
A_lnextc = zeros(3*N,6);

A_lnc(2*N+1:3*N,1:N) = A_lnc_3;
A_lnextc(2*N+1:3*N,1:6) = A_lnextc_3;

A_lnc= [A_lnc(1:N+Na_1+Na_2-2,:);A_lnc(N+Na_1+Na_2-2+Nb:3*N,:)];
A_lnextc= [A_lnextc(1:N+Na_1+Na_2-2,:);A_lnextc(N+Na_1+Na_2-2+Nb:3*N,:)];

%% B MATRIX
B_2 = [B_2(1:Na_1+Na_2-2);B_2(Na_1+Na_2-2+Nb:N)];
B = [B_1;B_2;B_3];

%% MASS MATRIX
M = zeros(3*N,3*N);
M(1:Na_1-1,1:Na_1-1) = epsilon_solid_1*eye(Na_1-1,Na_1-1);
M(Na_1:Na_1+Na_2-2,Na_1:Na_1+Na_2-2) = epsilon_solid_2*eye(Na_2-1,Na_2-1);
M(Na_1+Na_2-1:Na_1+Na_2+Nb-3,Na_1+Na_2-1:Na_1+Na_2+Nb-3) = epsilon_elyte*eye(Nb-1,Nb-1);
M(Na_1+Na_2+Nb-2:Na_1+Na_2+Nb+Nc_2-4,Na_1+Na_2+Nb-2:Na_1+Na_2+Nb+Nc_2-4) = epsilon_solid_2*eye(Nc_2-1,Nc_2-1);
M(Na_1+Na_2+Nb+Nc_2-3:N,Na_1+Na_2+Nb+Nc_2-3:N) = epsilon_solid_1*eye(Nc_1-1,Nc_1-1);

M(1:Na_1-1,N+1:N+Na_1-1) = K1*a_1*C/F*eye(Na_1-1,Na_1-1);
M(Na_1:Na_1+Na_2-2,N+Na_1:N+Na_1+Na_2-2) = K1*a_2*C/F*eye(Na_2-1,Na_2-1);
% M(Na_1+Na_2-1:Na_1+Na_2+Nb-3,Na_1+Na_2-1:Na_1+Na_2+Nb-3) = epsilon_elyte*eye(Nb-1,Nb-1);
M(Na_1+Na_2+Nb-2:Na_1+Na_2+Nb+Nc_2-4,N+Na_1+Na_2+Nb-2:N+Na_1+Na_2+Nb+Nc_2-4) = K1*a_2*C/F*eye(Nc_2-1,Nc_2-1);
M(Na_1+Na_2+Nb+Nc_2-3:N,N+Na_1+Na_2+Nb+Nc_2-3:N+N) = K1*a_1*C/F*eye(Nc_1-1,Nc_1-1);

M(1:Na_1-1,N+N+1:N+N+Na_1-1) = -K1*a_1*C/F*eye(Na_1-1,Na_1-1);
M(Na_1:Na_1+Na_2-2,N+N+Na_1:N+N+Na_1+Na_2-2) = -K1*a_2*C/F*eye(Na_2-1,Na_2-1);
% M(Na_1+Na_2-1:Na_1+Na_2+Nb-3,Na_1+Na_2-1:Na_1+Na_2+Nb-3) = epsilon_elyte*eye(Nb-1,Nb-1);
M(Na_1+Na_2+Nb-2:Na_1+Na_2+Nb+Nc_2-4,N+N+Na_1+Na_2+Nb-2:N+N+Na_1+Na_2+Nb+Nc_2-4) = -K1*a_2*C/F*eye(Nc_2-1,Nc_2-1);
M(Na_1+Na_2+Nb+Nc_2-3:N,N+N+Na_1+Na_2+Nb+Nc_2-3:N+N+N) = -K1*a_1*C/F*eye(Nc_1-1,Nc_1-1);

M(N+1:2*N,N+1:2*N) = blkdiag(a_1*C*eye(Na_1-1,Na_1-1),a_2*C*eye(Na_2-1,Na_2-1),0*eye(Nb-1,Nb-1),a_2*C*eye(Nc_2-1,Nc_2-1),a_1*C*eye(Nc_1-1,Nc_1-1));
M(N+1:2*N,2*N+1:3*N) = blkdiag(-a_1*C*eye(Na_1-1,Na_1-1),-a_2*C*eye(Na_2-1,Na_2-1),0*eye(Nb-1,Nb-1),-a_2*C*eye(Nc_2-1,Nc_2-1),-a_1*C*eye(Nc_1-1,Nc_1-1));

M = [M(1:N+Na_1+Na_2-2,1:N+Na_1+Na_2-2),M(1:N+Na_1+Na_2-2,N+Na_1+Na_2-2+Nb:3*N);
    M(N+Na_1+Na_2-2+Nb:3*N,1:N+Na_1+Na_2-2),M(N+Na_1+Na_2-2+Nb:3*N,N+Na_1+Na_2-2+Nb:3*N)];

% tf = issymmetric(M)

%% SIMULATION
rhsfun = @(t,X) (A*X+A_lnc*log(X(1:N,1))+A_lnextc*log((Dc_a\Dc_b)*X(1:N,1))+B*i); %(define the RHS function)
options = odeset('Mass',M);
[t,states] = ode15s(rhsfun,[0 tf],x0,options); %(solve the problem)
size_states = (size(states,1));

%% OUTPUT MATRICES
D_volt1_out = D_volt1_A ;
B_volt1_out = D_volt1_B;

C_int = D_volt1_out(4,:)-D_volt1_out(1,:);
C_int = [C_int(1:Na_1+Na_2-2),C_int(Na_1+Na_2-2+Nb:N)];

D = B_volt1_out(4,:)-B_volt1_out(1,:);

C = [zeros(1,N),C_int, zeros(1,N)];


%% Output Signals
c_ext = zeros(6,size_states);

for j = 1:size_states
    y = -C*states(j,:)'-D*i;
    y_store(j) = y;
    i_store(j) = i;
    t_store(j) = t(j);
    
    c_ext(:,j) = Dc_A*states(j,1:N)';   
end

c_all = [c_ext(1,:)',states(:,1:Na_1-1),c_ext(2,:)',states(:,Na_1:Na_1+Na_2-2),c_ext(3,:)',states(:,Na_1+Na_2-1:Na_1+Na_2+Nb-3),c_ext(4,:)',states(:,Na_1+Na_2+Nb-2:Na_1+Na_2+Nb+Nc_2-4),c_ext(5,:)',states(:,Na_1+Na_2+Nb+Nc_2-3:N),c_ext(6,:)'];

Phi1_L = states(:,N+1:N+Na_1+Na_2-2)';
Phi1_R = states(:,N+Na_1+Na_2-1:N+Na_1+Na_2+Nc_1+Nc_2-4)';
Phi2 = states(:,N+Na_1+Na_2+Nc_1+Nc_2-3:end)';

x = zeros(1,N+5);
x(1:Na_1+1) = La_1/2*(x_CHEBa_1(Na_1+1:-1:1)+1);
x(Na_1+1:Na_1+Na_2+1) = La_1+La_2/2*(x_CHEBa_2(Na_2+1:-1:1)+1);
x(Na_1+Na_2+2:Na_1+Na_2+Nb) = La_1+La_2+Lb/2*(x_CHEBb(Nb:-1:2)+1);
x(Na_1+Na_2+Nb+1:Na_1+Na_2+Nb+Nc_2+1) = La_1+La_2+Lb+Lc_2/2*(x_CHEBc_1(Nc_2+1:-1:1)+1);
x(Na_1+Na_2+Nb+Nc_2+1:Na_1+Na_2+Nb+Nc_2+Nc_1+1) = La_1+La_2+Lb+Lc_2+Lc_1/2*(x_CHEBc_2(Nc_1+1:-1:1)+1);

x_L = [x(2:Na_1),x(Na_1+2:Na_1+Na_2)];
x_R = [x(Na_1+Na_2+Nb+2:Na_1+Na_2+Nb+Nc_1),x(Na_1+Na_2+Nb+Nc_1+2:Na_1+Na_2+Nb+Nc_1+Nc_2)];

%% PLotting
figure
plot(t_store,y_store,'linewidth',2)
grid on
xlabel('Time (s)');
ylabel('Voltage (V)');


[X,Y] = meshgrid([x(2:Na_1),x(Na_1+2:Na_1+Na_2),x(Na_1+Na_2+2:Na_1+Na_2+Nb),x(Na_1+Na_2+Nb+2:Na_1+Na_2+Nb+Nc_1),x(Na_1+Na_2+Nb+Nc_1+2:Na_1+Na_2+Nb+Nc_1+Nc_2)],t_store);
[X2,Y2] = meshgrid(x,t_store);
[XL,YL] = meshgrid(x_L,t_store);
[XR,YR] = meshgrid(x_R,t_store);

size(states(:,1:N)');

font_size = 12;
figure % Concentraion
surf(X,Y,states(:,1:N),'EdgeColor','none')
xlabel('x(m)','interpreter','latex', 'FontSize', font_size');
ylabel('Time (s)','interpreter','latex', 'FontSize', font_size');
zlabel('c (mol/m$^3$)','interpreter','latex', 'FontSize', font_size')


font_size = 12;
figure % Concentraion
surf(X,Y,Phi2','EdgeColor','none')
xlabel('x(m)','interpreter','latex', 'FontSize', font_size');
ylabel('Time(s)','interpreter','latex', 'FontSize', font_size');
zlabel('$\phi_2$ (V)','interpreter','latex', 'FontSize', font_size')

font_size = 12;
figure % Concentraion
surf(XL,YL,Phi1_L','EdgeColor','none')
xlabel('x(m)','interpreter','latex', 'FontSize', font_size');
ylabel('Time (s)','interpreter','latex', 'FontSize', font_size');
zlabel('$\phi_1$ (V)','interpreter','latex', 'FontSize', font_size')

font_size = 12;
figure % Concentraion
surf(XR,YR,Phi1_R','EdgeColor','none')
xlabel('x(m)','interpreter','latex', 'FontSize', font_size');
ylabel('Time (s)','interpreter','latex', 'FontSize', font_size');
zlabel('$\phi_1$ (V)','interpreter','latex', 'FontSize', font_size')


