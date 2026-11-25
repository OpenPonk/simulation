"
Abstract Spec2 presenter for notation-specific simulation configuration embedded in the right scrollable sidebar of OPSimulationGUI. Holds the active diagram simulator, supports #on: initialization, renders an empty-state label when no options apply, and exposes #refreshFromSimulator for reloads and resets.
"
Class {
	#name : 'OPSimulationConfigurationGUI',
	#superclass : 'SpPresenter',
	#instVars : [
		'diagramSimulator',
		'emptyStateLabel'
	],
	#category : 'OpenPonk-Simulation-Simulation',
	#package : 'OpenPonk-Simulation',
	#tag : 'Simulation'
}

{ #category : 'testing' }
OPSimulationConfigurationGUI class >> isAbstract [

	^ self == OPSimulationConfigurationGUI
]

{ #category : 'layout' }
OPSimulationConfigurationGUI >> buildConfigurationLayout [

	^ self subclassResponsibility
]

{ #category : 'layout' }
OPSimulationConfigurationGUI >> defaultLayout [

	^ self hasConfigurableItems
		  ifTrue: [ self buildConfigurationLayout ]
		  ifFalse: [
				  SpBoxLayout newTopToBottom
					  borderWidth: 8;
					  add: emptyStateLabel expand: false;
					  yourself ]
]

{ #category : 'accessing' }
OPSimulationConfigurationGUI >> diagramSimulator [

	^ diagramSimulator
]

{ #category : 'accessing' }
OPSimulationConfigurationGUI >> diagramSimulator: aDiagramSimulator [

	diagramSimulator := aDiagramSimulator.
	self refreshFromSimulator
]

{ #category : 'accessing' }
OPSimulationConfigurationGUI >> emptyStateMessage [

	^ 'No configurable simulation options.'
]

{ #category : 'testing' }
OPSimulationConfigurationGUI >> hasConfigurableItems [

	^ false
]

{ #category : 'initialization' }
OPSimulationConfigurationGUI >> initializePresenters [

	super initializePresenters.
	emptyStateLabel := self newLabel
		                   label: self emptyStateMessage;
		                   yourself
]

{ #category : 'updating' }
OPSimulationConfigurationGUI >> refreshFromSimulator [
	"Subclasses may override to synchronize controls after simulator reload or reset."

	
]

{ #category : 'accessing - model' }
OPSimulationConfigurationGUI >> setModelBeforeInitialization: aDiagramSimulator [

	diagramSimulator := aDiagramSimulator
]
