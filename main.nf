#!/usr/bin/env nextflow
/*
                              (╯°□°)╯︵ ┻━┻

========================================================================================
                            Workflow for smRNA seq
                        Built for a collaborator using an HPC
========================================================================================
                  https://github.com/alemenze/hpc-smrna
*/

nextflow.enable.dsl = 2

def helpMessage(){
    log.info"""

    Usage:

        nextflow run alemenze/hpc-smrna \



    Mandatory:
        -profile                    Currently available for docker (local) singularity (HPC local), slurm (HPC multi node)
    Optional:   
        --outdir                    Directory for output directories/files. Defaults to './results' 

    Slurm Controller:
        --node_partition            Specify the node partition in use for slurm executor. Defaults to 'main' 
    """
}

// Show help message
if (params.help) {
    helpMessage()
    exit 0
}
////////////////////////////////////////////////////
/* --            Initiate Channel              -- */
////////////////////////////////////////////////////
if (params.samplesheet) {file(params.samplesheet, checkIfExists: true)} else { exit 1, 'Samplesheet file not specified!'}

Channel
    .fromPath(params.samplesheet)
    .splitCsv(header:true)
    .map{ row -> tuple(row.sample_id, file(row.fastq_r1),file(row.fastq_r2)) }
    .set { reads }

// Check optional parameters
if (!params.mirtrace_species){
    exit 1, "Reference species for miRTrace is not defined."
}
// Genome options
bt_index_from_species = params.genome ? params.genomes[ params.genome ].bowtie ?: false : false
bt_index              = params.bt_indices ?: bt_index_from_species
mirtrace_species_from_species = params.genome ? params.genomes[ params.genome ].mirtrace_species ?: false : false
mirtrace_species = params.mirtrace_species ?: mirtrace_species_from_species
fasta_from_species = params.genome ? params.genomes[ params.genome ].fasta ?: false : false
fasta = params.fasta ?: fasta_from_species
mirna_gtf_from_species = params.mirtrace_species ? "https://mirbase.org/ftp/CURRENT/genomes/${params.mirtrace_species}.gff3" : false
mirna_gtf = params.mirna_gtf ? params.mirna_gtf : mirna_gtf_from_species
if (params.mature) { reference_mature = file(params.mature, checkIfExists: true) } else { exit 1, "Mature miRNA fasta file not found: ${params.mature}" }
if (params.hairpin) { reference_hairpin = file(params.hairpin, checkIfExists: true) } else { exit 1, "Hairpin miRNA fasta file not found: ${params.hairpin}" }

////////////////////////////////////////////////////
/* --              IMPORT MODULES              -- */
////////////////////////////////////////////////////
include { Mirtrace } from './modules/tools/mirtrace'
include { Qc_trim } from './modules/subworkflows/qc_trim'
include { Quant } from './modules/subworkflows/mirquant'
include { Genome_quant } from './modules/subworkflows/genome_quant'
include { Mirdeep2 } from './modules/subworkflows/mirdeep2'

////////////////////////////////////////////////////
/* --           RUN MAIN WORKFLOW              -- */
////////////////////////////////////////////////////

workflow {

    reads
        .map { it[1], it[2] }
        .flatten()
        .set { full_reads }

    Mirtrace ( 
        full_reads.collect() 
    )

    Qc_trim (
        reads
    )

    Quant (
        reference_mature,
        reference_hairpin,
        mirna_gtf,
        Qc_trim.out.umi_reads
    )

    fasta_ch = fasta
    Genome_quant (
        fasta,
        bt_index,
        Quant.out.unmapped
    )

    Mirdeep2 (
        Qc_trim.out.umi_reads,
        Genome_quant.out.fasta,
        Genome_quant.out.indices,
        Quant.out.fasta_hairpin,
        Quant.out.fasta_mature
    )
}