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
	self assert: event simulator identicalTo: simulator.
	self assert: event isLimited description: 'Run event with repeatTimes must be limited'.
	self assert: event repeatTimes equals: 4.
	self assert: event delay equals: 2.

	event := OPSimulatorRunEvent simulator: simulator delay: 2.
	self assert: event simulator identicalTo: simulator.
	self deny: event isLimited description: 'Run event without repeatTimes must not be limited'.
	self assert: event repeatTimes identicalTo: nil.
	self assert: event delay equals: 2
]
