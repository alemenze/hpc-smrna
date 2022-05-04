process Format_fasta_mirna {
    label 'process_medium'

    container 'quay.io/biocontainers/fastx_toolkit:0.0.14--he1b5a44_8'

    input:
        path fasta

    output:
        path '*_idx.fa'    , emit: formatted_fasta

    script:
        """
        fasta_formatter -w 0 -i $fasta -o ${fasta}_idx.fa
        """
}