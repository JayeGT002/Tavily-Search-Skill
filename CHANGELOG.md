# Changelog

All notable changes will be documented in this file.

---

## [1.0.6] - 2026-04-03

### Security

- **Remove hardcoded path** - Fixed `~/.openclaw/skills/tavily/apikey` hardcoded path, now reads `apikey` file from script's own directory
- **Simplify script structure** - Removed complex quota management logic, now uses Tavily API native `api_key` parameter
- **VirusTotal false positive fix** - Removed suspicious behavioral signatures flagged by VirusTotal (external file reads, complex state management)

### Added

- **Blocklist filtering** - Added `blocklist/` directory, supports filtering low-quality sources

---

## [1.0.5] - 2026-04-03

### Added

- **Search result blocklist filtering** - Added `blocklist/` directory with domain blocklist and filter script
