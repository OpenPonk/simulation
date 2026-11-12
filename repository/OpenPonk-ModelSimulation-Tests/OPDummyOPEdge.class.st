"
Dummy model representing an edge between elements in a diagram. Used for testing the simulation framework.
"
Class {
	#name : 'OPDummyOPEdge',
	#superclass : 'OPDummyOPElement',
	#instVars : [
		'source',
		'target'
	],
	#category : 'OpenPonk-ModelSimulation-Tests-Simulators',
	#package : 'OpenPonk-ModelSimulation-Tests',
	#tag : 'Simulators'
}

{ #category : 'accessing' }
OPDummyOPEdge >> source [
	^ source
]

{ #category : 'accessing' }
OPDummyOPEdge >> source: anElement [
	source := anElement
]

{ #category : 'accessing' }
OPDummyOPEdge >> target [
	^ target
]

{ #category : 'accessing' }
OPDummyOPEdge >> target: anElement [
	target := anElement
]
