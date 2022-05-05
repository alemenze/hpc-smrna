process Umi_extract {

    label "process_low"

    publishDir "${params.outdir}/umitools/",
        mode: "copy",
        overwrite: true,
        saveAs: { filename -> filename }
    if (!workflow.profile=='slurm'){
        maxForks 1
    }

    container "quay.io/biocontainers/umi_tools:1.1.2--py38h4a8c8d9_0"

    input:
        tuple val(meta), path(r1)

    output:
        tuple val(meta), path("*.fastq.gz"), emit: reads
        tuple val(meta), path("*.log"), emit: log

    script:
        """
            umi_tools extract -I $r1 \\
                -S ${meta}.umi_1.fastq.gz \\
                --extract-method=${params.umitools_extract_method} --bc-pattern='${params.umitools_bc_pattern}' > ${meta}.umi_extract.log
        """
}