#!/usr/bin/env nextflow

/*
Description: This is a experiment to understand how to filter channels, given a flag

Concept:

Every non-terminal optional process must have a 'skip equivalent'

If the optional process is on, it mixes the previous process output and the skip equivalent, but filters for the process's file (i.e. not the skip).
If the optional process is off, it sets the previous process' skip output channel as the sole output channel


*/


// Default settings for modules

params.singleEnd = false
params.pairedEnd = false
params.bam_input = false

params.skip_convertbam = false

params.run_fastp = false

params.skip_adapterremoval = false

params.skip_deduplication = false

params.skip_mapping = false
params.mapper_to_use = 'bwa' // or 'bwamem' or 'cm'

params.run_bam_filtering = false

params.dedupper_to_use = "dedup" // or markdup

params.run_pmdtools = false
params.run_bamtrim = false

params.run_genotyping = false
params.run_genotyping_source = 'cleaned' // or 'trimmed' or 'pmd'
params.genotyper_to_use = 'ug' // or 'hc' or 'freebayes' 



// Find all the input BAM files
if ( params.bam_input ) {
    Channel
        .fromPath( './*bam' )
        .into { ch_input_for_skipconvertbam; ch_input_for_convertbam }
} else {
    Channel
        .fromPath( './*fq' )
        .into { ch_input_for_skipconvertbam; ch_input_for_convertbam } 
}


/*
FASTQ PROCESSING
*/


process convert_bam {

    publishDir "${params.outdir}/convert_bam", mode: 'copy'

    when:
    params.bam_input && !params.skip_convertbam

    input:
    file bam from ch_input_for_convertbam

    output:
    file '*.fq' into ch_output_from_convertbam

    script:
    """
    echo "I have been convert_bammed" > ${bam}  
    mv ${bam} ${bam}_converted.fq
    """

}

// Skip convert_bam
if (params.run_bam_filtering) {
    ch_input_for_skipconvertbam.mix(ch_output_from_convertbam)
        .filter{ it =~/.*converted.fq/}
        .into { from_convertbam_for_fastp; from_convertbam_for_skipfastp } 
} else {
    ch_input_for_skipconvertbam
        .into { from_convertbam_for_fastp; from_convertbam_for_skipfastp } 
}


process fastp {
    publishDir "${params.outdir}/fastp", mode: 'copy'

    when:
    params.run_fastp

    input:
    file fq from from_convertbam_for_fastp

    output:
    file "*pG.fq" into ch_output_from_fastp

    script:
    """
    echo "I have been fastp'd" > ${fq}  
    mv ${fq} ${fq}.pG.fq
    """
}

// Skip fastp
if (params.run_fastp) {
    from_convertbam_for_skipfastp.mix(ch_output_from_fastp)
        .filter { it =~/.*pG.fq/ }
        .into { from_fastp_for_adapterremoval; from_fastp_for_skipadapterremoval } 
} else {
    from_convertbam_for_skipfastp
        .into { from_fastp_for_adapterremoval; from_fastp_for_skipadapterremoval } 
}



// Need to add if statement for singleEnd/PairedEnd i.e. truncated or combined
process adapter_removal {
    publishDir "${params.outdir}/adapterremoval", mode: 'copy'
    

    when:
    !params.skip_adapterremoval

    input:
    file fq from from_fastp_for_adapterremoval

    output:
    file "*adapterremoval.fq" into ch_output_from_adapterremoval

    script:
    if (params.singleEnd){
        """
        echo "I have been adapter_removal'd" > ${fq}  
        mv ${fq} ${fq}.adapterremoval.fq
        """
    }
    else if (params.pairedEnd) {
        """
        echo "I have been adapter_removal'd" > ${fq}  
        mv ${fq} ${fq}.adapterremoval.fq
        """
    }
}

if (!params.skip_adapterremoval) {
    ch_output_from_adapterremoval.mix(from_fastp_for_skipadapterremoval)
        .filter { it =~/.*adapterremoval.fq|.*adapterremoval.fq/ }
        .into { for_bwa; for_cm; for_bwamem } 
} else {
    from_fastp_for_skipadapterremoval
        .into { for_skipmap; for_bwa; for_cm; for_bwamem } 
}


/*
MAPPING
*/


process bwa {
    publishDir "${params.outdir}/mapping", mode: 'copy'

    when:
    !params.skip_mapping && params.mapper_to_use == "bwa"

    input:
    file fq from for_bwa

    output:
    file "*.bam" into from_bwa_for_filtering


    """
    mv ${fq} ${fq}.mapped.bam
    """

}

process bwamem {
    publishDir "${params.outdir}/mapping", mode: 'copy'
    
    when:
    !params.skip_mapping && params.mapper_to_use == "bwamem"

    input:
    file fq from for_bwamem

    output:
    file "*.bam" into from_bwamem_for_filtering


    """
    mv ${fq} ${fq}.mapped.bam
    """
    
}

process circularmapper {
    publishDir "${params.outdir}/mapping", mode: 'copy'

    when:
    !params.skip_mapping && params.mapper_to_use == "circularmapper"

    input:
    file fq from for_cm

    output:
    file "*.bam" into from_cm_for_filtering

    """
    mv ${fq} ${fq}.mapped.bam
    """

}

if (!params.skip_mapping) {
    from_bwa_for_filtering.mix(from_bwamem_for_filtering, from_cm_for_filtering)
        .filter { it =~/.*mapped.bam/ }
        .into { from_mapping_for_filtering; from_mapping_for_skipfiltering } 
} else {
    for_skipmap
        .into { from_mapping_for_filtering; from_mapping_for_skipfiltering } 
}

/*
MAPPING MODIFICATION
*/


process samtools_filter {
    publishDir "${params.outdir}/samtools/filter", mode: 'copy'

    when:
    params.run_bam_filtering

    input:
    file bam from from_mapping_for_filtering

    output:
    file "*.filtered.bam" into from_filtering_for_rmdup

    """
    mv ${bam} ${bam}.filtered.bam
    """
    
}

if (params.run_bam_filtering) {
    from_mapping_for_skipfiltering.mix(from_filtering_rmdup)
        .filter { it =~/.*filtered.bam/ }
        .into { from_filtering_for_skiprmdup; from_filtering_for_dedup; from_filtering_for_markdup } 
} else {
    from_mapping_for_skipfiltering
        .into { from_filtering_for_skiprmdup; from_filtering_for_dedup; from_filtering_for_markdup } 
}


/*
MAPPING DEDUPLICATION
*/

process dedup {
    publishDir "${params.outdir}/deduplication", mode: 'copy'

    when:
    !params.skip_deduplication && params.dedupper_to_use == "dedup"

    input:
    file bam from  from_filtering_for_dedup

    output:
    file "*_rmdup.bam" into from_dedup_for_damagemanipulation

    """
    mv ${bam} ${bam}_rmdup.bam
    """
    
}

process markdup {
    publishDir "${params.outdir}/deduplication", mode: 'copy'

    when:
    !params.skip_deduplication && params.dedupper_to_use == "markdup"

    input:
    file bam from  from_filtering_for_markdup

    output:
    file "*_rmdup.bam" into from_markdup_for_damagemanipulation

    """
    mv ${bam} ${bam}_rmdup.bam
    """
    
}

if (params.run_bam_filtering) {
    from_mapping_for_skiprmdup.mix(from_dedup_for_damagemanipulation,from_markdup_for_damagemanipulation)
        .filter { it =~/.*rmdup.bam/ }
        .into { from_filtering_for_rmdup; from_filtering_for_rmdup } 
} else {
    from_filtering_for_skiprmdup
        .into { from_rmdup_for_skipdamagemanipulation; from_rmdup_for_bamutils; from_rmdup_for_pmdtools } 
}



/*
DAMAGE MODIFICATION
*/

process pmdtools {
    publishDir "${params.outdir}/pmdtools", mode: 'copy'

    when:
    params.run_pmdtools

    input:
    file bam from from_rmdup_for_pmdtools

    output:
    file "*.pmd.bam" into from_pmdtools_for_genotyping

    """
    mv ${bam} ${bam}.pmd.bam
    """
    
}

process bamtrim {
    publishDir "${params.outdir}/bamtrim", mode: 'copy'

    when:
    params.run_bamtrim

    input:
    file bam from from_rmdup_for_bamutils

    output:
    file "*.trimmed.bam" into from_bamutils_for_genotyping

    """
    mv ${bam} ${bam}.trimmed.bam
    """
    
}

if ( params.run_genotyping && params.run_genotyping_source == "cleaned" ) {
    from_rmdup_for_skipdamagemanipulation.mix(from_pmdtools_for_genotyping,from_bamutils_for_genotyping)
        .into { from_damagemanipulation_for_skipgenotyping; from_damagemanipulation_for_genotyping_ug; from_damagemanipulation_for_genotyping_hc; from_damagemanipulation_for_genotyping_freebayes } 
} else if ( params.run_genotyping && params.run_genotyping_source == "trimmed" )  {
    from_rmdup_for_skipdamagemanipulation.mix(from_pmdtools_for_genotyping,from_bamutils_for_genotyping)
        .filter { it =~/.*trimmed.bam/ }
        .into { from_damagemanipulation_for_skipgenotyping; from_damagemanipulation_for_genotyping_ug; from_damagemanipulation_for_genotyping_hc; from_damagemanipulation_for_genotyping_freebayes } 
} else if ( params.run_genotyping && params.run_genotyping_source == "pmd" )  {
    from_rmdup_for_skipdamagemanipulation.mix(from_pmdtools_for_genotyping,from_bamutils_for_genotyping)
        .filter { it =~/.*trimmed.bam/ }
        .into { from_damagemanipulation_for_skipgenotyping; from_damagemanipulation_for_genotyping_ug; from_damagemanipulation_for_genotyping_hc; from_damagemanipulation_for_genotyping_freebayes } 
} else if ( !params.run_genotyping )  {
    from_rmdup_for_skipdamagemanipulation.mix(from_pmdtools_for_genotyping,from_bamutils_for_genotyping)
        .set { from_damagemanipulation_for_skipgenotyping } 
}

/*
GENOTYPING

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

*/