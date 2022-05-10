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
            --samplesheet './example_samplesheet.csv'
            --genome GRCh37
            --mirtrace_species 'hsa'

    Mandatory:
        -profile                    Currently available for docker (local) singularity (HPC local), slurm (HPC multi node)
        --samplesheet               Path to an appropriate sample sheet listing the sample IDs and single read R1
        --genome                    Current genome to use. If you do not use iGenomes, then you have to provide the other genome files
        --mirtrace_species          What species from mirtrace should you use. Generally 'hsa' for human

    Optional:   
        --outdir                    Directory for output directories/files. Defaults to './results' 
        --three_prime_adapter       The 3' adapter to trim. Defaults to "TGGAATTCTCGGGTGCCAAGG"
        --umitools_extract_method   Method for UMITools to extract UMIs. Defaults to "string"
        --umitools_bc_pattern       For any custom barcode pattern. Defaults to "NNNNNN"
        --min_length                Minimum length to trim. Defaults to 17 for smRNA
        --max_length                Maximum length to trim. Defaults to 40 for smRNA
        --fasta                     If there is no iGenomes to use, specify a fasta file
        --mirna_gtf                 If there is no iGenomes to use, specify a gtf file for the miRNA
        --bt_indices                If there is no iGenomes to use, specify a bowtie index to use
        --mirtrace_protocol         Which mitrace protocol to use. Defaults to "illumina"
        --mature                    Mature miRNA database. Defaults to "https://mirbase.org/ftp/CURRENT/mature.fa.gz"
        --hairpin                   Hairpin miRNA database. Defaults to "https://mirbase.org/ftp/CURRENT/hairpin.fa.gz"

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
    .map{ row -> tuple(row.sample_id, file(row.fastq_r1)) }
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
        .map { it[1] }
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