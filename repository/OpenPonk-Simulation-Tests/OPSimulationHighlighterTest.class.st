"
Unit tests verifying fill, stroke, batch replacement, timed flash, and lossless restoration in OPSimulationHighlighter.
"
Class {
	#name : 'OPSimulationHighlighterTest',
	#superclass : 'TestCase',
	#instVars : [
		'rootModel',
		'firstElement',
		'secondElement',
		'relationElement',
		'diagramController',
		'highlighter'
	],
	#category : 'OpenPonk-Simulation-Tests-Simulation',
	#package : 'OpenPonk-Simulation-Tests',
	#tag : 'Simulation'
}

{ #category : 'running' }
OPSimulationHighlighterTest >> setUp [

	super setUp.
	OPPluginRegistry setDefault: (OPPluginRegistry new
			 add: OPTestPlugin new;
			 yourself).
	self
		setUpModel;
		setUpDiagramController.
	highlighter := OPSimulationHighlighter on: diagramController.
	highlighter uiDispatcher: [ :aBlock | aBlock value ]
]

{ #category : 'running' }
OPSimulationHighlighterTest >> setUpDiagramController [

	| project diagram projectController plugin |
	project := OPProject named: 'Highlighter Test'.
	project addModel: rootModel.
	diagram := OPOpenPonkDiagram forModelElement: rootModel.
	project addDiagram: diagram.
	projectController := OPProjectController forProject: project.
	plugin := OPPluginRegistry default plugins detect: [ :eachPlugin | eachPlugin isKindOf: OPTestPlugin ].
	diagramController := OPTestDiagramController new.
	projectController addDiagramController: diagramController.
	diagramController
		editor: (OPEditor on: plugin);
		canvasPresenter: OPHeadlessCanvasPresenter new;
		diagramElement: diagram;
		model: rootModel
]

{ #category : 'running' }
OPSimulationHighlighterTest >> setUpModel [

	rootModel := OPTestContainerModel new.
	rootModel instVarNamed: #uuid put: UUID new.
	firstElement := OPTestEntityModel new.
	firstElement instVarNamed: #uuid put: UUID new.
	secondElement := OPTestEntityModel new.
	secondElement instVarNamed: #uuid put: UUID new.
	relationElement := OPTestRelationModel new
		                   source: firstElement;
		                   target: secondElement;
		                   yourself.
	relationElement instVarNamed: #uuid put: UUID new.
	rootModel
		add: firstElement;
		add: secondElement;
		add: relationElement
]

{ #category : 'running' }
OPSimulationHighlighterTest >> tearDown [

	highlighter ifNotNil: [ highlighter clearAll ].
	OPPluginRegistry resetDefault.
	highlighter := nil.
	diagramController := nil.
	relationElement := nil.
	secondElement := nil.
	firstElement := nil.
	rootModel := nil.
	super tearDown
]

{ #category : 'tests' }
OPSimulationHighlighterTest >> testFillStrokeAndLineHighlightsPreserveCustomColorsAndRestoreOnClearAll [

	| firstController secondController relationController firstShape secondShape relationShape customFill |
	firstController := diagramController showInDiagramModel: firstElement.
	secondController := diagramController showInDiagramModel: secondElement.
	relationController := diagramController showInDiagramModel: relationElement.
	firstShape := firstController roassalShape.
	secondShape := secondController roassalShape.
	relationShape := relationController roassalShape.

	customFill := Color cyan.
	firstShape color: customFill.
	firstShape borderColor: Color blue.
	secondShape noBorder.
	relationShape color: Color darkGray.

	highlighter
		highlightFillOfModel: firstElement color: Color green;
		highlightStrokeOfModel: firstElement color: Color red;
		highlightStrokeOfModel: secondElement color: Color orange;
		highlightStrokeOfModel: relationElement color: Color green darker.

	self assert: firstShape color equals: Color green.
	self assert: firstShape borderColor equals: Color red.
	self assert: secondShape hasBorder description: 'Highlighting stroke on borderless shape must add temporary border'.
	self assert: secondShape borderColor equals: Color orange.
	self assert: relationShape color equals: Color green darker.

	highlighter clearAll.
	self assert: firstShape color equals: customFill.
	self assert: firstShape borderColor equals: Color blue.
	self deny: secondShape hasBorder description: 'Clearing highlight must restore noBorder on originally borderless shape'.
	self assert: relationShape color equals: Color darkGray
]

{ #category : 'tests' }
OPSimulationHighlighterTest >> testFlashFillCancelsPreviousTimerIgnoresStaleRestoreAndClearsOnClearAll [

	| firstController firstShape originalColor firstProcess secondProcess |
	firstController := diagramController showInDiagramModel: firstElement.
	firstShape := firstController roassalShape.
	originalColor := firstShape color.

	highlighter flashFillOfModel: firstElement color: Color lightOrange lighter duration: 5 seconds.
	firstProcess := (highlighter instVarNamed: #flashProcesses) at: firstController.
	self assert: firstShape color equals: Color lightOrange lighter.
	self deny: firstProcess isTerminated description: 'Flash timer process must be active'.

	highlighter flashFillOfModel: firstElement color: Color lightOrange lighter duration: 5 seconds.
	secondProcess := (highlighter instVarNamed: #flashProcesses) at: firstController.
	self assert: firstProcess isTerminated description: 'Re-flashing the same element must terminate prior timer'.
	self deny: secondProcess identicalTo: firstProcess.

	highlighter finishFlashRestoreFor: firstController process: firstProcess.
	self assert: firstShape color equals: Color lightOrange lighter.

	highlighter clearAll.
	self assert: secondProcess isTerminated description: 'clearAll must terminate active flash timers'.
	self assert: firstShape color equals: originalColor.
	self assertEmpty: (highlighter instVarNamed: #flashProcesses)
]

{ #category : 'tests' }
OPSimulationHighlighterTest >> testIgnoresHiddenAndUnrenderedElements [

	| firstController |
	highlighter
		highlightFillOfModel: firstElement color: Color green;
		highlightStrokeOfModel: firstElement color: Color red;
		flashFillOfModel: firstElement color: Color yellow duration: 1 second.
	self assertEmpty: (highlighter instVarNamed: #originalFillColors).
	self assertEmpty: (highlighter instVarNamed: #originalBorderStates).

	firstController := diagramController showInDiagramModel: firstElement.
	firstController removeRender.
	highlighter highlightFillOfModel: firstElement color: Color green.
	self assert: firstController roassalShape identicalTo: nil.
	self assertEmpty: (highlighter instVarNamed: #originalFillColors)
]

{ #category : 'tests' }
OPSimulationHighlighterTest >> testReplaceHighlightsDuringRestoresInactiveElementsOnly [

	| firstController secondController firstShape secondShape originalFirstColor originalSecondColor |
	firstController := diagramController showInDiagramModel: firstElement.
	secondController := diagramController showInDiagramModel: secondElement.
	firstShape := firstController roassalShape.
	secondShape := secondController roassalShape.
	originalFirstColor := firstShape color.
	originalSecondColor := secondShape color.

	highlighter replaceHighlightsDuring: [ highlighter highlightFillOfModel: firstElement color: Color green ].
	self assert: firstShape color equals: Color green.
	self assert: secondShape color equals: originalSecondColor.

	highlighter replaceHighlightsDuring: [ highlighter highlightFillOfModel: secondElement color: Color yellow ].
	self assert: firstShape color equals: originalFirstColor.
	self assert: secondShape color equals: Color yellow
]
