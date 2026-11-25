"
Unit tests for OPSimulator. 
Verifies the core stepping, repeating, delay management, and action execution logic of the simulator.
"
Class {
	#name : 'OPSimulatorTest',
	#superclass : 'TestCase',
	#instVars : [
		'simulator'
	],
	#category : 'OpenPonk-ModelSimulation-Tests-Simulators',
	#package : 'OpenPonk-ModelSimulation-Tests',
	#tag : 'Simulators'
}

{ #category : 'testing' }
OPSimulatorTest class >> isAbstract [
	^ self == OPSimulatorTest
]

{ #category : 'hooks' }
OPSimulatorTest >> prepareOneNotSteppable [
	self prepareOneSimulable.
	simulator steppable: false
]

{ #category : 'hooks' }
OPSimulatorTest >> prepareOneSimulable [
	self subclassResponsibility
]

{ #category : 'hooks' }
OPSimulatorTest >> prepareOneSteppable [
	self prepareOneSimulable.
	simulator steppable: true
]

{ #category : 'running' }
OPSimulatorTest >> setUp [

	super setUp.
	simulator := self simulatorClass new
]

{ #category : 'hooks' }
OPSimulatorTest >> simulatorClass [

	^ self subclassResponsibility
]

{ #category : 'tests' }
OPSimulatorTest >> testAnnounceActions [

	| events action1 action2 |
	events := OrderedCollection new.
	action1 := [ :item |  ].
	action2 := [ :item |  ].
	self prepareOneSteppable.
	simulator
		addAction: action1;
		addAction: action2;
		when: OPSimulatorActionEvent do: [ :event | events add: event ] for: self.
	simulator doAction: 2.
	self assert: (events collect: #class as: Array) equals: {
			OPSimulatorWillDoAction.
			OPSimulatorDidAction }.
	self assert: events first simulator identicalTo: simulator.
	self assert: events first action identicalTo: action2.
	self assert: events first index equals: 2.
	self assert: events second action identicalTo: action2.
	self assert: events second index equals: 2.

	events removeAll.
	simulator step.
	self assert: (events collect: #class as: Array) equals: {
			OPSimulatorWillDoAction.
			OPSimulatorDidAction.
			OPSimulatorWillDoAction.
			OPSimulatorDidAction }.
	self assert: (events collect: #index as: Array) equals: #( 1 1 2 2 )
]

{ #category : 'tests' }
OPSimulatorTest >> testAnnounceStep [

	| will steps |
	self prepareOneNotSteppable.
	will := 0.
	steps := 0.
	simulator
		when: OPSimulatorWillStep
		do: [ will := will + 1 ]
		for: self.
	simulator
		when: OPSimulatorWillStep
		do: [ self assert: steps equals: 0 ]
		for: self.
	simulator
		when: OPSimulatorStepped
		do: [ steps := steps + 1 ]
		for: self.
	self assert: will equals: 0.
	self assert: steps equals: 0.

	simulator step.
	self assert: will equals: 0.
	self assert: steps equals: 0.

	simulator steppable: true.
	simulator step.
	self assert: will equals: 1.
	self assert: steps equals: 1
]

{ #category : 'tests' }
OPSimulatorTest >> testDoAction [

	| counter action1 action2 |
	counter := 0.
	action1 := [ :item | counter := counter + 1 ].
	action2 := [ :item | counter := counter + 10 ].
	self prepareOneSteppable.

	simulator addAction: action1.
	self assert: counter equals: 0.

	simulator doAction: 1.
	self assert: counter equals: 1.

	simulator addAction: action2.

	simulator doAction: 1.
	self assert: counter equals: 2.
	simulator doAction: 2.
	self assert: counter equals: 12.

	simulator addFirstAction: action2.
	simulator doAction: 1.
	simulator doAction: 3.
	self assert: counter equals: 32
]

{ #category : 'tests' }
OPSimulatorTest >> testInstanceCreation [

	self assert: simulator delay equals: 1000.
	simulator addAction: [ :item |  ]
]

{ #category : 'tests' }
OPSimulatorTest >> testIsFinished [

	self prepareOneNotSteppable.
	self assert: simulator isFinished description: 'Non-steppable simulator must report isFinished'.
	simulator steppable: true.
	self deny: simulator isFinished description: 'Steppable simulator must not report isFinished'
]

{ #category : 'tests' }
OPSimulatorTest >> testRepeatOnce [

	| count |
	count := 0.
	self prepareOneSteppable.
	simulator addAction: [ :item | count := count + 1 ].
	simulator repeatOnce.
	self assert: count equals: 1
]

{ #category : 'tests' }
OPSimulatorTest >> testWhenSendTo [

	| receivedEvents |
	receivedEvents := OrderedCollection new.
	self prepareOneSteppable.
	simulator when: OPSimulatorStepped send: #add: to: receivedEvents.
	simulator step.
	self assert: receivedEvents size equals: 1.
	self assert: receivedEvents first class identicalTo: OPSimulatorStepped.
	self assert: receivedEvents first simulator identicalTo: simulator
]
