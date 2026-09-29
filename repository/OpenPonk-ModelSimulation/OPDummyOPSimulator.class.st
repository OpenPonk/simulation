"
Dummy simulator class used for testing the simulation framework and priority logic.
"
Class {
	#name : 'OPDummyOPSimulator',
	#superclass : 'Object',
	#instVars : [
		'priority'
	],
	#category : 'OpenPonk-ModelSimulation-Tests',
	#package : 'OpenPonk-ModelSimulation',
	#tag : 'Tests'
}

{ #category : 'initialization' }
OPDummyOPSimulator >> initialize [
	super initialize.
	priority := 0
]

{ #category : 'accessing' }
OPDummyOPSimulator >> priority [
	^ priority
]

{ #category : 'accessing' }
OPDummyOPSimulator >> priority: aPriority [
	priority := aPriority
]
