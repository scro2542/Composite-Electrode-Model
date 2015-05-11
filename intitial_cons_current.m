% This file sets up the initial conditions of the solver x0 and the charging
% current i. 

%My name is Ross Drummond (ross.drummond@eng.ox.ac.uk) and I hold the MIT license for this code. 

function [x0,i] = intitial_cons_current(Na_1,Na_2,Nb,Nc_1,Nc_2,sigma_1,sigma_2,La_1,La_2,Lb,Lc_1,Lc_2)

i = 100/2.747;

N = Na_1+Na_2+Nb+Nc_1+Nc_2-5;
N2 = Na_1+Na_2+Nc_1+Nc_2-4;

%% INITIAL CONDITIONS
% Concentraion
c_0 = zeros(N,1);
ceq = 930;
c_0(1:Na_1-1)= ceq;
c_0(Na_1:Na_1+Na_2-2)= ceq;
c_0(Na_1+Na_2-1:Na_1+Na_2+Nb-3)= ceq;
c_0(Na_1+Na_2-1:Na_1+Na_2+Nb-3)= ceq;
c_0(Na_1+Na_2+Nb-2:Na_1+Na_2+Nb+Nc_1-4)= ceq;
c_0(Na_1+Na_2+Nb+Nc_1-3:Na_1+Na_2+Nb+Nc_1+Nc_2-5)= ceq;

%% Phi1
[~,x_CHEBa_1] = cheb(Na_1);
[~,x_CHEBa_2] = cheb(Na_2);
[~,x_CHEBb] = cheb(Nb);
[~,x_CHEBc_1] = cheb(Nc_1);
[~,x_CHEBc_2] = cheb(Nc_2);

x = zeros(1,N+6);
x(1:Na_1+1) = La_1/2*(x_CHEBa_1(Na_1+1:-1:1)+1);
x(Na_1+1:Na_1+Na_2+1) = La_1+La_2/2*(x_CHEBa_2(Na_2+1:-1:1)+1);
x(Na_1+Na_2+2:Na_1+Na_2+Nb) = La_1+La_2+Lb/2*(x_CHEBb(Nb:-1:2)+1);
x(Na_1+Na_2+Nb+1:Na_1+Na_2+Nb+Nc_1+1) = La_1+La_2+Lb+Lc_1/2*(x_CHEBc_1(Nc_1+1:-1:1)+1);
x(Na_1+Na_2+Nb+Nc_1+1:Na_1+Na_2+Nb+Nc_1+Nc_2+1) = La_1+La_2+Lb+Lc_1+Lc_2/2*(x_CHEBc_2(Nc_2+1:-1:1)+1);

volt1_0 = zeros(N2,1);
volt1_0(1:Na_1-1)= -i*x(2:Na_1)/sigma_1;
volt1_0(Na_1:Na_1+Na_2-2)= -i*x(Na_1+2:Na_1+Na_2)/sigma_2;
volt1_0(Na_1+Na_2-1:Na_1+Na_2+Nc_1-3)= -i*x(Na_1+Na_2+Nb+2:Na_1+Na_2+Nb+Nc_1)/sigma_2;
volt1_0(Na_1+Na_2+Nc_1-3+1:end)= -i*x(Na_1+Na_2+Nb+Nc_1+2:Na_1+Na_2+Nb+Nc_1+Nc_2)/sigma_1;

%% Phi2
volt2_0 = 0.1*ones(N,1);

%%
x0 = [c_0;volt1_0; volt2_0];

end

