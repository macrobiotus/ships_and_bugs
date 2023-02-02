# Getting a SRA sequencing metadata file
# - 2-Feb-2023 
# - Paul Czechowski

# Objective is to fill the last column of the pre-filled file:
# "/Users/paul/Documents/CU_NIS-WRAPS_manuscript/230201_data_submission/230201_sra/SRA_metadata_draft.xlsx"

library("magrittr")
library("dplyr")
library("readr")
library("readxl")
library("janitor")
library("hablar")
library("stringr")

# To extract barcodes from file names
# https://stackoverflow.com/questions/44934703/r-extract-string-between-nth-and-ith-instance-of-delimiter
xtr_str = function(x, n, i){
  do.call(c, lapply(x, function(X)
    paste(unlist(strsplit(X, "_"))[(n+1):(i)], collapse = "_")))
}

# https://stackoverflow.com/questions/5831794/opposite-of-in-exclude-rows-with-values-specified-in-a-vector
'%!in%' <- function(x,y)!('%in%'(x,y))

# Read in preliminary SRA files  ----

# _a) Biosample files (accepted) ----

sra_bio <- read_excel("/Users/paul/Documents/CU_NIS-WRAPS_manuscript/230201_data_submission/230201_sra/MIMARKS.survey.water.6.0_filled_samples_only.xlsx", skip = 11, .name_repair = "universal")

# _b) Sequencing metadata file (unfinished) ----

sra_seq <- read_excel("/Users/paul/Documents/CU_NIS-WRAPS_manuscript/230201_data_submission/230201_sra/SRA_metadata_draft.xlsx", sheet = 2, .name_repair = "universal")

# Read in Qiime files  ----

# _a) Manifest files ----

# - CU_RT_AN
man1 <- read_excel(path = "/Volumes/paul/Documents/CU_RT_AN/Zenodo/Manifest/08_18S_manifest_10410623_preliminary.xlsx", skip = 1, .name_repair = "universal" )

# - CU_US_ports_a
man2 <- read_delim(file = "/Volumes/paul/Documents/CU_US_ports_a/Zenodo/Manifest/05_18S_manifest_local.txt", delim = ",", skip = 2,  col_names = c("sample.id", "absolute.filepath", "direction"))

# - CU_WL_GH_ZEE
man3 <- read_delim(file = "/Volumes/paul/Documents/CU_WL_GH_ZEE/Zenodo/Manifest/03_18S_manifest_10414227_full.txt", delim = ",", skip = 2,  col_names = c("sample.id", "absolute.filepath", "direction"))

# __ isolate barcodes ----

man1 %<>% mutate(barcode = xtr_str(x = absolute.filepath, n = 13, i = 14)) 
man2 %<>% mutate(barcode = xtr_str(x = absolute.filepath, n = 10, i = 11)) # isolate barcode -  for merging later
man3 %<>% mutate(barcode = xtr_str(x = absolute.filepath, n = 14, i = 15)) # isolate barcode -  for merging later


# _b) Separate mapping file of original analysis - from network drive ----

# - CU_RT_AN
met1 <- read_delim(file = '/Volumes/paul/Documents/CU_RT_AN/Zenodo/Manifest/10_18S_mapping_file_10410623.tsv')
# - CU_US_ports_a
met2 <- read_delim(file = '/Volumes/paul/Documents/CU_US_ports_a/Zenodo/Manifest/05_18S_merged_metadata.tsv')
# - CU_WL_GH_ZEE
met3 <- read_delim(file = '/Volumes/paul/Documents/CU_WL_GH_ZEE/Zenodo/Manifest/05_18S_mapping_file_run_10414227_full.txt')

# __ type correction  ----

met1 %<>% convert(chr(SampleID, BarcodeSequence, LinkerPrimerSequence, Port, Location, Type, Long, Facility), dbl(Temp, Sali, Lati, Run, CollYear))

met2 %<>% convert(chr(SampleID, BarcodeSequence, LinkerPrimerSequence, Port, Location, Type, Long, Facility), dbl(Temp, Sali, Lati, Run, CollYear))

met3 %<>% convert(chr(SampleID, BarcodeSequence, LinkerPrimerSequence, Port, Location, Type, Long, Facility), dbl(Temp, Sali, Lati, Run, CollYear))

# Fomat QIIME data for merging with SRA data ----

# _a) Merge manifest und metadata, based on barcode----

man_met1 <- left_join(man1, met1, by = c("barcode" =  "BarcodeSequence"))
man_met2 <- left_join(man2, met2, by = c("barcode" =  "BarcodeSequence"))
man_met3 <- left_join(man3, met3, by = c("barcode" =  "BarcodeSequence"))

# _b) Stack data ---- 
qiime_full <- bind_rows(man_met1, man_met2, man_met3) # looks ok - should work

# _c) Format stacked QIIME data for merging, while handling files  ----

# __1.) Rename file paths to point to network drive ----

qiime_full %<>% mutate(absolute.filepath = str_replace(absolute.filepath, "/Users/paul/Sequences", "/Volumes/paul/Sequences"))

# __2.) Copy files from network storage to new upload storage folder to facilitate uploading  ----

target_dir <- "/Users/paul/Documents/CU_NIS-WRAPS_manuscript/230201_data_submission/230201_sra_seq_files/"
source_files <- qiime_full %>% pull(absolute.filepath)
# file.copy(source_files, target_dir)

# __3.) Truncate file names in Qiime data ----

qiime_full %<>% mutate(absolute.filepath = basename(absolute.filepath))
qiime_full %<>% rename(filepath = absolute.filepath)

# __4.) Move file names side-by-side for megring with SRA data  ----

qiime_full_fwd <- qiime_full %>% filter(direction == "forward")
qiime_full_rev <- qiime_full %>% filter(direction == "reverse")

# dims should be identical - yes 
dim(qiime_full_fwd)
dim(qiime_full_rev)

qiime_full_rev_filenames <- qiime_full_rev %>% dplyr::select(sample.id, filepath)
qiime_full_wide <- left_join(qiime_full_fwd, qiime_full_rev_filenames, by = "sample.id")
qiime_full_wide %<>% relocate(filepath.y, .after = filepath.x)
qiime_full_wide %<>% select(-direction)




# Merge QIIME data and preliminary SRA data ----

# _a) Isolate forward reads----

sra_seq_fwd <- qiime_full_wide %>% select(SampleID, filepath.x)

# and rename for joining
sra_seq_fwd %<>% rename(filename = filepath.x)
sra_seq_fwd %<>% rename(library_ID = SampleID)

# _b) Isolate reverse reads ----

sra_seq_rev <- qiime_full_wide %>% select(SampleID, filepath.y)

# and rename for joining
sra_seq_rev %<>% rename(filename2 = filepath.y)
sra_seq_rev %<>% rename(library_ID = SampleID)

# _c) Merge files into draft Excel file ----

# merge filenames into table 
sra_seq %<>% left_join(sra_seq_fwd, by = "library_ID")
sra_seq %<>% left_join(sra_seq_rev, by = "library_ID")

# tidy column names
sra_seq %>% select(filename.y, filename2.y, filename.x, filename2.x)
sra_seq <- sra_seq %>% select(-filename.x, -filename2.x)
sra_seq %<>% rename(filename = filename.y, filename2 = filename2.y)
sra_seq %>% select(filename, filename2)
sra_seq %<>% relocate(filename2, .before = filename3)
sra_seq %<>% relocate(filename, .before = filename2)

# _d) Delete superfluous files

all_seq_files <- list.files("/Users/paul/Documents/CU_NIS-WRAPS_manuscript/230201_data_submission/230201_sra_seq_files")

keep_seq_files <- c(sra_seq$filename,sra_seq$filename2) 


delete_seq_files <- all_seq_files[all_seq_files  %!in%  keep_seq_files]

file.remove(paste0("/Users/paul/Documents/CU_NIS-WRAPS_manuscript/230201_data_submission/230201_sra_seq_files/", delete_seq_files))

# Save data ----

openxlsx::write.xlsx(x = sra_seq,  sheetName = "SRA_data",  file = "/Users/paul/Documents/CU_NIS-WRAPS_manuscript/230201_data_submission/230201_sra/230223_get_sra_filenames__sra_seq.xlsx")
openxlsx::write.xlsx(x = qiime_full, file = "/Users/paul/Documents/CU_NIS-WRAPS_manuscript/230201_data_submission/230201_sra/230223_get_sra_filenames__qiime_data.xlsx")
save.image("/Users/paul/Documents/CU_NIS-WRAPS_manuscript/230201_data_submission/230201_sra/230223_get_sra_filenames__workspace.Rdata")

