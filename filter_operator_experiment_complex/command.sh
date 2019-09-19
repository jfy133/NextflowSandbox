#!/usr/bin/env bash

rm -r */
rm -r .nextflow*
rm -r flowchart*

nextflow run filter_operator_experiment_complex.nf -with-dag flowchart.pdf -name 'fastpOFF_clipON_dedupOn' --singleEnd --mapper_to_use 'bwa' --outdir "$(pwd)"/fastpOFF_clipmergeON_dedupON -w "$(pwd)"/fastpOFF_clipmergeON_dedupON/work
nextflow run filter_operator_experiment_complex.nf -with-dag flowchart.pdf -name 'fastpON_clipmergeON_dedupOn' --singleEnd --mapper_to_use 'bwa' --outdir "$(pwd)"/fastpON_clipmergeON_dedupON -w "$(pwd)"/fastpON_clipmergeON_dedupON/work --run_fastp
nextflow run filter_operator_experiment_complex.nf -with-dag flowchart.pdf -name 'fastpOFF_clipmergeOFF_dedupOn' --singleEnd --mapper_to_use 'bwa' --outdir "$(pwd)"/fastpOFF_clipmergeOFF_dedupON -w "$(pwd)"/fastpOFF_clipmergeOFF_dedupON/work  --skip_adapterremoval
nextflow run filter_operator_experiment_complex.nf -with-dag flowchart.pdf -name 'fastpON_clipmergeOFF_dedupOn' --singleEnd --mapper_to_use 'bwa' --outdir "$(pwd)"/fastpON_clipmergeOFF_dedupON -w "$(pwd)"/fastpON_clipmergeOFF_dedupON/work --run_fastp --skip_adapterremoval
nextflow run filter_operator_experiment_complex.nf -with-dag flowchart.pdf -name 'fastpON_clipmergeOFF_dedupOFF' --singleEnd --mapper_to_use 'bwa' --outdir "$(pwd)"/fastpON_clipmergeOFF_dedupOFF -w "$(pwd)"/fastpON_clipmergeOFF_dedupON/work --run_fastp --skip_adapterremoval --skip_deduplication
nextflow run filter_operator_experiment_complex.nf -with-dag flowchart.pdf -name 'fastpON_clipmergeOFF_dedupOFF' --singleEnd --mapper_to_use 'bwa' --outdir "$(pwd)"/fastpON_clipmergeOFF_dedupON -w "$(pwd)"/fastpON_clipmergeOFF_dedupON/work --run_fastp --skip_adapterremoval --skip_deduplication --run_pmdtools
nextflow run filter_operator_experiment_complex.nf -with-dag flowchart.pdf -name 'fastpON_clipmergeOFF_dedupOFF_pmdON' --singleEnd --mapper_to_use 'bwa' --outdir "$(pwd)"/fastpON_clipmergeOFF_dedupON_pmdON -w "$(pwd)"/fastpON_clipmergeOFF_dedupON_pmdON/work --run_fastp --skip_adapterremoval --skip_deduplication --run_pmdtools
nextflow run filter_operator_experiment_complex.nf -with-dag flowchart.pdf -name 'fastpON_clipmergeOFF_dedupOFF_trimbamON' --singleEnd --mapper_to_use 'bwa' --outdir "$(pwd)"/fastpON_clipmergeOFF_dedupON_trimbamON -w "$(pwd)"/fastpON_clipmergeOFF_dedupON_trimbamON/work --run_fastp --skip_adapterremoval --skip_deduplication --run_bamtrim
nextflow run filter_operator_experiment_complex.nf -with-dag flowchart.pdf -name 'fastpON_clipmergeOFF_dedupOFF_pmdON_trimbamON' --singleEnd --mapper_to_use 'bwa' --outdir "$(pwd)"/fastpON_clipmergeOFF_dedupON_pmdON_trimbamON -w "$(pwd)"/fastpON_clipmergeOFF_dedupON_pmdON_trimbamON/work --run_fastp --skip_adapterremoval --skip_deduplication --run_pmdtools --run_bamtrim
nextflow run filter_operator_experiment_complex.nf -with-dag flowchart.pdf -name 'fastpON_clipmergeOFF_dedupOFF_pmdON_trimbamON' --singleEnd --mapper_to_use 'bwa' --outdir "$(pwd)"/fastpON_clipmergeOFF_dedupON_pmdON_trimbamON -w "$(pwd)"/fastpON_clipmergeOFF_dedupON_pmdON_trimbamON/work --run_fastp --skip_adapterremoval --skip_deduplication --run_pmdtools --run_bamtrim

nextflow run filter_operator_experiment_complex.nf -with-dag flowchart.pdf -name 'fastpON_clipmergeOFF_skipmapON_dedupOFF_pmdON_trimbamON' --singleEnd --skip_mapping --mapper_to_use 'bwa' --outdir "$(pwd)"/fastpON_clipmergeOFF_skipmapON_dedupON_pmdON_trimbamON -w "$(pwd)"/fastpON_clipmergeOFF_skipmapON_dedupON_pmdON_trimbamON/work --run_fastp --skip_adapterremoval --skip_deduplication --run_pmdtools --run_bamtrim




#nextflow run filter_operator_experiment_complex.nf -name 'bam_fastpOFF_clipmergeON' --singleEnd --bam_input --mapper_to_use 'bwa' --outdir "$(pwd)"/bam_fastpOFF_clipmergeON -w "$(pwd)"/bam_fastpOFF_clipmergeON/work
#nextflow run filter_operator_experiment_complex.nf -name 'bam_fastpOFF_clipmergeON' --singleEnd --bam_input --mapper_to_use 'bwa' --outdir "$(pwd)"/bam_fastpOFF_clipmergeON -w "$(pwd)"/bam_fastpOFF_clipmergeON/work
#nextflow run filter_operator_experiment_complex.nf -name 'bam_fastpON_clipmergeON' --singleEnd --bam_input --mapper_to_use 'bwa' --outdir "$(pwd)"/bam_fastpON_clipmergeON -w "$(pwd)"/bam_fastpON_clipmergeON/work --run_fastp
#nextflow run filter_operator_experiment_complex.nf -name 'bam_fastpOFF_clipmergeOFF' --singleEnd --bam_input --mapper_to_use 'bwa' --outdir "$(pwd)"/bam_fastpOFF_clipmergeOFF -w "$(pwd)"/bam_fastpOFF_clipmergeOFF/work  --skip_adapterremoval
#nextflow run filter_operator_experiment_complex.nf -name 'bam_fastpON_clipmergeOFF' --singleEnd --bam_input --mapper_to_use 'bwa' --outdir "$(pwd)"/bam_fastpON_clipmergeOFF -w "$(pwd)"/bam_fastpON_clipmergeOFF/work --run_fastp --skip_adapterremoval