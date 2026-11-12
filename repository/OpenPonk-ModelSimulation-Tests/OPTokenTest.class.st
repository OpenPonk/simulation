"
Unit tests for OPToken. 
Verifies token initialization, property management, and steppability within the simulation framework.
"
Class {
	#name : 'OPTokenTest',
	#superclass : 'OPSimulatorTest',
	#category : 'OpenPonk-ModelSimulation-Tests-Simulators',
	#package : 'OpenPonk-ModelSimulation-Tests',
	#tag : 'Simulators'
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
	self assert: simulator state equals: 1.
	simulator step.
	self assert: simulator state equals: 1.
	simulator steppable: true.
	simulator step.
	self assert: simulator state equals: 2
]
