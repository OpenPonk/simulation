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
		'simulationGui',
		'workbenchAnnouncer'
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
	OPSimulationRegistry default closeAll.
	self currentWorld submorphs
		select: [ :eachMorph | eachMorph isSystemWindow and: [ (openWindowsBefore includes: eachMorph) not ] ]
		thenDo: [ :eachWindow | eachWindow delete ].
	OPPluginRegistry resetDefault.
	simulationGui := nil.
	elementController := nil.
	diagramController := nil.
	workbenchAnnouncer := nil.
	editor := nil.
	secondElement := nil.
	firstElement := nil.
	rootModel := nil.
	openWindowsBefore := nil.
	super tearDown
]

{ #category : 'tests' }
OPSimulationGUITest >> testButtonItemsAndModularCompositionWithoutMandatoryButtons [

	| buttonsByLabel saveCountBefore loadCountBefore |
	simulationGui := OPTestSimulationGUI new
		                 supportsSavingStateFlag: true;
		                 hasConfigurationFlag: true;
		                 diagramController: diagramController;
		                 open;
		                 yourself.
	self assert: (simulationGui buttons collect: #label as: Array) equals: #( 'Play' 'Step' 'Reset' 'Save state' 'Configure' ).
	self assert: simulationGui controlsPresenter layout class identicalTo: SpBoxLayout.

	buttonsByLabel := (simulationGui buttons collect: [ :eachButton | eachButton label -> eachButton ]) asDictionary.
	saveCountBefore := simulationGui diagramSimulator saveStateCount.
	(buttonsByLabel at: 'Save state') performAction.
	self assert: simulationGui diagramSimulator saveStateCount equals: saveCountBefore + 1.

	loadCountBefore := simulationGui diagramSimulator loadStateCount.
	(buttonsByLabel at: 'Reset') performAction.
	self assert: simulationGui diagramSimulator loadStateCount equals: loadCountBefore + 1.

	simulationGui customButtonsBlock: [ :gui |
			{
				gui newStepButton.
				gui newResetButton } ].
	simulationGui addButtons.
	self assert: (simulationGui buttons collect: #label as: Array) equals: #( 'Step' 'Reset' )
]

{ #category : 'tests' }
OPSimulationGUITest >> testCloseClosedWindowMorphAndActivateAreSafeBeforeOpenAndIdempotent [

	| unopenedGui activeSession |
	unopenedGui := OPTestSimulationGUI new.
	self deny: unopenedGui isOpen description: 'Unopened simulation GUI must not report open'.
	self assert: unopenedGui windowMorph identicalTo: nil.
	unopenedGui activate.
	unopenedGui close.
	unopenedGui closed.

	simulationGui := OPTestSimulationGUI diagramController: diagramController.
	activeSession := simulationGui session.
	self
		assert:
		(rootModel announcer subscriptions subscriptions anySatisfy: [ :eachSubscription | eachSubscription subscriber == activeSession ])
		description: 'Open simulation GUI session must subscribe to model children change announcements'.
	simulationGui close.
	self
		deny:
		(rootModel announcer subscriptions subscriptions anySatisfy: [ :eachSubscription | eachSubscription subscriber == activeSession ])
		description: 'Closing simulation GUI must unsubscribe its session from model announcer'.
	simulationGui closed.
	self assert: simulationGui diagramController identicalTo: nil
]

{ #category : 'tests' }
OPSimulationGUITest >> testConfigurationSidebarToggleReloadAndWindowSizing [

	| compactWidth expandedWidth initialConfig |
	simulationGui := OPTestSimulationGUI new
		                 hasConfigurationFlag: true;
		                 diagramController: diagramController;
		                 open;
		                 yourself.
	self deny: simulationGui isConfigurationVisible description: 'Configuration sidebar must start collapsed'.
	self assert: simulationGui layout class identicalTo: SpBoxLayout.
	compactWidth := simulationGui preferredExtent x.

	simulationGui toggleConfiguration.
	self assert: simulationGui isConfigurationVisible description: 'toggleConfiguration must expand sidebar'.
	self assert: simulationGui layout class identicalTo: SpPanedLayout.
	initialConfig := simulationGui configurationPresenter.
	self assert: initialConfig diagramSimulator identicalTo: simulationGui diagramSimulator.
	expandedWidth := simulationGui preferredExtent x.
	self assert: expandedWidth > compactWidth description: 'Expanding configuration sidebar must widen window'.

	rootModel add: (OPTestSimulationModel new
			 name: 'Third';
			 yourself).
	self assert: simulationGui isConfigurationVisible description: 'Open configuration sidebar must stay open across reload'.
	self deny: simulationGui configurationPresenter identicalTo: initialConfig.
	self assert: simulationGui configurationPresenter diagramSimulator identicalTo: simulationGui diagramSimulator.

	simulationGui hideConfiguration.
	self deny: simulationGui isConfigurationVisible description: 'hideConfiguration must collapse sidebar'.
	self assert: simulationGui layout class identicalTo: SpBoxLayout.
	self assert: simulationGui preferredExtent x equals: compactWidth
]

{ #category : 'tests' }
OPSimulationGUITest >> testDefaultHooksOnMinimalSubclassAndStepConfigureButtonActions [

	| minimalGui stepButton configureButton actionCount |
	minimalGui := OPMinimalTestSimulationGUI diagramController: diagramController.
	[
		self deny: minimalGui hasConfiguration description: 'Base OPSimulationGUI must default hasConfiguration to false'.
		self deny: minimalGui supportsSavingState description: 'Base OPSimulationGUI must default supportsSavingState to false'.
		self assert: minimalGui showsDelayControl description: 'Base OPSimulationGUI must default showsDelayControl to true'.
		self assert: minimalGui buildConfigurationPresenter identicalTo: nil.
		self assert: (minimalGui buttons collect: #label as: Array) equals: #( 'Play' 'Step' 'Reset' ).

		minimalGui showConfiguration.
		self deny: minimalGui isConfigurationVisible description: 'showConfiguration must be a no-op when hasConfiguration is false'.
		minimalGui hideConfiguration.

		actionCount := 0.
		minimalGui diagramSimulator addAction: [ :item |
				actionCount := actionCount + 1.
				item step ].
		(minimalGui diagramSimulator simulatorOf: firstElement) addAction: [ :item |  ].
		stepButton := minimalGui buttons detect: [ :each | each label = 'Step' ].
		stepButton performAction.
		self assert: actionCount equals: 2 ] ensure: [ minimalGui close ].

	simulationGui := OPTestSimulationGUI new
		                 hasConfigurationFlag: true;
		                 diagramController: diagramController;
		                 open;
		                 yourself.
	configureButton := simulationGui buttons detect: [ :each | each label = 'Configure' ].
	configureButton performAction.
	self assert: simulationGui isConfigurationVisible description: 'Clicking Configure button must open sidebar'.
	configureButton performAction.
	self deny: simulationGui isConfigurationVisible description: 'Clicking Configure button again must hide sidebar'.

	simulationGui diagramSimulator addAction: [ :item | item step ].
	(simulationGui diagramSimulator simulatorOf: firstElement) addAction: [ :item |  ].
	simulationGui session step.
	self assert: simulationGui actionEvents size equals: 1
]

{ #category : 'tests' }
OPSimulationGUITest >> testDelaySelectionPersistsAcrossReloadAndEditorClosedClosesGui [

	| thirdElement |
	simulationGui := OPTestSimulationGUI diagramController: diagramController.
	simulationGui controlsPresenter selectDelay: 500.
	self assert: simulationGui diagramSimulator delay equals: 500.

	thirdElement := OPTestSimulationModel new
		                name: 'Third';
		                yourself.
	rootModel add: thirdElement.
	self assert: simulationGui diagramSimulator delay equals: 500.

	workbenchAnnouncer announce: (OPEditorClosed on: editor).
	self deny: simulationGui isOpen description: 'Closing owning editor must close simulation GUI'.
	self assert: simulationGui diagramController identicalTo: nil.
	self assertEmpty: OPSimulationRegistry default openGuis
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
OPSimulationGUITest >> testPlayPauseToggleAndStepDisableOnRunningStateChange [

	| playPauseButton stepButton |
	simulationGui := OPTestSimulationGUI diagramController: diagramController.
	simulationGui session uiDispatcher: [ :aBlock | aBlock value ].
	playPauseButton := simulationGui buttons detect: [ :each | each label = 'Play' ].
	stepButton := simulationGui buttons detect: [ :each | each label = 'Step' ].
	self assert: stepButton isEnabled description: 'Step button must start enabled'.

	simulationGui diagramSimulator
		delay: 5000;
		addAction: [ :item | item step ].
	playPauseButton performAction.
	self assert: simulationGui session isRunning description: 'Clicking Play must start running simulation'.
	self assert: playPauseButton label equals: 'Pause'.
	self deny: stepButton isEnabled description: 'Step button must disable while simulation is running'.

	playPauseButton performAction.
	self deny: simulationGui session isRunning description: 'Clicking Pause must stop simulation'.
	self assert: playPauseButton label equals: 'Play'.
	self assert: stepButton isEnabled description: 'Step button must re-enable after pausing'
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

{ #category : 'tests' }
OPSimulationGUITest >> testVisualHooksAndAutomaticHighlightCleanupOnResetReloadAndClose [

	| entityModel entityController entityShape originalColor visualCountAfterLoad |
	entityModel := OPTestEntityModel new.
	entityModel instVarNamed: #uuid put: UUID new.
	entityController := diagramController showInDiagramModel: entityModel.
	entityShape := entityController roassalShape.
	originalColor := entityShape color.

	simulationGui := OPTestSimulationGUI diagramController: diagramController.
	visualCountAfterLoad := simulationGui visualUpdateCount.
	self assert: visualCountAfterLoad equals: 1.

	simulationGui highlighter highlightFillOfController: entityController color: Color green.
	self assert: entityShape color equals: Color green.
	simulationGui session reset.
	self assert: entityShape color equals: originalColor.
	self assert: simulationGui visualUpdateCount equals: visualCountAfterLoad + 1.

	simulationGui highlighter highlightFillOfController: entityController color: Color yellow.
	self assert: entityShape color equals: Color yellow.
	simulationGui reloadController.
	self assert: entityShape color equals: originalColor.
	self assert: simulationGui visualUpdateCount equals: visualCountAfterLoad + 2.

	simulationGui highlighter highlightFillOfController: entityController color: Color orange.
	self assert: entityShape color equals: Color orange.
	simulationGui close.
	self assert: entityShape color equals: originalColor
]
