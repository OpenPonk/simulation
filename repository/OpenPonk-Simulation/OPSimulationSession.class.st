"
Headless coordinator managing the lifecycle between a diagram controller and its diagram simulator. Handles simulator creation, model-change reloads, editor-close cleanup, preserved step delay, playback actions, and thread-safe UI dispatch independently of Spec2 widgets.
"
Class {
	#name : 'OPSimulationSession',
	#superclass : 'Object',
	#instVars : [
		'diagramController',
		'simulatorClass',
		'diagramSimulator',
		'delayInMilliseconds',
		'uiDispatcher',
		'pendingStepSemaphores',
		'callbacks',
		'isActive'
	],
	#category : 'OpenPonk-Simulation-Simulation',
	#package : 'OpenPonk-Simulation',
	#tag : 'Simulation'
}

{ #category : 'instance creation' }
OPSimulationSession class >> diagramController: aDiagramController simulatorClass: aSimulatorClass [

	^ self new
		  diagramController: aDiagramController;
		  simulatorClass: aSimulatorClass;
		  yourself
]

{ #category : 'private' }
OPSimulationSession >> cancelPendingStepWaits [

	pendingStepSemaphores copy do: [ :eachSemaphore |
			pendingStepSemaphores remove: eachSemaphore ifAbsent: [ ].
			eachSemaphore signal ]
]

{ #category : 'actions' }
OPSimulationSession >> close [

	isActive ifFalse: [ ^ self ].
	isActive := false.
	self unsubscribeFromDiagram.
	self tearDownSimulator.
	self invokeCallback: #closed
]

{ #category : 'private' }
OPSimulationSession >> defaultUiDispatcher [

	^ [ :aBlock |
		  | uiProcess |
		  uiProcess := UIManager default uiProcess.
		  (uiProcess isNil or: [ uiProcess == Processor activeProcess or: [ uiProcess isTerminated ] ])
			  ifTrue: [ aBlock value ]
			  ifFalse: [ self executeOnUiThreadAndWait: aBlock ] ]
]

{ #category : 'accessing' }
OPSimulationSession >> delay [

	^ delayInMilliseconds
]

{ #category : 'accessing' }
OPSimulationSession >> delay: anInteger [

	delayInMilliseconds := anInteger.
	diagramSimulator ifNotNil: [ :simulator | simulator delay: anInteger ]
]

{ #category : 'accessing' }
OPSimulationSession >> diagramController [

	^ diagramController
]

{ #category : 'accessing' }
OPSimulationSession >> diagramController: aDiagramController [

	diagramController := aDiagramController
]

{ #category : 'accessing' }
OPSimulationSession >> diagramModel [

	^ diagramController ifNotNil: [ :controller | controller model ]
]

{ #category : 'accessing' }
OPSimulationSession >> diagramSimulator [

	^ diagramSimulator
]

{ #category : 'private' }
OPSimulationSession >> dispatchToUI: aBlock [

	^ self uiDispatcher value: aBlock
]

{ #category : 'private' }
OPSimulationSession >> executeOnUiThreadAndWait: aBlock [

	| completionSemaphore |
	completionSemaphore := Semaphore new.
	pendingStepSemaphores add: completionSemaphore.
	[
		UIManager default defer: [
				[ aBlock value ] ensure: [
						pendingStepSemaphores remove: completionSemaphore ifAbsent: [ ].
						completionSemaphore signal ] ].
		completionSemaphore wait ] ensure: [ pendingStepSemaphores remove: completionSemaphore ifAbsent: [ ] ]
]

{ #category : 'private' }
OPSimulationSession >> handleEditorClosed: anAnnouncement [

	diagramController ifNil: [ ^ self ].
	anAnnouncement editor == diagramController editor ifTrue: [ self close ]
]

{ #category : 'initialization' }
OPSimulationSession >> initialize [

	super initialize.
	delayInMilliseconds := 1000.
	uiDispatcher := self defaultUiDispatcher.
	pendingStepSemaphores := IdentitySet new.
	callbacks := IdentityDictionary new.
	isActive := false
]

{ #category : 'private' }
OPSimulationSession >> invokeCallback: aKey [

	callbacks at: aKey ifPresent: [ :aBlock | aBlock value ]
]

{ #category : 'private' }
OPSimulationSession >> invokeCallback: aKey with: anArgument [

	callbacks at: aKey ifPresent: [ :aBlock | aBlock cull: anArgument ]
]

{ #category : 'testing' }
OPSimulationSession >> isActive [

	^ isActive
]

{ #category : 'testing' }
OPSimulationSession >> isRunning [

	^ diagramSimulator isNotNil and: [ diagramSimulator isRunning ]
]

{ #category : 'private' }
OPSimulationSession >> loadSimulator [

	diagramSimulator := simulatorClass model: self diagramModel.
	diagramSimulator
		delay: delayInMilliseconds;
		stepRunner: [ :aBlock | self dispatchToUI: aBlock ].
	self subscribeToSimulator
]

{ #category : 'callbacks' }
OPSimulationSession >> onAction: aBlock [

	callbacks at: #action put: aBlock
]

{ #category : 'callbacks' }
OPSimulationSession >> onClosed: aBlock [

	callbacks at: #closed put: aBlock
]

{ #category : 'callbacks' }
OPSimulationSession >> onReloaded: aBlock [

	callbacks at: #reloaded put: aBlock
]

{ #category : 'callbacks' }
OPSimulationSession >> onReset: aBlock [

	callbacks at: #reset put: aBlock
]

{ #category : 'callbacks' }
OPSimulationSession >> onRunningStateChanged: aBlock [

	callbacks at: #runningStateChanged put: aBlock
]

{ #category : 'callbacks' }
OPSimulationSession >> onStepped: aBlock [

	callbacks at: #stepped put: aBlock
]

{ #category : 'callbacks' }
OPSimulationSession >> onWillReload: aBlock [

	callbacks at: #willReload put: aBlock
]

{ #category : 'actions' }
OPSimulationSession >> pause [

	self cancelPendingStepWaits.
	diagramSimulator ifNotNil: [ :simulator | simulator stop ]
]

{ #category : 'actions' }
OPSimulationSession >> play [

	diagramSimulator ifNotNil: [ :simulator | simulator repeat ]
]

{ #category : 'actions' }
OPSimulationSession >> reload [

	isActive ifFalse: [ ^ self ].
	self invokeCallback: #willReload.
	self tearDownSimulator.
	self loadSimulator.
	self invokeCallback: #reloaded
]

{ #category : 'actions' }
OPSimulationSession >> reset [

	self cancelPendingStepWaits.
	diagramSimulator ifNotNil: [ :simulator | simulator reset ]
]

{ #category : 'actions' }
OPSimulationSession >> saveState [

	diagramSimulator ifNotNil: [ :simulator | simulator saveState ]
]

{ #category : 'accessing' }
OPSimulationSession >> simulatorClass [

	^ simulatorClass
]

{ #category : 'accessing' }
OPSimulationSession >> simulatorClass: aSimulatorClass [

	simulatorClass := aSimulatorClass
]

{ #category : 'actions' }
OPSimulationSession >> start [

	isActive ifTrue: [ ^ self ].
	isActive := true.
	self
		loadSimulator;
		subscribeToDiagram
]

{ #category : 'actions' }
OPSimulationSession >> step [

	diagramSimulator ifNotNil: [ :simulator | simulator step ]
]

{ #category : 'actions' }
OPSimulationSession >> stepElementController: anElementController [

	| elementSimulator |
	diagramSimulator ifNil: [ ^ self ].
	elementSimulator := diagramSimulator simulatorOf: anElementController model.
	elementSimulator step
]

{ #category : 'private' }
OPSimulationSession >> subscribeToDiagram [

	self diagramModel ifNotNil: [ :diagramModel | diagramModel weakWhen: OPModelChildrenChangedEvent send: #reload to: self ].
	diagramController workbenchAnnouncer ifNotNil: [ :workbenchAnnouncer |
		workbenchAnnouncer weak when: OPEditorClosed send: #handleEditorClosed: to: self ]
]

{ #category : 'private' }
OPSimulationSession >> subscribeToSimulator [

	diagramSimulator
		when: OPSimulatorWillRun do: [ self invokeCallback: #runningStateChanged with: true ] for: self;
		when: OPSimulatorStoppedRun do: [ self invokeCallback: #runningStateChanged with: false ] for: self;
		when: OPSimulatorStepped do: [ :event | self invokeCallback: #stepped with: event ] for: self;
		when: OPSimulatorReset do: [ :event | self invokeCallback: #reset with: event ] for: self.
	diagramSimulator simulableElementsDo: [ :eachElement |
		eachElement when: OPSimulatorDidAction do: [ :event | self invokeCallback: #action with: event ] for: self ]
]

{ #category : 'private' }
OPSimulationSession >> tearDownSimulator [

	| activeSimulator |
	self cancelPendingStepWaits.
	activeSimulator := diagramSimulator.
	diagramSimulator := nil.
	activeSimulator ifNil: [ ^ self ].
	activeSimulator
		unsubscribeAll: self;
		loadState
]

{ #category : 'actions' }
OPSimulationSession >> togglePlayPause [

	self isRunning
		ifTrue: [ self pause ]
		ifFalse: [ self play ]
]

{ #category : 'accessing' }
OPSimulationSession >> uiDispatcher [

	^ uiDispatcher
]

{ #category : 'accessing' }
OPSimulationSession >> uiDispatcher: aBlock [

	uiDispatcher := aBlock
]

{ #category : 'private' }
OPSimulationSession >> unsubscribeFromDiagram [

	diagramController ifNil: [ ^ self ].
	self diagramModel ifNotNil: [ :diagramModel | diagramModel announcer unsubscribe: self ].
	diagramController workbenchAnnouncer ifNotNil: [ :workbenchAnnouncer | workbenchAnnouncer unsubscribe: self ]
]
