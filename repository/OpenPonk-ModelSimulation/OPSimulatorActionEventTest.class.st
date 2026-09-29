"
Unit tests for OPSimulatorActionEvent. 
Verifies the instantiation and behavior of action-related simulator events.
"
Class {
	#name : 'OPSimulatorActionEventTest',
	#superclass : 'OPSimulatorEventTest',
	#category : 'OpenPonk-ModelSimulation-Tests',
	#package : 'OpenPonk-ModelSimulation',
	#tag : 'Tests'
}

{ #category : 'tests' }
OPSimulatorActionEventTest >> testInstanceCreation [
	| event |
	event := OPSimulatorActionEvent simulator: simulator action: [ 2 + 2 ] index: 2.
	self assert: event simulator = simulator & (event action value = 4) & (event index = 2)
]
