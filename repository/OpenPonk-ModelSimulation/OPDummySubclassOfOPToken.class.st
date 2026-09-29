"
Concrete subclass of OPToken used strictly for testing steppability and state logic within the simulation framework.
"
Class {
	#name : 'OPDummySubclassOfOPToken',
	#superclass : 'OPToken',
	#instVars : [
		'steppable',
		'state'
	],
	#category : 'OpenPonk-ModelSimulation-Tests',
	#package : 'OpenPonk-ModelSimulation',
	#tag : 'Tests'
}

{ #category : 'actions' }
OPDummySubclassOfOPToken >> doState [
	state := state + 1
]

{ #category : 'initialization' }
OPDummySubclassOfOPToken >> initialize [
	super initialize.
	steppable := false.
	state := 1
]

{ #category : 'testing' }
OPDummySubclassOfOPToken >> isSimulable [
	^ true
]

{ #category : 'testing' }
OPDummySubclassOfOPToken >> isSteppable [
	^ steppable
]

{ #category : 'accessing' }
OPDummySubclassOfOPToken >> state [
	^ state
]

{ #category : 'accessing' }
OPDummySubclassOfOPToken >> steppable: aBoolean [
	steppable := aBoolean
]
