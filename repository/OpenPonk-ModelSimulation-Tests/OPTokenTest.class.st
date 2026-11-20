"
Unit tests for OPToken. 
Verifies token initialization, property management, and steppability within the simulation framework.
"
Class {
	#name : 'OPTokenTest',
	#superclass : 'OPSimulatorTest',
	#category : 'OpenPonk-ModelSimulation-Tests-Simulators',
	#package : 'OpenPonk-ModelSimulation-Tests',
	#tag : 'Simulators'
}

{ #category : 'hooks' }
OPTokenTest >> controllerClass [
	^ OPDummySubclassOfOPToken
]

{ #category : 'hooks' }
OPTokenTest >> prepareOneSimulable [
	"do nothing"
]

{ #category : 'tests' }
OPTokenTest >> testElementAndDiagramSimulator [

	| diagramModel diagramSimulator elementSimulator tokenFromElement tokenFromDiagram |
	diagramModel := OPDummyOPDiagram new.
	diagramSimulator := OPDummySubclassOfOPDiagramSimulator model: diagramModel.
	elementSimulator := OPDummySubclassOfOPElementSimulator model: OPDummyOPElement new diagramSimulator: diagramSimulator.

	tokenFromElement := self controllerClass element: elementSimulator.
	self assert: tokenFromElement element identicalTo: elementSimulator.
	self assert: tokenFromElement diagramSimulator identicalTo: diagramSimulator.
	self assert: tokenFromElement diagram identicalTo: diagramModel.

	tokenFromElement element: nil.
	self assert: tokenFromElement element identicalTo: nil.
	self assert: tokenFromElement diagramSimulator identicalTo: nil.

	tokenFromDiagram := self controllerClass diagramSimulator: diagramSimulator.
	self assert: tokenFromDiagram element identicalTo: nil.
	self assert: tokenFromDiagram diagramSimulator identicalTo: diagramSimulator.
	self assert: tokenFromDiagram diagram identicalTo: diagramModel
]

{ #category : 'tests' }
OPTokenTest >> testPriority [

	self assert: simulator priority equals: 0.
	simulator priority: 7.
	self assert: simulator priority equals: 7
]

{ #category : 'tests' }
OPTokenTest >> testStep [

	simulator addAction: [ :item | item doState ].
	self assert: simulator state equals: 1.
	simulator step.
	self assert: simulator state equals: 1.
	simulator steppable: true.
	simulator step.
	self assert: simulator state equals: 2
]
