# Feasibility prototype, 2026-11-06. Not a released R package.
# Assisted-by: OpenAI. No user authorship or maintenance commitment is asserted.
# Public metadata: NASA OSDR Biological Data API. See ../manifest.json.
# No code copied from The-Matrix-2022, isatabr, Risa, or other packages.

read_osdr_snapshot <- function(path) {
    x <- read.csv(path, check.names = FALSE, stringsAsFactors = FALSE,
                  na.strings = character())
    required <- c("id.accession", "id.assay name", "id.sample name",
                  "investigation.study assays.study assay technology type")
    if (!all(required %in% names(x))) stop("Snapshot lacks required ID/assay fields")
    ids <- x[required[1:3]]
    invalid <- vapply(ids, function(v) anyNA(v) || any(!nzchar(trimws(v))), TRUE)
    if (any(invalid)) stop("Missing or empty accession/assay/sample ID")
    if (anyDuplicated(ids)) stop("Duplicate accession/assay/sample key")
    x
}

field_map <- function() {
    list(
        organism = "study.characteristics.organism",
        tissue = c("study.characteristics.material type",
                   "study.characteristics.organism part"),
        ecotype = c("study.factor value.ecotype", "study.characteristics.variety"),
        genotype = "study.characteristics.genotype",
        spaceflight = "study.factor value.spaceflight",
        age_hours = "study.characteristics.age",
        growth_hours = "study.parameter value.growth time",
        hardware = "study.parameter value.hardware",
        light_cycle = "study.parameter value.light cycle",
        light_source = "study.parameter value.light source",
        light_treatment = "study.factor value.treatment",
        preservation = c("study.parameter value.sample preservation method",
                         "study.factor value.sample preservation method"),
        growth_medium = "study.parameter value.growth medium",
        growth_temperature = "study.parameter value.growth temperature"
    )
}

value_status <- function(x) {
    z <- tolower(trimws(x))
    if (is.na(x) || z %in% c("", "na", "n/a", "not available", "unknown")) {
        "missing"
    } else if (z == "not applicable") {
        "not_applicable"
    } else {
        "observed"
    }
}

normalise_value <- function(value, field) {
    z <- tolower(gsub("[[:space:]]+", " ", trimws(value)))
    if (value_status(value) != "observed") return(NA_character_)
    if (field %in% c("age_hours", "growth_hours")) {
        pattern <- "^([0-9]+(?:[.][0-9]+)?) *\\{(day|hour)\\}$"
        match <- regmatches(z, regexec(pattern, z, perl = TRUE))[[1L]]
        if (!length(match)) return(NA_character_)
        value <- as.numeric(match[2L]) * if (match[3L] == "day") 24 else 1
        return(as.character(value))
    }
    # Narrow, explicit alias only. This does NOT validate all BRIC hardware.
    if (field == "hardware" && z == "bric-pdfu (petri dish fixation unit)") {
        z <- "bric-pdfu"
    }
    z
}

harmonise_plant_metadata <- function(x, rnaseq_only = TRUE) {
    technology <- "investigation.study assays.study assay technology type"
    if (rnaseq_only) {
        keep <- tolower(trimws(x[[technology]])) == "rna sequencing (rna-seq)"
        x <- x[keep & !is.na(keep), , drop = FALSE]
    }
    mapping <- field_map()
    cols <- data.frame(accession = x[["id.accession"]],
                       assay = x[["id.assay name"]],
                       sample = x[["id.sample name"]],
                       stringsAsFactors = FALSE)
    for (field in names(mapping)) cols[[field]] <- rep(NA_character_, nrow(x))
    provenance <- list()
    at <- 0L
    for (i in seq_len(nrow(x))) {
        for (field in names(mapping)) {
            candidates <- intersect(mapping[[field]], names(x))
            raw <- vapply(candidates, function(k) as.character(x[[k]][i]), "")
            usable <- !is.na(raw) & nzchar(trimws(raw))
            candidates <- candidates[usable]
            raw <- raw[usable]
            status <- if (!length(raw)) "missing" else vapply(raw, value_status, "")
            normal <- if (!length(raw)) NA_character_ else
                vapply(raw, normalise_value, "", field = field)
            # Retain all observed sources; never silently choose conflicting aliases.
            observed <- status == "observed"
            if (any(observed) && (anyNA(normal[observed]))) {
                result_status <- "unparsed"
                value <- NA_character_
            } else if (length(unique(normal[observed])) > 1L ||
                       (any(observed) && any(status == "not_applicable"))) {
                result_status <- "conflict"
                value <- NA_character_
            } else if (any(observed)) {
                result_status <- "observed"
                value <- unique(normal[observed])[1L]
            } else {
                result_status <- if (any(status == "not_applicable"))
                    "not_applicable" else "missing"
                value <- NA_character_
            }
            cols[[field]][i] <- value
            at <- at + 1L
            provenance[[at]] <- data.frame(
                accession = cols$accession[i], assay = cols$assay[i],
                sample = cols$sample[i], field = field,
                source_fields = paste(candidates, collapse = " | "),
                raw_values = paste(raw, collapse = " | "),
                canonical_value = value, status = result_status,
                stringsAsFactors = FALSE)
        }
    }
    empty <- data.frame(accession=character(),assay=character(),sample=character(),
                        field=character(),source_fields=character(),raw_values=character(),
                        canonical_value=character(),status=character())
    list(col_data = cols, provenance = if (length(provenance))
        do.call(rbind, provenance) else empty)
}

summarise_completeness <- function(provenance) {
    if (!nrow(provenance)) return(data.frame())
    aggregate(list(n = rep(1L, nrow(provenance))),
              provenance[c("accession", "field", "status")], sum)
}

compare_study_profiles <- function(col_data,
        fields = c("organism", "tissue", "ecotype", "age_hours", "hardware",
                   "light_cycle", "preservation")) {
    if (!all(fields %in% names(col_data))) stop("Unknown comparison fields")
    studies <- sort(unique(col_data$accession))
    if (length(studies) < 2L) return(data.frame())
    pairs <- combn(studies, 2L, simplify = FALSE)
    results <- list()
    for (pair in pairs) {
        for (field in fields) {
            left <- col_data[col_data$accession == pair[1L], field]
            right <- col_data[col_data$accession == pair[2L], field]
            a <- sort(unique(left[!is.na(left)]))
            b <- sort(unique(right[!is.na(right)]))
            status <- if (!length(a) || !length(b)) "unavailable_metadata" else
                if (anyNA(left) || anyNA(right)) "incomplete_metadata" else
                if (identical(a, b)) "same_observed_values" else
                if (length(intersect(a, b))) "overlapping_observed_values" else
                "different_observed_values"
            results[[length(results) + 1L]] <- data.frame(
                study_a = pair[1L], study_b = pair[2L], field = field,
                values_a = paste(a, collapse = " | "),
                values_b = paste(b, collapse = " | "),
                n_missing_a = sum(is.na(left)), n_missing_b = sum(is.na(right)),
                result = status, stringsAsFactors = FALSE)
        }
    }
    do.call(rbind, results)
}

summarise_design <- function(col_data) {
    fields <- c("accession", "tissue", "ecotype", "spaceflight", "preservation",
                "light_treatment")
    if (!all(fields %in% names(col_data))) stop("Missing design fields")
    groups <- col_data[fields]
    groups[] <- lapply(groups, function(x) {
        x[is.na(x)] <- "<missing>"
        x
    })
    if (!nrow(groups)) return(data.frame())
    aggregate(list(n_assay_sample_records = rep(1L, nrow(groups))), groups, sum)
}
