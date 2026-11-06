# OSDR plant metadata audit

A runnable R feasibility prototype for auditing selected metadata from Arabidopsis RNA-seq studies in the NASA Open Science Data Repository (OSDR).

The goal is to make differences, missing values and ambiguous mappings visible **before** researchers define cross-study contrasts. It does not decide whether studies can be pooled.

**Status:** early script prototype for discussion and development. This is not an installable R package, an official NASA or Bioconductor project, a Bioconductor submission, or a validated scientific eligibility classifier. Substantial AI assistance is disclosed in [AI_ASSISTANCE.md](AI_ASSISTANCE.md).

## Quick start

From the repository root, with native R installed:

```sh
Rscript prototype/tests.R
Rscript audit/edge_tests.R
Rscript prototype/demo.R
python3 audit/verify_outputs.py
```

The demonstration runs offline using the included metadata snapshots. The Python verifier uses only the standard library. Native R commands are the intended next validation target; they have **not** been executed in the preparation environment.

The tested alternative uses Node.js and webR 0.6.0:

```sh
npm ci --prefix runtime
node runtime/run.mjs
node audit/run_edge.mjs
python3 audit/verify_outputs.py
```

Installing dependencies and starting webR may require internet access. `node_modules` is deliberately excluded. The lockfile pins the dependency tree; a completely fresh npm installation has not yet been verified.

To refresh data, run `python3 download_public_metadata.py`. This requires internet access and **overwrites the snapshots and manifest**. Keep a copy first if reproducing the original result matters. Updated upstream metadata may require corresponding test and mapping changes.

## What it does

- Validates required identifiers and rejects missing or duplicate accession/assay/sample keys.
- Selects records whose declared assay technology is `RNA Sequencing (RNA-Seq)`.
- Applies explicit field aliases and narrow value normalization rules.
- Keeps source field, raw value, normalized value and quality status for every selected field.
- Distinguishes observed, missing, not-applicable, unparsed and conflicting values.
- Reports completeness, pairwise field differences and joint design-cell counts.

## Demonstrated results

Three public API snapshots were retrieved on 2026-11-06 UTC. `manifest.json` records exact URLs, retrieval times and SHA-256 checksums.

- 218 assay/sample records in the source snapshots.
- 104 selected RNA-seq records: OSD-37 = 56, OSD-38 = 12, OSD-120 = 36.
- 1,456 field-level provenance records, 21 pairwise field comparisons and 23 design cells.
- 23 groups of project assertions plus additional edge tests passed in webR 0.6.0, R 4.6.0, wasm32-unknown-emscripten.
- An independent Python recalculation of output/provenance consistency passed. This is automated validation, not independent scientific peer review.

These are **records**, not a claim of 104 independent biological replicates. See [the verification report](audit/AUDIT_REPORT_PT.md) and `results/sessionInfo.txt`.

### Why the distinction matters

OSD-37 and OSD-38 both expose seedlings, BRIC-PDFU hardware and continuous darkness after narrow normalization, but their reported ages are 192 and 76 hours. OSD-37 contains four ecotypes; OSD-38 contains Col-0. Preservation is uniformly RNALater in OSD-37 and mixed in OSD-38. In OSD-38, liquid-nitrogen records occur only in ground controls.

OSD-120 contains root samples and multiple assay technologies. Its selected RNA-seq records lack the queried structured age field while reporting 13 days of growth. The prototype preserves that distinction instead of inferring age from growth time.

## Repository layout

- `prototype/compare.R`: import, harmonization and descriptive summaries.
- `prototype/tests.R`, `audit/edge_tests.R`: executable assertions.
- `prototype/demo.R`: offline demonstration.
- `raw/*.csv`, `manifest.json`: unmodified source snapshots and retrieval provenance.
- `results/`: generated canonical metadata, provenance, completeness, comparisons, design cells and execution logs.
- `audit/`: verification scripts, logs and machine-readable summary.
- `runtime/`: optional webR runner and dependency lockfile.
- [PROJECT_SCOPE.md](PROJECT_SCOPE.md): proposed development scope and relevant prior art.
- [DATA_SOURCES.md](DATA_SOURCES.md): source attribution and reuse guidance.
- [RIGHTS.md](RIGHTS.md): software/data rights and current licensing status.

## Limits and next steps

The mappings have only been checked against these three snapshots. The assay filter is strict, unknown age units remain unparsed, and conflicting aliases are not silently overwritten. Marginal field comparisons do not capture interactions, independence, confounding, missions, protocols, sequencing or processing differences. The design-cell summary is partial, not a full identifiability analysis. Missing queried metadata may be available elsewhere in protocols or publications.

Outputs currently use base `data.frame`, not S4Vectors `DataFrame` or `SummarizedExperiment`. Native R, package installation, `R CMD check`, `BiocCheck`, and cross-platform CI have not been run. The next steps are biological review, native-R validation, broader tests and a decision on whether this should become a package, an existing-package contribution, or a documented workflow. An open-source software license and actual contributor/maintainer roles still need to be selected before a package release.

Data courtesy of NASA OSDR and the study investigators. No endorsement by NASA or Bioconductor is implied.
