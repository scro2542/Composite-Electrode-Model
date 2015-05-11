# Supercapacitor-Model
This code simulates a constant-current(CC), constant-voltage (CV) charging profile for the Verbrugge supercapacitor model discretised using the spectral collocation method. Execution of the master.m file runs this simulation. The simulation results are compared to experimental data. Both the model parameters and experimental data were obtained from http://jes.ecsdl.org/content/152/5/D79.short.

In the CC charging profile, the model input is the current and the output is the voltage. With the CV charging profile, the input is the voltage and the current is the output. These simulations are ran by Constant_Current.m and Constant_voltage.m. The spectral collocation differentiation matrices were obtained using cheb.m from https://people.maths.ox.ac.uk/trefethen/spectral.html.  The model parameters are set up in super_params.m and are defined there.

To simulate the results of http://jes.ecsdl.org/content/152/5/D79.short, the 3 CC charging times (12.7s,18.7s and 23.2s) were implemented. The experimental results for these charging profiles are stored in different files data_2V.txt, data.txt and data_25V.txt. 

My name is Ross Drummond (ross.drummond@eng.ox.ac.uk) and I hold the MIT licencse for this code. The accompanying paper for the code can be found at http://www.sciencedirect.com/science/article/pii/S0378775314019739. I would ask that you cite this paper as Drummond, Ross, David A. Howey, and Stephen R. Duncan. "Low-order mathematical modelling of electric double layer supercapacitors using spectral methods." Journal of Power Sources 277 (2015): 317-328 if you want to use this code for your own research. For further details on the work of the Energy Power Group at Oxford, please see epg.eng.ox.ac.uk.
