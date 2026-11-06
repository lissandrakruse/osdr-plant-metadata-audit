# Proposed development scope

## Research question

Which metadata differences, gaps and ambiguities need to be resolved before selecting samples and contrasts for cross-study Arabidopsis RNA-seq analyses?

The current prototype provides an auditable descriptive starting point. A future tool should support a researcher's decision rather than automatically certify that studies can be combined.

## Proposed small MVP

- Validate and harmonize selected metadata from three to five public Arabidopsis RNA-seq studies.
- Preserve the source field, raw value, explicit normalization rule and quality state.
- Keep age, growth duration and flight duration conceptually separate.
- Support explicit sample strata/contrasts, with counts and alerts for factors present in only one condition.
- Reuse Bioconductor infrastructure where appropriate, such as S4Vectors `DataFrame` and validation of existing `SummarizedExperiment` `colData`.
- Include an English, offline, executable vignette with public snapshots and a complete provenance trail.
- Test with native R, then evaluate packaging and applicable Bioconductor checks.

Out of scope: universal ontology equivalence, automatic pooling, differential-expression analysis, batch correction, raw read processing, all species/assays, a complete OSDR mirror, inferred missing values, or a single scientific compatibility score.

## Relevant prior art

- [NASA OSDR Biological Data API](https://visualization.osdr.nasa.gov/biodata/api/) already provides metadata retrieval. A new download-only wrapper would offer limited additional value.
- Barker and colleagues' [Arabidopsis spaceflight meta-analysis](https://pmc.ncbi.nlm.nih.gov/articles/PMC10027818/) and [The-Matrix-2022](https://github.com/dr-richard-barker/The-Matrix-2022) already address metadata comparison and study selection. This project does not claim to be the first matrix or the first R analysis for this problem.
- [isatabr](https://biometris.github.io/isatabr/) provides ISA-Tab tooling; a new full ISA-Tab reader is not proposed.
- [Bioconductor infrastructure reuse guidance](https://contributions.bioconductor.org/reusebioc.html) informs possible integration with existing data classes.

The intended contribution is a small, reusable and auditable layer for validation, field-level provenance and explicit warnings. Whether that is best delivered as an independent package, a contribution to existing infrastructure or a documented workflow remains an open development question. Acceptance into a mentoring program or Bioconductor is not assumed.
