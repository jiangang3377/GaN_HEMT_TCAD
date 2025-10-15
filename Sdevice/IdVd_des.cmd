# IdVd curve

#include "Common_des.cmd"

Solve {
	# Solution at initial conditions
	# Tighten up Poisson-only solution to ensure better initial solution
	Coupled(RHSMin= 1e-8 Iterations= 1000 LineSearchDamping= 1e-4){ Poisson }
	Coupled(Iterations= 100) { Poisson Electron Hole }
	
	# Ramp up gate bias
	Transient (
		InitialTime= 0 FinalTime= 1
		InitialStep= 0.01 MinStep= 1.0e-5 Maxstep= 0.02
		Goal { Name= gate Voltage= @Vgs_IdVd@ }
	) {                  
		Coupled { Poisson Electron Hole } 
	}

	# Ramp up drain bias
	NewCurrentFile="IdVd_"
	Transient (
		InitialTime= 1 FinalTime= 2
		InitialStep= 0.002 MinStep= 1.0e-5 Maxstep= 0.01
		Goal { Name= drain Voltage= @Vds_IdVd@ }
	) {                  
		Coupled { Poisson Electron Hole } 
		Plot(FilePrefix="n@node@_ss" Time=(Range=(1 2) Intervals= 5) NoOverwrite)
	}
}
