"
Coordinates transient Roassal token-movement animations and temporary edge/actor accents along diagram polylines during simulation steps. Supports multi-phase sequential playback, delay-adaptive duration scaling, lossless cleanup on completion or cancellation, and background-thread completion waiting without blocking the UI process.
"
Class {
	#name : 'OPSimulationAnimator',
	#superclass : 'Object',
	#instVars : [
		'diagramController',
		'highlighter',
		'isEnabled',
		'activeAnimation',
		'activeOverlayShapes',
		'highlightedEdgeModels',
		'highlightedActorModels',
		'completionSemaphore',
		'liveAnimationChecker',
		'pendingCompletionBlock'
	],
	#category : 'OpenPonk-Simulation-Simulation',
	#package : 'OpenPonk-Simulation',
	#tag : 'Simulation'
}

{ #category : 'instance creation' }
OPSimulationAnimator class >> on: aDiagramController highlighter: aHighlighter [

	^ self new
		  diagramController: aDiagramController;
		  highlighter: aHighlighter;
		  yourself
]

{ #category : 'accessing' }
OPSimulationAnimator >> activeAnimation [

	^ activeAnimation
]

{ #category : 'private' }
OPSimulationAnimator >> actorFillColor [

	^ Color lightOrange lighter
]

{ #category : 'animating' }
OPSimulationAnimator >> animateTransfers: aCollection delay: aDelayMilliseconds isPlaying: isPlaying [

	self
		animateTransfers: aCollection
		delay: aDelayMilliseconds
		isPlaying: isPlaying
		onCompleted: nil
]

{ #category : 'animating' }
OPSimulationAnimator >> animateTransfers: aCollection delay: aDelayMilliseconds isPlaying: isPlaying onCompleted: aCompletionBlock [

	| canvas entries |
	self completeImmediately.
	(isEnabled and: [ aCollection isNotEmpty ]) ifFalse: [
			aCompletionBlock ifNotNil: [ aCompletionBlock value ].
			^ self ].
	canvas := self canvas.
	(liveAnimationChecker value: canvas) ifFalse: [
			aCompletionBlock ifNotNil: [ aCompletionBlock value ].
			^ self ].
	entries := self buildRenderableEntriesFor: aCollection.
	entries ifEmpty: [
			aCompletionBlock ifNotNil: [ aCompletionBlock value ].
			^ self ].
	pendingCompletionBlock := aCompletionBlock.
	self
		startSequenceFor: entries
		delay: aDelayMilliseconds
		isPlaying: isPlaying
		onCanvas: canvas
]

{ #category : 'private' }
OPSimulationAnimator >> beginPhaseEntries: phaseEntries onCanvas: aCanvas [

	phaseEntries do: [ :entry |
			| transfer points dot label |
			transfer := entry at: #transfer.
			points := entry at: #points.
			dot := self newTokenShapeFor: transfer.
			dot translateTo: points first.
			aCanvas add: dot.
			activeOverlayShapes add: dot.
			entry at: #dot put: dot.
			transfer amount > 1 ifTrue: [
					label := self newAmountLabelFor: transfer.
					label translateTo: points first + (8 @ -8).
					aCanvas add: label.
					activeOverlayShapes add: label.
					entry at: #label put: label ].
			highlighter highlightStrokeOfModel: transfer edgeModel color: (self edgeAccentColorFor: transfer) width: 3.
			highlightedEdgeModels add: transfer edgeModel ]
]

{ #category : 'private' }
OPSimulationAnimator >> buildPhaseAnimationFor: phaseEntries duration: aDurationMilliseconds onCanvas: aCanvas [

	| phaseAnimation |
	phaseAnimation := RSTransitionAnimation new
		                  canvas: aCanvas;
		                  duration: aDurationMilliseconds milliSeconds;
		                  from: 0.0;
		                  to: 1.0;
		                  yourself.
	phaseAnimation when: RSAnimationStartEvent do: [ self beginPhaseEntries: phaseEntries onCanvas: aCanvas ] for: self.
	phaseAnimation onStepDo: [ :progress | self updatePhaseEntries: phaseEntries atProgress: progress ].
	phaseAnimation when: RSAnimationEndEvent do: [ self endPhaseEntries: phaseEntries ] for: self.
	^ phaseAnimation
]

{ #category : 'private' }
OPSimulationAnimator >> buildRenderableEntriesFor: aCollection [

	| entries |
	entries := OrderedCollection new.
	aCollection do: [ :eachTransfer |
			(self polylinePointsForTransfer: eachTransfer) ifNotNil: [ :points |
					entries add: (Dictionary newFrom: {
								 (#transfer -> eachTransfer).
								 (#points -> points) }) ] ].
	^ entries
]

{ #category : 'private' }
OPSimulationAnimator >> buildSequenceAnimationFor: entries phases: phases phaseDuration: aPhaseDurationMs canvas: aCanvas [

	| sequenceAnimation |
	sequenceAnimation := RSSequentialAnimation new.
	sequenceAnimation addAll: (phases collect: [ :eachPhase |
				 | phaseEntries |
				 phaseEntries := entries select: [ :entry | (entry at: #transfer) phase = eachPhase ].
				 self buildPhaseAnimationFor: phaseEntries duration: aPhaseDurationMs onCanvas: aCanvas ]).
	sequenceAnimation when: RSAnimationEndEvent do: [ self finishAnimation: sequenceAnimation ] for: self.
	^ sequenceAnimation
]

{ #category : 'animating' }
OPSimulationAnimator >> cancel [

	pendingCompletionBlock := nil.
	self stopActiveAnimationAndSignal
]

{ #category : 'private' }
OPSimulationAnimator >> canvas [

	^ diagramController ifNotNil: [ :controller | controller canvas ]
]

{ #category : 'private' }
OPSimulationAnimator >> cleanupOverlaysAndHighlights [

	activeOverlayShapes copy do: [ :eachShape | eachShape remove ].
	activeOverlayShapes removeAll.
	highlightedEdgeModels copy do: [ :eachEdge | highlighter restoreStrokeOfModel: eachEdge ].
	highlightedActorModels copy do: [ :eachActor | highlighter restoreFillOfModel: eachActor ].
	highlightedEdgeModels removeAll.
	highlightedActorModels removeAll.
	self canvas signalUpdate
]

{ #category : 'animating' }
OPSimulationAnimator >> completeImmediately [

	| completionToRun |
	completionToRun := pendingCompletionBlock.
	pendingCompletionBlock := nil.
	self stopActiveAnimationAndSignal.
	completionToRun ifNotNil: [ completionToRun value ]
]

{ #category : 'accessing' }
OPSimulationAnimator >> diagramController [

	^ diagramController
]

{ #category : 'accessing' }
OPSimulationAnimator >> diagramController: aDiagramController [

	diagramController := aDiagramController
]

{ #category : 'animating' }
OPSimulationAnimator >> durationForDelay: aDelayMilliseconds isPlaying: isPlaying [

	isPlaying ifFalse: [ ^ 420 ].
	^ ((aDelayMilliseconds * 0.65) rounded min: 500) max: 120
]

{ #category : 'animating' }
OPSimulationAnimator >> durationForDelay: aDelayMilliseconds isPlaying: isPlaying phaseCount: aPhaseCount [

	| singlePhaseDuration maxPlayDuration |
	singlePhaseDuration := self durationForDelay: aDelayMilliseconds isPlaying: isPlaying.
	aPhaseCount <= 1 ifTrue: [ ^ singlePhaseDuration ].
	isPlaying ifFalse: [ ^ (singlePhaseDuration * 1.5) rounded ].
	maxPlayDuration := (aDelayMilliseconds * 0.85) rounded max: 180.
	^ (singlePhaseDuration * 1.5) rounded min: maxPlayDuration
]

{ #category : 'private' }
OPSimulationAnimator >> edgeAccentColorFor: aTransfer [

	aTransfer kind == #reset ifTrue: [ ^ Color fromHexString: 'D9534F' ].
	^ Color fromHexString: 'E67E22'
]

{ #category : 'private' }
OPSimulationAnimator >> endPhaseEntries: phaseEntries [

	phaseEntries do: [ :entry |
			| transfer |
			transfer := entry at: #transfer.
			entry at: #dot ifPresent: [ :dot |
					dot remove.
					activeOverlayShapes remove: dot ifAbsent: [ ] ].
			entry at: #label ifPresent: [ :label |
					label remove.
					activeOverlayShapes remove: label ifAbsent: [ ] ].
			highlighter restoreStrokeOfModel: transfer edgeModel.
			highlightedEdgeModels remove: transfer edgeModel ifAbsent: [ ] ]
]

{ #category : 'private' }
OPSimulationAnimator >> finishAnimation: aSequenceAnimation [

	| semaphoreToSignal completionToRun |
	activeAnimation == aSequenceAnimation ifFalse: [ ^ self ].
	activeAnimation := nil.
	self cleanupOverlaysAndHighlights.
	completionToRun := pendingCompletionBlock.
	pendingCompletionBlock := nil.
	completionToRun ifNotNil: [ completionToRun value ].
	semaphoreToSignal := completionSemaphore.
	completionSemaphore := nil.
	semaphoreToSignal ifNotNil: [ semaphoreToSignal signal ]
]

{ #category : 'private' }
OPSimulationAnimator >> highlightActorsFor: entries [

	entries do: [ :entry |
			(entry at: #transfer) actorModel ifNotNil: [ :actorModel |
					highlighter highlightFillOfModel: actorModel color: self actorFillColor.
					highlightedActorModels add: actorModel ] ]
]

{ #category : 'accessing' }
OPSimulationAnimator >> highlighter [

	^ highlighter
]

{ #category : 'accessing' }
OPSimulationAnimator >> highlighter: aHighlighter [

	highlighter := aHighlighter
]

{ #category : 'initialization' }
OPSimulationAnimator >> initialize [

	super initialize.
	isEnabled := true.
	activeOverlayShapes := OrderedCollection new.
	highlightedEdgeModels := IdentitySet new.
	highlightedActorModels := IdentitySet new.
	liveAnimationChecker := [ :aCanvas |
	                        aCanvas isNotNil and: [
		                        aCanvas morph isNotNil and: [ aCanvas morph isInWorld and: [ aCanvas morph visible ] ] ] ]
]

{ #category : 'accessing' }
OPSimulationAnimator >> isEnabled [

	^ isEnabled
]

{ #category : 'accessing' }
OPSimulationAnimator >> isEnabled: aBoolean [

	isEnabled := aBoolean.
	isEnabled ifFalse: [ self completeImmediately ]
]

{ #category : 'accessing' }
OPSimulationAnimator >> liveAnimationChecker: aBlock [

	liveAnimationChecker := aBlock
]

{ #category : 'private' }
OPSimulationAnimator >> newAmountLabelFor: aTransfer [

	^ RSLabel new
		  text: aTransfer amount asString;
		  color: (self edgeAccentColorFor: aTransfer);
		  fontSize: 9;
		  yourself
]

{ #category : 'private' }
OPSimulationAnimator >> newTokenShapeFor: aTransfer [

	^ RSCircle new
		  size: 12;
		  color: (self edgeAccentColorFor: aTransfer);
		  border: (RSBorder new
				   color: Color white;
				   width: 1.5;
				   yourself);
		  yourself
]

{ #category : 'private' }
OPSimulationAnimator >> pointAlongPolyline: points atDistance: aTargetDistance [

	| traversed |
	traversed := 0.0.
	1 to: points size - 1 do: [ :index |
			| startPoint endPoint segmentLength |
			startPoint := points at: index.
			endPoint := points at: index + 1.
			segmentLength := startPoint distanceTo: endPoint.
			(segmentLength > 0.0 and: [ traversed + segmentLength >= aTargetDistance ]) ifTrue: [
					| localFraction delta |
					localFraction := aTargetDistance - traversed / segmentLength.
					delta := endPoint - startPoint.
					^ startPoint + (delta * localFraction) ].
			traversed := traversed + segmentLength ].
	^ points last
]

{ #category : 'animating' }
OPSimulationAnimator >> pointAlongPolyline: points atProgress: aProgress [

	| clampedProgress totalLength |
	points isEmpty ifTrue: [ ^ 0 @ 0 ].
	points size = 1 ifTrue: [ ^ points first ].
	clampedProgress := (aProgress max: 0.0) min: 1.0.
	clampedProgress <= 0.0 ifTrue: [ ^ points first ].
	clampedProgress >= 1.0 ifTrue: [ ^ points last ].
	totalLength := self polylineLength: points.
	totalLength <= 0.0 ifTrue: [ ^ points first ].
	^ self pointAlongPolyline: points atDistance: totalLength * clampedProgress
]

{ #category : 'private' }
OPSimulationAnimator >> polylineLength: points [

	| totalLength |
	totalLength := 0.0.
	1 to: points size - 1 do: [ :index | totalLength := totalLength + ((points at: index) distanceTo: (points at: index + 1)) ].
	^ totalLength
]

{ #category : 'private' }
OPSimulationAnimator >> polylinePointsForTransfer: aTransfer [

	| edgeController edgeShape |
	aTransfer edgeModel ifNil: [ ^ nil ].
	edgeController := diagramController controllerForModel: aTransfer edgeModel ifNone: [ ^ nil ].
	edgeController diagramElement exists ifFalse: [ ^ nil ].
	edgeShape := edgeController roassalShape ifNil: [ ^ nil ].
	edgeShape isControlPointsLine ifTrue: [
			| controlPoints |
			controlPoints := edgeShape controlPoints.
			controlPoints size < 2 ifTrue: [ ^ nil ].
			^ controlPoints copy ].
	^ {
		  edgeShape startPoint.
		  edgeShape endPoint }
]

{ #category : 'private' }
OPSimulationAnimator >> startSequenceFor: entries delay: aDelayMilliseconds isPlaying: isPlaying onCanvas: aCanvas [

	| phases totalDuration phaseDuration sequenceAnimation |
	phases := (entries collect: [ :each | (each at: #transfer) phase ] as: Set) asSortedCollection.
	totalDuration := self durationForDelay: aDelayMilliseconds isPlaying: isPlaying phaseCount: phases size.
	phaseDuration := (totalDuration / phases size) rounded max: 80.
	completionSemaphore := Semaphore new.
	self highlightActorsFor: entries.
	sequenceAnimation := self
		                     buildSequenceAnimationFor: entries
		                     phases: phases
		                     phaseDuration: phaseDuration
		                     canvas: aCanvas.
	activeAnimation := sequenceAnimation.
	aCanvas addAnimation: sequenceAnimation.
	aCanvas morph ifNotNil: [ :morph | morph startStepping ]
]

{ #category : 'private' }
OPSimulationAnimator >> stopActiveAnimationAndSignal [

	| animationToStop semaphoreToSignal |
	animationToStop := activeAnimation.
	activeAnimation := nil.
	animationToStop ifNotNil: [
			animationToStop stop.
			self canvas animations remove: animationToStop ifAbsent: [ ] ].
	self cleanupOverlaysAndHighlights.
	semaphoreToSignal := completionSemaphore.
	completionSemaphore := nil.
	semaphoreToSignal ifNotNil: [ semaphoreToSignal signal ]
]

{ #category : 'private' }
OPSimulationAnimator >> updatePhaseEntries: phaseEntries atProgress: aProgress [

	phaseEntries do: [ :entry |
			| position |
			position := self pointAlongPolyline: (entry at: #points) atProgress: aProgress.
			entry at: #dot ifPresent: [ :dot | dot translateTo: position ].
			entry at: #label ifPresent: [ :label | label translateTo: position + (8 @ -8) ] ]
]

{ #category : 'animating' }
OPSimulationAnimator >> waitForCompletion [

	| semaphoreToWait |
	semaphoreToWait := completionSemaphore.
	semaphoreToWait ifNil: [ ^ self ].
	semaphoreToWait wait
]
