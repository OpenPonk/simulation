"
Unit tests verifying vertical button layout, dynamic Play/Pause toggling, step-button disabling, delay selection, and preferred height calculation in OPSimulationControlsGUI.
"
Class {
	#name : 'OPSimulationControlsGUITest',
	#superclass : 'TestCase',
	#instVars : [
		'controlsGui'
	],
	#category : 'OpenPonk-Simulation-Tests-Simulation',
	#package : 'OpenPonk-Simulation-Tests',
	#tag : 'Simulation'
}

{ #category : 'running' }
OPSimulationControlsGUITest >> setUp [

	super setUp.
	controlsGui := OPSimulationControlsGUI new.
	controlsGui
		application: SpApplication defaultApplication;
		owner: nil
]

{ #category : 'running' }
OPSimulationControlsGUITest >> tearDown [

	controlsGui := nil.
	super tearDown
]

{ #category : 'tests' }
OPSimulationControlsGUITest >> testAccessorsAndUpdateRunningStateWithoutPlayPauseButton [

	| onlyStepButton |
	onlyStepButton := controlsGui newButton
		                  label: 'Step';
		                  yourself.
	controlsGui
		registerStepButton: onlyStepButton;
		buttons: { onlyStepButton }.

	self assert: controlsGui buttons size equals: 1.
	self assert: controlsGui delayDropList selectedItem value equals: 1000.

	controlsGui updateRunningState: true.
	self deny: onlyStepButton isEnabled description: 'Step button must disable even when no Play/Pause button is registered'.
	controlsGui updateRunningState: false.
	self assert: onlyStepButton isEnabled description: 'Step button must re-enable when stopped'
]

{ #category : 'tests' }
OPSimulationControlsGUITest >> testAnimationToggleDefaultsEnabledAndNotifiesCallback [

	| observedStates heightWithAnimation heightWithoutAnimation |
	observedStates := OrderedCollection new.
	controlsGui onAnimationToggled: [ :isEnabled | observedStates add: isEnabled ].

	self assert: controlsGui showsAnimationControl description: 'Animation toggle control must be shown by default'.
	self assert: controlsGui animateCheckBox label equals: 'Animate steps'.
	self assert: controlsGui isAnimationEnabled description: 'Animation must be enabled by default'.

	controlsGui isAnimationEnabled: false.
	self deny: controlsGui isAnimationEnabled description: 'Setting animation disabled must update checkbox state'.
	self deny: controlsGui animateCheckBox state description: 'Checkbox presenter state must mirror disabled state'.
	self assert: observedStates asArray equals: #( false ).

	heightWithAnimation := controlsGui preferredHeight.
	controlsGui showsAnimationControl: false.
	heightWithoutAnimation := controlsGui preferredHeight.
	self assert: heightWithoutAnimation < heightWithAnimation description: 'Hiding animation toggle must reduce preferred height'
]

{ #category : 'tests' }
OPSimulationControlsGUITest >> testDelayOptionsPreservesSelectionAndFallsBackToDefaultWhenUnselected [

	controlsGui selectDelay: 500.
	controlsGui delayOptions: {
			('0.5 s' -> 500).
			('1 s' -> 1000) }.
	self assert: controlsGui selectedDelay equals: 500.

	controlsGui delayOptions: #(  ).
	self assert: controlsGui selectedDelay identicalTo: nil.

	controlsGui delayOptions: {
			('0.5 s' -> 500).
			('1 s' -> 1000) }.
	self assert: controlsGui selectedDelay equals: 1000
]

{ #category : 'tests' }
OPSimulationControlsGUITest >> testDelaySelectionAndPreferredHeightScaling [

	| selectedDelays heightWithDelay heightWithoutDelay |
	selectedDelays := OrderedCollection new.
	controlsGui onDelayChanged: [ :milliseconds | selectedDelays add: milliseconds ].
	self assert: controlsGui selectedDelay equals: 1000.

	controlsGui selectDelay: 250.
	self assert: controlsGui selectedDelay equals: 250.
	self assert: selectedDelays last equals: 250.

	controlsGui buttons: {
			(controlsGui newButton
				 label: 'A';
				 yourself).
			(controlsGui newButton
				 label: 'B';
				 yourself).
			(controlsGui newButton
				 label: 'C';
				 yourself) }.
	heightWithDelay := controlsGui preferredHeight.

	controlsGui showsDelayControl: false.
	heightWithoutDelay := controlsGui preferredHeight.
	self assert: heightWithoutDelay < heightWithDelay description: 'Hiding delay control must reduce preferred height'
]

{ #category : 'tests' }
OPSimulationControlsGUITest >> testPlayPauseToggleAndStepButtonDisableWhileRunning [

	| playPauseButton stepButton |
	playPauseButton := controlsGui newButton.
	stepButton := controlsGui newButton
		              label: 'Step';
		              yourself.
	controlsGui
		registerPlayPauseButton: playPauseButton configuration: (Dictionary newFrom: {
						 (#playLabel -> 'Play').
						 (#pauseLabel -> 'Pause').
						 (#playIcon -> #smallPrintItIcon).
						 (#pauseIcon -> #testYellow).
						 (#playHelp -> 'Play simulation').
						 (#pauseHelp -> 'Pause simulation') });
		registerStepButton: stepButton;
		buttons: {
				playPauseButton.
				stepButton }.

	self assert: playPauseButton label equals: 'Play'.
	self assert: stepButton isEnabled description: 'Step button must start enabled'.

	controlsGui updateRunningState: true.
	self assert: playPauseButton label equals: 'Pause'.
	self assert: playPauseButton help equals: 'Pause simulation'.
	self deny: stepButton isEnabled description: 'Step button must be disabled while running'.

	controlsGui updateRunningState: false.
	self assert: playPauseButton label equals: 'Play'.
	self assert: playPauseButton help equals: 'Play simulation'.
	self assert: stepButton isEnabled description: 'Step button must re-enable after stopping'
]
