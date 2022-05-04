process Parse_fasta_mirna {
    label 'process_medium'

    container 'quay.io/biocontainers/seqkit:2.0.0--h9ee0642_0'

    input:
        path fasta

    output:
        path '*_igenome.fa', emit: parsed_fasta

    script:
    """
        # Uncompress FASTA reference files if necessary
        FASTA="$fasta"
        if [ \${FASTA: -3} == ".gz" ]; then
            gunzip -f \$FASTA
            FASTA=\${FASTA%%.gz}
        fi
        sed '/^[^>]/s/[^AUGCaugc]/N/g' \$FASTA > \${FASTA}_parsed.fa
        sed -i 's/\s.*//' \${FASTA}_parsed.fa
        seqkit grep -r --pattern \".*${params.mirtrace_species}-.*\" \${FASTA}_parsed.fa > \${FASTA}_sps.fa
        seqkit seq --rna2dna \${FASTA}_sps.fa > \${FASTA}_igenome.fa
    """

}