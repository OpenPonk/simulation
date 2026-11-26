# OpenPonk: Simulation

[![Nightly](https://github.com/OpenPonk/simulation/actions/workflows/nightly.yml/badge.svg)](https://github.com/OpenPonk/simulation/actions/workflows/nightly.yml) [![Coverage Status](https://coveralls.io/repos/github/OpenPonk/simulation/badge.svg?branch=master)](https://coveralls.io/github/OpenPonk/simulation?branch=master)

Discrete-event and step-by-step simulation framework for [OpenPonk](https://openponk.org) models and diagrams. Used by [`borm-editor`](https://github.com/OpenPonk/borm-editor), [`BPMN`](https://github.com/OpenPonk/BPMN), and [`petrinets`](https://github.com/OpenPonk/petrinets).

## Installation

See [openponk.org/#direct-installation](https://openponk.org/#direct-installation) for the supported Pharo version.

```smalltalk
Metacello new
	baseline: 'OpenPonkSimulation';
	repository: 'github://OpenPonk/simulation';
	load.
```

For GUI-independent model simulation only, load `baseline: 'OpenPonkModelSimulation'`.

## Documentation

Part of the [OpenPonk](https://openponk.org) platform. For architecture, the repository catalog, and contributing guidelines, see [`OpenPonk/.github`](https://github.com/OpenPonk/.github/blob/main/profile/README.md).
