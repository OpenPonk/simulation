"
Concrete subclass of OPElementSimulator used strictly for testing state saving, loading, and steppability within the simulation framework.
"
Class {
	#name : 'OPDummySubclassOfOPElementSimulator',
	#superclass : 'OPElementSimulator',
	#instVars : [
		'steppable'
	],
	#category : 'OpenPonk-ModelSimulation-Tests',
	#package : 'OpenPonk-ModelSimulation',
	#tag : 'Tests'
}

{ #category : 'initialization' }
OPDummySubclassOfOPElementSimulator >> initialize [
	super initialize.
	steppable := false
]

{ #category : 'testing' }
OPDummySubclassOfOPElementSimulator >> isSimulable [
	^ true
]

{ #category : 'testing' }
OPDummySubclassOfOPElementSimulator >> isSteppable [
	^ steppable
]

{ #category : 'actions' }
OPDummySubclassOfOPElementSimulator >> loadState [
	model resetState
]

{ #category : 'actions' }
OPDummySubclassOfOPElementSimulator >> saveState [
	model doState
]

{ #category : 'accessing' }
OPDummySubclassOfOPElementSimulator >> steppable: aBoolean [
	steppable := aBoolean
]
