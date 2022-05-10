include { Parse_fasta_mirna as Parse_mature
            Parse_fasta_mirna as Parse_hairpin } from '../tools/parse_fasta_mirna'

include { Format_fasta_mirna as Format_mature
            Format_fasta_mirna as Format_hairpin } from '../tools/format_fasta_mirna'

include { Index_mirna as Index_mature
            Index_mirna as Index_hairpin } from '../tools/bowtie_mirna'
include { Bowtie_mirna_seq as Bowtie_map_mature
            Bowtie_mirna_seq as Bowtie_map_hairpin
            Bowtie_mirna_seq as Bowtie_mirna_seqcluster } from '../tools/bowtie_map_mirna'

include { Bam_work as Bam_work_mature
            Bam_work as Bam_work_hairpin
            Bam_work as Bam_work_seqcluster } from './bam_work'

include { Seqcluster_sequences } from '../tools/seqcluster_sequences'
include { Mirtop_quant } from '../tools/mirtop_quant'

workflow Quant {
    take: 
        mature
        hairpin
        gtf
        reads

    main:
        Parse_mature ( mature ).parsed_fasta.set { mirna_parsed }

        Format_mature ( mirna_parsed )

        Parse_hairpin ( hairpin ).parsed_fasta.set { hairpin_parsed }

        Format_hairpin ( hairpin_parsed )

        Index_mature ( Format_mature.out.formatted_fasta ).bt_indices.set { mature_bowtie }

        Index_hairpin ( Format_hairpin.out.formatted_fasta ).bt_indices.set { hairpin_bowtie }

        reads
            .map { add_suffix(it, "mature") }
            .set { reads_mirna }

        Bowtie_map_mature (
            reads_mirna,
            mature_bowtie.collect(),
            "Mature_miRNA"
        )

        Bowtie_map_mature.out.unmapped
            .map { add_suffix(it, "hairpin") }
            .set { reads_hairpin }

        Bowtie_map_hairpin (
            reads_hairpin,
            hairpin_bowtie.collect(),
            "Hairpin_miRNA"
        )

        Bam_work_mature (
            Bowtie_map_mature.out.bam, 
            Format_mature.out.formatted_fasta,
            "Mature"
        )

        Bam_work_hairpin (
            Bowtie_map_hairpin.out.bam, 
            Format_hairpin.out.formatted_fasta,
            "Hairpin"
        )

        reads
            .map { add_suffix(it, "seqcluster") }
            .set { reads_seqcluster }
        
        Seqcluster_sequences ( reads_seqcluster ).collapsed.set {reads_collapsed}
        Bowtie_mirna_seqcluster ( 
            reads_collapsed, 
            hairpin_bowtie.collect(), 
            'Seqcluster')
        Mirtop_quant ( 
            Bowtie_mirna_seqcluster.out.bam.collect{it[1]}, 
            Format_hairpin.out.formatted_fasta, 
            gtf )

        Bowtie_map_hairpin.out.unmapped
            .map { add_suffix(it, "genome") }
            .set { reads_genome }

    emit:
        fasta_mature = Format_mature.out.formatted_fasta
        fasta_hairpin = Format_hairpin.out.formatted_fasta
        unmapped = reads_genome

}
def add_suffix(row, suffix) {
    def meta = [:]
    meta.id           = "${row[0].id}_${suffix}"
    def array = []
    array = [ meta, row[1] ]
    return array
}