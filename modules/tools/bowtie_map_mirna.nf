process Bowtie_mirna_seq {
    label 'process_medium'

    publishDir "${params.outdir}/bowtie/${type}/${meta}",
        mode: "copy",
        overwrite: true,
        saveAs: { filename -> filename }
    if (!workflow.profile=='slurm'){
        maxForks 1
    }

    container 'quay.io/biocontainers/mulled-v2-ffbf83a6b0ab6ec567a336cf349b80637135bca3:40128b496751b037e2bd85f6789e83d4ff8a4837-0'

    input:
        tuple val(meta), path(reads)
        path index
        val(type)

    output:
        tuple val(meta), path("*bam")           , emit: bam
        tuple val(meta), path('unmapped/*fq.gz'), emit: unmapped

    script:
    def index_base = index.toString().tokenize(' ')[0].tokenize('.')[0]
    """
    bowtie \\
        -x $index_base \\
        -q <(zcat $reads) \\
        -p ${task.cpus} \\
        -t \\
        -k 50 \\
        --best \\
        --strata \\
        -e 99999 \\
        --chunkmbs 2048 \\
        --un ${meta}_unmapped.fq -S > ${meta}.sam
    samtools view -bS ${meta}.sam > ${meta}.bam
    if [ ! -f  "${meta}_unmapped.fq" ]
    then
        touch ${meta}_unmapped.fq
    fi
    gzip ${meta}_unmapped.fq
    mkdir unmapped
    mv  ${meta}_unmapped.fq.gz  unmapped/.
    """

}