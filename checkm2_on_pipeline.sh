#!/usr/bin/env bash

# Global variables 
START_ITERATION=4 
END_ITERATION=20

echo -e "Running CheckM2 on draft genome assemblies ${START_ITERATION} to ${END_ITERATION}"

for (( round=START_ITERATION; round<=END_ITERATION; round++ )); do

  echo -e "Round ${round} start\nRunning CheckM2 on M. hutchinsoni"
  checkm2 predict --debug --threads 16 --input pipeline_mapping_round_${round}/m_hutch/assembly/contigs.fasta --output-directory qc_on_4_20/m_hutch/checkM2/${round}
  
  echo -e "\nRunning CheckM2 on S. stutzeri"
  checkm2 predict --debug --threads 16 --input pipeline_mapping_round_${round}/s_stut/assembly/contigs.fasta --output-directory qc_on_4_20/s_stut/checkM2/${round}

  echo -e "Round ${round} end"
done

echo -e "\nPipeline completed successfully!"