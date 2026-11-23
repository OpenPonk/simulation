"
Abstract Spec2 presenter bridging a diagram controller with its diagram simulator.
Provides singleton-like lookup per open diagram controller via #diagramController:, manages simulation control buttons and model child-change reloads, and cleans up subscriptions and saved state when the simulation window closes.
Subclasses must implement #simulatorClass to return the concrete OPDiagramSimulator subclass and may override #buttonItems and #loadSimulation.
"
Class {
	#name : 'OPSimulationGUI',
	#superclass : 'SpPresenter',
	#instVars : [
		'diagramSimulator',
		'diagramController',
		'buttons'
	],
	#category : 'OpenPonk-Simulation-Simulation',
	#package : 'OpenPonk-Simulation',
	#tag : 'Simulation'
}

{ #category : 'instance creation' }
OPSimulationGUI class >> diagramController: aDiagramController [
	"answers existing simulatorGUI with aDiagramController or creates new one for it"

	| gui |
	gui := self allInstances
		       detect: [ :anyInstance |
			       anyInstance isOpen and: [
				       anyInstance diagramController == aDiagramController ] ]
		       ifNone: [ self newForController: aDiagramController ].
	gui activate. "causes simulation GUI to get on top of screen"
	^ gui
]

{ #category : 'instance creation' }
OPSimulationGUI class >> newForController: aDiagramController [
	^ self new
		diagramController: aDiagramController;
		open;
		yourself
]

{ #category : 'instance creation' }
OPSimulationGUI class >> stepSimulatorOfController: anElementController [
	"answers existing simulatorGUI with aDiagramController or creates new one for it and steps simulator of elementController"

	| myInstance |
	myInstance := self diagramController: anElementController diagramController.
	myInstance stepSimulatorOfController: anElementController.
	^ myInstance
]

{ #category : 'windows' }
OPSimulationGUI >> activate [
	"causes simulation GUI to get on top of screen"

	self windowMorph ifNotNil: [ :morph | morph activate ]
]

{ #category : 'adding' }
OPSimulationGUI >> addButtons [

	buttons := self buttonItems.
	self initializeLayout.
	self withWindowDo: [ :window | self initializeWindow: window ]
]

{ #category : 'private - hooks' }
OPSimulationGUI >> buttonItems [
	"creates collection of buttons for this GUI"

	^ OrderedCollection
		with:
			((self newButton)
				label: 'Save state';
				iconName: #smallSave;
				help: 'Save current state into model';
				action: [ self diagramSimulator saveState ])
		with:
			((self newButton)
				label: 'Stop + Load state';
				iconName: #smallUpdate;
				help: 'Load state from model from before simulate';
				action: [ self diagramSimulator loadState ])
]

{ #category : 'windows' }
OPSimulationGUI >> close [
	"ends simulation and closes window
	it ends simulation by event triggered by closing window"

	self withWindowDo: [ :aWindow | aWindow close ]
]

{ #category : 'private - updating' }
OPSimulationGUI >> closed [

	diagramController ifNotNil: [ self diagramModel announcer unsubscribe: self ].
	diagramSimulator ifNotNil: [ diagramSimulator loadState ].
	diagramController := nil.
	diagramSimulator := nil
]

{ #category : 'accessing' }
OPSimulationGUI >> diagramController [
	^ diagramController
]

{ #category : 'accessing' }
OPSimulationGUI >> diagramController: aDiagramController [

	diagramController := aDiagramController.
	self application: aDiagramController editor application.
	self initializeWithController
]

{ #category : 'accessing' }
OPSimulationGUI >> diagramModel [
	^ self diagramController model
]

{ #category : 'accessing' }
OPSimulationGUI >> diagramSimulator [
	^ diagramSimulator
]

{ #category : 'building widgets' }
OPSimulationGUI >> initializeLayout [

	| items gridLayout counter |
	gridLayout := SpGridLayout new.
	items := buttons.
	buttons size odd ifTrue: [
		items := items copyWith: SpNullPresenter new ].
	counter := 0.
	items pairsDo: [ :odd :even |
			counter := counter + 1.
			gridLayout add: odd atPoint: 1 @ counter.

			gridLayout add: even atPoint: 2 @ counter ].
	self layout: gridLayout
]

{ #category : 'initialization' }
OPSimulationGUI >> initializePresenters [

	super initializePresenters.
	buttons := OrderedCollection new.
	self initializeLayout
]

{ #category : 'initialization' }
OPSimulationGUI >> initializeWindow: aWindow [

	super initializeWindow: aWindow.
	diagramController ifNil: [ ^ self ].
	aWindow initialExtent: 360 @ (buttons size * self class buttonHeight).
	aWindow title: 'Simulation of ' , (self diagramModel name ifNil: [ '' ])
]

{ #category : 'initialization' }
OPSimulationGUI >> initializeWithController [
	"creates and prepares simulator for current diagramController"

	self loadSimulation.
	self whenWindowClosedUnsubscribeFrom: self diagramModel.
	self subscribeToModel.
	self addButtons
]

{ #category : 'windows' }
OPSimulationGUI >> isOpen [

	^ self hasWindow and: [ self window isOpen ]
]

{ #category : 'private - hooks' }
OPSimulationGUI >> loadSimulation [
	"prepares simulation - called with every reload"

	diagramSimulator := self simulatorClass model: self diagramModel
]

{ #category : 'showing' }
OPSimulationGUI >> open [
	self isOpen
		ifTrue: [ ^ self takeKeyboardFocus ].
	super open.
	self window whenClosedDo: [ self closed ]
]

{ #category : 'updating' }
OPSimulationGUI >> reloadController [
	"reloads elements from diagramController"

	| controller |
	controller := self diagramController.
	controller ifNil: [ ^ self ].
	self closed.
	diagramController := controller.
	self
		loadSimulation;
		subscribeToModel;
		open;
		activate
]

{ #category : 'private - hooks' }
OPSimulationGUI >> simulatorClass [
	"diagram simulator class"

	^ self subclassResponsibility
]

{ #category : 'actions' }
OPSimulationGUI >> stepSimulatorOfController: anElementController [
	"steps simulator of elementController"

	| elementSimulator |
	elementSimulator := self diagramSimulator simulatorOf: anElementController model.
	elementSimulator step
]

{ #category : 'private - updating' }
OPSimulationGUI >> subscribeToModel [

	self diagramModel weakWhen: OPModelChildrenChangedEvent send: #reloadController to: self
]

{ #category : 'accessing' }
OPSimulationGUI >> windowMorph [

	^ self withWindowDo: [ :aWindow | aWindow window ]
]
