"
Test double element simulator recording step, saveState, and loadState invocations for simulation GUI tests.
"
Class {
	#name : 'OPTestSimulationElementSimulator',
	#superclass : 'OPElementSimulator',
	#instVars : [
		'stepCount',
		'saveStateCount',
		'loadStateCount'
	],
	#category : 'OpenPonk-Simulation-Tests-Simulation',
	#package : 'OpenPonk-Simulation-Tests',
	#tag : 'Simulation'
}

{ #category : 'initialization' }
OPTestSimulationElementSimulator >> initialize [

	super initialize.
	stepCount := 0.
	saveStateCount := 0.
	loadStateCount := 0
]

{ #category : 'testing' }
OPTestSimulationElementSimulator >> isSimulable [

	^ true
]

{ #category : 'testing' }
OPTestSimulationElementSimulator >> isSteppable [

	^ true
]

{ #category : 'actions' }
OPTestSimulationElementSimulator >> loadState [

	loadStateCount := loadStateCount + 1
]

{ #category : 'accessing' }
OPTestSimulationElementSimulator >> loadStateCount [

	^ loadStateCount
]

{ #category : 'actions' }
OPTestSimulationElementSimulator >> saveState [

	saveStateCount := saveStateCount + 1
]

{ #category : 'accessing' }
OPTestSimulationElementSimulator >> saveStateCount [

	^ saveStateCount
]

{ #category : 'actions' }
OPTestSimulationElementSimulator >> step [

	stepCount := stepCount + 1.
	super step
]

{ #category : 'accessing' }
OPTestSimulationElementSimulator >> stepCount [

	^ stepCount
]
