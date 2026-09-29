"
Unit tests for OPToken. 
Verifies token initialization, property management, and steppability within the simulation framework.
"
Class {
	#name : 'OPTokenTest',
	#superclass : 'OPSimulatorTest',
	#category : 'OpenPonk-ModelSimulation-Tests',
	#package : 'OpenPonk-ModelSimulation',
	#tag : 'Tests'
}

{ #category : 'hooks' }
OPTokenTest >> controllerClass [
	^ OPDummySubclassOfOPToken
]

{ #category : 'hooks' }
OPTokenTest >> prepareOneSimulable [
	"do nothing"
]

{ #category : 'tests' }
OPTokenTest >> testStep [
	simulator addAction: [ :item | item doState ].

	self assert: simulator state = 1.
	simulator step.
	self assert: simulator state = 1.
	simulator steppable: true.
	simulator step.
	self assert: simulator state = 2
]
