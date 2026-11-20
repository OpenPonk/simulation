"
Unit tests for OPElementSimulator. 
Verifies the simulation state, connected items mapping, and token handling for individual diagram elements.
"
Class {
	#name : 'OPElementSimulatorTest',
	#superclass : 'OPModelSimulatorTest',
	#category : 'OpenPonk-ModelSimulation-Tests-Simulators',
	#package : 'OpenPonk-ModelSimulation-Tests',
	#tag : 'Simulators'
}

{ #category : 'hooks' }
OPElementSimulatorTest >> controllerClass [
	^ OPDummySubclassOfOPElementSimulator
]

{ #category : 'hooks' }
OPElementSimulatorTest >> prepareOneSimulable [
	simulator fromSelf
]

{ #category : 'running' }
OPElementSimulatorTest >> setUp [

	super setUp.
	simulator model: OPDummyOPElement new.
	simulator
		addToken: OPDummyOPToken new;
		addToken: OPDummyOPToken new
]

{ #category : 'tests' }
OPElementSimulatorTest >> testAccessing [

	| assertTokens |
	assertTokens := [ :amount |
		                self assert: simulator tokenCount equals: amount.
		                self assert: simulator tokens size equals: amount.
		                self assertEmpty: simulator steppableTokens.
		                self assert: simulator simulableTokens size equals: amount.
		                simulator tokens do: [ :eachToken | self assert: eachToken element identicalTo: simulator ] ].

	simulator addToken: OPDummyOPToken new.
	assertTokens value: 3.
	simulator addToken: OPDummyOPToken new.
	assertTokens value: 4.
	simulator removeToken: simulator tokens first.
	assertTokens value: 3.
	simulator removeAllTokens.
	assertTokens value: 0
]

{ #category : 'tests' }
OPElementSimulatorTest >> testAddIncomingAndOutgoingIgnoreNil [

	simulator addIncoming: nil.
	simulator addOutgoing: nil.
	self assertEmpty: simulator incoming.
	self assertEmpty: simulator outgoing
]

{ #category : 'tests' }
OPElementSimulatorTest >> testAddTokensAndTokensDo [

	| tokenA tokenB visited |
	tokenA := OPDummySubclassOfOPToken new.
	tokenB := OPDummySubclassOfOPToken new.
	simulator addTokens: {
			tokenA.
			tokenB }.
	self assert: simulator tokenCount equals: 4.
	self assert: tokenA element identicalTo: simulator.
	self assert: tokenB element identicalTo: simulator.
	visited := OrderedCollection new.
	simulator tokensDo: [ :each | visited add: each ].
	self assertCollection: visited hasSameElements: simulator tokens
]

{ #category : 'tests' }
OPElementSimulatorTest >> testConnected [

	| incoming outgoing |
	self assertEmpty: simulator outgoing.
	self assertEmpty: simulator incoming.

	incoming := self controllerClass new.
	simulator addIncoming: incoming.
	self assert: simulator incoming size equals: 1.

	outgoing := self controllerClass new.
	simulator addOutgoing: outgoing.
	self assert: simulator outgoing size equals: 1.

	self assert: incoming outgoing first equals: simulator.
	self assert: outgoing incoming first equals: simulator.
	self assertEmpty: outgoing outgoing.
	self assertEmpty: incoming incoming
]

{ #category : 'tests' }
OPElementSimulatorTest >> testConnectedEnumeration [

	| incoming outgoing visitedIncoming visitedOutgoing visitedConnected |
	incoming := self controllerClass new.
	outgoing := self controllerClass new.
	simulator
		addIncoming: incoming;
		addOutgoing: outgoing.
	visitedIncoming := OrderedCollection new.
	visitedOutgoing := OrderedCollection new.
	visitedConnected := OrderedCollection new.
	simulator incomingDo: [ :each | visitedIncoming add: each ].
	simulator outgoingDo: [ :each | visitedOutgoing add: each ].
	simulator connectedDo: [ :each | visitedConnected add: each ].
	self assertCollection: visitedIncoming hasSameElements: { incoming }.
	self assertCollection: visitedOutgoing hasSameElements: { outgoing }.
	self assertCollection: visitedConnected hasSameElements: {
			incoming.
			outgoing }
]

{ #category : 'tests' }
OPElementSimulatorTest >> testModelDiagramSimulatorCreation [

	| diagramModel diagramSimulator elementModel createdSimulator |
	diagramModel := OPDummyOPDiagram new.
	diagramSimulator := OPDummySubclassOfOPDiagramSimulator model: diagramModel.
	elementModel := OPDummyOPElement new.
	createdSimulator := self controllerClass model: elementModel diagramSimulator: diagramSimulator.
	self assert: createdSimulator model identicalTo: elementModel.
	self assert: createdSimulator diagramSimulator identicalTo: diagramSimulator.
	self assert: createdSimulator diagram identicalTo: diagramModel
]

{ #category : 'tests' }
OPElementSimulatorTest >> testPriority [

	self assert: simulator priority equals: 0.
	simulator priority: 5.
	self assert: simulator priority equals: 5
]

{ #category : 'tests' }
OPElementSimulatorTest >> testStates [

	self assert: simulator model state equals: 1.
	simulator saveState.
	self assert: simulator model state equals: 2.
	simulator loadState.
	self assert: simulator model state equals: 1
]

{ #category : 'tests' }
OPElementSimulatorTest >> testStep [

	simulator
		fromSelf;
		orderAny;
		priorityAny;
		selectAll;
		addAction: [ :item | item saveState ].

	self assert: simulator model state equals: 1.
	simulator step.
	self assert: simulator model state equals: 1.
	simulator steppable: true.
	simulator step.
	self assert: simulator model state equals: 2
]
