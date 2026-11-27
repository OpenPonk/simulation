"
I'm a root class in simulators hierarchy above model.
I handle stepping and repeating steps and contains announcers.

Protocol stepping contains settings for steps, actions contain executing steps.

    Instance Variables
	actions:		collection of blocks of actions taken with each step
	announcer:		Announcer instance
	delayInMilliseconds:		integer containing delay between steps
	shouldRun:		boolean telling whether running should continue
"
Class {
	#name : 'OPSimulator',
	#superclass : 'Object',
	#instVars : [
		'shouldRun',
		'announcer',
		'actions',
		'delayInMilliseconds',
		'runProcess',
		'waitSemaphore',
		'runGeneration',
		'stepRunner',
		'stepCycleWaiter'
	],
	#category : 'OpenPonk-ModelSimulation-Simulators',
	#package : 'OpenPonk-ModelSimulation',
	#tag : 'Simulators'
}

{ #category : 'stepping' }
OPSimulator >> addAction: block [
	"stepping settings
	source based on valueForAction method
	
	adds block to collection of actions for stepping"

	actions addLast: block
]

{ #category : 'stepping' }
OPSimulator >> addFirstAction: block [
	"stepping settings
	source based on valueForAction method
	
	adds block to collection of actions for stepping"

	actions addFirst: block
]

{ #category : 'announcing' }
OPSimulator >> announce: anAnnouncement [
	announcer announce: anAnnouncement
]

{ #category : 'private - actions' }
OPSimulator >> announceRunEvent: anEventClass delay: aDelay maxSteps: aMaxStepsOrNil [

	self announce: (aMaxStepsOrNil
			 ifNil: [ anEventClass simulator: self delay: aDelay ]
			 ifNotNil: [ anEventClass simulator: self delay: aDelay repeatTimes: aMaxStepsOrNil ])
]

{ #category : 'accessing' }
OPSimulator >> delay [
	"pause between steps while repeating"

	^ delayInMilliseconds
]

{ #category : 'accessing' }
OPSimulator >> delay: milliSeconds [
	"pause between steps while repeating"

	delayInMilliseconds := milliSeconds
]

{ #category : 'accessing' }
OPSimulator >> diagram [
	^ self diagramSimulator model
]

{ #category : 'accessing' }
OPSimulator >> diagramSimulator [
	^ self subclassResponsibility
]

{ #category : 'actions' }
OPSimulator >> doAction: anIndex [
	"makes selected action"

	| itemsToAct action |
	itemsToAct := self itemsForAction.
	action := actions at: anIndex.
	self announce: (OPSimulatorWillDoAction simulator: self action: action index: anIndex).
	itemsToAct do: action.
	self announce: (OPSimulatorDidAction simulator: self action: action index: anIndex)
]

{ #category : 'private - actions' }
OPSimulator >> executeActionsOn: itemsToAct [

	actions withIndexDo: [ :action :index |
			self announce: (OPSimulatorWillDoAction simulator: self action: action index: index).
			itemsToAct do: action.
			self announce: (OPSimulatorDidAction simulator: self action: action index: index) ]
]

{ #category : 'private - actions' }
OPSimulator >> executeViaStepRunner: aBlock [

	^ self stepRunner value: aBlock
]

{ #category : 'private - actions' }
OPSimulator >> finishRunGeneration: aGeneration delayBlock: aDelayBlock maxSteps: aMaxStepsOrNil [

	runGeneration = aGeneration ifFalse: [ ^ self ].
	shouldRun := false.
	runProcess := nil.
	waitSemaphore := nil.
	self executeViaStepRunner: [ self announceRunEvent: OPSimulatorStoppedRun delay: aDelayBlock value maxSteps: aMaxStepsOrNil ]
]

{ #category : 'stepping' }
OPSimulator >> fromSelf [
	"stepping settings
	before: none
	after: priority
	
	steps self"

	self subclassResponsibility
]

{ #category : 'initialization' }
OPSimulator >> initialize [

	super initialize.
	shouldRun := false.
	runGeneration := 0.
	stepRunner := [ :aBlock | aBlock value ].
	stepCycleWaiter := [ :elapsedMs :delayMs :aWaitSemaphore | aWaitSemaphore waitTimeoutMilliseconds: delayMs ].
	self
		delay: 1000;
		resetActions;
		setDefaultStepping.
	announcer := Announcer new
]

{ #category : 'testing' }
OPSimulator >> isFinished [
	"is there not any way to step anymore?"

	^ self isSteppable not
]

{ #category : 'testing' }
OPSimulator >> isRunning [
	"Answer whether repeating execution is currently active."

	^ shouldRun
]

{ #category : 'testing' }
OPSimulator >> isSimulable [
	"could there be any possibility to step? - rigid: should return always true or always false"

	^ self subclassResponsibility
]

{ #category : 'testing' }
OPSimulator >> isSteppable [
	"can I step right now?"

	^ self subclassResponsibility
]

{ #category : 'private - accessing' }
OPSimulator >> itemsForAction [
	^ self subclassResponsibility
]

{ #category : 'actions' }
OPSimulator >> repeat [
	"repeats step until finished or stopped, reading delay before each wait"

	self runRepeatingWithDelayBlock: [ self delay ] maxSteps: nil
]

{ #category : 'actions' }
OPSimulator >> repeatOnce [
	"steps once"

	self step
]

{ #category : 'actions' }
OPSimulator >> repeatTimes: anInteger [
	"repeats step anInteger times, stopping early if finished or stopped"

	self runRepeatingWithDelayBlock: [ self delay ] maxSteps: anInteger
]

{ #category : 'actions' }
OPSimulator >> repeatWithDelay: aDelay [
	"repeats step until finished or stopped, waiting aDelay milliseconds between steps"

	self runRepeatingWithDelayBlock: [ aDelay ] maxSteps: nil
]

{ #category : 'stepping' }
OPSimulator >> resetActions [
	actions := OrderedCollection new
]

{ #category : 'private - actions' }
OPSimulator >> runLoopForGeneration: aGeneration delayBlock: aDelayBlock maxSteps: aMaxStepsOrNil waitSemaphore: aWaitSemaphore [

	| stepsExecuted |
	stepsExecuted := 0.
	[ self shouldContinueRun: aGeneration maxSteps: aMaxStepsOrNil executed: stepsExecuted ] whileTrue: [
			| stepStartMs elapsedMs |
			stepStartMs := Time millisecondClockValue.
			self executeViaStepRunner: [
				(self shouldContinueRun: aGeneration maxSteps: aMaxStepsOrNil executed: stepsExecuted) ifTrue: [ self step ] ].
			stepsExecuted := stepsExecuted + 1.
			(self shouldContinueRun: aGeneration maxSteps: aMaxStepsOrNil executed: stepsExecuted) ifTrue: [
					elapsedMs := Time millisecondsSince: stepStartMs.
					self stepCycleWaiter value: elapsedMs value: aDelayBlock value value: aWaitSemaphore ] ]
]

{ #category : 'private - actions' }
OPSimulator >> runRepeatingWithDelayBlock: aDelayBlock maxSteps: aMaxStepsOrNil [

	| currentGeneration currentWaitSemaphore |
	shouldRun ifTrue: [ ^ self ].
	self isSteppable ifFalse: [ ^ self ].
	(aMaxStepsOrNil isNotNil and: [ aMaxStepsOrNil <= 0 ]) ifTrue: [ ^ self ].
	runGeneration := runGeneration + 1.
	currentGeneration := runGeneration.
	currentWaitSemaphore := Semaphore new.
	waitSemaphore := currentWaitSemaphore.
	shouldRun := true.
	self announceRunEvent: OPSimulatorWillRun delay: aDelayBlock value maxSteps: aMaxStepsOrNil.
	runProcess := [
		              [
			              self
				              runLoopForGeneration: currentGeneration
				              delayBlock: aDelayBlock
				              maxSteps: aMaxStepsOrNil
				              waitSemaphore: currentWaitSemaphore ] ensure: [
			              self finishRunGeneration: currentGeneration delayBlock: aDelayBlock maxSteps: aMaxStepsOrNil ] ] fork
]

{ #category : 'initialization' }
OPSimulator >> setDefaultStepping [
	"sets default stepping settings"

	self fromSelf
]

{ #category : 'private - actions' }
OPSimulator >> shouldContinueRun: aGeneration maxSteps: aMaxStepsOrNil executed: aStepCount [

	^ shouldRun and: [
		  runGeneration = aGeneration and: [ self isSteppable and: [ aMaxStepsOrNil isNil or: [ aStepCount < aMaxStepsOrNil ] ] ] ]
]

{ #category : 'actions' }
OPSimulator >> step [
	"makes all actions"

	| itemsToAct |
	self isSteppable ifFalse: [ ^ self ].
	itemsToAct := self itemsForAction.
	self announce: (OPSimulatorWillStep simulator: self).
	self executeActionsOn: itemsToAct.
	self announce: (OPSimulatorStepped simulator: self)
]

{ #category : 'accessing' }
OPSimulator >> stepCycleWaiter [

	^ stepCycleWaiter
]

{ #category : 'accessing' }
OPSimulator >> stepCycleWaiter: aThreeArgBlock [

	stepCycleWaiter := aThreeArgBlock
]

{ #category : 'accessing' }
OPSimulator >> stepRunner [
	"Answer the execution wrapper block used to run each repeated step and final stop notification."

	^ stepRunner
]

{ #category : 'accessing' }
OPSimulator >> stepRunner: aBlock [
	"Set the execution wrapper block (e.g. UI-thread dispatcher) for repeated steps."

	stepRunner := aBlock
]

{ #category : 'actions' }
OPSimulator >> stop [
	"Stops repeating execution immediately, waking any active delay wait without interrupting a step."

	| activeSemaphore stoppedDelay |
	shouldRun ifFalse: [ ^ self ].
	stoppedDelay := self delay.
	shouldRun := false.
	runGeneration := runGeneration + 1.
	runProcess := nil.
	activeSemaphore := waitSemaphore.
	waitSemaphore := nil.
	activeSemaphore ifNotNil: [ :semaphore | semaphore signal ].
	self announce: (OPSimulatorStoppedRun simulator: self delay: stoppedDelay)
]

{ #category : 'announcing' }
OPSimulator >> unsubscribe: aSubscriber [

	announcer unsubscribe: aSubscriber
]

{ #category : 'announcing' }
OPSimulator >> when: anEvent do: aBlock for: aReceiver [

	announcer when: anEvent do: aBlock for: aReceiver
]

{ #category : 'announcing' }
OPSimulator >> when: anAnnouncementClass send: aSelector to: aReceiver [

	^ announcer when: anAnnouncementClass send: aSelector to: aReceiver
]
