"
Dummy element simulator used for testing state loading, connections, and simulability logic within the simulation framework.
"
Class {
	#name : 'OPDummyOPElementSimulator',
	#superclass : 'OPDummyOPSimulator',
	#instVars : [
		'steppable',
		'incoming',
		'outgoing',
		'loaded',
		'diagramSimulator',
		'loadedConnected',
		'state',
		'model',
		'tokens'
	],
	#category : 'OpenPonk-ModelSimulation-Tests',
	#package : 'OpenPonk-ModelSimulation',
	#tag : 'Tests'
}

{ #category : 'instance creation' }
OPDummyOPElementSimulator class >> model: aModel diagramSimulator: aSimulator [
	^ self new
		model: aModel;
		diagramSimulator: aSimulator;
		yourself
]

{ #category : 'accessing' }
OPDummyOPElementSimulator >> diagramSimulator [
	^ diagramSimulator
]

{ #category : 'accessing' }
OPDummyOPElementSimulator >> diagramSimulator: aSimulator [
	diagramSimulator := aSimulator
]

{ #category : 'initialization' }
OPDummyOPElementSimulator >> initialize [

	super initialize.
	loaded := false.
	steppable := false.
	state := 0.
	tokens := OrderedCollection with: OPDummyOPToken new
]

{ #category : 'testing' }
OPDummyOPElementSimulator >> isSimulable [
	^ true
]

{ #category : 'testing' }
OPDummyOPElementSimulator >> isSteppable [
	^ steppable
]

{ #category : 'creation' }
OPDummyOPElementSimulator >> loadConnectedItems [
	loadedConnected := true
]

{ #category : 'actions' }
OPDummyOPElementSimulator >> loadState [
	state := 1
]

{ #category : 'accessing' }
OPDummyOPElementSimulator >> loaded [
	^ state > 0 & loadedConnected
]

{ #category : 'accessing' }
OPDummyOPElementSimulator >> model [
	^ model
]

{ #category : 'accessing' }
OPDummyOPElementSimulator >> model: aModel [
	model := aModel
]

{ #category : 'actions' }
OPDummyOPElementSimulator >> saveState [
	state := state + 1
]

{ #category : 'tokens' }
OPDummyOPElementSimulator >> simulableTokens [
	^ self tokens
]

{ #category : 'accessing' }
OPDummyOPElementSimulator >> state [
	^ state
]

{ #category : 'accessing' }
OPDummyOPElementSimulator >> steppable: aBoolean [
	steppable := aBoolean
]

{ #category : 'tokens' }
OPDummyOPElementSimulator >> steppableTokens [
	^ OrderedCollection new
]

{ #category : 'tokens' }
OPDummyOPElementSimulator >> tokenCount [
	^ tokens size
]

{ #category : 'accessing' }
OPDummyOPElementSimulator >> tokens [
	^ tokens
]
