# Simulation of IdVg curves

#include "Common_des.cmd"

Solve {
	# Solution at initial conditions
	# Tighten up Poisson-only solution to ensure better initial solution
	Coupled(RHSMin= 1e-8 Iterations= 1000 LineSearchDamping= 1e-4){ Poisson }
	Coupled(Iterations= 100) { Poisson Electron Hole }
	
	Plot(FilePrefix="n@node@_Zero")

	Transient (
		InitialTime= 0 FinalTime= 1
		InitialStep= 0.001 MinStep= 1e-5 Maxstep= 0.05
		Goal { Name= drain Voltage= @Vd@ }
	) {                  
		Coupled { Poisson Electron Hole } 
	}

	NewCurrentFile="IdVg_"
	Transient (
		InitialTime= 1 FinalTime= 2
		InitialStep= 0.001 MinStep= 1e-5 Maxstep= 0.02
		Goal { Name= gate Voltage= @Vg@ }
	) {                  
		Coupled { Poisson Electron Hole } 
		Plot(FilePrefix="n@node@_ss" 
			Time=(Range=(1 2) Intervals= !(puts -nonewline [expr int(@Vg@)])!) 
			NoOverwrite
		)
	}
}

