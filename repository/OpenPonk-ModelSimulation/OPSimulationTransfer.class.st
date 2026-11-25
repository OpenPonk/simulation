"
Immutable record describing a single causal token or message transfer observed during a simulation step. Captures source, edge, target, optional firing actor, transferred amount, execution phase, and transfer kind without referencing GUI layers.
"
Class {
	#name : 'OPSimulationTransfer',
	#superclass : 'Object',
	#instVars : [
		'sourceModel',
		'edgeModel',
		'targetModel',
		'actorModel',
		'amount',
		'phase',
		'kind'
	],
	#category : 'OpenPonk-ModelSimulation-Events',
	#package : 'OpenPonk-ModelSimulation',
	#tag : 'Events'
}

{ #category : 'instance creation' }
OPSimulationTransfer class >> source: aSourceModel edge: anEdgeModel target: aTargetModel [

	^ self new
		  sourceModel: aSourceModel;
		  edgeModel: anEdgeModel;
		  targetModel: aTargetModel;
		  yourself
]

{ #category : 'comparing' }
OPSimulationTransfer >> = anObject [

	self == anObject ifTrue: [ ^ true ].
	self class = anObject class ifFalse: [ ^ false ].
	^ sourceModel = anObject sourceModel and: [
			  edgeModel = anObject edgeModel and: [
					  targetModel = anObject targetModel and: [
						  actorModel = anObject actorModel and: [
							  amount = anObject amount and: [ phase = anObject phase and: [ kind = anObject kind ] ] ] ] ] ]
]

{ #category : 'accessing' }
OPSimulationTransfer >> actorModel [

	^ actorModel
]

{ #category : 'accessing' }
OPSimulationTransfer >> actorModel: anObject [

	actorModel := anObject
]

{ #category : 'accessing' }
OPSimulationTransfer >> amount [

	^ amount
]

{ #category : 'accessing' }
OPSimulationTransfer >> amount: anInteger [

	amount := anInteger
]

{ #category : 'accessing' }
OPSimulationTransfer >> edgeModel [

	^ edgeModel
]

{ #category : 'accessing' }
OPSimulationTransfer >> edgeModel: anObject [

	edgeModel := anObject
]

{ #category : 'comparing' }
OPSimulationTransfer >> hash [

	^ ((((sourceModel hash bitXor: edgeModel hash) bitXor: targetModel hash) bitXor: amount hash) bitXor: phase hash) bitXor:
		  kind hash
]

{ #category : 'initialization' }
OPSimulationTransfer >> initialize [

	super initialize.
	amount := 1.
	phase := 1.
	kind := #token
]

{ #category : 'accessing' }
OPSimulationTransfer >> kind [

	^ kind
]

{ #category : 'accessing' }
OPSimulationTransfer >> kind: aSymbol [

	kind := aSymbol
]

{ #category : 'accessing' }
OPSimulationTransfer >> phase [

	^ phase
]

{ #category : 'accessing' }
OPSimulationTransfer >> phase: anInteger [

	phase := anInteger
]

{ #category : 'accessing' }
OPSimulationTransfer >> sourceModel [

	^ sourceModel
]

{ #category : 'accessing' }
OPSimulationTransfer >> sourceModel: anObject [

	sourceModel := anObject
]

{ #category : 'accessing' }
OPSimulationTransfer >> targetModel [

	^ targetModel
]

{ #category : 'accessing' }
OPSimulationTransfer >> targetModel: anObject [

	targetModel := anObject
]
