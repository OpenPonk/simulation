"
Concrete subclass of OPDiagramSimulator used strictly for testing class mapping and steppability within the simulation framework.
"
Class {
	#name : 'OPDummySubclassOfOPDiagramSimulator',
	#superclass : 'OPDiagramSimulator',
	#category : 'OpenPonk-ModelSimulation-Tests-Simulators',
	#package : 'OpenPonk-ModelSimulation-Tests',
	#tag : 'Simulators'
}

{ #category : 'initialization' }
OPDummySubclassOfOPDiagramSimulator class >> initialClassMapping [
	^ super initialClassMapping
		at: OPDummyOPElement put: OPDummyOPElementSimulator;
		at: OPDummyOPEdge put: OPDummyOPEdgeSimulator;
		yourself
]

{ #category : 'accessing' }
OPDummySubclassOfOPDiagramSimulator >> steppable: aBoolean [
	self elementsDo: [ :each | each steppable: aBoolean ]
]
