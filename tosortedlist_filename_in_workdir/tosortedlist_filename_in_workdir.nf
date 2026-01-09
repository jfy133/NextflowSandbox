/*
Name: toSortedList by filename in workdir

Aim: sort a list of paths based on the file name and not the full path, within a toSortedList() closure

Input:
/home/james/git/jfy133/NextflowSandbox/tosortedlist_filename_in_workdir/work/fb/7a5a001ad2e34e36b496115c6d8f8d/SPAdes-test_minigut_pydamage_results.csv
/home/james/git/jfy133/NextflowSandbox/tosortedlist_filename_in_workdir/work/67/81807a558bcfef89cb47aace43ea9b/SPAdes-test_minigut_sample2_pydamage_results.csv
/home/james/git/jfy133/NextflowSandbox/tosortedlist_filename_in_workdir/work/8e/efc29a0d95fa5c16a55bfe69806024/MEGAHIT-test_minigut_pydamage_results.csv
/home/james/git/jfy133/NextflowSandbox/tosortedlist_filename_in_workdir/work/f6/58bc5e73d1ee7ed3e5f7ea741c011f/MEGAHIT-test_minigut_sample2_pydamage_results.csv

Expected output:
[
/home/james/git/jfy133/NextflowSandbox/tosortedlist_filename_in_workdir/work/8e/efc29a0d95fa5c16a55bfe69806024/MEGAHIT-test_minigut_pydamage_results.csv
/home/james/git/jfy133/NextflowSandbox/tosortedlist_filename_in_workdir/work/f6/58bc5e73d1ee7ed3e5f7ea741c011f/MEGAHIT-test_minigut_sample2_pydamage_results.csv
/home/james/git/jfy133/NextflowSandbox/tosortedlist_filename_in_workdir/work/fb/7a5a001ad2e34e36b496115c6d8f8d/SPAdes-test_minigut_pydamage_results.csv
/home/james/git/jfy133/NextflowSandbox/tosortedlist_filename_in_workdir/work/67/81807a558bcfef89cb47aace43ea9b/SPAdes-test_minigut_sample2_pydamage_results.csv
]

*/

// Load files as in work directory
// The order of this will be SPADES, SPADES, MEGAHIT, MEGAHIT, based simply on how Nextflow loads the files (this may be inconsistent)
ch_files = Channel.fromPath('work/**/*.csv')//.view()

// Sort using basic .toSortedList
// The order of this will be SPADES, MEGAHIT, MEGAHIT, SPADES, on the corresponding root work dir (67, 8e, f6, fb)
// However don't want to base it on that but rather than file name itself

ch_files
    .toSortedList()
//.view()

// Object check
// As we want to essentially sort on the basename, we can check we can retrieve that using the Nextflow file attributes
ch_files
    .map{
        csv -> 
            println(csv.getClass())
            println("Basename: "+ csv.getBaseName())
        }
        
// Sort using custom .toSortedList
// We can just specify the specific 'object' that the sort will be applied upon
ch_files
    .toSortedList{
        csv -> 
             csv.getBaseName()
     }
     .view()
     