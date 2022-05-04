process Seqcluster_sequences {
    label 'process_medium'

    container 'quay.io/biocontainers/seqcluster:1.2.8--pyh5e36f6f_0'

    input:
        tuple val(meta), path(reads)

    output:
        tuple val(meta), path("final/*.fastq.gz"), emit: collapsed

    script:
        """
        seqcluster collapse -f $reads -m 1 --min_size 15 -o collapsed
        gzip collapsed/*_trimmed.fastq
        mkdir final
        mv collapsed/*.fastq.gz final/.
        """

}