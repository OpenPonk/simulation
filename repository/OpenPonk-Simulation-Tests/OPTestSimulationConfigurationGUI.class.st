"
Concrete test subclass of OPSimulationConfigurationGUI used by OpenPonk-Simulation-Tests to verify embedded sidebar rendering, refresh, and empty-state behavior.
"
Class {
	#name : 'OPTestSimulationConfigurationGUI',
	#superclass : 'OPSimulationConfigurationGUI',
	#instVars : [
		'hasItems',
		'refreshCount',
		'itemLabel'
	],
	#category : 'OpenPonk-Simulation-Tests-Simulation',
	#package : 'OpenPonk-Simulation-Tests',
	#tag : 'Simulation'
}

{ #category : 'layout' }
OPTestSimulationConfigurationGUI >> buildConfigurationLayout [

	^ SpBoxLayout newTopToBottom
		  borderWidth: 8;
		  add: itemLabel expand: false;
		  yourself
]

{ #category : 'testing' }
OPTestSimulationConfigurationGUI >> hasConfigurableItems [

	^ hasItems ifNil: [ true ]
]

{ #category : 'accessing' }
OPTestSimulationConfigurationGUI >> hasItems: aBoolean [

	hasItems := aBoolean
]

{ #category : 'initialization' }
OPTestSimulationConfigurationGUI >> initializePresenters [

	super initializePresenters.
	hasItems := true.
	refreshCount := 0.
	itemLabel := self newLabel
		             label: 'Configurable option';
		             yourself
]

{ #category : 'accessing' }
OPTestSimulationConfigurationGUI >> refreshCount [

	^ refreshCount ifNil: [ 0 ]
]

{ #category : 'updating' }
OPTestSimulationConfigurationGUI >> refreshFromSimulator [

	refreshCount := self refreshCount + 1
]
