process Index_genome {
    label 'process_medium'

    container 'quay.io/biocontainers/bowtie:1.3.0--py38hcf49a77_2'

    input:
        path fasta

    output:
        path 'genome*ebwt'     , emit: bt_indices
        path 'genome.edited.fa', emit: fasta

    script:
        """
        # Remove any special base characters from reference genome FASTA file
        sed '/^[^>]/s/[^ATGCatgc]/N/g' $fasta > genome.edited.fa
        sed -i 's/ .*//' genome.edited.fa
        # Build bowtie index
        bowtie-build genome.edited.fa genome --threads ${task.cpus}
        """
}