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
OPDiagramSimulatorTest >> prepareOneSimulable [
	diagram := OPDummyOPDiagram new addElements: 1.
	simulator := self simulatorClass model: diagram
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

{ #category : 'hooks' }
OPDiagramSimulatorTest >> simulatorClass [
	^ OPDummySubclassOfOPDiagramSimulator
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
OPDiagramSimulatorTest >> testClassForUnknownModel [

	self should: [ self simulatorClass classFor: Object new ] raise: Error
]

{ #category : 'tests' }
OPDiagramSimulatorTest >> testDiagramAndDiagramSimulator [

	self assert: simulator diagramSimulator identicalTo: simulator.
	self assert: simulator diagram identicalTo: diagram
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
OPDiagramSimulatorTest >> testFromAllElements [

	simulator fromAllElements.
	self assert: simulator itemsForPriority size equals: simulator elements size.
	self assertCollection: simulator itemsForPriority hasSameElements: simulator elements
]

{ #category : 'tests' }
OPDiagramSimulatorTest >> testIsSimulable [

	| emptySimulator |
	self assert: simulator isSimulable description: 'Diagram simulator with simulable elements must be simulable'.
	emptySimulator := self simulatorClass model: OPDummyOPDiagram new.
	self deny: emptySimulator isSimulable description: 'Empty diagram simulator must not be simulable'
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
OPDiagramSimulatorTest >> testRecordTransferCapturedDuringStepAndClearedBetweenSteps [

	| steppedEvents sourceModel targetModel edgeModel transfer |
	steppedEvents := OrderedCollection new.
	sourceModel := diagram elements first.
	targetModel := diagram elements second.
	edgeModel := diagram elements last.
	transfer := (OPSimulationTransfer source: sourceModel edge: edgeModel target: targetModel)
		            actorModel: sourceModel;
		            amount: 2;
		            phase: 1;
		            kind: #token;
		            yourself.
	simulator recordTransfer: transfer.
	simulator when: OPSimulatorStepped do: [ :event | steppedEvents add: event ] for: self.
	simulator elements first steppable: true.
	simulator
		fromSteppableElements;
		orderAny;
		priorityAny;
		selectAll;
		addAction: [ :item | simulator recordTransfer: transfer ].

	simulator step.
	self assert: steppedEvents size equals: 1.
	self assert: steppedEvents first transfers equals: { transfer }.

	simulator resetActions.
	simulator addAction: [ :item |  ].
	simulator step.
	self assert: steppedEvents size equals: 2.
	self assertEmpty: steppedEvents second transfers
]

{ #category : 'tests' }
OPDiagramSimulatorTest >> testResetClassMapping [

	self simulatorClass resetClassMapping.
	self assert: (self simulatorClass classFor: OPDummyOPElement new) identicalTo: OPDummyOPElementSimulator.
	self simulatorClass resetClassMapping.
	self
		assert: (self simulatorClass hasSimulatorFor: OPDummyOPElement new)
		description: 'ClassMapping must re-initialize lazily after resetClassMapping'
]

{ #category : 'tests' }
OPDiagramSimulatorTest >> testResetStopsRestoresStateAndAnnouncesReset [

	| resetEvents |
	resetEvents := OrderedCollection new.
	simulator when: OPSimulatorReset do: [ :event | resetEvents add: event ] for: self.
	simulator saveState.
	self assert: (simulator elements sum: [ :each | each state ]) equals: 8.

	simulator reset.
	self assert: (simulator elements sum: [ :each | each state ]) equals: 4.
	self assert: resetEvents size equals: 1.
	self assert: resetEvents first simulator identicalTo: simulator
]

{ #category : 'tests' }
OPDiagramSimulatorTest >> testSimulatorOf [

	| elementSimulator |
	elementSimulator := simulator simulatorOf: diagram elements first.
	self assert: elementSimulator model identicalTo: diagram elements first.
	self assert: (simulator simulatorOf: diagram) identicalTo: simulator.
	self should: [ simulator simulatorOf: Object new ] raise: Error
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

{ #category : 'tests' }
OPDiagramSimulatorTest >> testStepCycleWaiterWaitsBeforeNextRepeatedStepAndStopsCleanly [

	| stepCount firstStepStarted releaseBarrier secondStepReached waiterCalls |
	stepCount := 0.
	waiterCalls := 0.
	firstStepStarted := Semaphore new.
	releaseBarrier := Semaphore new.
	secondStepReached := Semaphore new.
	simulator elements first steppable: true.
	simulator
		delay: 10;
		fromSteppableElements;
		addAction: [ :item |
				stepCount := stepCount + 1.
				stepCount = 1 ifTrue: [ firstStepStarted signal ].
				stepCount = 2 ifTrue: [ secondStepReached signal ] ];
		stepCycleWaiter: [ :elapsedMs :delayMs :waitSemaphore |
				waiterCalls := waiterCalls + 1.
				releaseBarrier wait ].

	[
		simulator repeat.
		self deny: (firstStepStarted waitTimeoutSeconds: 2) description: 'First repeated step must execute promptly'.
		self
			assert: (secondStepReached waitTimeoutMilliseconds: 80)
			description: 'Second repeated step must wait while stepCycleWaiter blocks'.
		self assert: stepCount equals: 1.
		self assert: waiterCalls equals: 1.

		releaseBarrier signal.
		self
			deny: (secondStepReached waitTimeoutSeconds: 2)
			description: 'Second repeated step must proceed once stepCycleWaiter unblocks'.
		self assert: stepCount >= 2 description: 'At least two steps must execute after releasing barrier' ] ensure: [
			releaseBarrier signal.
			simulator stop ]
]

{ #category : 'tests' }
OPDiagramSimulatorTest >> testStepElementRecordsTransfersAndAnnouncesStepped [

	| steppedEvents elementSimulator transfer |
	steppedEvents := OrderedCollection new.
	elementSimulator := OPDummySubclassOfOPElementSimulator new
		                    steppable: true;
		                    addAction: [ :item |
				                    transfer := OPSimulationTransfer
					                                source: diagram elements first
					                                edge: diagram elements last
					                                target: diagram elements second.
				                    simulator recordTransfer: transfer ];
		                    yourself.
	simulator when: OPSimulatorStepped do: [ :event | steppedEvents add: event ] for: self.

	simulator stepElement: elementSimulator.
	self assert: steppedEvents size equals: 1.
	self assert: steppedEvents first simulator identicalTo: simulator.
	self assert: steppedEvents first transfers equals: { transfer }.

	elementSimulator steppable: false.
	simulator stepElement: elementSimulator.
	self assert: steppedEvents size equals: 1
]

{ #category : 'tests' }
OPDiagramSimulatorTest >> testUnsubscribeAllUnsubscribesDiagramAndElementSimulators [

	| receivedEvents realElement |
	receivedEvents := OrderedCollection new.
	realElement := OPDummySubclassOfOPElementSimulator new
		               steppable: true;
		               addAction: [ :item |  ];
		               yourself.
	simulator elements
		removeAll;
		add: realElement.
	simulator simulableElements
		removeAll;
		add: realElement.
	simulator
		fromSteppableElements;
		addAction: [ :item | item step ].
	simulator when: OPSimulatorStepped do: [ :event | receivedEvents add: event ] for: self.
	realElement when: OPSimulatorDidAction do: [ :event | receivedEvents add: event ] for: self.

	simulator unsubscribeAll: self.
	simulator step.
	self assertEmpty: receivedEvents
]
