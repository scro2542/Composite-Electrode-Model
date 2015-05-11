# Supercapacitor-Model
This code simulates a constant-current charging profile for a composite electrode supercapacitor model discretised using the spectral collocation method. Execution of Composite_Electrode_CC.m runs the simulation. The model input is the current and the output is the voltage. The spectral collocation differentiation matrices were obtained using cheb.m from https://people.maths.ox.ac.uk/trefethen/spectral.html.  The model parameters are set up in super_params.m and are defined there. The simulation initial condition and charging current are given in initial_cons_current.m.


My name is Ross Drummond (ross.drummond@eng.ox.ac.uk) and I hold the MIT licencse for this code. 
