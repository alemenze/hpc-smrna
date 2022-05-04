include { Fastqc } from '../tools/fastqc'
include { Umi_extract } from '../tools/umitools'

workflow Qc_trim {
    take:
        reads

    main:
        Fastqc ( 
            reads
        )

        Umi_extract (
            reads
        )

        Trimgalore (
            Umi_extract.out.reads
        )
        umi_reads=Trimgalore.out.reads
    emit:
        umi_reads
}