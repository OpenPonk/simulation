"
Concrete test subclass of OPSimulationGUI with configurable button count for headless simulation GUI tests.
"
Class {
	#name : 'OPTestSimulationGUI',
	#superclass : 'OPSimulationGUI',
	#instVars : [
		'extraButtonsCount'
	],
	#category : 'OpenPonk-Simulation-Tests-Simulation',
	#package : 'OpenPonk-Simulation-Tests',
	#tag : 'Simulation'
}

{ #category : 'private - hooks' }
OPTestSimulationGUI >> buttonItems [

	| items |
	items := super buttonItems.
	self extraButtonsCount timesRepeat: [
			items add: (self newButton
					 label: 'Extra';
					 yourself) ].
	^ items
]

{ #category : 'accessing' }
OPTestSimulationGUI >> buttons [

	^ buttons
]

{ #category : 'accessing' }
OPTestSimulationGUI >> extraButtonsCount [

	^ extraButtonsCount ifNil: [ 0 ]
]

{ #category : 'accessing' }
OPTestSimulationGUI >> extraButtonsCount: anInteger [

	extraButtonsCount := anInteger
]

{ #category : 'initialization' }
OPTestSimulationGUI >> initialize [

	super initialize.
	extraButtonsCount := 0
]

{ #category : 'private - hooks' }
OPTestSimulationGUI >> simulatorClass [

	^ OPTestSimulationDiagramSimulator
]
