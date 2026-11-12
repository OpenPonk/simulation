"
Dummy model representing an element within a diagram. Used for testing the simulation framework.
"
Class {
	#name : 'OPDummyOPElement',
	#superclass : 'Object',
	#instVars : [
		'state'
	],
	#category : 'OpenPonk-ModelSimulation-Tests-Simulators',
	#package : 'OpenPonk-ModelSimulation-Tests',
	#tag : 'Simulators'
}

{ #category : 'actions' }
OPDummyOPElement >> doState [
	state := state + 1
]

{ #category : 'initialization' }
OPDummyOPElement >> initialize [

	super initialize.
	state := 1
]

{ #category : 'private' }
OPDummyOPElement >> resetState [
	state := 1
]

{ #category : 'accessing' }
OPDummyOPElement >> state [
	^ state
]
