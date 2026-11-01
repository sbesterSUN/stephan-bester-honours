#!/usr/bin/env bash

# Global variables
START_ITERATION=4 
END_ITERATION=20
LINE="-------------------------------------------------------------------------------\n"

echo -e "${LINE}${LINE}Starting draft genome improvement pipeline\n${LINE}${LINE}"

for (( round=START_ITERATION; round<=END_ITERATION; round++ )); do

  echo "Round $round start"
  prev_round=$((round - 1))
  
  # Setup directory structure to contain the draft genomes and associated files
  echo -e "${LINE}\tSetting up directory structure"
  mkdir pipeline_mapping_round_${round}
  cd pipeline_mapping_round_${round} || (echo "pipeline_mapping_round_${round} not found"; exit 1)
  mkdir m_hutch
  mkdir s_stut
  mkdir reads_from_round_$prev_round
  
  # Extract unused reads
  (
    echo -e "${LINE}\tPrepare reads to maps"
    echo -e "\t\tExtracting unused reads from:"
    echo -e "\t\t\tM_hutch"
    cd reads_from_round_$prev_round || (echo "reads_from_round_$prev_round not found"; exit 1)
    samtools view ../../pipeline_mapping_round_${prev_round}/m_hutch/m_hutch_round_${prev_round}_sorted_under_q10.bam | cut -f1 | sort -u > m_hutch_unmapped_reads_from_round_${prev_round}.txt
    echo -e "\t\t\tS_stut"
    samtools view ../../pipeline_mapping_round_${prev_round}/s_stut/s_stut_round_${prev_round}_sorted_under_q10.bam | cut -f1 | sort -u > s_stut_unmapped_reads_from_round_${prev_round}.txt
    
    echo -e "\t\tCombine reads that were unused in both species"
    comm -12 m_hutch_unmapped_reads_from_round_${prev_round}.txt s_stut_unmapped_reads_from_round_${prev_round}.txt > unmapped_reads_round_${prev_round}.txt
    samtools view -N unmapped_reads_round_${prev_round}.txt -b ../../comp_map_initial/results_with_only_single/initial_comp_mapped_sorted.bam > unmapped_reads_round_${prev_round}.bam
    unmapped_read_count=$(samtools view -c unmapped_reads_round_${prev_round}.bam)
    echo -e "\t\t\tTotal unused reads: $unmapped_read_count"
    
    if [ $unmapped_read_count -lt 100 ]; then
      echo -e "\t\tToo few reads to continue"
      exit 1
    fi
    
    echo -e "\t\tConverting to fastq"
    samtools sort -n unmapped_reads_round_${prev_round}.bam -o unmapped_reads_round_${prev_round}_namesorted.bam
    samtools fastq -1 unmapped_reads_round_${prev_round}_R1.fastq.gz -2  unmapped_reads_round_${prev_round}_R2.fastq.gz -s unmapped_reads_round_${prev_round}_singletons.fastq.gz unmapped_reads_round_${prev_round}_namesorted.bam
  )
  
  echo -e "${LINE}\tM_hutch processing:"
  (
    # Map reads to m_hutch
    echo -e "\t\tRead mapping"
    cd m_hutch || (echo "m_hutch not found"; exit 1)
    bowtie2-build ../../pipeline_mapping_round_${prev_round}/m_hutch/assembly/contigs.fasta m_hutch_from_round_${prev_round}_index
    echo -e "$LINE Bowtie stats:"
    bowtie2 --very-sensitive \
      -x m_hutch_from_round_${prev_round}_index \
      -1 ../reads_from_round_${prev_round}/unmapped_reads_round_${prev_round}_R1.fastq.gz \
      -2 ../reads_from_round_${prev_round}/unmapped_reads_round_${prev_round}_R2.fastq.gz \
      -U ../reads_from_round_${prev_round}/unmapped_reads_round_${prev_round}_singletons.fastq.gz \
      -S m_hutch_round_${round}.sam
    
    # Process files
    echo -e "${LINE}\t\tProcessing files"
    samtools view -b m_hutch_round_${round}.sam > m_hutch_round_${round}.bam
    samtools sort m_hutch_round_${round}.bam -o m_hutch_round_${round}_sorted.bam
    samtools index m_hutch_round_${round}_sorted.bam 
    
    # Filter files
    samtools view -b -q 10 \
      -o m_hutch_round_${round}_sorted_q10.bam \
      -U m_hutch_round_${round}_sorted_under_q10.bam \
      m_hutch_round_${round}_sorted.bam
      
    read_count=$(samtools view -c m_hutch_round_${round}_sorted.bam)
    echo -e "${LINE}\t\tReads to be used: ${read_count}" 
    
    # Get fasta files
    echo -e "${LINE}\t\tExtracting fasta files"
    mkdir "assembly"
    samtools merge m_hutch_reads_assembly_${round}.bam \
      m_hutch_round_${round}_sorted_q10.bam \
      ../../pipeline_mapping_round_${prev_round}/m_hutch/m_hutch_reads_assembly_${prev_round}_namesorted.bam
    samtools sort -n m_hutch_reads_assembly_${round}.bam \
      -o m_hutch_reads_assembly_${round}_namesorted.bam
    samtools fastq \
      -1 m_hutch_${round}_R1.fastq.gz \
      -2 m_hutch_${round}_R2.fastq.gz \
      -s m_hutch_${round}_singletons.fastq.gz \
      m_hutch_reads_assembly_${round}_namesorted.bam
      
    # Assemble
    echo -e "${LINE}\t\tAssembly"
    cd assembly || (echo "assembly dir not found"; exit 1)
    spades.py --isolate \
      -1 ../m_hutch_${round}_R1.fastq.gz \
      -2 ../m_hutch_${round}_R2.fastq.gz \
      -s ../m_hutch_${round}_singletons.fastq.gz \
      -o ./
      
    echo -e "${LINE}\tM_hutch completed!"
  )
  
  echo -e "${LINE}\tS_stut processing:"
  (
    # Map reads to s_stut
    echo -e "\t\tRead mapping"
    cd s_stut || (echo "s_stut not found"; exit 1)
    bowtie2-build ../../pipeline_mapping_round_${prev_round}/s_stut/assembly/contigs.fasta s_stut_from_round_${prev_round}_index
    echo -e "$LINE Bowtie stats:"
    bowtie2 --very-sensitive \
      -x s_stut_from_round_${prev_round}_index \
      -1 ../reads_from_round_${prev_round}/unmapped_reads_round_${prev_round}_R1.fastq.gz \
      -2 ../reads_from_round_${prev_round}/unmapped_reads_round_${prev_round}_R2.fastq.gz \
      -U ../reads_from_round_${prev_round}/unmapped_reads_round_${prev_round}_singletons.fastq.gz \
      -S s_stut_round_${round}.sam
      
    # Process files
    echo -e "${LINE}\t\tProcessing files"
    samtools view -b s_stut_round_${round}.sam > s_stut_round_${round}.bam
    samtools sort s_stut_round_${round}.bam -o s_stut_round_${round}_sorted.bam
    samtools index s_stut_round_${round}_sorted.bam 
    
    # Filter files
    samtools view -b -q 10 \
      -o s_stut_round_${round}_sorted_q10.bam \
      -U s_stut_round_${round}_sorted_under_q10.bam \
      s_stut_round_${round}_sorted.bam
      
    read_count=$(samtools view -c s_stut_round_${round}_sorted.bam)
    echo -e "${LINE}\t\tReads to be used: ${read_count}" 
    
    # Get fasta files
    echo -e "${LINE}\t\tExtracting fasta files"
    mkdir "assembly"
    samtools merge s_stut_reads_assembly_${round}.bam \
      s_stut_round_${round}_sorted_q10.bam \
      ../../pipeline_mapping_round_${prev_round}/s_stut/s_stut_reads_assembly_${prev_round}_namesorted.bam
    samtools sort -n s_stut_reads_assembly_${round}.bam \
      -o s_stut_reads_assembly_${round}_namesorted.bam
    samtools fastq \
      -1 s_stut_${round}_R1.fastq.gz \
      -2 s_stut_${round}_R2.fastq.gz \
      -s s_stut_${round}_singletons.fastq.gz \
      s_stut_reads_assembly_${round}_namesorted.bam
      
    # Assemble
    echo -e "${LINE}\t\tAssembly"
    cd assembly || (echo "assembly dir not found"; exit 1)
    spades.py --isolate \
      -1 ../s_stut_${round}_R1.fastq.gz \
      -2 ../s_stut_${round}_R2.fastq.gz \
      -s ../s_stut_${round}_singletons.fastq.gz \
      -o ./
    echo -e "${LINE}\tM_hutch completed!"
  )

  cd ../
  
  echo -e "${LINE}Round $round end"
  echo -e $LINE
done

echo -e "\nPipeline completed successfully!"