# SoundCraft — Requirements Traceability

Contract R06. Every numbered requirement maps to implementation files, tests, platform support and status.
Statuses: `PLANNED | BUILT | TESTED | BLOCKED(reason)`. This file is updated with every phase.

Requirement ID scheme:
- `R-xx` core contract rules (R01–R15 §0)
- `ROUTE-xx` route inventory (§23.1)
- `CTL-xx` control inventory (§4 / §22)
- `TEST-xx` testing matrix (§12)
- `PLAT-xx` platform access matrix (§24.3)

| ID | Requirement | Implementation | Tests | Android | iOS | Win | Linux | macOS | Web | Status |
|---|---|---|---|---|---|---|---|---|---|---|
| R-01 | Build, don't describe | whole repo | test suite | part | part | part | yes | part | yes | IN PROGRESS |
| R-02 | No fake completeness | lint rule review pending | tests | | | | | | | PLANNED |
| R-04 | Zero secret leakage | `.env.example`, gateway env vars | secret scan in CI | | | | | | | PLANNED |
| R-05 | Legal content first | rights gate `lib/domain/rights.dart` | rights tests | | | | | | | PLANNED |
| R-09 | Responsive/adaptive | `lib/design_system/layout.dart` | golden/widget tests | | | | | | | PLANNED |
| R-11 | Intentional multi-platform | platform folders + CI | CI builds | CI | CI | CI | local | CI | local | PARTIAL |

(Detail rows are appended per phase; see git history for evolution.)
