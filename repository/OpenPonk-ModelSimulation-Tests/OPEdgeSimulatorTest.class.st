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

	self assert: simulator source isNil.
	self assert: simulator target isNil.

	simulator source: self controllerClass new.
	simulator target: self controllerClass new.
	self assert: simulator source class equals: self controllerClass.
	self assert: simulator target class equals: self controllerClass.
	self assertCollection: simulator source outgoing includesAll: { simulator }.
	self assertCollection: simulator target incoming includesAll: { simulator }
]
