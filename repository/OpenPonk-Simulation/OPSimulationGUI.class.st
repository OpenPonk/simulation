"
Abstract top-level Spec2 presenter coordinating a diagram simulation window. Delegates open-instance lookup to OPSimulationRegistry, simulator lifecycle and UI-safe dispatch to OPSimulationSession, diagram shape overlays to OPDiagramHighlighter, and action buttons plus step delay to OPSimulationControlsGUI. Subclasses implement #simulatorClass and may override modular button hooks, visual update hooks, and #buildConfigurationPresenter for an embedded right-side scrollable configuration sidebar.
"
Class {
	#name : 'OPSimulationGUI',
	#superclass : 'SpPresenter',
	#instVars : [
		'diagramSimulator',
		'diagramController',
		'buttons',
		'session',
		'highlighter',
		'controlsPresenter',
		'configurationPresenter',
		'isConfigurationVisible',
		'configureButton',
		'animator'
	],
	#category : 'OpenPonk-Simulation-Simulation',
	#package : 'OpenPonk-Simulation',
	#tag : 'Simulation'
}

{ #category : 'instance creation' }
OPSimulationGUI class >> diagramController: aDiagramController [
	"Answers existing open simulation GUI for aDiagramController or creates and opens a new one."

	| simulationGui |
	simulationGui := self registry guiFor: aDiagramController ifAbsentPut: [ self newForController: aDiagramController ].
	simulationGui activate.
	^ simulationGui
]

{ #category : 'instance creation' }
OPSimulationGUI class >> newForController: aDiagramController [

	^ self new
		  diagramController: aDiagramController;
		  open;
		  yourself
]

{ #category : 'accessing' }
OPSimulationGUI class >> registry [

	^ OPSimulationRegistry default
]

{ #category : 'instance creation' }
OPSimulationGUI class >> stepSimulatorOfController: anElementController [
	"Opens or reuses simulation GUI for anElementController's diagram and steps its simulator."

	| simulationGui |
	simulationGui := self diagramController: anElementController diagramController.
	simulationGui stepSimulatorOfController: anElementController.
	^ simulationGui
]

{ #category : 'windows' }
OPSimulationGUI >> activate [
	"causes simulation GUI to get on top of screen"

	self windowMorph ifNotNil: [ :morph | morph activate ]
]

{ #category : 'adding' }
OPSimulationGUI >> addButtons [

	controlsPresenter clearTrackedButtons.
	configureButton := nil.
	buttons := self buttonItems asOrderedCollection.
	controlsPresenter
		showsDelayControl: self showsDelayControl;
		buttons: buttons.
	session ifNotNil: [ :activeSession | controlsPresenter updateRunningState: activeSession isRunning ].
	self
		refreshLayout;
		updateWindowExtent
]

{ #category : 'private - hooks' }
OPSimulationGUI >> afterStepVisualsUpdated [
	"Subclasses may override to react once step visuals (including any live animation) finish updating."

	
]

{ #category : 'private - updating' }
OPSimulationGUI >> animateStepEvent: anEvent onCompleted: aCompletionBlock [

	(animator isNil or: [ session isNil ]) ifTrue: [
			aCompletionBlock value.
			^ self ].
	animator
		animateTransfers: anEvent transfers
		delay: session delay
		isPlaying: session isRunning
		onCompleted: aCompletionBlock
]

{ #category : 'accessing' }
OPSimulationGUI >> animator [

	^ animator
]

{ #category : 'configuration' }
OPSimulationGUI >> buildConfigurationPresenter [
	"Subclasses with configuration override to return a Spec2 presenter (typically an OPSimulationConfigurationGUI subclass)."

	^ nil
]

{ #category : 'private - hooks' }
OPSimulationGUI >> buttonItems [
	"Builds the default modular action button collection. Subclasses may override capability hooks or override this method completely without super."

	| items |
	items := OrderedCollection with: self newPlayPauseButton with: self newStepButton with: self newResetButton.
	self supportsSavingState ifTrue: [ items add: self newSaveStateButton ].
	self hasConfiguration ifTrue: [ items add: self newConfigureButton ].
	items addAll: self extraButtonItems.
	^ items
]

{ #category : 'accessing' }
OPSimulationGUI >> buttons [

	^ buttons
]

{ #category : 'windows' }
OPSimulationGUI >> close [

	self withWindowDo: [ :aWindow | aWindow isOpen ifTrue: [ aWindow close ] ]
]

{ #category : 'private - updating' }
OPSimulationGUI >> closed [

	| activeSession |
	self class registry unregister: self.
	animator ifNotNil: [ :activeAnimator | activeAnimator cancel ].
	highlighter ifNotNil: [ :activeHighlighter | activeHighlighter clearAll ].
	configurationPresenter := nil.
	isConfigurationVisible := false.
	activeSession := session.
	session := nil.
	activeSession ifNotNil: [ activeSession close ].
	diagramController := nil.
	diagramSimulator := nil.
	animator := nil.
	highlighter := nil
]

{ #category : 'accessing' }
OPSimulationGUI >> configurationPresenter [

	^ configurationPresenter
]

{ #category : 'private - updating' }
OPSimulationGUI >> connectSessionCallbacks [

	session
		onWillStep: [ animator ifNotNil: [ :activeAnimator | activeAnimator completeImmediately ] ];
		onCancelVisuals: [ animator ifNotNil: [ :activeAnimator | activeAnimator completeImmediately ] ];
		onWillReload: [
				animator ifNotNil: [ :activeAnimator | activeAnimator cancel ].
				highlighter ifNotNil: [ :activeHighlighter | activeHighlighter clearAll ] ];
		onReloaded: [ self handleReloaded ];
		onClosed: [ self handleSessionClosed ];
		onStepped: [ :event | self handleSimulatorStepped: event ];
		onAction: [ :event | self handleSimulatorAction: event ];
		onReset: [ :event | self handleSimulatorReset: event ];
		onRunningStateChanged: [ :isRunning | controlsPresenter updateRunningState: isRunning ]
]

{ #category : 'accessing' }
OPSimulationGUI >> controlsPresenter [

	^ controlsPresenter
]

{ #category : 'private - hooks' }
OPSimulationGUI >> delayOptions [

	^ {
		  ('0.25 s' -> 250).
		  ('0.5 s' -> 500).
		  ('1 s' -> 1000).
		  ('2 s' -> 2000).
		  ('5 s' -> 5000) }
]

{ #category : 'accessing' }
OPSimulationGUI >> diagramController [

	^ diagramController
]

{ #category : 'accessing' }
OPSimulationGUI >> diagramController: aDiagramController [

	diagramController := aDiagramController.
	aDiagramController editor ifNotNil: [ :editor | self application: editor application ].
	self initializeWithController
]

{ #category : 'accessing' }
OPSimulationGUI >> diagramModel [

	^ diagramController ifNotNil: [ :controller | controller model ]
]

{ #category : 'accessing' }
OPSimulationGUI >> diagramSimulator [

	^ diagramSimulator
]

{ #category : 'private - hooks' }
OPSimulationGUI >> extraButtonItems [

	^ #(  )
]

{ #category : 'private - updating' }
OPSimulationGUI >> handleReloaded [

	diagramSimulator := session ifNotNil: [ :activeSession | activeSession diagramSimulator ].
	self loadSimulation.
	self rebuildConfigurationForReload.
	controlsPresenter updateRunningState: (session isNotNil and: [ session isRunning ]).
	self updateSimulationVisuals.
	self isOpen ifTrue: [ self activate ]
]

{ #category : 'private - updating' }
OPSimulationGUI >> handleSessionClosed [

	session ifNil: [ ^ self ].
	self isOpen
		ifTrue: [ self close ]
		ifFalse: [ self closed ]
]

{ #category : 'private - hooks' }
OPSimulationGUI >> handleSimulatorAction: anActionEvent [
	"Subclasses may override to react to element simulator actions on the UI thread."

	
]

{ #category : 'private - updating' }
OPSimulationGUI >> handleSimulatorReset: aResetEvent [

	animator ifNotNil: [ :activeAnimator | activeAnimator cancel ].
	highlighter ifNotNil: [ :activeHighlighter | activeHighlighter clearAll ].
	configurationPresenter ifNotNil: [ :activeConfiguration | activeConfiguration refreshFromSimulator ].
	controlsPresenter updateRunningState: (session isNotNil and: [ session isRunning ]).
	self updateSimulationVisuals
]

{ #category : 'private - updating' }
OPSimulationGUI >> handleSimulatorStepped: anEvent [

	self animateStepEvent: anEvent onCompleted: [
			self updateSimulationVisuals.
			self afterStepVisualsUpdated ]
]

{ #category : 'testing' }
OPSimulationGUI >> hasConfiguration [

	^ false
]

{ #category : 'configuration' }
OPSimulationGUI >> hideConfiguration [

	self isConfigurationVisible ifFalse: [ ^ self ].
	isConfigurationVisible := false.
	self
		refreshLayout;
		updateWindowExtent
]

{ #category : 'accessing' }
OPSimulationGUI >> highlighter [

	^ highlighter
]

{ #category : 'initialization' }
OPSimulationGUI >> initializePresenters [

	super initializePresenters.
	buttons := OrderedCollection new.
	isConfigurationVisible := false.
	controlsPresenter := self instantiate: OPSimulationControlsGUI.
	controlsPresenter
		showsDelayControl: self showsDelayControl;
		showsAnimationControl: self showsAnimationControl;
		delayOptions: self delayOptions;
		onDelayChanged: [ :milliseconds | session ifNotNil: [ :activeSession | activeSession delay: milliseconds ] ];
		onAnimationToggled: [ :isEnabled | animator ifNotNil: [ :activeAnimator | activeAnimator isEnabled: isEnabled ] ].
	self refreshLayout
]

{ #category : 'initialization' }
OPSimulationGUI >> initializeWindow: aWindow [

	super initializeWindow: aWindow.
	aWindow initialExtent: self preferredExtent.
	diagramController ifNil: [ ^ self ].
	aWindow title: 'Simulation of ' , (self diagramModel name ifNil: [ '' ])
]

{ #category : 'initialization' }
OPSimulationGUI >> initializeWithController [
	"Creates session, highlighter, animator, simulator, and action controls for diagramController."

	highlighter := OPDiagramHighlighter on: diagramController.
	animator := OPSimulationAnimator on: diagramController highlighter: highlighter.
	animator isEnabled: controlsPresenter isAnimationEnabled.
	session := self sessionClass diagramController: diagramController simulatorClass: self simulatorClass.
	session stepCompletionWaiter: [ animator ifNotNil: [ :activeAnimator | activeAnimator waitForCompletion ] ].
	self connectSessionCallbacks.
	session start.
	diagramSimulator := session diagramSimulator.
	self loadSimulation.
	self addButtons.
	controlsPresenter
		selectDelay: session delay;
		updateRunningState: session isRunning.
	self updateSimulationVisuals
]

{ #category : 'testing' }
OPSimulationGUI >> isConfigurationVisible [

	^ isConfigurationVisible
]

{ #category : 'testing' }
OPSimulationGUI >> isOpen [

	^ self hasWindow and: [ self window isOpen ]
]

{ #category : 'private - hooks' }
OPSimulationGUI >> loadSimulation [
	"Prepares simulation state after session loads or reloads the diagram simulator."

	diagramSimulator := session diagramSimulator
]

{ #category : 'button factories' }
OPSimulationGUI >> newButtonLabeled: aLabel iconName: anIconName help: aHelp action: aBlock [

	| button |
	button := controlsPresenter newButton
		          label: aLabel;
		          help: aHelp;
		          action: aBlock;
		          yourself.
	anIconName ifNotNil: [ button iconName: anIconName ].
	^ button
]

{ #category : 'button factories' }
OPSimulationGUI >> newConfigureButton [

	^ self newConfigureButtonLabeled: 'Configure' help: 'Toggle simulation configuration sidebar'
]

{ #category : 'button factories' }
OPSimulationGUI >> newConfigureButtonLabeled: aLabel help: aHelp [

	configureButton := self
		                   newButtonLabeled: aLabel
		                   iconName: #configuration
		                   help: aHelp
		                   action: [ self toggleConfiguration ].
	^ configureButton
]

{ #category : 'button factories' }
OPSimulationGUI >> newPlayPauseButton [

	^ self
		  newPlayPauseButtonLabeled: 'Play'
		  pauseLabel: 'Pause'
		  playHelp: 'Play simulation continuously'
		  pauseHelp: 'Pause simulation'
]

{ #category : 'button factories' }
OPSimulationGUI >> newPlayPauseButtonLabeled: aPlayLabel pauseLabel: aPauseLabel playHelp: aPlayHelp pauseHelp: aPauseHelp [

	| button |
	button := self
		          newButtonLabeled: aPlayLabel
		          iconName: #smallPrintItIcon
		          help: aPlayHelp
		          action: [ self session ifNotNil: [ :activeSession | activeSession togglePlayPause ] ].
	controlsPresenter registerPlayPauseButton: button configuration: (Dictionary newFrom: {
				 (#playLabel -> aPlayLabel).
				 (#pauseLabel -> aPauseLabel).
				 (#playIcon -> #smallPrintItIcon).
				 (#pauseIcon -> #testYellow).
				 (#playHelp -> aPlayHelp).
				 (#pauseHelp -> aPauseHelp) }).
	^ button
]

{ #category : 'button factories' }
OPSimulationGUI >> newResetButton [

	^ self newResetButtonLabeled: 'Reset' help: 'Stop simulation and restore initial state'
]

{ #category : 'button factories' }
OPSimulationGUI >> newResetButtonLabeled: aLabel help: aHelp [

	^ self
		  newButtonLabeled: aLabel
		  iconName: #smallUpdate
		  help: aHelp
		  action: [ self session ifNotNil: [ :activeSession | activeSession reset ] ]
]

{ #category : 'button factories' }
OPSimulationGUI >> newSaveStateButton [

	^ self
		  newButtonLabeled: 'Save state'
		  iconName: #smallSave
		  help: 'Save current simulation state into model'
		  action: [ self session ifNotNil: [ :activeSession | activeSession saveState ] ]
]

{ #category : 'button factories' }
OPSimulationGUI >> newStepButton [

	^ self
		  newStepButtonLabeled: 'Step'
		  help: 'Step simulation once'
		  action: [ self session ifNotNil: [ :activeSession | activeSession step ] ]
]

{ #category : 'button factories' }
OPSimulationGUI >> newStepButtonLabeled: aLabel help: aHelp action: aBlock [

	| button |
	button := self
		          newButtonLabeled: aLabel
		          iconName: #forwardIcon
		          help: aHelp
		          action: aBlock.
	controlsPresenter registerStepButton: button.
	^ button
]

{ #category : 'showing' }
OPSimulationGUI >> open [
	self isOpen
		ifTrue: [ ^ self takeKeyboardFocus ].
	super open.
	self window whenClosedDo: [ self closed ]
]

{ #category : 'accessing' }
OPSimulationGUI >> preferredExtent [

	| width height |
	width := controlsPresenter preferredWidth.
	height := controlsPresenter preferredHeight + 32.
	(self isConfigurationVisible and: [ configurationPresenter isNotNil ]) ifTrue: [
			width := width + 360.
			height := height max: 260 ].
	^ width @ height
]

{ #category : 'private - updating' }
OPSimulationGUI >> rebuildConfigurationForReload [

	self isConfigurationVisible
		ifTrue: [
				configurationPresenter := self buildConfigurationPresenter.
				configurationPresenter ifNil: [ isConfigurationVisible := false ].
				self
					refreshLayout;
					updateWindowExtent ]
		ifFalse: [ configurationPresenter := nil ]
]

{ #category : 'layout' }
OPSimulationGUI >> refreshLayout [

	self layout: ((self isConfigurationVisible and: [ configurationPresenter isNotNil ])
			 ifTrue: [
					 SpPanedLayout newLeftToRight
						 add: controlsPresenter;
						 add: (SpScrollableLayout with: configurationPresenter);
						 positionOfSlider: controlsPresenter preferredWidth;
						 yourself ]
			 ifFalse: [
					 SpBoxLayout newTopToBottom
						 add: controlsPresenter;
						 yourself ])
]

{ #category : 'actions' }
OPSimulationGUI >> reloadController [

	session ifNotNil: [ :activeSession | activeSession reload ]
]

{ #category : 'accessing' }
OPSimulationGUI >> session [

	^ session
]

{ #category : 'private - hooks' }
OPSimulationGUI >> sessionClass [

	^ OPSimulationSession
]

{ #category : 'configuration' }
OPSimulationGUI >> showConfiguration [

	self hasConfiguration ifFalse: [ ^ self ].
	configurationPresenter ifNil: [ configurationPresenter := self buildConfigurationPresenter ].
	configurationPresenter ifNil: [ ^ self ].
	self isConfigurationVisible ifTrue: [ ^ self ].
	isConfigurationVisible := true.
	self
		refreshLayout;
		updateWindowExtent
]

{ #category : 'testing' }
OPSimulationGUI >> showsAnimationControl [

	^ true
]

{ #category : 'testing' }
OPSimulationGUI >> showsDelayControl [

	^ true
]

{ #category : 'private - hooks' }
OPSimulationGUI >> simulatorClass [
	"diagram simulator class"

	^ self subclassResponsibility
]

{ #category : 'actions' }
OPSimulationGUI >> stepSimulatorOfController: anElementController [

	session ifNotNil: [ :activeSession | activeSession stepElementController: anElementController ]
]

{ #category : 'testing' }
OPSimulationGUI >> supportsSavingState [

	^ false
]

{ #category : 'configuration' }
OPSimulationGUI >> toggleConfiguration [

	self isConfigurationVisible
		ifTrue: [ self hideConfiguration ]
		ifFalse: [ self showConfiguration ]
]

{ #category : 'private - hooks' }
OPSimulationGUI >> updateSimulationVisuals [
	"Subclasses may override to update diagram highlights after load, step, reset, or reload on the UI thread."

	
]

{ #category : 'layout' }
OPSimulationGUI >> updateWindowExtent [

	self withWindowDo: [ :activeWindow | activeWindow isOpen ifTrue: [ activeWindow resize: self preferredExtent ] ]
]

{ #category : 'accessing' }
OPSimulationGUI >> windowMorph [

	^ self withWindowDo: [ :aWindow | aWindow window ]
]
