source("prototype/compare.R")
stopifnot(normalise_value("8 {day}", "age_hours") == "192")
stopifnot(normalise_value("76 {hour}", "age_hours") == "76")
stopifnot(is.na(normalise_value("unknown unit", "age_hours")))
stopifnot(value_status("Not Applicable") == "not_applicable")
stopifnot(value_status("Not Available") == "missing")
stopifnot(normalise_value("BRIC-PDFU (Petri Dish Fixation Unit)", "hardware") ==
          normalise_value("BRIC-PDFU", "hardware"))
x37 <- read_osdr_snapshot("raw/OSD-37.csv")
x38 <- read_osdr_snapshot("raw/OSD-38.csv")
x120 <- read_osdr_snapshot("raw/OSD-120.csv")
xdup <- rbind(x37, x37[1L, ])
tmp <- tempfile(fileext = ".csv")
write.csv(xdup, tmp, row.names = FALSE)
stopifnot(inherits(try(read_osdr_snapshot(tmp), silent=TRUE), "try-error"))
unlink(tmp)
y37 <- harmonise_plant_metadata(x37)
y38 <- harmonise_plant_metadata(x38)
y120 <- harmonise_plant_metadata(x120)
stopifnot(nrow(y37$col_data) == 56L, nrow(y38$col_data) == 12L,
          nrow(y120$col_data) == 36L)
stopifnot(all(y38$col_data$tissue == "seedlings"))
stopifnot(all(y38$col_data$ecotype == "col-0"))
# Growth duration is NOT automatically treated as age.
stopifnot(all(is.na(y120$col_data$age_hours)),
          all(y120$col_data$growth_hours == "312"))
# Conflicting aliases are flagged, not silently overwritten.
conflict <- x37[1L, ]
conflict[["study.characteristics.organism part"]] <- "Plant Roots"
yc <- harmonise_plant_metadata(conflict)
stopifnot(is.na(yc$col_data$tissue),
          yc$provenance$status[yc$provenance$field == "tissue"] == "conflict")
empty <- harmonise_plant_metadata(x37[FALSE, ])
stopifnot(nrow(empty$col_data) == 0L, nrow(empty$provenance) == 0L)
cd <- rbind(y37$col_data, y38$col_data, y120$col_data)
p <- compare_study_profiles(cd)
stopifnot(nrow(p) == 21L)
stopifnot(p$result[p$study_a=="OSD-37" & p$study_b=="OSD-38" &
                  p$field=="age_hours"] == "different_observed_values")
stopifnot(p$result[p$study_a=="OSD-120" & p$study_b=="OSD-37" &
                  p$field=="age_hours"] == "unavailable_metadata")
stopifnot(p$result[p$study_a=="OSD-37" & p$study_b=="OSD-38" &
                  p$field=="ecotype"] == "overlapping_observed_values")
cd$hardware[1L] <- NA_character_
p <- compare_study_profiles(cd, "hardware")
stopifnot(p$result[p$study_a=="OSD-37" & p$study_b=="OSD-38"] == "incomplete_metadata")
cat("All 18 assertion groups passed.\n")
design <- summarise_design(rbind(y37$col_data, y38$col_data, y120$col_data))
stopifnot(sum(design$n_assay_sample_records) == 104L)
stopifnot(all(design$spaceflight[design$accession == "OSD-38" &
               design$preservation == "liquid nitrogen"] == "ground control"))
cat("Two additional design-cell assertion groups passed (20 total).\n")

# IDs must exist; distinct tuples must not collide through a string separator.
blank <- x37[1L, ]
blank[["id.sample name"]] <- " "
write.csv(blank, tmp, row.names = FALSE)
stopifnot(inherits(try(read_osdr_snapshot(tmp), silent=TRUE), "try-error"))
pair <- x37[1:2, ]
pair[["id.assay name"]] <- c("a::b", "a")
pair[["id.sample name"]] <- c("c", "b::c")
write.csv(pair, tmp, row.names = FALSE)
stopifnot(nrow(read_osdr_snapshot(tmp)) == 2L)
unlink(tmp)
stopifnot(all(design$n_assay_sample_records[design$accession == "OSD-120"] == 3L))
cat("Three additional ID and light-stratification assertion groups passed (23 total).\n")
