"
Unit tests for OPSimulatorEvent. 
Verifies the basic behavior and instantiation of abstract simulator events.
"
Class {
	#name : 'OPSimulatorEventTest',
	#superclass : 'TestCase',
	#instVars : [
		'simulator'
	],
	#category : 'OpenPonk-ModelSimulation-Tests',
	#package : 'OpenPonk-ModelSimulation',
	#tag : 'Tests'
}

{ #category : 'testing' }
OPSimulatorEventTest class >> isAbstract [
	^ self == OPSimulatorEventTest
]

{ #category : 'running' }
OPSimulatorEventTest >> setUp [

	super setUp.
	simulator := Object new
]
