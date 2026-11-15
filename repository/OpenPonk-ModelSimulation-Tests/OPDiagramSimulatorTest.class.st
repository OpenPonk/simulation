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
	#category : 'OpenPonk-ModelSimulation-Tests-Simulators',
	#package : 'OpenPonk-ModelSimulation-Tests',
	#tag : 'Simulators'
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

	self assert: (simulator elements collect: #state as: Array) equals: #( 1 1 1 1 ).
	simulator elementsDo: [ :each | each saveState ].
	self assert: (simulator elements collect: #state as: Array) equals: #( 2 2 2 2 ).
	simulator simulableElementsDo: [ :each | each saveState ].
	self assert: (simulator elements collect: #state as: Array) equals: #( 3 3 3 2 )
]

{ #category : 'tests' }
OPDiagramSimulatorTest >> testLoadingOfModel [

	simulator elements do: [ :eachElement |
		self assert: eachElement loaded description: 'Every element simulator must be loaded after model loading' ].
	self assert: simulator elements size equals: 4.
	self assert: (simulator elements count: [ :each | each class = OPDummyOPEdgeSimulator ]) equals: 1.
	self assert: (simulator elements count: [ :each | each class = OPDummyOPElementSimulator ]) equals: 3.
	self assert: (simulator simulatorOf: diagram elements last) class identicalTo: OPDummyOPEdgeSimulator.
	simulator elements do: [ :eachElement | self assert: eachElement diagramSimulator identicalTo: simulator ]
]

{ #category : 'tests' }
OPDiagramSimulatorTest >> testStates [

	self assert: (simulator elements sum: [ :each | each state ]) equals: 4.
	simulator saveState.
	self assert: (simulator elements sum: [ :each | each state ]) equals: 8.
	simulator loadState.
	self assert: (simulator elements sum: [ :each | each state ]) equals: 4
]

{ #category : 'tests' }
OPDiagramSimulatorTest >> testStep [

	simulator
		fromSteppableElements;
		orderAny;
		priorityAny;
		selectAll;
		addAction: [ :item | item saveState ].
	self assert: (simulator elements sum: [ :each | each state ]) equals: 4.
	simulator step.
	self assert: (simulator elements sum: [ :each | each state ]) equals: 4.
	simulator elements first steppable: true.
	simulator elements second steppable: true.
	simulator step.
	self assert: (simulator elements sum: [ :each | each state ]) equals: 6
]
