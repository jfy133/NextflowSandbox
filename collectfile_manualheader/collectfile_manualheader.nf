// This works but weirdly produces an empty line between the header and the rest of the rows
// Specify the header for each element in the map, split with a new line
// In collect file make sure to specify newLine to ensure each element is a new row, and keepHeader to keep the first half of the element and share across all
channel.of('1,2\nalpha,one\n', '1,2\nbeta,two\n', '1,2\ngamma,three\n')
    .collectFile(
        name: 'sample.txt',
        storeDir: '/home/james/git/jfy133/NextflowSandbox/collectfile_manualheader',
        keepHeader: true,
     )
    .subscribe { file ->
        println "Entries are saved to file: $file"
        println "File content is:\n${file.text}"
    }
    
// More compliant Nextflow Mahesh Binzer-Panchal version: https://nfcore.slack.com/archives/CE6SDBX2A/p1768221626738289?thread_ts=1767954023.555569&cid=CE6SDBX2A
// When using closure, the first element needs to be the file name to save to, but the second element is the content itself.
// We can then add the new line there, but already Nextflow knows to keep the first line across all of these.
  channel.of('1,2\nalpha,one', '1,2\nbeta,two', '1,2\ngamma,three')
    .collectFile(
        keepHeader: true,
    ) { txt ->
        ["sample.txt", txt + '\n']
    }
    .subscribe { file ->
        println "Entries are saved to file: $file"
        println "File content is:\n${file.text}"
    }