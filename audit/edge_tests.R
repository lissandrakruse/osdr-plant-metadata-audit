source('prototype/compare.R')
report <- function(label, expr) {
  v <- tryCatch(force(expr), error = function(e) paste('ERROR:', conditionMessage(e)))
  cat(label, ': ', paste(v, collapse = ' | '), '\n', sep='')
}
x <- read_osdr_snapshot('raw/OSD-37.csv')
roundtrip <- function(d) {
  p <- tempfile(fileext='.csv'); on.exit(unlink(p)); write.csv(d,p,row.names=FALSE,na=''); read_osdr_snapshot(p)
}
blank <- x[1L,,drop=FALSE]; blank[['id.sample name']] <- ''
report('BLANK_SAMPLE_REJECTED', inherits(try(roundtrip(blank),silent=TRUE),'try-error'))
collision <- x[1:2,,drop=FALSE]
collision[['id.assay name']] <- c('a::b','a')
collision[['id.sample name']] <- c('c','b::c')
report('DISTINCT_TUPLES_ACCEPTED', !inherits(try(roundtrip(collision),silent=TRUE),'try-error'))
for (v in c('24 {hour}', '1 {day}', '1.5 {day}', 'NA', 'Not Applicable', 'Not Available', 'bad unit')) {
 report(paste('NORMALISE',v), normalise_value(v,'age_hours'))
}
z <- x[1L,,drop=FALSE]; z[['study.characteristics.organism part']] <- 'Not Applicable'
y <- harmonise_plant_metadata(z)
report('OBSERVED_VS_NOT_APPLICABLE_CONFLICT', y$provenance$status[y$provenance$field=='tissue']=='conflict')
z <- x[1L,,drop=FALSE]; z[['study.characteristics.organism part']] <- 'Not Available'
y <- harmonise_plant_metadata(z)
report('OBSERVED_VS_MISSING_OBSERVED', y$provenance$status[y$provenance$field=='tissue']=='observed')
z <- x[1L,,drop=FALSE]; z[['study.characteristics.age']] <- '8 {fortnight}'
y <- harmonise_plant_metadata(z)
report('UNSUPPORTED_UNIT_FLAGGED', y$provenance$status[y$provenance$field=='age_hours']=='unparsed')
z <- x[1L,,drop=FALSE]; z[['investigation.study assays.study assay technology type']] <- 'RNASeq'
y <- harmonise_plant_metadata(z)
report('UNRECOGNISED_TECHNOLOGY_SILENTLY_REMOVED', nrow(y$col_data)==0)
