process Mirdeep2_mapper {
    label 'process_medium'

    publishDir "${params.outdir}/mirdeep2_inputs/",
        mode: "copy",
        overwrite: true,
        saveAs: { filename -> filename }
    if (!workflow.profile=='slurm'){
        maxForks 1
    }

    container 'quay.io/biocontainers/mirdeep2:2.0.1.3--hdfd78af_1'

    input:
        tuple val(meta), path(reads)
        path index

    output:
        tuple path('*_collapsed.fa'), path('*reads_vs_refdb.arf'), emit: mirdeep2_inputs

    script:
        def index_base = index.toString().tokenize(' ')[0].tokenize('.')[0]
        """
        mapper.pl \\
        $reads \\
        -e \\
        -h \\
        -i \\
        -j \\
        -m \\
        -p $index_base \\
        -s ${meta}_collapsed.fa \\
        -t ${meta}_reads_vs_refdb.arf \\
        -o 4
        """
}