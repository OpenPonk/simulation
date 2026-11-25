"
Manages transient visual highlights on rendered Roassal shapes during simulation without mutating persistent diagram element styles. Tracks original fill and border states per controller so highlights restore losslessly on step updates, reset, reload, or close, and supports cancellable timed flash animations.
"
Class {
	#name : 'OPSimulationHighlighter',
	#superclass : 'Object',
	#instVars : [
		'diagramController',
		'originalFillColors',
		'originalBorderStates',
		'flashProcesses',
		'activeBatchControllers',
		'uiDispatcher'
	],
	#category : 'OpenPonk-Simulation-Simulation',
	#package : 'OpenPonk-Simulation',
	#tag : 'Simulation'
}

{ #category : 'instance creation' }
OPSimulationHighlighter class >> on: aDiagramController [

	^ self new
		  diagramController: aDiagramController;
		  yourself
]

{ #category : 'highlighting' }
OPSimulationHighlighter >> clearAll [

	| controllersToRestore |
	flashProcesses values copy do: [ :eachProcess | eachProcess terminate ].
	flashProcesses removeAll.
	controllersToRestore := IdentitySet new.
	controllersToRestore
		addAll: originalFillColors keys;
		addAll: originalBorderStates keys.
	controllersToRestore do: [ :eachController | self restoreController: eachController ]
]

{ #category : 'accessing' }
OPSimulationHighlighter >> diagramController [

	^ diagramController
]

{ #category : 'accessing' }
OPSimulationHighlighter >> diagramController: aDiagramController [

	diagramController := aDiagramController
]

{ #category : 'private' }
OPSimulationHighlighter >> finishFlashRestoreFor: aController process: aProcess [

	(flashProcesses at: aController ifAbsent: [ nil ]) == aProcess ifFalse: [ ^ self ].
	self restoreController: aController
]

{ #category : 'highlighting' }
OPSimulationHighlighter >> flashFillOfController: aController color: aColor duration: aDuration [

	| shape |
	shape := self renderedShapeForController: aController ifAbsent: [ ^ self ].
	originalFillColors at: aController ifAbsentPut: [ shape color ].
	flashProcesses at: aController ifPresent: [ :existingProcess | existingProcess terminate ].
	shape color: aColor.
	shape signalUpdate.
	self scheduleFlashRestoreFor: aController duration: aDuration
]

{ #category : 'highlighting' }
OPSimulationHighlighter >> flashFillOfModel: aModel color: aColor duration: aDuration [

	self
		renderedControllerForModel: aModel
		ifPresent: [ :controller | self flashFillOfController: controller color: aColor duration: aDuration ]
]

{ #category : 'highlighting' }
OPSimulationHighlighter >> highlightFillOfController: aController color: aColor [

	| shape |
	shape := self renderedShapeForController: aController ifAbsent: [ ^ self ].
	self recordBatchController: aController.
	(flashProcesses removeKey: aController ifAbsent: [ nil ]) ifNotNil: [ :existingProcess | existingProcess terminate ].
	originalFillColors at: aController ifAbsentPut: [ shape color ].
	shape color: aColor.
	shape signalUpdate
]

{ #category : 'highlighting' }
OPSimulationHighlighter >> highlightFillOfModel: aModel color: aColor [

	self renderedControllerForModel: aModel ifPresent: [ :controller | self highlightFillOfController: controller color: aColor ]
]

{ #category : 'highlighting' }
OPSimulationHighlighter >> highlightStrokeOfController: aController color: aColor [

	self highlightStrokeOfController: aController color: aColor width: nil
]

{ #category : 'highlighting' }
OPSimulationHighlighter >> highlightStrokeOfController: aController color: aColor width: aWidthOrNil [

	| shape |
	shape := self renderedShapeForController: aController ifAbsent: [ ^ self ].
	self recordBatchController: aController.
	originalBorderStates at: aController ifAbsentPut: [ self snapshotBorderStateOf: shape ].
	shape hasBorder ifTrue: [ shape border: shape border copy ].
	shape isLine
		ifTrue: [
				shape color: aColor.
				aWidthOrNil ifNotNil: [ :lineWidth | shape width: lineWidth ] ]
		ifFalse: [
				shape borderColor: aColor.
				aWidthOrNil ifNotNil: [ :borderWidth | shape borderWidth: borderWidth ] ].
	shape signalUpdate
]

{ #category : 'highlighting' }
OPSimulationHighlighter >> highlightStrokeOfModel: aModel color: aColor [

	self renderedControllerForModel: aModel ifPresent: [ :controller | self highlightStrokeOfController: controller color: aColor ]
]

{ #category : 'highlighting' }
OPSimulationHighlighter >> highlightStrokeOfModel: aModel color: aColor width: aWidthOrNil [

	self
		renderedControllerForModel: aModel
		ifPresent: [ :controller | self highlightStrokeOfController: controller color: aColor width: aWidthOrNil ]
]

{ #category : 'initialization' }
OPSimulationHighlighter >> initialize [

	super initialize.
	originalFillColors := IdentityDictionary new.
	originalBorderStates := IdentityDictionary new.
	flashProcesses := IdentityDictionary new.
	uiDispatcher := [ :aBlock | UIManager default defer: aBlock ]
]

{ #category : 'private' }
OPSimulationHighlighter >> recordBatchController: aController [

	activeBatchControllers ifNotNil: [ :batch | batch add: aController ]
]

{ #category : 'private' }
OPSimulationHighlighter >> renderedControllerForModel: aModel ifPresent: aBlock [

	| controller |
	diagramController ifNil: [ ^ self ].
	controller := diagramController controllerForModel: aModel ifNone: [ ^ self ].
	controller diagramElement exists ifFalse: [ ^ self ].
	controller roassalShape ifNil: [ ^ self ].
	aBlock value: controller
]

{ #category : 'private' }
OPSimulationHighlighter >> renderedShapeForController: aController ifAbsent: aBlock [

	aController ifNil: [ ^ aBlock value ].
	aController diagramElement exists ifFalse: [ ^ aBlock value ].
	^ aController roassalShape ifNil: [ aBlock value ]
]

{ #category : 'highlighting' }
OPSimulationHighlighter >> replaceHighlightsDuring: aBlock [

	| previouslyHighlighted |
	previouslyHighlighted := IdentitySet new.
	previouslyHighlighted
		addAll: originalFillColors keys;
		addAll: originalBorderStates keys.
	activeBatchControllers := IdentitySet new.
	[ aBlock value ] ensure: [
			| touchedControllers |
			touchedControllers := activeBatchControllers.
			activeBatchControllers := nil.
			previouslyHighlighted
				reject: [ :eachController | touchedControllers includes: eachController ]
				thenDo: [ :eachController | self restoreController: eachController ] ]
]

{ #category : 'private' }
OPSimulationHighlighter >> restoreBorderOf: aShape for: aController [

	| originalBorderState |
	originalBorderState := originalBorderStates removeKey: aController ifAbsent: [ ^ false ].
	originalBorderState == #noBorder ifTrue: [
			aShape hasBorder ifFalse: [ ^ false ].
			aShape noBorder.
			^ true ].
	^ aShape isLine
		  ifTrue: [ self restoreLineStrokeOf: aShape color: originalBorderState first width: originalBorderState second ]
		  ifFalse: [ self restoreNodeBorderOf: aShape color: originalBorderState first width: originalBorderState second ]
]

{ #category : 'highlighting' }
OPSimulationHighlighter >> restoreController: aController [

	| shape fillChanged borderChanged |
	(flashProcesses removeKey: aController ifAbsent: [ nil ]) ifNotNil: [ :existingProcess | existingProcess terminate ].
	shape := self renderedShapeForController: aController ifAbsent: [
			         originalFillColors removeKey: aController ifAbsent: [ ].
			         originalBorderStates removeKey: aController ifAbsent: [ ].
			         ^ self ].
	fillChanged := self restoreFillOf: shape for: aController.
	borderChanged := self restoreBorderOf: shape for: aController.
	(fillChanged or: [ borderChanged ]) ifTrue: [ shape signalUpdate ]
]

{ #category : 'private' }
OPSimulationHighlighter >> restoreFillOf: aShape for: aController [

	| originalColor |
	originalColor := originalFillColors removeKey: aController ifAbsent: [ ^ false ].
	aShape color = originalColor ifTrue: [ ^ false ].
	aShape color: originalColor.
	^ true
]

{ #category : 'highlighting' }
OPSimulationHighlighter >> restoreFillOfController: aController [

	| shape |
	(flashProcesses removeKey: aController ifAbsent: [ nil ]) ifNotNil: [ :existingProcess | existingProcess terminate ].
	shape := self renderedShapeForController: aController ifAbsent: [
			         originalFillColors removeKey: aController ifAbsent: [ ].
			         ^ self ].
	(self restoreFillOf: shape for: aController) ifTrue: [ shape signalUpdate ]
]

{ #category : 'highlighting' }
OPSimulationHighlighter >> restoreFillOfModel: aModel [

	diagramController ifNil: [ ^ self ].
	diagramController controllerForModel: aModel ifFound: [ :controller | self restoreFillOfController: controller ] ifNone: [ ]
]

{ #category : 'private' }
OPSimulationHighlighter >> restoreLineStrokeOf: aShape color: anOriginalColor width: anOriginalWidth [

	| changed |
	changed := false.
	aShape color = anOriginalColor ifFalse: [
			aShape color: anOriginalColor.
			changed := true ].
	(aShape hasBorder not or: [ aShape border width ~= anOriginalWidth ]) ifTrue: [
			aShape width: anOriginalWidth.
			changed := true ].
	^ changed
]

{ #category : 'highlighting' }
OPSimulationHighlighter >> restoreModel: aModel [

	diagramController ifNil: [ ^ self ].
	diagramController controllerForModel: aModel ifFound: [ :controller | self restoreController: controller ] ifNone: [ ]
]

{ #category : 'private' }
OPSimulationHighlighter >> restoreNodeBorderOf: aShape color: anOriginalColor width: anOriginalWidth [

	| changed |
	changed := false.
	(aShape hasBorder and: [ aShape borderColor = anOriginalColor ]) ifFalse: [
			aShape borderColor: anOriginalColor.
			changed := true ].
	(aShape hasBorder and: [ aShape border width = anOriginalWidth ]) ifFalse: [
			aShape borderWidth: anOriginalWidth.
			changed := true ].
	^ changed
]

{ #category : 'highlighting' }
OPSimulationHighlighter >> restoreStrokeOfController: aController [

	| shape |
	shape := self renderedShapeForController: aController ifAbsent: [
			         originalBorderStates removeKey: aController ifAbsent: [ ].
			         ^ self ].
	(self restoreBorderOf: shape for: aController) ifTrue: [ shape signalUpdate ]
]

{ #category : 'highlighting' }
OPSimulationHighlighter >> restoreStrokeOfModel: aModel [

	diagramController ifNil: [ ^ self ].
	diagramController controllerForModel: aModel ifFound: [ :controller | self restoreStrokeOfController: controller ] ifNone: [ ]
]

{ #category : 'private' }
OPSimulationHighlighter >> scheduleFlashRestoreFor: aController duration: aDuration [

	| timerProcess |
	timerProcess := [
		                | currentProcess |
		                currentProcess := Processor activeProcess.
		                aDuration wait.
		                self uiDispatcher value: [ self finishFlashRestoreFor: aController process: currentProcess ] ] newProcess.
	flashProcesses at: aController put: timerProcess.
	timerProcess resume
]

{ #category : 'private' }
OPSimulationHighlighter >> snapshotBorderStateOf: aShape [

	aShape isLine ifTrue: [
			^ {
				  aShape color.
				  (aShape hasBorder
					   ifTrue: [ aShape border width ]
					   ifFalse: [ 1 ]) } ].
	^ aShape hasBorder
		  ifTrue: [
				  {
					  aShape borderColor.
					  aShape border width } ]
		  ifFalse: [ #noBorder ]
]

{ #category : 'accessing' }
OPSimulationHighlighter >> uiDispatcher [

	^ uiDispatcher
]

{ #category : 'accessing' }
OPSimulationHighlighter >> uiDispatcher: aBlock [

	uiDispatcher := aBlock
]
