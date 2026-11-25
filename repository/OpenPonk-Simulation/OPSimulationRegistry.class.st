"
Registry mapping open diagram controllers to their active simulation windows. Prevents duplicate simulation windows for the same diagram controller without scanning all instances, and prunes closed windows automatically on lookup.
"
Class {
	#name : 'OPSimulationRegistry',
	#superclass : 'Object',
	#instVars : [
		'openGuis'
	],
	#classInstVars : [
		'default'
	],
	#category : 'OpenPonk-Simulation-Simulation',
	#package : 'OpenPonk-Simulation',
	#tag : 'Simulation'
}

{ #category : 'accessing' }
OPSimulationRegistry class >> default [

	^ default ifNil: [ default := self new ]
]

{ #category : 'initialization' }
OPSimulationRegistry class >> resetDefault [

	default := nil
]

{ #category : 'accessing' }
OPSimulationRegistry class >> setDefault: aRegistry [

	default := aRegistry
]

{ #category : 'managing' }
OPSimulationRegistry >> closeAll [

	| activeGuis |
	activeGuis := openGuis values copy.
	openGuis removeAll.
	activeGuis select: [ :eachGui | eachGui isOpen ] thenDo: [ :eachGui | eachGui close ]
]

{ #category : 'accessing' }
OPSimulationRegistry >> guiFor: aDiagramController ifAbsent: aBlock [

	| existingGui |
	existingGui := openGuis at: aDiagramController ifAbsent: [ ^ aBlock value ].
	existingGui isOpen ifTrue: [ ^ existingGui ].
	openGuis removeKey: aDiagramController ifAbsent: [ ].
	^ aBlock value
]

{ #category : 'accessing' }
OPSimulationRegistry >> guiFor: aDiagramController ifAbsentPut: aBlock [

	^ self guiFor: aDiagramController ifAbsent: [
			  | newGui |
			  newGui := aBlock value.
			  self register: newGui for: aDiagramController.
			  newGui ]
]

{ #category : 'initialization' }
OPSimulationRegistry >> initialize [

	super initialize.
	openGuis := IdentityDictionary new
]

{ #category : 'accessing' }
OPSimulationRegistry >> openGuis [

	self pruneClosedGuis.
	^ openGuis values asArray
]

{ #category : 'managing' }
OPSimulationRegistry >> pruneClosedGuis [

	openGuis keys copy
		reject: [ :eachController | (openGuis at: eachController) isOpen ]
		thenDo: [ :eachController | openGuis removeKey: eachController ifAbsent: [ ] ]
]

{ #category : 'managing' }
OPSimulationRegistry >> register: aSimulationGui for: aDiagramController [

	aDiagramController ifNil: [ ^ self ].
	openGuis at: aDiagramController put: aSimulationGui
]

{ #category : 'managing' }
OPSimulationRegistry >> unregister: aSimulationGui [

	openGuis keys copy
		select: [ :eachController | (openGuis at: eachController) == aSimulationGui ]
		thenDo: [ :eachController | openGuis removeKey: eachController ifAbsent: [ ] ]
]

{ #category : 'managing' }
OPSimulationRegistry >> unregisterController: aDiagramController [

	openGuis removeKey: aDiagramController ifAbsent: [ ]
]
