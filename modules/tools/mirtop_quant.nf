process Mirtop_quant {
    label 'process_medium'

    publishDir "${params.outdir}/mirtop_quant",
            mode: "copy",
            overwrite: true,
            saveAs: { filename -> filename }
        if (!workflow.profile=='slurm'){
            maxForks 1
        }

    container 'quay.io/biocontainers/mulled-v2-0c13ef770dd7cc5c76c2ce23ba6669234cf03385:63be019f50581cc5dfe4fc0f73ae50f2d4d661f7-0'

    input:
        path ("bams/*")
        path hairpin
        path gtf

    output:
        path "mirtop/mirtop.gff"
        path "mirtop/mirtop.tsv"        , emit: mirtop_table
        path "mirtop/mirtop_rawData.tsv"
        path "mirtop/stats/*"           , emit: logs

    script:
        """
        mirtop gff --hairpin $hairpin --gtf $gtf -o mirtop --sps $params.mirtrace_species ./bams/*
        mirtop counts --hairpin $hairpin --gtf $gtf -o mirtop --sps $params.mirtrace_species --add-extra --gff mirtop/mirtop.gff
        mirtop export --format isomir --hairpin $hairpin --gtf $gtf --sps $params.mirtrace_species -o mirtop mirtop/mirtop.gff
        mirtop stats mirtop/mirtop.gff --out mirtop/stats
        mv mirtop/stats/mirtop_stats.log mirtop/stats/full_mirtop_stats.log
        """

}