nextflow.enable.dsl=2

include { CELLRANGER_BAMTOFASTQ         } from '../../modules/local/btcmodules/cellranger_bamtofastq'
include { CELLRANGER_DEMULTIPLEX         } from '../../modules/local/btcmodules/cellranger_demultiplex'
include { CELLRANGER_PERSAMPLE         } from '../../modules/local/btcmodules/cellranger_by_sample'


workflow CELLRANGER_DEMULTIPLEX_WF{

    take:
        reference
        vdj_reference
        meta_yaml
        gex_fastq
        gex_id
        cite_fastq
        cite_id
        tcr_fastq
        tcr_id
        bcr_fastq
        bcr_id
        jobmode
        numcores

    main:

        CELLRANGER_DEMULTIPLEX(
            reference,
            meta_yaml,
            gex_fastq,
            gex_id,
            cite_fastq,
            cite_id,
            jobmode,
            numcores
        )

        demux_channel = CELLRANGER_DEMULTIPLEX.out.per_sample_data.flatten()
        CELLRANGER_BAMTOFASTQ(demux_channel)

        new_channel = CELLRANGER_BAMTOFASTQ.out.map{
            it -> [
                it[0], it[1], it[2], tcr_fastq, tcr_id,
                bcr_fastq, bcr_id, cite_fastq, cite_id,
                meta_yaml, reference,
                vdj_reference, jobmode, numcores
            ]
        }

        CELLRANGER_PERSAMPLE(new_channel)
}
