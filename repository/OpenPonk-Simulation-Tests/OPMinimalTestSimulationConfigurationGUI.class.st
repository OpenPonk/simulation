"
Minimal concrete OPSimulationConfigurationGUI subclass overriding only #buildConfigurationLayout so tests exercise default base hooks directly.
"
Class {
	#name : 'OPMinimalTestSimulationConfigurationGUI',
	#superclass : 'OPSimulationConfigurationGUI',
	#category : 'OpenPonk-Simulation-Tests-Simulation',
	#package : 'OpenPonk-Simulation-Tests',
	#tag : 'Simulation'
}

{ #category : 'layout' }
OPMinimalTestSimulationConfigurationGUI >> buildConfigurationLayout [

	^ SpBoxLayout newTopToBottom yourself
]
