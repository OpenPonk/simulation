"
Dummy model representing a diagram. Used for testing the simulation framework.
"
Class {
	#name : 'OPDummyOPDiagram',
	#superclass : 'Object',
	#instVars : [
		'elements'
	],
	#category : 'OpenPonk-ModelSimulation-Tests-Simulators',
	#package : 'OpenPonk-ModelSimulation-Tests',
	#tag : 'Simulators'
}

{ #category : 'adding' }
OPDummyOPDiagram >> add: anElement [
	elements add: anElement
]

{ #category : 'adding' }
OPDummyOPDiagram >> addElements: aNumber [
	aNumber timesRepeat: [ elements add: OPDummyOPElement new ]
]

{ #category : 'accessing' }
OPDummyOPDiagram >> allElements [

	^ self elements
]

{ #category : 'accessing' }
OPDummyOPDiagram >> elements [
	^ elements
]

{ #category : 'initialization' }
OPDummyOPDiagram >> initialize [

	super initialize.
	elements := OrderedCollection new
]
