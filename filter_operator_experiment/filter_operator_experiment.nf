#!/usr/bin/env nextflow

/*
Description: This is a experiment to understand how to filter channels, given a flag
*/



// Find all the input BAM files
ch_for_prededup = Channel.fromPath( './*bam' )

// Default setting for skipping a (fake) deduplication module
params.skip_deduplication = false

// Create the pre-DeDup files
process preDeDup {
    publishDir "${params.outdir}/prededup", mode: 'copy'


    input:
    file bam from ch_for_prededup

    output:
    file '*.bam' into ch_for_dedup,prededup_dp

    """
    printf ${bam}
    cat ${bam} <(echo "prededup") > '${bam}'_prededup.bam
    """
}

// Create the post-DeDup files
process fakeDeDup {

    publishDir "${params.outdir}/dedup", mode: 'copy'

    when:
    !params.skip_deduplication

    input:
    file bam from ch_for_dedup

    output:
    file '*_rmdup.bam' into dp_dedup

    """
    cat ${bam} <(echo "runningdedup") > "${bam}"_rmdup.bam
    """
}



// If deduplication activated, mix the pre-dedup and post-dedup
// channels, filter for just the post-dedup files and emit 
// into a new channel for downstream; if skipped,  just emit
// the pre-dedup files into the new channel. First try filtering
// without the switch

prededup_dp
	.mix(dp_dedup)
    .view()
	.filter( =~/*rmdup*/)
	.set{ch_fakedp}

// Downstream process (here is damage profiler)
process fakeDP {

	publishDir "${params.outdir}/damageprofiler", mode: 'copy'
	
	input:
	file bam from ch_fakedp

	output:
	file '*.pdf' into onwards

	"""
    cat ${bam} <(echo "running damageprofiler") > "${bam}"_dp.pdf
	"""

}
