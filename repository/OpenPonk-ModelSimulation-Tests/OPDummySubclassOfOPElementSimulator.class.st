"
Concrete subclass of OPElementSimulator used strictly for testing state saving, loading, and steppability within the simulation framework.
"
Class {
	#name : 'OPDummySubclassOfOPElementSimulator',
	#superclass : 'OPElementSimulator',
	#instVars : [
		'steppable'
	],
	#category : 'OpenPonk-ModelSimulation-Tests-Simulators',
	#package : 'OpenPonk-ModelSimulation-Tests',
	#tag : 'Simulators'
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

	super loadState.
	model resetState
]

{ #category : 'actions' }
OPDummySubclassOfOPElementSimulator >> saveState [

	super saveState.
	model doState
]

{ #category : 'accessing' }
OPDummySubclassOfOPElementSimulator >> steppable: aBoolean [
	steppable := aBoolean
]
