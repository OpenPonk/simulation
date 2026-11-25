"
Verifies polyline path sampling, multi-phase token animation lifecycle, delay-adaptive durations, overlay cleanup, and headless bypass behavior of OPSimulationAnimator.
"
Class {
	#name : 'OPSimulationAnimatorTest',
	#superclass : 'TestCase',
	#instVars : [
		'rootModel',
		'firstElement',
		'secondElement',
		'thirdElement',
		'firstEdge',
		'secondEdge',
		'diagramController',
		'highlighter',
		'animator'
	],
	#category : 'OpenPonk-Simulation-Tests-Simulation',
	#package : 'OpenPonk-Simulation-Tests',
	#tag : 'Simulation'
}

{ #category : 'running' }
OPSimulationAnimatorTest >> setUp [

	super setUp.
	OPPluginRegistry setDefault: (OPPluginRegistry new
			 add: OPTestPlugin new;
			 yourself).
	self
		setUpModel;
		setUpDiagramController.
	highlighter := OPSimulationHighlighter on: diagramController.
	highlighter uiDispatcher: [ :aBlock | aBlock value ].
	animator := OPSimulationAnimator on: diagramController highlighter: highlighter.
	animator liveAnimationChecker: [ :canvas | canvas isNotNil ]
]

{ #category : 'running' }
OPSimulationAnimatorTest >> setUpDiagramController [

	| project diagram projectController plugin |
	project := OPProject named: 'Animator Test'.
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
OPSimulationAnimatorTest >> setUpModel [

	rootModel := OPTestContainerModel new.
	rootModel instVarNamed: #uuid put: UUID new.
	firstElement := OPTestEntityModel new.
	firstElement instVarNamed: #uuid put: UUID new.
	secondElement := OPTestEntityModel new.
	secondElement instVarNamed: #uuid put: UUID new.
	thirdElement := OPTestEntityModel new.
	thirdElement instVarNamed: #uuid put: UUID new.
	firstEdge := OPTestRelationModel new
		             source: firstElement;
		             target: secondElement;
		             yourself.
	firstEdge instVarNamed: #uuid put: UUID new.
	secondEdge := OPTestRelationModel new
		              source: secondElement;
		              target: thirdElement;
		              yourself.
	secondEdge instVarNamed: #uuid put: UUID new.
	rootModel
		add: firstElement;
		add: secondElement;
		add: thirdElement;
		add: firstEdge;
		add: secondEdge
]

{ #category : 'running' }
OPSimulationAnimatorTest >> tearDown [

	animator ifNotNil: [ animator cancel ].
	highlighter ifNotNil: [ highlighter clearAll ].
	OPPluginRegistry resetDefault.
	animator := nil.
	highlighter := nil.
	diagramController := nil.
	secondEdge := nil.
	firstEdge := nil.
	thirdElement := nil.
	secondElement := nil.
	firstElement := nil.
	rootModel := nil.
	super tearDown
]

{ #category : 'tests' }
OPSimulationAnimatorTest >> testCancelRemovesOverlaysRestoresHighlightsAndUnblocksWaiter [

	| firstController secondController edgeController edgeShape originalColor originalWidth canvas shapesBefore waiterDone transfer |
	firstController := diagramController showInDiagramModel: firstElement.
	secondController := diagramController showInDiagramModel: secondElement.
	edgeController := diagramController showInDiagramModel: firstEdge.
	firstController roassalShape translateTo: 0 @ 0.
	secondController roassalShape translateTo: 100 @ 0.
	edgeShape := edgeController roassalShape.
	originalColor := edgeShape color.
	originalWidth := edgeShape border width.
	canvas := diagramController canvas.
	shapesBefore := canvas shapes size.

	transfer := (OPSimulationTransfer source: firstElement edge: firstEdge target: secondElement)
		            actorModel: secondElement;
		            amount: 2;
		            phase: 1;
		            yourself.
	animator animateTransfers: { transfer } delay: 1000 isPlaying: true.
	animator activeAnimation refresh.
	self assert: canvas shapes size > shapesBefore description: 'Active animation must add transient token overlay shapes to canvas'.

	waiterDone := Semaphore new.
	[
		animator waitForCompletion.
		waiterDone signal ] fork.

	animator cancel.
	self deny: (waiterDone waitTimeoutSeconds: 2) description: 'Canceling animation must unblock completion waiter'.
	self assert: canvas shapes size equals: shapesBefore.
	self assert: edgeShape color equals: originalColor.
	self assert: edgeShape border width equals: originalWidth.
	self assertEmpty: canvas animations
]

{ #category : 'tests' }
OPSimulationAnimatorTest >> testDefaultLiveAnimationCheckerSkipsHeadlessCanvasAndEmptyOrNilEdgeTransfers [

	| defaultAnimator completedCount nilEdgeTransfer |
	defaultAnimator := OPSimulationAnimator on: diagramController highlighter: highlighter.
	diagramController showInDiagramModel: firstElement.
	diagramController showInDiagramModel: secondElement.
	diagramController showInDiagramModel: firstEdge.
	completedCount := 0.

	defaultAnimator
		animateTransfers: { (OPSimulationTransfer source: firstElement edge: firstEdge target: secondElement) }
		delay: 1000
		isPlaying: true
		onCompleted: [ completedCount := completedCount + 1 ].
	self assert: defaultAnimator activeAnimation identicalTo: nil.
	self assert: completedCount equals: 1.

	animator
		animateTransfers: #(  )
		delay: 1000
		isPlaying: true
		onCompleted: [ completedCount := completedCount + 1 ].
	self assert: completedCount equals: 2.

	nilEdgeTransfer := OPSimulationTransfer source: firstElement edge: nil target: secondElement.
	animator
		animateTransfers: { nilEdgeTransfer }
		delay: 1000
		isPlaying: true
		onCompleted: [ completedCount := completedCount + 1 ].
	self assert: animator activeAnimation identicalTo: nil.
	self assert: completedCount equals: 3
]

{ #category : 'tests' }
OPSimulationAnimatorTest >> testDeferredCompletionRunsAfterAnimationEndsOrOnCompleteImmediatelyNotOnCancel [

	| firstController secondController completedCount transfer sequenceAnimation phaseAnim |
	firstController := diagramController showInDiagramModel: firstElement.
	secondController := diagramController showInDiagramModel: secondElement.
	diagramController showInDiagramModel: firstEdge.
	firstController roassalShape translateTo: 0 @ 0.
	secondController roassalShape translateTo: 100 @ 0.
	transfer := OPSimulationTransfer source: firstElement edge: firstEdge target: secondElement.

	completedCount := 0.
	animator
		animateTransfers: { transfer }
		delay: 1000
		isPlaying: true
		onCompleted: [ completedCount := completedCount + 1 ].
	self assert: completedCount equals: 0.

	sequenceAnimation := animator activeAnimation.
	phaseAnim := sequenceAnimation animations first.
	phaseAnim start.
	phaseAnim refresh.
	phaseAnim stepWithNumber: 1.
	phaseAnim remove.
	sequenceAnimation remove.
	self assert: completedCount equals: 1.

	animator
		animateTransfers: { transfer }
		delay: 1000
		isPlaying: true
		onCompleted: [ completedCount := completedCount + 1 ].
	self assert: completedCount equals: 1.
	animator completeImmediately.
	self assert: completedCount equals: 2.

	animator
		animateTransfers: { transfer }
		delay: 1000
		isPlaying: true
		onCompleted: [ completedCount := completedCount + 1 ].
	animator cancel.
	self assert: completedCount equals: 2.

	animator liveAnimationChecker: [ :canvas | false ].
	animator
		animateTransfers: { transfer }
		delay: 1000
		isPlaying: true
		onCompleted: [ completedCount := completedCount + 1 ].
	self assert: completedCount equals: 3
]

{ #category : 'tests' }
OPSimulationAnimatorTest >> testDisabledHeadlessAndHiddenTransfersSkipLiveAnimationWithoutBlocking [

	| edgeController canvas shapesBefore hiddenTransfer renderedTransfer |
	diagramController showInDiagramModel: firstElement.
	diagramController showInDiagramModel: secondElement.
	edgeController := diagramController controllerForModel: firstEdge ifNone: [ diagramController showInDiagramModel: firstEdge ].
	canvas := diagramController canvas.
	shapesBefore := canvas shapes size.
	hiddenTransfer := OPSimulationTransfer source: secondElement edge: secondEdge target: thirdElement.
	renderedTransfer := OPSimulationTransfer source: firstElement edge: firstEdge target: secondElement.

	animator animateTransfers: { hiddenTransfer } delay: 1000 isPlaying: true.
	self assertEmpty: canvas animations.
	self assert: canvas shapes size equals: shapesBefore.

	animator isEnabled: false.
	animator animateTransfers: { renderedTransfer } delay: 1000 isPlaying: true.
	self assertEmpty: canvas animations.
	self assert: canvas shapes size equals: shapesBefore.

	animator
		isEnabled: true;
		liveAnimationChecker: [ :aCanvas | false ].
	animator animateTransfers: { renderedTransfer } delay: 1000 isPlaying: true.
	self assertEmpty: canvas animations.
	self assert: canvas shapes size equals: shapesBefore.
	animator waitForCompletion.

	edgeController removeRender.
	shapesBefore := canvas shapes size.
	animator liveAnimationChecker: [ :aCanvas | aCanvas isNotNil ].
	animator animateTransfers: { renderedTransfer } delay: 1000 isPlaying: true.
	self assertEmpty: canvas animations.
	self assert: canvas shapes size equals: shapesBefore
]

{ #category : 'tests' }
OPSimulationAnimatorTest >> testDurationScalingForPlayAndManualStep [

	self assert: (animator durationForDelay: 250 isPlaying: true) equals: 163.
	self assert: (animator durationForDelay: 500 isPlaying: true) equals: 325.
	self assert: (animator durationForDelay: 1000 isPlaying: true) equals: 500.
	self assert: (animator durationForDelay: 5000 isPlaying: true) equals: 500.
	self assert: (animator durationForDelay: 100 isPlaying: true) equals: 120.
	self assert: (animator durationForDelay: 5000 isPlaying: false) equals: 420.
	self assert: (animator durationForDelay: 250 isPlaying: false) equals: 420.

	self assert: (animator durationForDelay: 1000 isPlaying: true phaseCount: 1) equals: 500.
	self assert: (animator durationForDelay: 1000 isPlaying: true phaseCount: 2) equals: 750.
	self assert: (animator durationForDelay: 5000 isPlaying: true phaseCount: 2) equals: 750.
	self assert: (animator durationForDelay: 500 isPlaying: true phaseCount: 2) equals: 425.
	self assert: (animator durationForDelay: 250 isPlaying: true phaseCount: 2) equals: 213.
	self assert: (animator durationForDelay: 1000 isPlaying: false phaseCount: 2) equals: 630
]

{ #category : 'tests' }
OPSimulationAnimatorTest >> testPointAlongPolylineInterpolatesByArcLengthAcrossBends [

	| points degeneratePoints |
	points := {
		          (0 @ 0).
		          (0 @ 0).
		          (100 @ 0).
		          (100 @ 100) }.
	self assert: (animator pointAlongPolyline: points atProgress: 0) equals: 0 @ 0.
	self assert: (animator pointAlongPolyline: points atProgress: 0.25) equals: 50 @ 0.
	self assert: (animator pointAlongPolyline: points atProgress: 0.5) equals: 100 @ 0.
	self assert: (animator pointAlongPolyline: points atProgress: 0.75) equals: 100 @ 50.
	self assert: (animator pointAlongPolyline: points atProgress: 1) equals: 100 @ 100.

	self assert: (animator pointAlongPolyline: #(  ) atProgress: 0.5) equals: 0 @ 0.
	self assert: (animator pointAlongPolyline: { (12 @ 34) } atProgress: 0.5) equals: 12 @ 34.
	degeneratePoints := {
		                    (5 @ 5).
		                    (5 @ 5) }.
	self assert: (animator pointAlongPolyline: degeneratePoints atProgress: 0.5) equals: 5 @ 5.
	self assert: (animator pointAlongPolyline: points atDistance: 250) equals: 100 @ 100
]

{ #category : 'tests' }
OPSimulationAnimatorTest >> testPolylineControlPointsAndStaleAnimationFinishAreHandledSafely [

	| firstController secondController edgeController polyline transfer sequenceAnimation |
	firstController := diagramController showInDiagramModel: firstElement.
	secondController := diagramController showInDiagramModel: secondElement.
	edgeController := diagramController showInDiagramModel: firstEdge.
	polyline := OPRSPolyline new
		            controlPoints: {
				            (0 @ 0).
				            (50 @ 0).
				            (50 @ 50) };
		            yourself.
	edgeController diagramElement instVarNamed: #roassalShape put: polyline.
	transfer := OPSimulationTransfer source: firstElement edge: firstEdge target: secondElement.

	self assert: (animator polylinePointsForTransfer: transfer) equals: {
			(0 @ 0).
			(50 @ 0).
			(50 @ 50) }.

	polyline controlPoints: { (0 @ 0) }.
	self assert: (animator polylinePointsForTransfer: transfer) identicalTo: nil.

	polyline controlPoints: {
			(0 @ 0).
			(100 @ 0) }.
	animator animateTransfers: { transfer } delay: 1000 isPlaying: true.
	sequenceAnimation := animator activeAnimation.
	animator cancel.
	animator finishAnimation: sequenceAnimation.
	self assert: animator activeAnimation identicalTo: nil
]

{ #category : 'tests' }
OPSimulationAnimatorTest >> testResetTransferUsesDistinctAccentColorAndAccessorsReportCollaborators [

	| firstController secondController edgeController edgeShape resetTransfer labelShape |
	self assert: animator diagramController identicalTo: diagramController.
	self assert: animator highlighter identicalTo: highlighter.
	self assert: animator isEnabled description: 'Animator must start enabled by default'.

	firstController := diagramController showInDiagramModel: firstElement.
	secondController := diagramController showInDiagramModel: secondElement.
	edgeController := diagramController showInDiagramModel: firstEdge.
	firstController roassalShape translateTo: 0 @ 0.
	secondController roassalShape translateTo: 100 @ 0.
	edgeShape := edgeController roassalShape.

	resetTransfer := (OPSimulationTransfer source: firstElement edge: firstEdge target: secondElement)
		                 amount: 2;
		                 kind: #reset;
		                 yourself.
	animator animateTransfers: { resetTransfer } delay: 1000 isPlaying: true.
	animator activeAnimation refresh.
	self assert: edgeShape color equals: (Color fromHexString: 'D9534F').
	labelShape := diagramController canvas shapes detect: [ :each | (each isKindOf: RSLabel) and: [ each text = '2' ] ].
	self assert: labelShape color equals: (Color fromHexString: 'D9534F').
	animator cancel
]

{ #category : 'tests' }
OPSimulationAnimatorTest >> testTwoPhaseAnimationHighlightsEdgesAndActorCleansUpOnCompletionAndSignalsWaiter [

	| firstController secondController thirdController firstEdgeController secondEdgeController firstEdgeShape secondEdgeShape actorShape originalActorFill originalActorBorder canvas shapesBefore phase1Transfer phase2Transfer sequenceAnimation phase1Anim phase2Anim waiterDone labelShape |
	firstController := diagramController showInDiagramModel: firstElement.
	secondController := diagramController showInDiagramModel: secondElement.
	thirdController := diagramController showInDiagramModel: thirdElement.
	firstEdgeController := diagramController showInDiagramModel: firstEdge.
	secondEdgeController := diagramController showInDiagramModel: secondEdge.
	firstController roassalShape translateTo: 0 @ 0.
	secondController roassalShape translateTo: 100 @ 0.
	thirdController roassalShape translateTo: 200 @ 0.
	firstEdgeShape := firstEdgeController roassalShape.
	secondEdgeShape := secondEdgeController roassalShape.
	actorShape := secondController roassalShape.
	originalActorFill := actorShape color.
	highlighter highlightStrokeOfModel: secondElement color: Color green darker width: 2.
	originalActorBorder := actorShape borderColor.
	canvas := diagramController canvas.
	shapesBefore := canvas shapes size.

	phase1Transfer := (OPSimulationTransfer source: firstElement edge: firstEdge target: secondElement)
		                  actorModel: secondElement;
		                  amount: 3;
		                  phase: 1;
		                  yourself.
	phase2Transfer := (OPSimulationTransfer source: secondElement edge: secondEdge target: thirdElement)
		                  actorModel: secondElement;
		                  amount: 1;
		                  phase: 2;
		                  yourself.

	animator
		animateTransfers: {
				phase1Transfer.
				phase2Transfer }
		delay: 1000
		isPlaying: true.
	sequenceAnimation := animator activeAnimation.
	self assert: sequenceAnimation class identicalTo: RSSequentialAnimation.
	self assert: sequenceAnimation animations size equals: 2.
	self assert: actorShape color equals: Color lightOrange lighter.

	waiterDone := Semaphore new.
	[
		animator waitForCompletion.
		waiterDone signal ] fork.

	phase1Anim := sequenceAnimation animations first.
	phase2Anim := sequenceAnimation animations second.
	phase1Anim start.
	phase1Anim refresh.
	self assert: firstEdgeShape border width equals: 3.
	self assert: secondEdgeShape border width equals: 1.
	self assert: canvas shapes size equals: shapesBefore + 2.
	labelShape := canvas shapes detect: [ :each | (each isKindOf: RSLabel) and: [ each text = '3' ] ].
	self assert: labelShape color equals: (Color fromHexString: 'E67E22').
	self assert: (waiterDone waitTimeoutMilliseconds: 40) description: 'Completion waiter must stay blocked while animation runs'.

	phase1Anim stepWithNumber: 1.
	phase1Anim remove.
	self assert: firstEdgeShape border width equals: 1.

	phase2Anim start.
	phase2Anim refresh.
	self assert: secondEdgeShape border width equals: 3.
	self assert: canvas shapes size equals: shapesBefore + 1.

	phase2Anim stepWithNumber: 1.
	phase2Anim remove.
	sequenceAnimation remove.

	self deny: (waiterDone waitTimeoutSeconds: 2) description: 'Finishing sequence animation must unblock completion waiter'.
	self assert: canvas shapes size equals: shapesBefore.
	self assert: firstEdgeShape border width equals: 1.
	self assert: secondEdgeShape border width equals: 1.
	self assert: actorShape color equals: originalActorFill.
	self assert: actorShape borderColor equals: originalActorBorder.
	self assert: actorShape border width equals: 2
]
