"
Concrete test subclass of OPSimulationGUI with configurable button count for headless simulation GUI tests.
"
Class {
	#name : 'OPTestSimulationGUI',
	#superclass : 'OPSimulationGUI',
	#instVars : [
		'extraButtonsCount',
		'supportsSavingStateFlag',
		'hasConfigurationFlag',
		'showsDelayControlFlag',
		'visualUpdateCount',
		'actionEvents',
		'customButtonsBlock'
	],
	#category : 'OpenPonk-Simulation-Tests-Simulation',
	#package : 'OpenPonk-Simulation-Tests',
	#tag : 'Simulation'
}

{ #category : 'accessing' }
OPTestSimulationGUI >> actionEvents [

	^ actionEvents
]

{ #category : 'configuration' }
OPTestSimulationGUI >> buildConfigurationPresenter [

	self hasConfiguration ifFalse: [ ^ nil ].
	^ OPTestSimulationConfigurationGUI on: self diagramSimulator
]

{ #category : 'private - hooks' }
OPTestSimulationGUI >> buttonItems [

	| items |
	customButtonsBlock ifNotNil: [ :aBlock | ^ aBlock value: self ].
	items := super buttonItems.
	self extraButtonsCount timesRepeat: [
			items add: (self
					 newButtonLabeled: 'Extra'
					 iconName: nil
					 help: 'Extra action'
					 action: [ ]) ].
	^ items
]

{ #category : 'accessing' }
OPTestSimulationGUI >> customButtonsBlock: aBlock [

	customButtonsBlock := aBlock
]

{ #category : 'accessing' }
OPTestSimulationGUI >> extraButtonsCount [

	^ extraButtonsCount ifNil: [ 0 ]
]

{ #category : 'accessing' }
OPTestSimulationGUI >> extraButtonsCount: anInteger [

	extraButtonsCount := anInteger
]

{ #category : 'private - hooks' }
OPTestSimulationGUI >> handleSimulatorAction: anActionEvent [

	actionEvents add: anActionEvent
]

{ #category : 'testing' }
OPTestSimulationGUI >> hasConfiguration [

	^ hasConfigurationFlag ifNil: [ false ]
]

{ #category : 'accessing' }
OPTestSimulationGUI >> hasConfigurationFlag: aBoolean [

	hasConfigurationFlag := aBoolean
]

{ #category : 'initialization' }
OPTestSimulationGUI >> initialize [

	super initialize.
	extraButtonsCount := 0.
	supportsSavingStateFlag := false.
	hasConfigurationFlag := false.
	showsDelayControlFlag := true.
	visualUpdateCount := 0.
	actionEvents := OrderedCollection new
]

{ #category : 'testing' }
OPTestSimulationGUI >> showsDelayControl [

	^ showsDelayControlFlag ifNil: [ true ]
]

{ #category : 'accessing' }
OPTestSimulationGUI >> showsDelayControlFlag: aBoolean [

	showsDelayControlFlag := aBoolean
]

{ #category : 'private - hooks' }
OPTestSimulationGUI >> simulatorClass [

	^ OPTestSimulationDiagramSimulator
]

{ #category : 'testing' }
OPTestSimulationGUI >> supportsSavingState [

	^ supportsSavingStateFlag ifNil: [ false ]
]

{ #category : 'accessing' }
OPTestSimulationGUI >> supportsSavingStateFlag: aBoolean [

	supportsSavingStateFlag := aBoolean
]

{ #category : 'private - hooks' }
OPTestSimulationGUI >> updateSimulationVisuals [

	visualUpdateCount := visualUpdateCount + 1
]

{ #category : 'accessing' }
OPTestSimulationGUI >> visualUpdateCount [

	^ visualUpdateCount
]
