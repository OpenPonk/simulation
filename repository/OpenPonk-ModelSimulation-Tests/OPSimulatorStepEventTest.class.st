"
Unit tests for OPSimulatorStepEvent. 
Verifies the instantiation and behavior of step-related simulator events.
"
Class {
	#name : 'OPSimulatorStepEventTest',
	#superclass : 'OPSimulatorEventTest',
	#category : 'OpenPonk-ModelSimulation-Tests-Events',
	#package : 'OpenPonk-ModelSimulation-Tests',
	#tag : 'Events'
}

{ #category : 'tests' }
OPSimulatorStepEventTest >> testInstanceCreation [

	| event |
	event := OPSimulatorStepEvent simulator: simulator.
	self assert: event simulator equals: simulator
]
