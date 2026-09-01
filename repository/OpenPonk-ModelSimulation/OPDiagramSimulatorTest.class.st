"
Unit tests for OPDiagramSimulator. 
Verifies the loading of model elements, connections, and overall diagram simulation state tracking.
"
Class {
	#name : 'OPDiagramSimulatorTest',
	#superclass : 'OPModelSimulatorTest',
	#instVars : [
		'diagram'
	],
	#category : 'OpenPonk-ModelSimulation-Tests',
	#package : 'OpenPonk-ModelSimulation',
	#tag : 'Tests'
}

{ #category : 'hooks' }
OPDiagramSimulatorTest >> controllerClass [
	^ OPDummySubclassOfOPDiagramSimulator
]

{ #category : 'hooks' }
OPDiagramSimulatorTest >> prepareOneSimulable [
	diagram := OPDummyOPDiagram new addElements: 1.
	simulator := self controllerClass model: diagram
]

{ #category : 'running' }
OPDiagramSimulatorTest >> setUp [
	| edge |
	super setUp.
	diagram := OPDummyOPDiagram new.
	diagram addElements: 3.
	edge := OPDummyOPEdge new
		source: diagram elements first;
		target: diagram elements second;
		yourself.
	diagram add: edge.
	simulator model: diagram
]

{ #category : 'tests' }
OPDiagramSimulatorTest >> testAccessing [

	self assert: simulator simulableElements size equals: 3.
	self assertEmpty: simulator steppableElements.
	simulator elements first steppable: true.
	self assert: simulator steppableElements size equals: 1.

	self assert: simulator tokenCount equals: 3.
	self assert: simulator tokens size equals: 3.
	self assertEmpty: simulator steppableTokens.
	self assert: simulator simulableTokens size equals: 3.

	self assert: simulator model class equals: OPDummyOPDiagram
]

{ #category : 'tests' }
OPDiagramSimulatorTest >> testEnumeration [
	self assert: (simulator elements allSatisfy: [ :each | each state = 1 ]).
	simulator elementsDo: [ :each | each saveState ].
	self assert: (simulator elements allSatisfy: [ :each | each state = 2 ]).
	simulator simulableElementsDo: [ :each | each saveState ].
	self assert: (simulator elements allSatisfy: [ :each | each isSimulable not or: [ each state = 3 ] ])
]

{ #category : 'tests' }
OPDiagramSimulatorTest >> testLoadingOfModel [
	self assert: (simulator elements allSatisfy: [ :each | each loaded ]).
	self assert: simulator elements size = 4.
	self assert: (simulator elements count: [ :each | each class = OPDummyOPEdgeSimulator ]) = 1.
	self assert: (simulator elements count: [ :each | each class = OPDummyOPElementSimulator ]) = 3.

	self assert: (simulator simulatorOf: diagram elements last) class = OPDummyOPEdgeSimulator.
	self assert: (simulator elements allSatisfy: [ :each | each diagramSimulator = simulator ])
]

{ #category : 'tests' }
OPDiagramSimulatorTest >> testStates [
	self assert: (simulator elements sum: [ :each | each state ]) = 4.
	simulator saveState.
	self assert: (simulator elements sum: [ :each | each state ]) = 8.
	simulator loadState.
	self assert: (simulator elements sum: [ :each | each state ]) = 4
]

{ #category : 'tests' }
OPDiagramSimulatorTest >> testStep [
	simulator
		fromSteppableElements;
		orderAny;
		priorityAny;
		selectAll;
		addAction: [ :item | item saveState ].

	self assert: (simulator elements sum: [ :each | each state ]) = 4.
	simulator step.
	self assert: (simulator elements sum: [ :each | each state ]) = 4.
	simulator elements first steppable: true.
	simulator elements second steppable: true.
	simulator step.
	self assert: (simulator elements sum: [ :each | each state ]) = 6
]
