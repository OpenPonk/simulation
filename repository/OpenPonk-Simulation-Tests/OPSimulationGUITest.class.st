"
Headless UI tests for OPSimulationGUI covering singleton-like controller lookup, button actions, layout construction, model change reload, window lifecycle, and idempotent cleanup.
"
Class {
	#name : 'OPSimulationGUITest',
	#superclass : 'OPAbstractUITest',
	#instVars : [
		'openWindowsBefore',
		'rootModel',
		'firstElement',
		'secondElement',
		'editor',
		'diagramController',
		'elementController',
		'simulationGui'
	],
	#category : 'OpenPonk-Simulation-Tests-Simulation',
	#package : 'OpenPonk-Simulation-Tests',
	#tag : 'Simulation'
}

{ #category : 'running' }
OPSimulationGUITest >> setUp [

	super setUp.
	openWindowsBefore := (self currentWorld submorphs select: [ :eachMorph | eachMorph isSystemWindow ]) asIdentitySet.
	OPPluginRegistry setDefault: (OPPluginRegistry new
			 add: OPTestPlugin new;
			 yourself).
	self setUpModel.
	self setUpDiagramController
]

{ #category : 'running' }
OPSimulationGUITest >> setUpDiagramController [

	| project diagram projectController plugin |
	project := OPProject named: 'Simulation GUI Test'.
	project addModel: rootModel.
	diagram := OPOpenPonkDiagram forModelElement: rootModel.
	project addDiagram: diagram.
	projectController := OPProjectController forProject: project.
	plugin := OPPluginRegistry default plugins detect: [ :eachPlugin | eachPlugin isKindOf: OPTestPlugin ].
	editor := OPEditor on: plugin.
	diagramController := OPTestDiagramController new.
	projectController addDiagramController: diagramController.
	diagramController
		editor: editor;
		canvasPresenter: OPHeadlessCanvasPresenter new;
		diagramElement: diagram;
		model: rootModel.
	elementController := OPTestEntityController new
		                     diagramController: diagramController;
		                     model: firstElement;
		                     yourself
]

{ #category : 'running' }
OPSimulationGUITest >> setUpModel [

	rootModel := OPTestSimulationModel new
		             name: 'Test Model';
		             yourself.
	firstElement := OPTestSimulationModel new
		                name: 'First';
		                yourself.
	secondElement := OPTestSimulationModel new
		                 name: 'Second';
		                 yourself.
	rootModel
		add: firstElement;
		add: secondElement
]

{ #category : 'running' }
OPSimulationGUITest >> tearDown [

	simulationGui ifNotNil: [ :gui | gui hasWindow ifTrue: [ gui window close ] ].
	self currentWorld submorphs
		select: [ :eachMorph | eachMorph isSystemWindow and: [ (openWindowsBefore includes: eachMorph) not ] ]
		thenDo: [ :eachWindow | eachWindow delete ].
	OPPluginRegistry resetDefault.
	simulationGui := nil.
	elementController := nil.
	diagramController := nil.
	editor := nil.
	secondElement := nil.
	firstElement := nil.
	rootModel := nil.
	openWindowsBefore := nil.
	super tearDown
]

{ #category : 'tests' }
OPSimulationGUITest >> testButtonItemsAndLayoutForEvenAndOddButtonCounts [

	| buttonItems buttonsByLabel saveCountBefore loadCountBefore |
	simulationGui := OPTestSimulationGUI diagramController: diagramController.
	buttonItems := simulationGui buttons.
	self assert: (buttonItems collect: #label as: Array) equals: #( 'Save state' 'Stop + Load state' ).
	self assert: simulationGui layout children size equals: 2.

	buttonsByLabel := (buttonItems collect: [ :eachButton | eachButton label -> eachButton ]) asDictionary.
	saveCountBefore := simulationGui diagramSimulator saveStateCount.
	(buttonsByLabel at: 'Save state') performAction.
	self assert: simulationGui diagramSimulator saveStateCount equals: saveCountBefore + 1.

	loadCountBefore := simulationGui diagramSimulator loadStateCount.
	(buttonsByLabel at: 'Stop + Load state') performAction.
	self assert: simulationGui diagramSimulator loadStateCount equals: loadCountBefore + 1.

	simulationGui extraButtonsCount: 1.
	simulationGui addButtons.
	self assert: simulationGui buttons size equals: 3.
	self assert: simulationGui layout children size equals: 4.
	self assert: simulationGui layout children keys last class identicalTo: SpNullPresenter
]

{ #category : 'tests' }
OPSimulationGUITest >> testCloseClosedWindowMorphAndActivateAreSafeBeforeOpenAndIdempotent [

	| unopenedGui |
	unopenedGui := OPTestSimulationGUI new.
	self deny: unopenedGui isOpen description: 'Unopened simulation GUI must not report open'.
	self assert: unopenedGui windowMorph identicalTo: nil.
	unopenedGui activate.
	unopenedGui close.
	unopenedGui closed.

	simulationGui := OPTestSimulationGUI diagramController: diagramController.
	self
		assert:
		(rootModel announcer subscriptions subscriptions anySatisfy: [ :eachSubscription | eachSubscription subscriber == simulationGui ])
		description: 'Open simulation GUI must subscribe to model children change announcements'.
	simulationGui close.
	self
		deny:
		(rootModel announcer subscriptions subscriptions anySatisfy: [ :eachSubscription | eachSubscription subscriber == simulationGui ])
		description: 'Closing simulation GUI must unsubscribe from model announcer'.
	simulationGui closed.
	self assert: simulationGui diagramController identicalTo: nil
]

{ #category : 'tests' }
OPSimulationGUITest >> testDiagramControllerReturnsExistingOpenInstanceAndCreatesNewAfterClose [

	| reusedGui reopenedGui |
	simulationGui := OPTestSimulationGUI diagramController: diagramController.
	self assert: simulationGui diagramController identicalTo: diagramController.
	self assert: simulationGui diagramModel identicalTo: rootModel.
	self assert: simulationGui isOpen description: 'Simulation GUI must report open after creation'.
	self assert: simulationGui windowMorph isNotNil description: 'Open simulation GUI must expose its window morph'.

	reusedGui := OPTestSimulationGUI diagramController: diagramController.
	self assert: reusedGui identicalTo: simulationGui.

	simulationGui open.
	self assert: simulationGui isOpen description: 'Calling open on an already open simulation GUI must keep it open'.

	simulationGui close.
	self deny: simulationGui isOpen description: 'Simulation GUI must report closed after closing its window'.
	self assert: simulationGui diagramController identicalTo: nil.
	self assert: simulationGui diagramSimulator identicalTo: nil.

	reopenedGui := OPTestSimulationGUI diagramController: diagramController.
	self deny: reopenedGui identicalTo: simulationGui.
	self assert: reopenedGui isOpen description: 'Closing previous GUI must allow opening a new instance for the same controller'.
	simulationGui := reopenedGui
]

{ #category : 'tests' }
OPSimulationGUITest >> testInitializeWindowHandlesNamedUnnamedAndUnattachedStates [

	| unattachedGui |
	simulationGui := OPTestSimulationGUI diagramController: diagramController.
	self assert: simulationGui window title equals: 'Simulation of Test Model'.
	simulationGui close.

	rootModel name: nil.
	simulationGui := OPTestSimulationGUI diagramController: diagramController.
	self assert: simulationGui window title equals: 'Simulation of '.
	simulationGui close.

	unattachedGui := OPTestSimulationGUI new.
	unattachedGui open.
	self assert: unattachedGui isOpen description: 'Unattached simulation GUI must open without diagramController'.
	unattachedGui close.
	self deny: unattachedGui isOpen description: 'Unattached simulation GUI must close cleanly'
]

{ #category : 'tests' }
OPSimulationGUITest >> testReloadControllerReactsToMultipleModelChildrenChangedEvents [

	| thirdElement initialSimulator simulatorAfterAdd simulatorAfterRemove |
	simulationGui := OPTestSimulationGUI diagramController: diagramController.
	initialSimulator := simulationGui diagramSimulator.
	self assert: initialSimulator elements size equals: 2.

	thirdElement := OPTestSimulationModel new
		                name: 'Third';
		                yourself.
	rootModel add: thirdElement.
	simulatorAfterAdd := simulationGui diagramSimulator.
	self deny: simulatorAfterAdd identicalTo: initialSimulator.
	self assert: simulatorAfterAdd elements size equals: 3.

	rootModel remove: thirdElement.
	simulatorAfterRemove := simulationGui diagramSimulator.
	self deny: simulatorAfterRemove identicalTo: simulatorAfterAdd.
	self assert: simulatorAfterRemove elements size equals: 2.

	simulationGui close.
	simulationGui reloadController.
	self assert: simulationGui diagramController identicalTo: nil
]

{ #category : 'tests' }
OPSimulationGUITest >> testStepSimulatorOfControllerStepsElementAndReturnsGui [

	| returnedGui firstSimulator secondSimulator |
	returnedGui := OPTestSimulationGUI stepSimulatorOfController: elementController.
	simulationGui := returnedGui.
	self assert: returnedGui class identicalTo: OPTestSimulationGUI.
	self assert: returnedGui diagramController identicalTo: diagramController.

	firstSimulator := returnedGui diagramSimulator simulatorOf: firstElement.
	secondSimulator := returnedGui diagramSimulator simulatorOf: secondElement.
	self assert: firstSimulator stepCount equals: 1.
	self assert: secondSimulator stepCount equals: 0.

	returnedGui stepSimulatorOfController: elementController.
	self assert: firstSimulator stepCount equals: 2
]
