"
Spec2 presenter arranging simulation action buttons in a single vertical column with an optional step-delay selector below. Manages live Play/Pause toggling and disables step buttons while automatic playback is running.
"
Class {
	#name : 'OPSimulationControlsGUI',
	#superclass : 'SpPresenter',
	#instVars : [
		'buttons',
		'playPauseButton',
		'playPauseConfiguration',
		'stepButtons',
		'showsDelayControl',
		'delayLabel',
		'delayDropList',
		'onDelayChangedBlock',
		'showsAnimationControl',
		'animateCheckBox',
		'onAnimationToggledBlock'
	],
	#category : 'OpenPonk-Simulation-Simulation',
	#package : 'OpenPonk-Simulation',
	#tag : 'Simulation'
}

{ #category : 'accessing' }
OPSimulationControlsGUI >> animateCheckBox [

	^ animateCheckBox
]

{ #category : 'accessing' }
OPSimulationControlsGUI >> buttons [

	^ buttons
]

{ #category : 'accessing' }
OPSimulationControlsGUI >> buttons: aCollection [

	buttons := aCollection asOrderedCollection.
	self refreshLayout
]

{ #category : 'updating' }
OPSimulationControlsGUI >> clearTrackedButtons [

	playPauseButton := nil.
	playPauseConfiguration := nil.
	stepButtons removeAll
]

{ #category : 'accessing' }
OPSimulationControlsGUI >> defaultDelayOptions [

	^ {
		  ('0.25 s' -> 250).
		  ('0.5 s' -> 500).
		  ('1 s' -> 1000).
		  ('2 s' -> 2000).
		  ('5 s' -> 5000) }
]

{ #category : 'accessing' }
OPSimulationControlsGUI >> delayDropList [

	^ delayDropList
]

{ #category : 'accessing' }
OPSimulationControlsGUI >> delayOptions: aCollectionOfAssociations [

	| currentDelay |
	currentDelay := self selectedDelay ifNil: [ 1000 ].
	delayDropList items: aCollectionOfAssociations.
	self selectDelay: currentDelay
]

{ #category : 'initialization' }
OPSimulationControlsGUI >> initializePresenters [

	super initializePresenters.
	buttons := OrderedCollection new.
	stepButtons := OrderedCollection new.
	showsDelayControl := true.
	showsAnimationControl := true.
	delayLabel := self newLabel
		              label: 'Step delay:';
		              yourself.
	delayDropList := self newDropList.
	delayDropList
		display: [ :eachOption | eachOption key ];
		items: self defaultDelayOptions;
		whenSelectedItemChangedDo: [ :selectedOption |
			(selectedOption isNotNil and: [ onDelayChangedBlock isNotNil ]) ifTrue: [ onDelayChangedBlock value: selectedOption value ] ].
	animateCheckBox := self newCheckBox
		                   label: 'Animate steps';
		                   state: true;
		                   whenChangedDo: [ :isChecked | onAnimationToggledBlock ifNotNil: [ :callback | callback value: isChecked ] ];
		                   yourself.
	self
		selectDelay: 1000;
		refreshLayout
]

{ #category : 'accessing' }
OPSimulationControlsGUI >> isAnimationEnabled [

	^ animateCheckBox state
]

{ #category : 'accessing' }
OPSimulationControlsGUI >> isAnimationEnabled: aBoolean [

	animateCheckBox state: aBoolean
]

{ #category : 'accessing' }
OPSimulationControlsGUI >> onAnimationToggled: aBlock [

	onAnimationToggledBlock := aBlock
]

{ #category : 'accessing' }
OPSimulationControlsGUI >> onDelayChanged: aBlock [

	onDelayChangedBlock := aBlock
]

{ #category : 'accessing' }
OPSimulationControlsGUI >> preferredHeight [

	| rowCount |
	rowCount := (buttons size max: 1) + (self showsDelayControl
		             ifTrue: [ 1 ]
		             ifFalse: [ 0 ]) + (self showsAnimationControl
		             ifTrue: [ 1 ]
		             ifFalse: [ 0 ]).
	^ rowCount * (self class buttonHeight + 4) + 16
]

{ #category : 'accessing' }
OPSimulationControlsGUI >> preferredWidth [

	^ 210
]

{ #category : 'layout' }
OPSimulationControlsGUI >> refreshLayout [

	| boxLayout |
	boxLayout := SpBoxLayout newTopToBottom
		             spacing: 4;
		             borderWidth: 6;
		             yourself.
	buttons do: [ :eachButton | boxLayout add: eachButton height: self class buttonHeight ].
	self showsDelayControl ifTrue: [
			boxLayout
				add: (SpBoxLayout newLeftToRight
						 spacing: 6;
						 add: delayLabel expand: false;
						 add: delayDropList;
						 yourself)
				height: self class buttonHeight ].
	self showsAnimationControl ifTrue: [ boxLayout add: animateCheckBox height: self class buttonHeight ].
	self layout: boxLayout
]

{ #category : 'updating' }
OPSimulationControlsGUI >> registerPlayPauseButton: aButton configuration: aDictionary [

	playPauseButton := aButton.
	playPauseConfiguration := aDictionary.
	self updatePlayPauseButtonForRunning: false
]

{ #category : 'updating' }
OPSimulationControlsGUI >> registerStepButton: aButton [

	stepButtons add: aButton
]

{ #category : 'accessing' }
OPSimulationControlsGUI >> selectDelay: aMilliseconds [

	delayDropList items
		detect: [ :eachOption | eachOption value = aMilliseconds ]
		ifFound: [ :matchingOption | delayDropList selectItem: matchingOption ]
]

{ #category : 'accessing' }
OPSimulationControlsGUI >> selectedDelay [

	^ delayDropList selectedItem ifNotNil: [ :selectedOption | selectedOption value ]
]

{ #category : 'accessing' }
OPSimulationControlsGUI >> showsAnimationControl [

	^ showsAnimationControl
]

{ #category : 'accessing' }
OPSimulationControlsGUI >> showsAnimationControl: aBoolean [

	showsAnimationControl := aBoolean.
	self refreshLayout
]

{ #category : 'accessing' }
OPSimulationControlsGUI >> showsDelayControl [

	^ showsDelayControl
]

{ #category : 'accessing' }
OPSimulationControlsGUI >> showsDelayControl: aBoolean [

	showsDelayControl := aBoolean.
	self refreshLayout
]

{ #category : 'updating' }
OPSimulationControlsGUI >> updatePlayPauseButtonForRunning: isRunning [

	playPauseButton ifNil: [ ^ self ].
	isRunning
		ifTrue: [
				playPauseButton
					label: (playPauseConfiguration at: #pauseLabel);
					iconName: (playPauseConfiguration at: #pauseIcon);
					help: (playPauseConfiguration at: #pauseHelp) ]
		ifFalse: [
				playPauseButton
					label: (playPauseConfiguration at: #playLabel);
					iconName: (playPauseConfiguration at: #playIcon);
					help: (playPauseConfiguration at: #playHelp) ]
]

{ #category : 'updating' }
OPSimulationControlsGUI >> updateRunningState: isRunning [

	self updatePlayPauseButtonForRunning: isRunning.
	stepButtons do: [ :eachButton | eachButton enabled: isRunning not ]
]
