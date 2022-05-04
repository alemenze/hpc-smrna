# smRNA pipeline for collaborators using an HPC
![GitHub last commit](https://img.shields.io/github/last-commit/alemenze/hpc-smrna)
[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A520.11.0--edge-23aa62.svg?labelColor=000000)](https://www.nextflow.io/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)
[![run with slurm](https://img.shields.io/badge/run%20with-slurm-ff4d4d.svg?labelColor=000000)](https://slurm.schedmd.com/)

## Description
This is a smRNA workflow with UMI collapsing built for a specific collaborator. 
*Draws heavily from the workflow described by [nf-core smrnaseq](https://nf-co.re/smrnaseq) and [nf-core/rnaseq](https://nf-co.re/rnaseq)*
*The NF-core versions are not compatible with this collaborator and had to be rebuilt*

## Metadata
Gots to make that metadata. Check the example!

## Example commands
```bash
nohup ~/nextflow -bg run alemenze/hpc-smrna -r main --samplesheet ./metadata_example.csv -profile slurm --genome GRCh38 > example_log.txt
```