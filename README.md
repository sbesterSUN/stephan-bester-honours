# Stephan Bester Honours Project Repository 2026

## Repository Description

This repository contains all the code (bash scripts), manually created .bed files and tool calls that were used over the course of a BSc Honours project for Stephan Bester (27007030) at Stellenbosch University in 2026.

## Project Title

Partners in crime: Guiding microbial isolation of *Megasphaera* sp. by using comparative genomics to infer potential cross-feeding relationships with a bacterium from the *Pseudomonas* group

## Repository Contents

### Overview

| **File name**                  | **Brief Description**                                      |
|:------------------------------:|:----------------------------------------------------------:|
| LICENSE                        | A basic MIT license                                        |
| README.md                      | This file                                                  |
| checkm2_on_pipeline.sh         | Pipeline used to compare assemblies via CheckM2            |
| improve_assemblies_pipeline.sh | Pipeline used to iteratively improve draft genomes         |
| m_hutch_scaffolds.bed          | A genome coordinate file for the *M hutchinsoni* reference |
| tool_execution_log.pdf         | Sequential record of all the tools utilized                |

### LICENSE

A basic MIT licence that describes the copyright and terms of use for this repository. Everything provided in this repository is provided as is.

### checkm2_on_pipeline.sh

The script that was used to run CheckM2 on a range of draft genomes.

### improve_assemblies_pipeline.sh

The script that was used to implement the pipeline to iteratively improve the draft genomes for a specified number of times by remapping unused reads to the most recent assemblies and reassembling the draft genomes with newly mapped reads. The details on how this was implemented can be found annotated in both this file and in the "tool_execution_log.pdf" file.

### m_hutch_scaffolds.bed

A genome coordinate file containing the length of each scaffold of the *M. hutchinsoni* reference genome. This was used to extract reads that mapped to any *M. hutchinsoni* scaffold. 

### **tool_execution_log.pdf** 

Minimal coding and scripts were used in this project as often the tool outputs needed to be taken into consideration for future steps. This file is the record of all the tool calls that were used in the course of the project. **This serves as a detailed description of the methods used in the project**. 

## Contributors 

Main contributor: 
- Stephan Bester

Supervisors:
- Dr. Eduan Wilkinson
- Dr. Brian Kullin
- Prof. Jo-Ann Passmore

## Contact 

For any enquiries, contact Stephan Bester (27007030@sun.ac.za).
