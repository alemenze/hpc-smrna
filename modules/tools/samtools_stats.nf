process Samtools_stats {
    label 'process_low'

    publishDir "${params.outdir}/samtools_stats/${type}",
        mode: "copy",
        overwrite: true,
        saveAs: { filename -> filename }

    if (!workflow.profile=='slurm'){
        maxForks 1
    }
    
    container 'quay.io/biocontainers/samtools:1.15--h1170115_1'

    input:
        tuple val(meta), path(input), path(input_index)
        path fasta
        val(type)

    output:
        tuple val(meta), path("*.stats"), emit: stats

    script:
        def reference = fasta ? "--reference ${fasta}" : ""
        """
        samtools \\
            stats \\
            --threads ${task.cpus-1} \\
            ${reference} \\
            ${input} \\
            > ${input}.stats
        """
}