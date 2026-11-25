"
Minimal concrete OPSimulationGUI subclass overriding only #simulatorClass so tests exercise default base hooks directly.
"
Class {
	#name : 'OPMinimalTestSimulationGUI',
	#superclass : 'OPSimulationGUI',
	#category : 'OpenPonk-Simulation-Tests-Simulation',
	#package : 'OpenPonk-Simulation-Tests',
	#tag : 'Simulation'
}

{ #category : 'private - hooks' }
OPMinimalTestSimulationGUI >> simulatorClass [

	^ OPTestSimulationDiagramSimulator
]
