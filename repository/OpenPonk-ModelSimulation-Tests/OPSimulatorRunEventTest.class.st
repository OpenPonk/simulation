"
Unit tests for OPSimulatorRunEvent. 
Verifies the instantiation and property management (such as repeat limits and delays) of run-related simulator events.
"
Class {
	#name : 'OPSimulatorRunEventTest',
	#superclass : 'OPSimulatorEventTest',
	#category : 'OpenPonk-ModelSimulation-Tests-Events',
	#package : 'OpenPonk-ModelSimulation-Tests',
	#tag : 'Events'
}

{ #category : 'tests' }
OPSimulatorRunEventTest >> testInstanceCreation [
	| event |
	event := OPSimulatorRunEvent simulator: simulator delay: 2 repeatTimes: 4.
	self assert: event simulator = simulator & event isLimited & (event repeatTimes = 4) & (event delay = 2).

	event := OPSimulatorRunEvent simulator: simulator delay: 2.
	self assert: event simulator = simulator & event isLimited not & (event delay = 2)
]
