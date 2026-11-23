"
Test double diagram simulator mapping OPModelObject elements to OPTestSimulationElementSimulator instances and counting state operations.
"
Class {
	#name : 'OPTestSimulationDiagramSimulator',
	#superclass : 'OPDiagramSimulator',
	#instVars : [
		'saveStateCount',
		'loadStateCount'
	],
	#category : 'OpenPonk-Simulation-Tests-Simulation',
	#package : 'OpenPonk-Simulation-Tests',
	#tag : 'Simulation'
}

{ #category : 'initialization' }
OPTestSimulationDiagramSimulator class >> initialClassMapping [

	^ super initialClassMapping
		  at: OPTestSimulationModel put: OPTestSimulationElementSimulator;
		  yourself
]

{ #category : 'initialization' }
OPTestSimulationDiagramSimulator >> initialize [

	super initialize.
	saveStateCount := 0.
	loadStateCount := 0
]

{ #category : 'actions' }
OPTestSimulationDiagramSimulator >> loadState [

	loadStateCount := loadStateCount + 1.
	super loadState
]

{ #category : 'accessing' }
OPTestSimulationDiagramSimulator >> loadStateCount [

	^ loadStateCount
]

{ #category : 'actions' }
OPTestSimulationDiagramSimulator >> saveState [

	saveStateCount := saveStateCount + 1.
	super saveState
]

{ #category : 'accessing' }
OPTestSimulationDiagramSimulator >> saveStateCount [

	^ saveStateCount
]
