include { Samtools_sort 
            Samtools_sort as Samtools_dup_sort } from '../tools/samtools_sort'
include { Samtools_index 
            Samtools_index as Samtools_dup_index } from '../tools/samtools_index'
include { Umitools_dedup } from '../tools/umitools_dedup'
include { Samtools_stats  } from '../tools/samtools_stats'

workflow Bam_work {
    take:
        bam_in
        fasta
        type

    main:
        Samtools_sort (
            bam_in,
            type
        )

        Samtools_index (
            Samtools_sort.out.bam,
            type
        )

        Samtools_sort.out.bam
            .join(Samtools_index.out.bai, by:[0],remainder:true)
            .join(Samtools_index.out.csi, by:[0],remainder:true)
            .map {
                meta, bam, bai, csi ->
                    if (bai) {
                        [ meta, bam, bai ]
                    } else {
                        [ meta, bam, csi ]
                    }
            }
            .set { bam_bai }
        
        Umitools_dedup (
            bam_bai,
            type
        )

        Samtools_dup_sort (
            Umitools_dedup.out.bam,
            type
        )

        Samtools_dup_index (
            Samtools_dup_sort.out.bam,
            type
        )

        Samtools_dup_sort.out.bam
            .join(Samtools_dup_index.out.bai, by:[0],remainder:true)
            .join(Samtools_dup_index.out.csi, by:[0],remainder:true)
            .map {
                meta, bam, bai, csi ->
                    if (bai) {
                        [ meta, bam, bai ]
                    } else {
                        [ meta, bam, csi ]
                    }
            }
            .set { dedup_bam_bai }

        Samtools_stats  (
            dedup_bam_bai, 
            fasta,
            type
        )
    emit:
        bam = Samtools_dup_sort.out.bam
        bai = Samtools_dup_index.out.bai
}