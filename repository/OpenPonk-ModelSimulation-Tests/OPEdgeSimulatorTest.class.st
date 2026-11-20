"
Unit tests for OPEdgeSimulator. 
Verifies the simulation logic, state management, and source/target connection handling specific to edges.
"
Class {
	#name : 'OPEdgeSimulatorTest',
	#superclass : 'OPElementSimulatorTest',
	#category : 'OpenPonk-ModelSimulation-Tests-Simulators',
	#package : 'OpenPonk-ModelSimulation-Tests',
	#tag : 'Simulators'
}

{ #category : 'hooks' }
OPEdgeSimulatorTest >> controllerClass [
	^ OPDummySubclassOfOPEdgeSimulator
]

{ #category : 'running' }
OPEdgeSimulatorTest >> setUp [

	super setUp.
	simulator model: OPDummyOPEdge new
]

{ #category : 'tests' }
OPEdgeSimulatorTest >> testConnectedAliases [

	self assert: simulator source identicalTo: nil.
	self assert: simulator target identicalTo: nil.

	simulator source: self controllerClass new.
	simulator target: self controllerClass new.
	self assert: simulator source class identicalTo: self controllerClass.
	self assert: simulator target class identicalTo: self controllerClass.
	self assertCollection: simulator source outgoing includesAll: { simulator }.
	self assertCollection: simulator target incoming includesAll: { simulator }
]

{ #category : 'tests' }
OPEdgeSimulatorTest >> testLoadConnectedItems [

	| diagramSimulator sourceModel targetModel sourceSimulator targetSimulator edgeModel edgeSimulator |
	diagramSimulator := OPDummySubclassOfOPDiagramSimulator new.
	sourceModel := OPDummyOPElement new.
	targetModel := OPDummyOPElement new.
	sourceSimulator := OPDummySubclassOfOPElementSimulator model: sourceModel diagramSimulator: diagramSimulator.
	targetSimulator := OPDummySubclassOfOPElementSimulator model: targetModel diagramSimulator: diagramSimulator.
	diagramSimulator elements
		add: sourceSimulator;
		add: targetSimulator.
	edgeModel := OPDummyOPEdge new
		             source: sourceModel;
		             target: targetModel;
		             yourself.
	edgeSimulator := self controllerClass model: edgeModel diagramSimulator: diagramSimulator.
	edgeSimulator loadConnectedItems.
	self assert: edgeSimulator source identicalTo: sourceSimulator.
	self assert: edgeSimulator target identicalTo: targetSimulator.
	self assertCollection: sourceSimulator outgoing includesAll: { edgeSimulator }.
	self assertCollection: targetSimulator incoming includesAll: { edgeSimulator }
]

{ #category : 'tests' }
OPEdgeSimulatorTest >> testSourceAndTargetCannotBeSetTwice [

	| sourceError targetError |
	simulator source: self controllerClass new.
	sourceError := nil.
	[ simulator source: self controllerClass new ]
		on: Error
		do: [ :error | sourceError := error ].
	self assert: sourceError isNotNil description: 'Setting a second source must signal an Error'.
	self assert: sourceError messageText equals: 'edge can have only one source'.
	self assert: sourceError description equals: 'Error: edge can have only one source'.

	simulator target: self controllerClass new.
	targetError := nil.
	[ simulator target: self controllerClass new ]
		on: Error
		do: [ :error | targetError := error ].
	self assert: targetError isNotNil description: 'Setting a second target must signal an Error'.
	self assert: targetError messageText equals: 'edge can have only one target'.
	self assert: targetError description equals: 'Error: edge can have only one target'
]
