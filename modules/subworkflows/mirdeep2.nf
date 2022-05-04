include { Mirdeep2_prep } from '../tools/mirdeep2_prep'

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
            mature)
        )
}