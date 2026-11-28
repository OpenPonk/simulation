"
Headless unit tests verifying lifecycle, reload, editor-close handling, delay persistence, and UI-safe dispatch in OPSimulationSession.
"
Class {
	#name : 'OPSimulationSessionTest',
	#superclass : 'TestCase',
	#instVars : [
		'rootModel',
		'firstElement',
		'secondElement',
		'editor',
		'workbenchAnnouncer',
		'diagramController',
		'elementController',
		'session'
	],
	#category : 'OpenPonk-Simulation-Tests-Simulation',
	#package : 'OpenPonk-Simulation-Tests',
	#tag : 'Simulation'
}

{ #category : 'running' }
OPSimulationSessionTest >> setUp [

	| project diagram projectController plugin |
	super setUp.
	OPPluginRegistry setDefault: (OPPluginRegistry new
			 add: OPTestPlugin new;
			 yourself).
	rootModel := OPTestSimulationModel new
		             name: 'Session Model';
		             yourself.
	firstElement := OPTestSimulationModel new
		                name: 'First';
		                yourself.
	secondElement := OPTestSimulationModel new
		                 name: 'Second';
		                 yourself.
	rootModel
		add: firstElement;
		add: secondElement.
	project := OPProject named: 'Simulation Session Test'.
	project addModel: rootModel.
	diagram := OPOpenPonkDiagram forModelElement: rootModel.
	project addDiagram: diagram.
	projectController := OPProjectController forProject: project.
	plugin := OPPluginRegistry default plugins detect: [ :eachPlugin | eachPlugin isKindOf: OPTestPlugin ].
	editor := OPEditor on: plugin.
	workbenchAnnouncer := Announcer new.
	diagramController := OPTestDiagramController new.
	projectController addDiagramController: diagramController.
	diagramController
		editor: editor;
		workbenchAnnouncer: workbenchAnnouncer;
		canvasPresenter: OPHeadlessCanvasPresenter new;
		diagramElement: diagram;
		model: rootModel.
	elementController := OPTestEntityController new
		                     diagramController: diagramController;
		                     model: firstElement;
		                     yourself
]

{ #category : 'running' }
OPSimulationSessionTest >> tearDown [

	session ifNotNil: [ session close ].
	OPPluginRegistry resetDefault.
	session := nil.
	elementController := nil.
	diagramController := nil.
	workbenchAnnouncer := nil.
	editor := nil.
	secondElement := nil.
	firstElement := nil.
	rootModel := nil.
	super tearDown
]

{ #category : 'tests' }
OPSimulationSessionTest >> testActionsResetSaveStepElementAndDispatchedRepeat [

	| resetCount stepCount runningStates dispatchCalls firstStepDone |
	resetCount := 0.
	stepCount := 0.
	runningStates := OrderedCollection new.
	dispatchCalls := 0.
	firstStepDone := Semaphore new.
	session := OPSimulationSession diagramController: diagramController simulatorClass: OPTestSimulationDiagramSimulator.
	session
		uiDispatcher: [ :aBlock |
				dispatchCalls := dispatchCalls + 1.
				aBlock value ];
		onReset: [ resetCount := resetCount + 1 ];
		onStepped: [ :event |
				stepCount := stepCount + 1.
				stepCount = 1 ifTrue: [ firstStepDone signal ] ];
		onRunningStateChanged: [ :running | runningStates add: running ];
		start.

	session saveState.
	self assert: session diagramSimulator saveStateCount equals: 2.

	session reset.
	self assert: session diagramSimulator loadStateCount equals: 1.
	self assert: resetCount equals: 1.

	session stepElementController: elementController.
	self assert: (session diagramSimulator simulatorOf: firstElement) stepCount equals: 1.

	session delay: 5000.
	session diagramSimulator addAction: [ :item | item step ].
	session togglePlayPause.
	self assert: session isRunning description: 'togglePlayPause must start running simulation'.
	self deny: (firstStepDone waitTimeoutSeconds: 2) description: 'First repeated step must execute via uiDispatcher'.
	self assert: dispatchCalls >= 1 description: 'Repeated step must run through session uiDispatcher'.

	session togglePlayPause.
	self deny: session isRunning description: 'Second togglePlayPause must stop running simulation'.
	self assert: runningStates asArray equals: #( true false )
]

{ #category : 'tests' }
OPSimulationSessionTest >> testCloseOnEditorClosedUnsubscribesAndIsIdempotent [

	| closedCount otherEditor |
	closedCount := 0.
	session := OPSimulationSession diagramController: diagramController simulatorClass: OPTestSimulationDiagramSimulator.
	session
		uiDispatcher: [ :aBlock | aBlock value ];
		onClosed: [ closedCount := closedCount + 1 ];
		start.
	self assert: session isActive description: 'Started simulation session must report active'.

	otherEditor := OPEditor on: (OPPluginRegistry default plugins detect: [ :eachPlugin | eachPlugin isKindOf: OPTestPlugin ]).
	workbenchAnnouncer announce: (OPEditorClosed on: otherEditor).
	self assert: session isActive description: 'Closing an unrelated editor must not close this session'.
	self assert: closedCount equals: 0.

	workbenchAnnouncer announce: (OPEditorClosed on: editor).
	self deny: session isActive description: 'Closing the owning editor must close the simulation session'.
	self assert: closedCount equals: 1.
	self assert: session diagramSimulator identicalTo: nil.
	self
		deny: (rootModel announcer subscriptions subscriptions anySatisfy: [ :each | each subscriber == session ])
		description: 'Closing session must unsubscribe from diagram model'.
	self
		deny: (workbenchAnnouncer subscriptions subscriptions anySatisfy: [ :each | each subscriber == session ])
		description: 'Closing session must unsubscribe from workbench announcer'.

	session close.
	self assert: closedCount equals: 1
]

{ #category : 'tests' }
OPSimulationSessionTest >> testDefaultUiDispatcherExecutesOnUiThreadAndCancelsPendingWaits [

	| executedOnUi done inlineOnUi uiDone |
	session := OPSimulationSession diagramController: diagramController simulatorClass: OPTestSimulationDiagramSimulator.
	executedOnUi := false.
	done := Semaphore new.
	[
		session uiDispatcher value: [
				executedOnUi := UIManager default uiProcess isNil or: [ Processor activeProcess == UIManager default uiProcess ].
				done signal ] ] fork.
	self deny: (done waitTimeoutSeconds: 2) description: 'Default UI dispatcher must execute deferred block on UI process'.
	self assert: executedOnUi description: 'Deferred block must run on the UI process when one is active'.

	inlineOnUi := false.
	uiDone := Semaphore new.
	UIManager default defer: [
			session uiDispatcher value: [ inlineOnUi := true ].
			uiDone signal ].
	self
		deny: (uiDone waitTimeoutSeconds: 2)
		description: 'Default UI dispatcher invoked on UI process must run inline without deadlocking'.
	self assert: inlineOnUi description: 'Block dispatched from UI process must execute inline'.

	session start.
	(session instVarNamed: #pendingStepSemaphores) add: Semaphore new.
	session pause.
	self assertEmpty: (session instVarNamed: #pendingStepSemaphores)
]

{ #category : 'tests' }
OPSimulationSessionTest >> testPlayWaitsForStepCompletionWaiterBeyondDelayAndPauseUnblocks [

	| stepCount firstStepStarted secondStepReached releaseVisualBarrier cancelCount |
	stepCount := 0.
	cancelCount := 0.
	firstStepStarted := Semaphore new.
	secondStepReached := Semaphore new.
	releaseVisualBarrier := Semaphore new.
	session := OPSimulationSession diagramController: diagramController simulatorClass: OPTestSimulationDiagramSimulator.
	session
		uiDispatcher: [ :aBlock | aBlock value ];
		delay: 20;
		onCancelVisuals: [
				cancelCount := cancelCount + 1.
				releaseVisualBarrier signal ];
		stepCompletionWaiter: [ releaseVisualBarrier wait ];
		onStepped: [ :event |
				stepCount := stepCount + 1.
				stepCount = 1 ifTrue: [ firstStepStarted signal ].
				stepCount = 2 ifTrue: [ secondStepReached signal ] ];
		start.
	session diagramSimulator addAction: [ :item | item step ].

	session play.
	self deny: (firstStepStarted waitTimeoutSeconds: 2) description: 'First step must execute promptly'.
	self
		assert: (secondStepReached waitTimeoutMilliseconds: 80)
		description: 'Second step must wait until visual completion waiter returns even beyond delay'.
	self assert: stepCount equals: 1.

	releaseVisualBarrier signal.
	self deny: (secondStepReached waitTimeoutSeconds: 2) description: 'Second step must run once visual animation completes'.

	session pause.
	self deny: session isRunning description: 'Pause must stop playback even while waiting for visual completion'.
	self assert: cancelCount >= 1 description: 'Pause must invoke onCancelVisuals to release visual barriers'
]

{ #category : 'tests' }
OPSimulationSessionTest >> testReloadPreservesDelayAndRebuildsSimulatorOnModelChildrenChanged [

	| willReloadCount reloadedCount initialSimulator thirdElement |
	willReloadCount := 0.
	reloadedCount := 0.
	session := OPSimulationSession diagramController: diagramController simulatorClass: OPTestSimulationDiagramSimulator.
	session
		uiDispatcher: [ :aBlock | aBlock value ];
		onWillReload: [ willReloadCount := willReloadCount + 1 ];
		onReloaded: [ reloadedCount := reloadedCount + 1 ];
		start.
	session delay: 250.
	initialSimulator := session diagramSimulator.
	self assert: initialSimulator delay equals: 250.

	thirdElement := OPTestSimulationModel new
		                name: 'Third';
		                yourself.
	rootModel add: thirdElement.
	self assert: willReloadCount equals: 1.
	self assert: reloadedCount equals: 1.
	self deny: session diagramSimulator identicalTo: initialSimulator.
	self assert: session diagramSimulator elements size equals: 3.
	self assert: session diagramSimulator delay equals: 250
]

{ #category : 'tests' }
OPSimulationSessionTest >> testStepActionCallbackIdempotentStartInactiveReloadAndMetadata [

	| actionEvents stepEvents firstSimulator |
	actionEvents := OrderedCollection new.
	stepEvents := OrderedCollection new.
	session := OPSimulationSession diagramController: diagramController simulatorClass: OPTestSimulationDiagramSimulator.
	session
		uiDispatcher: [ :aBlock | aBlock value ];
		onAction: [ :event | actionEvents add: event ];
		onStepped: [ :event | stepEvents add: event ].

	self assert: session diagramController identicalTo: diagramController.
	self assert: session simulatorClass identicalTo: OPTestSimulationDiagramSimulator.
	session reload.
	session stepElementController: elementController.
	self assert: session diagramSimulator identicalTo: nil.

	session start.
	firstSimulator := session diagramSimulator.
	session start.
	self assert: session diagramSimulator identicalTo: firstSimulator.

	firstSimulator addAction: [ :item | item step ].
	(firstSimulator simulatorOf: firstElement) addAction: [ :item |  ].
	session step.
	self assert: stepEvents size equals: 1.
	self assert: actionEvents size equals: 1.
	self assert: actionEvents first simulator identicalTo: (firstSimulator simulatorOf: firstElement)
]

{ #category : 'tests' }
OPSimulationSessionTest >> testStepInvokesWillStepAndStepElementControllerAnnouncesStepped [

	| willStepCount steppedEvents |
	willStepCount := 0.
	steppedEvents := OrderedCollection new.
	session := OPSimulationSession diagramController: diagramController simulatorClass: OPTestSimulationDiagramSimulator.
	session
		uiDispatcher: [ :aBlock | aBlock value ];
		onWillStep: [ willStepCount := willStepCount + 1 ];
		onStepped: [ :event | steppedEvents add: event ];
		start.
	session diagramSimulator addAction: [ :item | item step ].

	session step.
	self assert: willStepCount equals: 1.
	self assert: steppedEvents size equals: 1.

	session stepElementController: elementController.
	self assert: willStepCount equals: 2.
	self assert: steppedEvents size equals: 2
]
