"
View model registered for OPTestSimulationModel so headless simulation GUI tests use the real project controller and view model registry.
"
Class {
	#name : 'OPTestSimulationModelViewModel',
	#superclass : 'OPModelObjectViewModel',
	#category : 'OpenPonk-Simulation-Tests-Simulation',
	#package : 'OpenPonk-Simulation-Tests',
	#tag : 'Simulation'
}

{ #category : 'accessing' }
OPTestSimulationModelViewModel class >> modelClass [

	^ OPTestSimulationModel
]
