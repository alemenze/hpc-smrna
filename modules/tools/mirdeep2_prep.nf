process Mirdeep2_prep {
    label 'process_low'

    container 'quay.io/biocontainers/bioconvert:0.4.3--py_0'

    input:
        tuple val(meta), path(reads)

    output:
        tuple val(meta), path("*.fq"), emit: reads

    script:
        def unzip = reads.toString() - '.gz'
        """
        pigz -f -d -p $task.cpus $reads
        """

}