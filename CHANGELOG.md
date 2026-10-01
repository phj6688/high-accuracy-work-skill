# Changelog

All notable changes to this skill are recorded here.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-10-01

### Added

- The `high-accuracy-work` skill sets a standard for work on files and data in
  seven parts: method, confidentiality, coverage, verification, calibration,
  limits, and delivery.
- `verify.sh` is the local gate. The GitHub Actions CI workflow ends in one gate
  job, `CI passed`, which needs every other job to pass.
