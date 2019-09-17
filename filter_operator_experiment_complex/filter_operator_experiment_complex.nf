#!/usr/bin/env nextflow

/*
Description: This is a experiment to understand how to filter channels, given a flag
*/


// Default settings for modules

params.bam_input = true
params.run_fastp = false
params.skip_adapterremoval = false
params.mapper_to_use = 'bwa'
params.run_bam_filtering = false
params.skip_deduplication = false
params.dedupper_to_use = "dedup"
params.run_pmdtools = false
params.run_bamtrim = false
params.run_genotyping = false
params.genotyper_to_use = 'ug'



// Find all the input BAM files
if (bam_input) {
    ch_input = Channel.fromPath( './*bam' )
} else {
    ch_input = Channel.fromPath( './*fastq.gz' )
}


/*
FASTQ PROCESSING
*/


process convert_bam {

    publishDir "${params.outdir}/convert_bam", mode: 'copy'

    when:
    params.bam_input = true

    input:
    bam from ch_input

    output:
    '*fastq.gz' into 

    """
    mv ${bam} ${bam}.fastq.gz
    """

    
}

// ISSUE ch_input ALSO USED ABOVE!
process fastp {
    publishDir "${params.outdir}/fastp", mode: 'copy'

    when:
    run_fastp

    input:
    fq from ch_input.mix(ch_converted_for_fastp)

    output:
    "*pG.fq.gz" into


    """
    mv ${fq} ${fq}.pG.fq.gz
    """
}


// Need to add if statement for singleEnd/PairedEnd i.e. truncated or combined
process adapter_removal {
    publishDir "${params.outdir}/adapterremoval", mode: 'copy'
    

    when:
    !params.skip_adapterremoval

    input:
    fq from 

    output:
    "*truncated.gz" into

    """
    mv ${fq} ${fq}.truncated.gz
    """
}


/*
MAPPING
*/



process bwa {
    publishDir "${params.outdir}/mapping", mode: 'copy'

    when:
    params.mapper_to_use = "bwa"

    input:
    fq from 

    output:
    "*.bam" into


    """
    mv ${fq} ${fq}.mapped.bam
    """

}

process bwamem {
    publishDir "${params.outdir}/mapping", mode: 'copy'
    
    when:
    params.mapper_to_use = "bwamem"

    input:
    fq from 

    output:
    "*.bam" into


    """
    mv ${fq} ${fq}.mapped.bam
    """
    
}

process circularmapper {
    publishDir "${params.outdir}/mapping", mode: 'copy'

    when:
    params.mapper_to_use = "circularmapper"

    input:
    fq from 

    output:
    "*.bam" into

    """
    mv ${fq} ${fq}.mapped.bam
    """

}

/*
MAPPING MODIFICATION
*/


process samtools_filter {
    publishDir "${params.outdir}/samtools/filter", mode: 'copy'

    when:
    params.run_bam_filtering

    input:
    bam from 

    output:
    "*.filtered.bam" into

    """
    mv ${bam} ${bam}.filtered.bam
    """
    
}

/*
MAPPING DEDUPLICATION
*/

process dedup {
    publishDir "${params.outdir}/deduplication", mode: 'copy'

    when:
    !params.skip_deduplication && params.dedupper_to_use = "dedup"

    input:
    bam from 

    output:
    "*_rmdup.bam" into

    """
    mv ${bam} ${bam}_rmdup.bam
    """
    
}

process_markdup {
    publishDir "${params.outdir}/deduplication", mode: 'copy'

    when:
    !params.skip_deduplication && params.dedupper_to_use = "markdup"

    input:
    bam from 

    output:
    "*_rmdup.bam" into

    """
    mv ${bam} ${bam}_rmdup.bam
    """
    
}

/*
DAMAGE MODIFICATION
*/

process pmdtools {
    publishDir "${params.outdir}/pmdtools", mode: 'copy'

    when:
    params.run_pmdtools

    input:
    bam from

    output:
    "*.pmd.bam" into

    """
    mv ${bam} ${bam}.pmd.bam
    """
    
}

process bamtrim {
    publishDir "${params.outdir}/bamtrim", mode: 'copy'

    when:
    params.run_bamtrim

    input:
    bam from

    output:
    "*.trimmed.bam" into

    """
    mv ${bam} ${bam}.trimmed.bam
    """
    
}


/*
Genotyping
*/

process genotyping_ug {
    publishDir "${params.outdir}/genotyping", mode: 'copy'

    when:
    params.run_genotyping && params.genotyper_to_use == "ug"

    input:
    bam from

    """
    mv ${bam} ${bam}.ug.vcf
    """

    
}

process genotyping_hc {
    publishDir "${params.outdir}/genotyping", mode: 'copy'

    when:
    params.run_genotyping && params.genotyper_to_use == "hc"

    """
    mv ${bam} ${bam}.hc.vcf
    """

}

process genotyping_freebayes {
    publishDir "${params.outdir}/genotyping", mode: 'copy'

    when:
    params.run_genotyping && params.genotyper_to_use == "freebayes"

    """
    mv ${bam} ${bam}.freebayes.vcf
    """

    
}