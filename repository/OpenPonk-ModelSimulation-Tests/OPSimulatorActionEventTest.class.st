"
Unit tests for OPSimulatorActionEvent. 
Verifies the instantiation and behavior of action-related simulator events.
"
Class {
	#name : 'OPSimulatorActionEventTest',
	#superclass : 'OPSimulatorEventTest',
	#category : 'OpenPonk-ModelSimulation-Tests-Events',
	#package : 'OpenPonk-ModelSimulation-Tests',
	#tag : 'Events'
}

{ #category : 'tests' }
OPSimulatorActionEventTest >> testInstanceCreation [

	| event |
	event := OPSimulatorActionEvent simulator: simulator action: [ 2 + 2 ] index: 2.
	self assert: event simulator identicalTo: simulator.
	self assert: event action value equals: 4.
	self assert: event index equals: 2
]
