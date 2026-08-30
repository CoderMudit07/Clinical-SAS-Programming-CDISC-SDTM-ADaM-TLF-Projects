## Clinical-SAS-Programming-CDISC-SDTM-ADaM-TLF-Projects
End-to-End Clinical SAS Programming Portfolio demonstrating CDISC SDTM, ADaM, TLF Generation, SAS Macros, Validation and QC using Mock Clinical Trial Data.
## Project Overview
This repository contains a Clinical SAS Programming project developed to demonstrate an end-to-end clinical data workflow and data standardization commonly used in pharmaceutical companies and clinical research organizations (CROs), from raw data processing to SDTM, ADaM, TLF generation, and validation.
The project follows a simplified clinical trial structure and illustrates the process of transforming raw clinical data into SDTM domains, deriving ADaM analysis datasets, generating Tables/Listings/Figures (TLFs), and performing independent quality control validation.

## Disclaimer
- All datasets used in this repository are mock datasets created for learning and portfolio purposes.
- No real patient data has been used.
- The project is intended solely for educational and demonstration purposes.
  
---
## Project Workflow

Raw Clinical Data
SDTM Domain Creation
ADaM Dataset Derivation
TLFs Generation
Independent QC Programming
Validation using PROC COMPARE
Final Reporting structure

---
## Project Structure

### Raw Data
Mock clinical trial datasets used as source data for the project.
Examples:
- Demographics (Raw_Dm)
- Adverse Events (Raw_Ae)
- Exposure (Raw_Ex)
- Disposition (Raw_Ds)
- Informed Conent (Raw_IC)
- Randomization_Dummy  (Raw_dummy_rnd)

### SDTM
SAS programmed to Mapped CDISC-SDTM domains from raw data by Implemententing SDTM IG v3.2.

SDTM Domain Examples:

- DM
- AE
- EX
- DS

### ADaM

Analysis-ready datasets derived from SDTM domains.

Examples:

- ADSL
- ADAE

### Tables, Listings and Figures (TLFs)

Programs developed to generate statistical outputs from ADaM datasets.

Tables Examples:

- Age Statistics Table (Safety Population)
- Age Statistics Table (Multiple Populations table creation using Macros) 
- Treatment Group Summary Table

Listing Examples:
- AE Listing (AE/SAE/Death listing using Macros)
  
### Quality Control

Independent QC programs developed to verify outputs.
Validation performed using:
- Independent Programming 
- PROC COMPARE
---
## Example Deliverables

The repository includes examples of:

- SDTM domain mapped datasets and SAS code 
- ADaM derivations datasets and SAS code logic (simple to complex)
- Population flag implementation
- Treatment group summaries
- Summary statistics (Age)
- Macro-based reporting 
- RTF output generation using Proc Report
- QC and reconciliation workflow

---

## QC and Validation Approach

Production and Quality Control (QC) programs were developed independently using different programming approaches to minimize the risk of replicating the same logic and programming assumptions.
The production outputs were generated using the primary reporting programs, while separate QC programs were developed independently using alternative methods and procedures to derive the same results.
Following completion of both programming streams, output datasets were reconciled and validated using PROC COMPARE to confirm consistency between production and QC results.
This approach reflects the independent double-programming and validation practices commonly used in clinical statistical programming environments.
---

---

## Future Enhancements

Planned additions include:

- Additional SDTM domains
- Expanded ADaM dataset derivations
- Safety analysis outputs
- Efficacy analysis examples
- Automated reporting macros
- Metadata and specification documentation

---

## Endnotes
This project was developed to simulate a complete clinical programming workflow, beginning with source data preparation and progressing through SDTM mapping, ADaM derivation, TLF generation, and independent quality control validation. The repository is intended to serve as a practical demonstration of programming concepts, reporting techniques, and validation practices commonly applied within clinical research and statistical programming environments.
