# Data sources and attribution

Data courtesy of the NASA Open Science Data Repository and the original study investigators.

The included CSVs contain selected structured factual metadata, not raw sequencing data, article text, participant data or private records. All three were obtained from public NASA OSDR Biological Data API query endpoints on 2026-11-06 UTC. manifest.json is the authoritative record of the exact queries, timestamps, record counts and SHA-256 checksums.

- OSD-37: [NASA OSDR study record](https://osdr.nasa.gov/bio/repo/data/studies/OSD-37/).
- OSD-38: [NASA OSDR study record](https://osdr.nasa.gov/bio/repo/data/studies/OSD-38/).
- OSD-120: public API query and exact response checksum are recorded in manifest.json.
- [Biological Data API documentation](https://visualization.osdr.nasa.gov/biodata/api/).

## Reuse and citation

NASA OSDR describes its public data as provided under its open-access policy and asks researchers to cite the datasets and original scientific sources. Its preferred study citation is available from the study's citation panel. Consult that record for the appropriate study version and publications when conducting or publishing a scientific analysis; this prototype is not a substitute for citing the investigators' work.

- [NASA OSDR terms and citation guidance](https://science.nasa.gov/reference/osdr-help-terms-and-conditions/).
- [NASA Science Data Licenses](https://science.data.nasa.gov/about/license).

The NASA license guidance distinguishes explicitly licensed data, NASA-led mission data without restrictive notices, and other data for which source rights should be checked. This repository does not assume that every NASA-hosted work is universally copyright-free, and does not apply a new software license to the data. No restrictive notice was present in the downloaded query responses; they consist of short factual metadata values.

Snapshots are fixed inputs to this demonstration. The repository's API metadata snapshot is not represented as a complete study-version archive. Updating a snapshot changes the reproducibility target, and may change the expected results.
