"
Unit tests verifying registration, lookup, stale-window pruning, and bulk closing in OPSimulationRegistry.
"
Class {
	#name : 'OPSimulationRegistryTest',
	#superclass : 'TestCase',
	#instVars : [
		'registry'
	],
	#category : 'OpenPonk-Simulation-Tests-Simulation',
	#package : 'OpenPonk-Simulation-Tests',
	#tag : 'Simulation'
}

{ #category : 'running' }
OPSimulationRegistryTest >> setUp [

	super setUp.
	registry := OPSimulationRegistry new
]

{ #category : 'running' }
OPSimulationRegistryTest >> tearDown [

	registry ifNotNil: [ registry closeAll ].
	registry := nil.
	super tearDown
]

{ #category : 'tests' }
OPSimulationRegistryTest >> testDefaultSetAndResetDefault [

	| customRegistry previousDefault |
	previousDefault := OPSimulationRegistry default.
	customRegistry := OPSimulationRegistry new.
	[
		OPSimulationRegistry setDefault: customRegistry.
		self assert: OPSimulationRegistry default identicalTo: customRegistry.
		OPSimulationRegistry resetDefault.
		self deny: OPSimulationRegistry default identicalTo: customRegistry ] ensure: [
		OPSimulationRegistry setDefault: previousDefault ]
]

{ #category : 'tests' }
OPSimulationRegistryTest >> testRegisterLookupPruneClosedAndCloseAll [

	| controllerA controllerB openGuiA closedGuiA replacementGuiA openGuiB closeCalls |
	controllerA := Object new.
	controllerB := Object new.
	closeCalls := OrderedCollection new.
	openGuiA := Mock new.
	openGuiA stub isOpen willReturn: true.
	openGuiA stub close will: [ closeCalls add: #guiA ].

	self assert: (registry guiFor: controllerA ifAbsentPut: [ openGuiA ]) identicalTo: openGuiA.
	self assert: (registry guiFor: controllerA ifAbsentPut: [ self fail: 'Open GUI must be reused' ]) identicalTo: openGuiA.
	self assertCollection: registry openGuis hasSameElements: { openGuiA }.

	closedGuiA := Mock new.
	closedGuiA stub isOpen willReturn: false.
	registry register: closedGuiA for: controllerA.
	replacementGuiA := Mock new.
	replacementGuiA stub isOpen willReturn: true.
	replacementGuiA stub close will: [ closeCalls add: #replacementA ].
	self assert: (registry guiFor: controllerA ifAbsentPut: [ replacementGuiA ]) identicalTo: replacementGuiA.

	openGuiB := Mock new.
	openGuiB stub isOpen willReturn: true.
	openGuiB stub close will: [ closeCalls add: #guiB ].
	registry register: openGuiB for: controllerB.
	self assertCollection: registry openGuis hasSameElements: {
			replacementGuiA.
			openGuiB }.

	registry unregister: replacementGuiA.
	self assertCollection: registry openGuis hasSameElements: { openGuiB }.

	registry closeAll.
	self assertCollection: closeCalls hasSameElements: #( #guiB ).
	self assertEmpty: registry openGuis
]

{ #category : 'tests' }
OPSimulationRegistryTest >> testUnregisterControllerPruneClosedAndNilControllerGuard [

	| controllerA controllerB openGui closedGui |
	controllerA := Object new.
	controllerB := Object new.
	openGui := Mock new.
	openGui stub isOpen willReturn: true.
	openGui stub close willReturn: nil.
	closedGui := Mock new.
	closedGui stub isOpen willReturn: false.

	registry register: openGui for: nil.
	self assertEmpty: registry openGuis.

	registry
		register: openGui for: controllerA;
		register: closedGui for: controllerB.
	self assertCollection: registry openGuis hasSameElements: { openGui }.

	registry unregisterController: controllerA.
	self assertEmpty: registry openGuis.
	registry unregisterController: controllerA.
	self assertEmpty: registry openGuis.
	self assert: (registry guiFor: controllerA ifAbsent: [ #missing ]) identicalTo: #missing
]
