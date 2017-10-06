#' Reimann et al., Molecular & Cellular Proteomics 2017
#'
#' Project description: The Z-disc is a protein-rich structure critically important for myofibril development and integrity.
#' In order to monitor the quantiative changes in C2C12 myoblast during myogenesis, a quantitative dimethyl-labelling approach was performed with d0 myoblasts, d5 myotubes and electrical puls stimulated d5 myotubes.
#' Data: Excerpts from the MaxQuant output files "proteinGroups.txt" (spreadsheet proteins); details for protein/protein group identification are given.
#' Identifications referring to reverse hits and potential contaminants have been removed.
#'
#' \itemize{
#'	\item Uniprot Uniprot accession numbers of all proteins assigned to the respective protein group
#'	\item First_ID First ID of Protein group(s) from MaxQuant output file proteinGroups.txt
#'	\item Gene_names Gene names of all proteins assigned to the respective group
#'	\item Protein_names Protein names of all proteins assigned to the respective group
#'	\item Main_cluster Assignment of proteins to the 4 main cluster after k-means clustering
#'	\item Cluster Assignment of proteins to the distinct cluster after k-means clustering
#'	\item Mol_weight_kDa Molecular weight in kDa
#'	\item Number_of_proteins Number of proteins assigned to the respective protein group
#'	\item Peptides Number of identified peptides assigned to the respective protein group
#'	\item Unique_peptides Number of peptide sequences identified across all replicates of this dataset that are unique for the respective protein group
#'	\item Sequence_coverage Percentage of the sequence that is covered by the identified peptides of the best protein sequence contained in the group
#'	\item Mean_log10_ratio_MTP_vs_MT The mean of the log10 transformed protein ratios of paced myotubes MTP to unpaced myotubes MT
#'	\item Mean_log10_ratio_MT_vs_MB The mean of the log10 transformed protein ratios of unpaced myotubes MT to myoblasts MB
#'	\item Mean_log10_ratio_MTP_vs_MB The mean of the log10 transformed protein ratios of paced myotubes MTP to myoblasts MB
#'	\item Minus_log10_p_value_MTP_vs_MB The negative log10 transformed p-value of paced myotubes MTP to unpaced myotubes MT
#'	\item Minus_log10_p_value_MT_vs_MB The negative log10 transformed p-value of unpaced myotubes MT to myoblasts MB
#'	\item Minus_log10_p_value_MTP_vs_MT The negative log10 transformed p-value of paced myotubes MTP to myoblasts MB
#'	\item log10_ratio_MTP_vs_MT The log10 transformed protein ratios of paced myotubes MTP to unpaced myotubes MT for each replicate
#'	\item log10_ratio_MT_vs_MB The log10 transformed protein ratios of unpaced myotubes MT to myoblasts MB for each replicate
#'	\item log10_ratio_MTP_vs_MB The log10 transformed protein ratios of paced myotubes MTP to myoblasts MB for each replicate
#' }
#'
#' @docType data
#' @keywords datasets
#' @name mcp_reimann_et_al_2017
#' @references Warscheid Lab, Freiburg University
#' @usage data(mcp_reimann_et_al_2017)
#' @format A data frame with  2588 rows and 23 variables
"mcp_reimann_et_al_2017"

#' Morgenstern et al., Cell Reports 2017
#'
#'Project description: Mitochondria perform central functions in cellular bioenergetics, metabolism and signaling and their malfunction has been linked to numerous diseases.
#'The available studies cover only part of the mitochondrial proteome and a separation of core mitochondrial proteins from associated fractions has not been achieved.
#'We developed an integrative, quantitative MS-based experimental approach to define the high confidence proteome of yeast mitochondria and to identify new mitochondrial proteins.
#'The analysis includes protein abundance under fermentable and non-fermentable growth, submitochondrial localization, single-protein analysis and subcellular classification of mitochondria-associated fractions.
#'We identified novel mitochondrial interactors of respiratory chain supercomplexes, ATP synthase, AAA proteases, the mitochondrial contact site and cristae organizing system (MICOS) and coenzyme Q biosynthesis cluster as well as new mitochondrial proteins with dual cellular localization.
#'The integrative proteome provides a high confidence source for the characterization of physiological and pathophysiological functions of mitochondria and their integration into the cellular environment.
#'Data: This data are a summary of proteome-wide absolute quantification of proteins under fermentable and non-fermentable growth conditions based on the 'Proteomic Ruler' approach.
#'Raw MS data and complete MaxQuant results files are available via ProteomeXchange with identifier PXD006146.
#' The variables are as follows:
#'
#' \itemize{
#'	\item Systematic_names ToDo
#'	\item Uniprot_ID ToDo
#'	\item Gene_names ToDo
#'	\item Protein_Description ToDo
#'	\item Moleular_weight_Da ToDo
#'	\item High_confidence_mito_proteome ToDo
#'	\item Sequence_coverage ToDo
#'	\item Mean_copy_number_Glucose ToDo
#'	\item Mean_copy_number_Galactose ToDo
#'	\item Mean_copy_number_Glycerol ToDo
#'	\item Absolute_quantification_accuracy ToDo
#'	\item Copy_number_Kulak_et_al_2014 ToDo
#'	\item Copy_number_Chong_et_al_2015 ToDo
#'	\item Copy_number_Ghaemmaghami_et_al_2003 ToDo
#'	\item Cluster ToDo
#'	\item pValue_ANOVA_test ToDo
#'	\item GOBP_terms ToDo
#'	\item GOBP_names ToDo
#'	\item GOMF_terms ToDo
#'	\item GOMF_names ToDo
#'	\item GOCC_terms ToDo
#'	\item GOC_names ToDo
#'	\item Copy_number_Gal_Rep1 ToDo
#'	\item Copy_number_Gal_Rep2 ToDo
#'	\item Copy_number_Gal_Rep3 ToDo
#'	\item Copy_number_Glc_Rep1 ToDo
#'	\item Copy_number_Glc_Rep2 ToDo
#'	\item Copy_number_Glc_Rep3 ToDo
#'	\item Copy_number_Gly_Rep1 ToDo
#'	\item Copy_number_Gly_Rep2 ToDo
#'	\item Copy_number_Gly_Rep3 ToDo
#'	\item Log2_copy_number_Gal_Rep1 ToDo
#'	\item Log2_copy_number_Gal_Rep2 ToDo
#'	\item Log2_copy_number_Gal_Rep3 ToDo
#'	\item Log2_copy_number_Glc_Rep1 ToDo
#'	\item Log2_copy_number_Glc_Rep2 ToDo
#'	\item Log2_copy_number_Glc_Rep3 ToDo
#'	\item Log2_copy_number_Gly_Rep1 ToDo
#'	\item Log2_copy_number_Gly_Rep2 ToDo
#'	\item Log2_copy_number_Gly_Rep3 ToDo
#'	\item MS_Intensity_Gal_Rep1 ToDo
#'	\item MS_Intensity_Gal_Rep2 ToDo
#'	\item MS_Intensity_Gal_Rep3 ToDo
#'	\item MS_Intensity_Glc_Rep1 ToDo
#'	\item MS_Intensity_Glc_Rep2 ToDo
#'	\item MS_Intensity_Glc_Rep3 ToDo
#'	\item MS_Intensity_Gly_Rep1 ToDo
#'	\item MS_Intensity_Gly_Rep2 ToDo
#'	\item MS_Intensity_Gly_Rep3 ToDo
#'	\item mean_log2_copy_number_Gal ToDo
#'	\item mean_log2_copy_number_Gly ToDo
#'	\item mean_log2_copy_number_Glc ToDo
#'	\item Gal_div_Glc ToDo
#'	\item Gly_div_Glc ToDo
#' }
#'
#' @docType data
#' @keywords datasets
#' @name cellr_morgenstern_et_al_2017
#' @references Warscheid Lab, Freiburg University
#' @usage data(cellr_morgenstern_et_al_2017)
#' @format A data frame with  1576 rows and 23 variables
"cellr_morgenstern_et_al_2017"



