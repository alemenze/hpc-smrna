process Mirtrace {
    label 'process_medium'

    publishDir "${params.outdir}/mirtrace/",
        mode: "copy",
        overwrite: true,
        saveAs: { filename -> filename }

    if (!workflow.profile=='slurm'){
        maxForks 1
    }

    container "quay.io/biocontainers/mirtrace:1.0.1--hdfd78af_1"

    input:
        path reads

     output:
        path "mirtrace/*", emit: mirtrace

    script:
        def three_prime_adapter = params.three_prime_adapter
        // Presets
        if (params.mirtrace_protocol == "illumina"){
            three_prime_adapter = "TGGAATTCTCGGGTGCCAAGG"
        } else if (params.mirtrace_protocol == "nextflex"){
            three_prime_adapter = "TGGAATTCTCGGGTGCCAAGG"
        } else if (params.mirtrace_protocol == "qiaseq"){
            three_prime_adapter = "AACTGTAGGCACCATCAAT"
        } else if (params.mirtrace_protocol == "cats"){
            three_prime_adapter = "AAAAAAAA"
        }
        if (params.three_prime_adapter){
            // to allow replace of 3' primer using one of the previous protocols
            three_prime_adapter = params.three_prime_adapter
        }
        // mirtrace protocol defaults to 'params.protocol' if not set
        def mirtrace_protocol = params.mirtrace_protocol
        if (!params.mirtrace_protocol){
            mirtrace_protocol = params.protocol
        }
        def primer = (mirtrace_protocol=="cats") ? " " : " --adapter $three_prime_adapter "
        def java_mem = ''
        if(task.memory){
            tmem = task.memory.toBytes()
            java_mem = "-Xms${tmem} -Xmx${tmem}"
        }
        """
        export mirtracejar=\$(dirname \$(which mirtrace))
        for i in $reads
        do
            path=\$(realpath \${i})
            prefix=\$(echo \${i} | sed -e 's/.gz//' -e 's/.fastq//' -e 's/.fq//' -e 's/_val_1//' -e 's/_trimmed//' -e 's/_R1//' -e 's/.R1//')
            echo \$path","\$prefix
        done > mirtrace_config
        java $java_mem -jar \$mirtracejar/mirtrace.jar --mirtrace-wrapper-name mirtrace qc  \\
            --species $params.mirtrace_species \\
            $primer \\
            --protocol $mirtrace_protocol \\
            --config mirtrace_config \\
            --write-fasta \\
            --output-dir mirtrace \\
            --force

        """
}
