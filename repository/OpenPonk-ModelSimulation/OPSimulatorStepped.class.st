"
I'm event - simulator just finished a step
"
Class {
	#name : 'OPSimulatorStepped',
	#superclass : 'OPSimulatorStepEvent',
	#instVars : [
		'transfers'
	],
	#category : 'OpenPonk-ModelSimulation-Events',
	#package : 'OpenPonk-ModelSimulation',
	#tag : 'Events'
}

{ #category : 'instance creation' }
OPSimulatorStepped class >> simulator: aSimulator transfers: aCollection [

	^ (self simulator: aSimulator)
		  transfers: aCollection;
		  yourself
]

{ #category : 'accessing' }
OPSimulatorStepped >> transfers [

	^ transfers ifNil: [ #(  ) ]
]

{ #category : 'accessing' }
OPSimulatorStepped >> transfers: aCollection [

	transfers := aCollection asArray
]
