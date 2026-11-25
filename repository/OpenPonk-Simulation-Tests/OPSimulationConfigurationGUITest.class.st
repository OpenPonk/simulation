"
Unit tests verifying simulator binding, empty-state rendering, and refresh hooks in OPSimulationConfigurationGUI.
"
Class {
	#name : 'OPSimulationConfigurationGUITest',
	#superclass : 'TestCase',
	#instVars : [
		'configurationGui'
	],
	#category : 'OpenPonk-Simulation-Tests-Simulation',
	#package : 'OpenPonk-Simulation-Tests',
	#tag : 'Simulation'
}

{ #category : 'running' }
OPSimulationConfigurationGUITest >> tearDown [

	configurationGui := nil.
	super tearDown
]

{ #category : 'tests' }
OPSimulationConfigurationGUITest >> testAbstractClassAndMinimalSubclassDefaults [

	| minimalConfig |
	self assert: OPSimulationConfigurationGUI isAbstract description: 'Base configuration GUI class must report abstract'.
	self deny: OPMinimalTestSimulationConfigurationGUI isAbstract description: 'Concrete subclass must not report abstract'.

	minimalConfig := OPMinimalTestSimulationConfigurationGUI on: Object new.
	self deny: minimalConfig hasConfigurableItems description: 'Base configuration GUI must default to no configurable items'.
	self assert: minimalConfig defaultLayout children first label equals: 'No configurable simulation options.'.
	minimalConfig refreshFromSimulator.
	self
		assert: minimalConfig diagramSimulator isNotNil
		description: 'Default refreshFromSimulator must preserve simulator reference'
]

{ #category : 'tests' }
OPSimulationConfigurationGUITest >> testOnBindsSimulatorBuildsLayoutAndRefreshes [

	| dummySimulator |
	dummySimulator := Object new.
	configurationGui := OPTestSimulationConfigurationGUI on: dummySimulator.
	self assert: configurationGui diagramSimulator identicalTo: dummySimulator.
	self assert: configurationGui defaultLayout class identicalTo: SpBoxLayout.

	configurationGui diagramSimulator: Object new.
	self assert: configurationGui refreshCount equals: 1.

	configurationGui hasItems: false.
	self assert: configurationGui defaultLayout children first label equals: 'No configurable simulation options.'
]
