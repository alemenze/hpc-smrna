process Samtools_index {
    label 'process_low'

    publishDir "${params.outdir}/samtools/${type}",
            mode: "copy",
            overwrite: true,
            saveAs: { filename -> filename }
        if (!workflow.profile=='slurm'){
            maxForks 1
        }

    container 'quay.io/biocontainers/samtools:1.15--h1170115_1'

    input:
        tuple val(meta), path(input)

    output:
        tuple val(meta), path("*.bai") , optional:true, emit: bai
        tuple val(meta), path("*.csi") , optional:true, emit: csi
        tuple val(meta), path("*.crai"), optional:true, emit: crai

    script:
        """
        samtools \\
            index \\
            -@ ${task.cpus-1} \\ \\
            $input
        """
}