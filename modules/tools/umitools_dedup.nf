process Umitools_dedup {
    label "process_medium"

    publishDir "${params.outdir}/dedup/${type}",
        mode: "copy",
        overwrite: true,
        saveAs: { filename -> filename }
    if (!workflow.profile=='slurm'){
        maxForks 1
    }

    container 'quay.io/biocontainers/umi_tools:1.1.2--py38h4a8c8d9_0'

    input:
        tuple val(meta), path(bam), path(bai)
        val(type)

    output:
        tuple val(meta), path("*.bam")             , emit: bam
        tuple val(meta), path("*edit_distance.tsv"), emit: tsv_edit_distance
        tuple val(meta), path("*per_umi.tsv")      , emit: tsv_per_umi
        tuple val(meta), path("*per_position.tsv") , emit: tsv_umi_per_position

    
    script:
        """
        umi_tools \\
            dedup \\
            -I $bam \\
            -S ${meta}.bam \\
            --output-stats ${meta} \\
        """
}