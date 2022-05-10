include { Mirdeep2_prep } from '../tools/mirdeep2_prep'
include { Mirdeep2_mapper } from '../tools/mirdeep2_mapper'
include { Mirdeep2_run } from '../tools/mirdeep2_run'

workflow Mirdeep2 {
    take: 
        reads
        fasta
        indices
        hairpin
        mature

    main:
        Mirdeep2_prep (
            reads
        )

        Mirdeep2_mapper(
            Mirdeep2_prep.out.reads,
            indices
        )

        Mirdeep2_run(
            fasta,
            Mirdeep2_mapper.out.mirdeep2_inputs,
            hairpin, 
            mature
        )
}