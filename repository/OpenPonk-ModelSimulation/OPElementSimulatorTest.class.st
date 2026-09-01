"
Unit tests for OPElementSimulator. 
Verifies the simulation state, connected items mapping, and token handling for individual diagram elements.
"
Class {
	#name : 'OPElementSimulatorTest',
	#superclass : 'OPModelSimulatorTest',
	#category : 'OpenPonk-ModelSimulation-Tests',
	#package : 'OpenPonk-ModelSimulation',
	#tag : 'Tests'
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
		                self
			                assert: simulator simulableTokens size
			                equals: amount.
		                self assert:
			                (simulator tokens allSatisfy: [ :token |
				                 token element = simulator ]) ].

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
