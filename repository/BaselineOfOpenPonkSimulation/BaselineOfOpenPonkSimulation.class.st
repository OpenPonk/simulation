"
Metacello baseline aggregating the loading configurations for OpenPonk simulation-related packages and plugins.
"
Class {
	#name : 'BaselineOfOpenPonkSimulation',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfOpenPonkSimulation',
	#package : 'BaselineOfOpenPonkSimulation'
}

{ #category : 'baselines' }
BaselineOfOpenPonkSimulation >> baseline: spec [

	<baseline>
	spec for: #common do: [
		spec
			baseline: 'OpenPonk'
			with: [ spec repository: 'github://openponk/openponk:v5.0.1' ].
		spec
			baseline: 'OpenPonkModelSimulation'
			with: [
			spec repository: 'github://openponk/simulation:v5.0.1' ].
		spec
			package: 'OpenPonk-Simulation'
			with: [ spec requires: #( 'OpenPonkModelSimulation' ) ].
		spec
			group: 'plugin' with: #( 'OpenPonk-Simulation' );
			group: 'default' with: #( 'OpenPonk' 'plugin' ) ]
]
