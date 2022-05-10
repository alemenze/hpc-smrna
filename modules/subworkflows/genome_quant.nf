include { Index_genome } from '../tools/bowtie_genome'
include { Bowtie_mirna_seq as Bowtie_map_genome } from '../tools/bowtie_map_mirna'
include { Bam_work as Bam_work_genome } from './bam_work'

workflow Genome_quant {
    take:
        fasta
        bt_index
        reads

    main:
        if (!bt_index){
            Index_genome ( fasta )
            bt_indices      = Index_genome.out.bt_indices
            fasta_formatted = Index_genome.out.fasta
        } else {
            bt_indices      = Channel.fromPath("${bt_index}**ebwt", checkIfExists: true).ifEmpty { exit 1, "Bowtie1 index directory not found: ${bt_index}" }
            fasta_formatted = fasta
        }

        if (bt_indices){
            Bowtime_map_genome (
                reads,
                bt_indices.collect(),
                "Genome"
            )
            Bam_work_genome (
                Bowtie_map_genome.out.bam,
                Channel.empty(),
                "Genome"
            )
        }


    emit:
        fasta = fasta.formatted
        indices = bt_indices
}