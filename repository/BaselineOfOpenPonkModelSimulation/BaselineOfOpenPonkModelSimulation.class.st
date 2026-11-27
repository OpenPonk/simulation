"
Metacello baseline for the OpenPonk Model Simulation package, defining core dependencies for simulation capabilities.
"
Class {
	#name : 'BaselineOfOpenPonkModelSimulation',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfOpenPonkModelSimulation',
	#package : 'BaselineOfOpenPonkModelSimulation'
}

{ #category : 'baselines' }
BaselineOfOpenPonkModelSimulation >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ spec
				baseline: 'OpenPonkModel'
				with: [ spec repository: 'github://OpenPonk/openponk-model' ].
			spec package: 'OpenPonk-ModelSimulation' with: [ spec requires: #('OpenPonkModel') ].
			spec package: 'OpenPonk-ModelSimulation-Tests' with: [ spec requires: #('OpenPonk-ModelSimulation') ].
			spec group: 'default' with: #('OpenPonk-ModelSimulation' 'OpenPonk-ModelSimulation-Tests') ]
]
