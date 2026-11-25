"
Unit tests for OPSimulatorReset announcement creation and simulator reference.
"
Class {
	#name : 'OPSimulatorResetTest',
	#superclass : 'OPSimulatorEventTest',
	#category : 'OpenPonk-ModelSimulation-Tests-Events',
	#package : 'OpenPonk-ModelSimulation-Tests',
	#tag : 'Events'
}

{ #category : 'tests' }
OPSimulatorResetTest >> testInstanceCreation [

	| event |
	event := OPSimulatorReset simulator: simulator.
	self assert: event simulator identicalTo: simulator
]
