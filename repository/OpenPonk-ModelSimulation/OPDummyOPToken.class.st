"
Dummy token simulator used for testing the flow and priority logic of tokens within the simulation framework.
"
Class {
	#name : 'OPDummyOPToken',
	#superclass : 'OPDummyOPSimulator',
	#instVars : [
		'element'
	],
	#category : 'OpenPonk-ModelSimulation-Tests',
	#package : 'OpenPonk-ModelSimulation',
	#tag : 'Tests'
}

{ #category : 'accessing' }
OPDummyOPToken >> element [
	^ element
]

{ #category : 'accessing' }
OPDummyOPToken >> element: anElement [
	element := anElement
]

{ #category : 'testing' }
OPDummyOPToken >> isSimulable [
	^ true
]

{ #category : 'testing' }
OPDummyOPToken >> isSteppable [
	^ false
]
