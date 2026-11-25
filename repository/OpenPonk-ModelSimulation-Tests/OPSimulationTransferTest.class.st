"
Verifies value semantics and defaults of simulation transfer records and stepped event payloads.
"
Class {
	#name : 'OPSimulationTransferTest',
	#superclass : 'TestCase',
	#category : 'OpenPonk-ModelSimulation-Tests-Events',
	#package : 'OpenPonk-ModelSimulation-Tests',
	#tag : 'Events'
}

{ #category : 'tests' }
OPSimulationTransferTest >> testDefaultValuesAndFactoryMethods [

	| defaultTransfer fullTransfer identicalCopy differentCopy steppedEvent |
	defaultTransfer := OPSimulationTransfer source: #source edge: #edge target: #target.
	self assert: defaultTransfer sourceModel identicalTo: #source.
	self assert: defaultTransfer edgeModel identicalTo: #edge.
	self assert: defaultTransfer targetModel identicalTo: #target.
	self assert: defaultTransfer actorModel identicalTo: nil.
	self assert: defaultTransfer amount equals: 1.
	self assert: defaultTransfer phase equals: 1.
	self assert: defaultTransfer kind identicalTo: #token.

	fullTransfer := (OPSimulationTransfer source: #place edge: #arc target: #transition)
		                actorModel: #transition;
		                amount: 3;
		                phase: 2;
		                kind: #reset;
		                yourself.
	identicalCopy := (OPSimulationTransfer source: #place edge: #arc target: #transition)
		                 actorModel: #transition;
		                 amount: 3;
		                 phase: 2;
		                 kind: #reset;
		                 yourself.
	differentCopy := (OPSimulationTransfer source: #place edge: #arc target: #transition)
		                 actorModel: #transition;
		                 amount: 1;
		                 phase: 2;
		                 kind: #reset;
		                 yourself.
	self assert: fullTransfer actorModel identicalTo: #transition.
	self assert: fullTransfer amount equals: 3.
	self assert: fullTransfer phase equals: 2.
	self assert: fullTransfer kind identicalTo: #reset.
	self assert: fullTransfer equals: fullTransfer.
	self assert: fullTransfer equals: identicalCopy.
	self assert: fullTransfer hash equals: identicalCopy hash.
	self deny: fullTransfer equals: differentCopy.
	self deny: fullTransfer equals: #notATransfer.

	self assertEmpty: (OPSimulatorStepped simulator: #sim) transfers.
	steppedEvent := OPSimulatorStepped simulator: #sim transfers: { fullTransfer }.
	self assert: steppedEvent simulator identicalTo: #sim.
	self assert: steppedEvent transfers equals: { fullTransfer }
]
