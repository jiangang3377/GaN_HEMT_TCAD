File {
	Grid= 			"@tdr@"
	Parameter= 		"@parameter@"
	
	Current= 		"@plot@"
	Plot= 			"@tdrdat@"
	Output=			"@log@"
} 

Electrode {
	{Name= source	Voltage= 0.0 Schottky Workfunction= 3.8 Resist= @<1e3*Rsd>@}	* Rsd in Ohm-mm
	{Name= drain	Voltage= 0.0 Schottky Workfunction= 3.8 Resist= @<1e3*Rsd>@}	* Rsd in Ohm-mm
	{Name= gate  	Voltage= 0.0 Schottky Workfunction= @WF@}
	{Name= bulk		Voltage= 0.0}
}

Physics { 
	# Latest set of calibrated parameters from the MaterialDB 
	DefaultParametersFromFile 

	# Use Fermi statistics
	Fermi
	
	# Thermionic emissionBCs at heterinterfaces
	Thermionic
	
	# Mobility dependence on doping and trap conscentration, as well as on local electric field
	# along current direction
	Mobility (
		DopingDependence
		HighFieldSaturation
	)
    
	# Turn on important generation/recombination processes in GaN HEMTs
	Recombination (
		SRH 
		Radiative
		Auger
	)
		
	# Significant incomplete ionization of Mg in GaN
	IncompleteIonization(Dopants= "pMagnesiumActiveConcentration")
	
	# No data available on bandgap narrowing. Therefore, turn model off
	EffectiveIntrinsicDensity ( NoBandGapNarrowing )
	
	# Automatically capture polarization charges via divergence of polarization fields
	Piezoelectric_Polarization(strain)
	
	# Tunneling of electrons from VB to gate metal dominates for low WF metals such as W
	# but hole tunneling may significantly contribute for larger work function metals (e.g. Ni)
	# Adding "Band2Band" option to eBarrierTunneling allows us to capture tunneling between
	# GaN valence band and metal "conduction band"
	eBarrierTunneling "NLM_Gate" (Band2Band)
	hBarrierTunneling "NLM_Gate"
}

Physics (Region="Barrier") {
	Traps (
		# Hypothesis is that traps mediate TAT and explain the somewhat large 
		# leakage levels observed experimentally
		(Acceptor Uniform Conc= @<Nt2>@ EnergyMid= @<Et2>@ EnergySig= @<st2>@  FromConductionBand
		 Add2TotalDoping hXSection= 1e-13 eXSection= 1e-13
			SpatialShape= @SpcShp2@ SpaceMid=(@xt2@,0,0) SpaceSig=(@dxt2@,100,100)
	   		#if @TAT@
	   		# TAT via 
	   		#	a) electron tunneling from channel to trap
	   		#	b) hole tunneling from pGate to trap
	  		eBarrierTunneling(NonLocal= "NLM_Bot")
	  		hBarrierTunneling(NonLocal= "NLM_Top")
 	  		TrapVolume= 1e-8 HuangRhys= 20 PhononEnergy= 0.091
 	  		#endif
	  	)
	)
 	
 	MoleFraction(xFraction= @xB@)
}

Physics (Region="Barrier.l") {
	MoleFraction(xFraction= @xB@)
}

Physics (Region="Barrier.r") {
 	MoleFraction(xFraction= @xB@)
}

Physics (Region="GaNBuffer") {
	Traps (
  		# Assume C doping imposes a level ~0.9 eV from Ev (~-0.8 from mid bandgap)
		(Acceptor Level Conc= 1e19 EnergyMid= -0.8 FromMidbandgap SFactor="DeepLevels")
	)
}

Physics (Region="AlGaNBuffer") {
	Traps (
  		# Assume C doping imposes a level ~0.9 eV from Ev (~-0.8 from mid bandgap)
		(Acceptor Level Conc= 1e19 EnergyMid= -0.8 FromMidbandgap SFactor="DeepLevels")
	)
	
 	MoleFraction(xFraction= 0)
}

Physics (Region="Nucleation") {
	Traps (
  		# Assume C doping imposes a level ~0.9 eV from Ev (~-0.8 from mid bandgap)
		(Acceptor Level Conc= 1e19 EnergyMid= -0.8 FromMidbandgap SFactor="DeepLevels")
	)
	
	# Turn off polarization effects around nucleation. Lack of available info
	Piezoelectric_Polarization(Activation= 0)
}

Physics (MaterialInterface="AlGaN/Si3N4") {
	Piezoelectric_Polarization(Activation= 0.1)
	Traps(Donor Level EnergyMid= 1.0 FromMidbandgap Conc= 1e13)
}

Physics (MaterialInterface="GaN/Si3N4") {
	Piezoelectric_Polarization(Activation= 0.0)
	# Traps(Donor Level EnergyMid= 1.0 FromMidbandgap Conc= 1e13)
}

Plot { 
	ElectricField/Vector 
	eMobility hMobility
	eCurrent/Vector hCurrent/Vector TotalCurrent/Vector CurrentPotential
	
	DopingConcentration DonorConcentration AcceptorConcentration
	TotalTrapConcentration eTrappedCharge hTrappedCharge
	TotalInterfaceTrapConcentration eInterfaceTrappedCharge hInterfaceTrappedCharge
	nSiliconActiveConcentration
	pMagnesiumActiveConcentration pMagnesiumConcentration pMagnesiumMinusConcentration
	PMIUserField0 PMIUserField1
	
	SpaceCharge
	ConductionBandEnergy ValenceBandEnergy eQuasiFermiEnergy hQuasiFermiEnergy
	EffectiveBandgap Affinity
	
	PE_Polarization/Vector PE_Charge
	
	xMoleFraction

	eBarrierTunneling hBarrierTunneling eGapStatesRecombination hGapStatesRecombination
	SRH Radiative
	
	StressXX StressXY StressXZ StressYY StressYZ StressZZ
	
	lHeatFlux TotalHeat eJouleHeat hJouleHeat PeltierHeat ThomsonHeat 
	RecombinationHeat netRecombinationHeat
	
	NonLocal
}

Math {
	Extrapolate
	ExtendedPrecision
	Digits= 5
	Iterations= 23
	
	* Only required if anisotropic models are turned on
	TensorGridAniso(Aniso)
	
	* Refine solution until RHS increases or drops below 1e-3
	* This improves robustness as initial guesses for computing new solution are more precise
	* However, it leads to a larger number of Newton iterations and, therefore, slower simulations
	CheckRhsAfterUpdate
	RHSMin= 1e-4
	
	Method= ILS(set= 11)
	ILSrc="
		set(11){
			iterative(gmres(100), tolrel=1e-12, tolunprec=1e-6, tolabs=0, maxit=200);
			preconditioning(ilut(5.0e-7,-1), right);
			ordering(symmetric=nd, nonsymmetric=mpsilst);
			options(compact=yes, linscale=0, refineresidual=10, verbose=0);
		};
	"
	Number_of_Threads= 4
	Wallclock
	
	Transient= BE
	# Traps(Damping= 0)
	DirectCurrent
	
	# Lowering relative error limit sometimes helps with convergence. No significant effect
	# seen for simulations included in this project
	ErrRef(electron)= 1e5
	ErrRef(hole)= 1e5
	
	# Set threshold densities for driving force damping large enough so that driving force is
	# as free of noise as possible.
	# Electrons will move parallel to interface while holes will primarily move vertically
	RefDens_eGradQuasiFermi_EparallelToInterface= 1e8
	RefDens_hGradQuasiFermi_ElectricField_HFS= 1e8

	# ElementEdge averaging is believed to be a better option today than the default "Element"
	eMobilityAveraging= ElementEdge
	hMobilityAveraging= ElementEdge

	SimStats
	CNormPrint
	
	ExitOnFailure
	
	ComputeDopingConcentration			* Forces S-Device to recompute DopingConcentration
	
	NonLocal "NLM_Gate" (
		Electrode="gate"
		Length= 15e-7
		Digits= 4
	)

	NonLocal "NLM_Bot" (
		RegionInterface="Channel/Barrier"
		Length= @<0.9*tB*1e-4>@
		Digits= 4
		Direction=(1 0 0) MaxAngle= 60
		-Transparent(Region="Channel")
	)

	NonLocal "NLM_Top" (
		RegionInterface="pGate/Barrier"
		Length= @<0.9*tB*1e-4>@
		Digits= 4
		Direction=(1 0 0) MaxAngle= 60
		-Transparent(Region="pGate")
	)
	
    -CheckUndefinedModels

    # Increase number of discretized trap levels for smoother, though slower, simulated curves
    TrapDLN= 30

	# Optional computation of simulation performance statistics
	# Data saved in the plt file along with other data such as terminal voltages, currents
	SimStats
}

