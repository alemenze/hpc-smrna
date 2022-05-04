process Samtools_sort {
    label 'process_medium'

    publishDir "${params.outdir}/samtools/${type}",
            mode: "copy",
            overwrite: true,
            saveAs: { filename -> filename }
        if (!workflow.profile=='slurm'){
            maxForks 1
        }

    container 'quay.io/biocontainers/samtools:1.15--h1170115_1'

    input:
        tuple val(meta), path(bam)
        val(type)

    output:
        tuple val(meta), path("*.bam"), emit: bam

    script:
        """
        samtools sort -@ $task.cpus -o ${meta}_sorted.bam -T $meta $bam
        """
}