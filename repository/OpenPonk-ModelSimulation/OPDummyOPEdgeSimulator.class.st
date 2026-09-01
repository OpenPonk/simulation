"
Dummy edge simulator used for testing the connections between source and target elements within the simulation framework.
"
Class {
	#name : 'OPDummyOPEdgeSimulator',
	#superclass : 'OPDummyOPElementSimulator',
	#category : 'OpenPonk-ModelSimulation-Tests',
	#package : 'OpenPonk-ModelSimulation',
	#tag : 'Tests'
}

{ #category : 'testing' }
OPDummyOPEdgeSimulator >> isSimulable [
	^ false
]

{ #category : 'accessing' }
OPDummyOPEdgeSimulator >> source [
	^ incoming first
]

{ #category : 'accessing' }
OPDummyOPEdgeSimulator >> target [
	^ outgoing first
]

{ #category : 'tokens' }
OPDummyOPEdgeSimulator >> tokenCount [
	^ 0
]

{ #category : 'accessing' }
OPDummyOPEdgeSimulator >> tokens [
	^ OrderedCollection new
]
