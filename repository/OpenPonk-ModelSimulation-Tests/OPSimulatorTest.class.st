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
OPSimulatorTest >> testIsRunningAndUnsubscribe [

	| stepEvents |
	self prepareOneSteppable.
	self deny: simulator isRunning description: 'Fresh simulator must not be running'.

	stepEvents := OrderedCollection new.
	simulator when: OPSimulatorStepped do: [ :event | stepEvents add: event ] for: self.
	simulator step.
	self assert: stepEvents size equals: 1.

	simulator unsubscribe: self.
	simulator step.
	self assert: stepEvents size equals: 1
]

{ #category : 'tests' }
OPSimulatorTest >> testRapidStopAndRestartDoesNotSpawnConcurrentLoops [

	| firstStepDone secondStepDone stepCount stoppedCount |
	self prepareOneSteppable.
	firstStepDone := Semaphore new.
	secondStepDone := Semaphore new.
	stepCount := 0.
	stoppedCount := 0.
	simulator addAction: [ :item |
			stepCount := stepCount + 1.
			stepCount = 1 ifTrue: [ firstStepDone signal ].
			stepCount = 2 ifTrue: [ secondStepDone signal ] ].
	simulator when: OPSimulatorStoppedRun do: [ stoppedCount := stoppedCount + 1 ] for: self.

	[
		simulator delay: 30.
		simulator repeat.
		self deny: (firstStepDone waitTimeoutSeconds: 2) description: 'First run must complete its first step'.
		simulator stop.
		self assert: stoppedCount equals: 1.

		simulator delay: 5000.
		simulator repeat.
		self deny: (secondStepDone waitTimeoutSeconds: 2) description: 'Second run must complete its first step'.
		(Delay forMilliseconds: 80) wait.
		self assert: stepCount equals: 2.
		self assert: stoppedCount equals: 1 ] ensure: [ simulator stop ]
]

{ #category : 'tests' }
OPSimulatorTest >> testRepeatDoesNotStartWhenNotSteppable [

	| runEvents |
	self prepareOneNotSteppable.
	runEvents := OrderedCollection new.
	simulator when: OPSimulatorRunEvent do: [ :event | runEvents add: event ] for: self.

	simulator repeat.
	self deny: simulator isRunning description: 'Non-steppable simulator must not start running on repeat'.
	self assertEmpty: runEvents
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
OPSimulatorTest >> testRepeatReadsDelayDynamically [

	| firstStepDone stepCount |
	self prepareOneSteppable.
	firstStepDone := Semaphore new.
	stepCount := 0.
	simulator addAction: [ :item |
			stepCount := stepCount + 1.
			stepCount = 1 ifTrue: [
					simulator delay: 5000.
					firstStepDone signal ] ].

	[
		simulator delay: 15.
		simulator repeat.
		self deny: (firstStepDone waitTimeoutSeconds: 2) description: 'First step must run and raise delay'.
		(Delay forMilliseconds: 60) wait.
		self assert: stepCount equals: 1 ] ensure: [ simulator stop ]
]

{ #category : 'tests' }
OPSimulatorTest >> testRepeatStopsNaturallyWhenNoLongerSteppable [

	| finished stepCount stoppedEvent |
	self prepareOneSteppable.
	finished := Semaphore new.
	stepCount := 0.
	stoppedEvent := nil.
	simulator delay: 1.
	simulator addAction: [ :item |
			stepCount := stepCount + 1.
			simulator steppable: false ].
	simulator
		when: OPSimulatorStoppedRun
		do: [ :event |
				stoppedEvent := event.
				finished signal ]
		for: self.

	[
		simulator repeat.
		self deny: (finished waitTimeoutSeconds: 2) description: 'Repeat must stop naturally when simulator is no longer steppable'.
		self assert: stepCount equals: 1.
		self deny: simulator isRunning description: 'Simulator must report not running after natural completion'.
		self assert: stoppedEvent simulator identicalTo: simulator ] ensure: [ simulator stop ]
]

{ #category : 'tests' }
OPSimulatorTest >> testRepeatTimesCompletesAndAnnouncesLimitedRunEvents [

	| runEvents finished stepCount |
	self prepareOneSteppable.
	runEvents := OrderedCollection new.
	finished := Semaphore new.
	stepCount := 0.
	simulator delay: 1.
	simulator addAction: [ :item | stepCount := stepCount + 1 ].
	simulator
		when: OPSimulatorRunEvent
		do: [ :event |
				runEvents add: event.
				(event isKindOf: OPSimulatorStoppedRun) ifTrue: [ finished signal ] ]
		for: self.

	[
		simulator repeatTimes: 0.
		self deny: simulator isRunning description: 'repeatTimes: 0 must not start running'.
		self assertEmpty: runEvents.

		simulator repeatTimes: 2.
		self deny: (finished waitTimeoutSeconds: 2) description: 'repeatTimes: 2 must complete and announce OPSimulatorStoppedRun'.
		self assert: stepCount equals: 2.
		self deny: simulator isRunning description: 'Simulator must not report running after repeatTimes finishes'.
		self assert: (runEvents collect: #class as: Array) equals: {
				OPSimulatorWillRun.
				OPSimulatorStoppedRun }.
		self assert: runEvents first repeatTimes equals: 2.
		self assert: runEvents second repeatTimes equals: 2 ] ensure: [ simulator stop ]
]

{ #category : 'tests' }
OPSimulatorTest >> testRepeatUsesStepRunnerAndStopsCleanlyWithoutDuplicateStoppedEvent [

	| firstStepDone runnerCalls stoppedCount stepCount |
	self prepareOneSteppable.
	firstStepDone := Semaphore new.
	runnerCalls := 0.
	stoppedCount := 0.
	stepCount := 0.
	simulator addAction: [ :item | stepCount := stepCount + 1 ].
	simulator stepRunner: [ :aBlock |
			runnerCalls := runnerCalls + 1.
			aBlock value.
			stepCount = 1 ifTrue: [ firstStepDone signal ] ].
	simulator when: OPSimulatorStoppedRun do: [ stoppedCount := stoppedCount + 1 ] for: self.

	[
		simulator delay: 5000.
		simulator repeat.
		self assert: simulator isRunning description: 'Simulator must report running after repeat starts'.
		self deny: (firstStepDone waitTimeoutSeconds: 2) description: 'First step must execute through stepRunner'.
		self assert: stepCount equals: 1.
		self assert: runnerCalls equals: 1.

		simulator stop.
		self deny: simulator isRunning description: 'Simulator must report not running immediately after stop'.
		self assert: stoppedCount equals: 1.
		(Delay forMilliseconds: 30) wait.
		self assert: stoppedCount equals: 1.
		self assert: stepCount equals: 1 ] ensure: [ simulator stop ]
]

{ #category : 'tests' }
OPSimulatorTest >> testRepeatWithDelayUsesExplicitDelayWithoutMutatingSimulatorDelay [

	| willRunEvent firstStepDone |
	self prepareOneSteppable.
	willRunEvent := nil.
	firstStepDone := Semaphore new.
	simulator delay: 1234.
	simulator addAction: [ :item | firstStepDone signal ].
	simulator when: OPSimulatorWillRun do: [ :event | willRunEvent := event ] for: self.

	[
		simulator repeatWithDelay: 5000.
		self deny: (firstStepDone waitTimeoutSeconds: 2) description: 'repeatWithDelay: must execute its first step'.
		self assert: willRunEvent delay equals: 5000.
		self assert: simulator delay equals: 1234.
		simulator repeat.
		self assert: simulator isRunning description: 'Calling repeat while already running must be a no-op' ] ensure: [ simulator stop ]
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
