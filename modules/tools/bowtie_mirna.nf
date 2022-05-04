process Index_mirna {
    label 'process_medium'

    container 'quay.io/biocontainers/bowtie:1.3.0--py38hcf49a77_2'

    input:
        path fasta

    output:
        path 'fasta_bidx*' , emit: bt_indices

    script:
        """
        bowtie-build ${fasta} fasta_bidx --threads ${task.cpus}
        """

}