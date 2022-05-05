process Fastqc {
    
    label 'process_medium'

    publishDir "${params.outdir}/fastqc/",
        mode: "copy",
        overwrite: true,
        saveAs: { filename -> filename }
    if (!workflow.profile=='slurm'){
        maxForks 1
    }

    container "quay.io/biocontainers/fastqc:0.11.9--0"

    input:
        tuple val(meta), path(r1)

    output:
        tuple val(meta), path("*.html"), emit: html
        tuple val(meta), path("*.zip"), emit: zip

    script:
        """
            fastqc --quiet --threads $task.cpus $r1
        """
}