"
Please describe the package using the class comment of the included manifest class. The manifest class also includes other additional metadata for the package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : 'ManifestOpenPonkSimulation',
	#superclass : 'PackageManifest',
	#category : 'OpenPonk-Simulation-Manifest',
	#package : 'OpenPonk-Simulation',
	#tag : 'Manifest'
}

{ #category : 'code-critics' }
ManifestOpenPonkSimulation class >> ruleReShouldSendSuperInitializeAsFirstMessageV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGMethodDefinition #(#OPSimulationGUI #initialize #false)) #'2026-08-30T22:37:16.725+02:00') )
]
