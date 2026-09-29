"
Concrete subclass of OPEdgeSimulator used strictly for testing state saving, loading, and steppability logic within the simulation framework.
"
Class {
	#name : 'OPDummySubclassOfOPEdgeSimulator',
	#superclass : 'OPEdgeSimulator',
	#instVars : [
		'steppable'
	],
	#category : 'OpenPonk-ModelSimulation-Tests',
	#package : 'OpenPonk-ModelSimulation',
	#tag : 'Tests'
}

{ #category : 'initialization' }
OPDummySubclassOfOPEdgeSimulator >> initialize [
	super initialize.
	steppable := false
]

{ #category : 'testing' }
OPDummySubclassOfOPEdgeSimulator >> isSimulable [
	^ true
]

{ #category : 'testing' }
OPDummySubclassOfOPEdgeSimulator >> isSteppable [
	^ steppable
]

{ #category : 'actions' }
OPDummySubclassOfOPEdgeSimulator >> loadState [
	model resetState
]

{ #category : 'actions' }
OPDummySubclassOfOPEdgeSimulator >> saveState [
	model doState
]

{ #category : 'accessing' }
OPDummySubclassOfOPEdgeSimulator >> steppable: aBoolean [
	steppable := aBoolean
]
