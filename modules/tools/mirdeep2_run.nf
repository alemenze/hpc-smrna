process Mirdeep2_run {
    label 'process_medium'
    errorStrategy 'ignore'

    publishDir "${params.outdir}/mirdeep2/",
        mode: "copy",
        overwrite: true,
        saveAs: { filename -> filename }
    if (!workflow.profile=='slurm'){
        maxForks 1
    }

    container 'quay.io/biocontainers/mirdeep2:2.0.1.3--hdfd78af_1'

    input:
        path fasta
        tuple path(reads), path(arf)
        path hairpin
        path mature

    output:
        path 'result*.{bed,csv,html}', emit: result

    script:
        """
        miRDeep2.pl \\
        $reads \\
        $fasta \\
        $arf \\
        $mature \\
        none \\
        $hairpin \\
        -d \\
        -z _${reads.simpleName}
        """
}