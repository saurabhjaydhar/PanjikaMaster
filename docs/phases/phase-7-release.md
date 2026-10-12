# Phase 7 — Release

**Goal:** the app is live on Google Play via a staged rollout, with every launch-checklist item true.

**Read first:** §19 (privacy and licensing checklist), §20 (monetisation, ad rules), §23 (release, store listing, icon, screenshots).

### App core (state, data, platform)
| ID | Task | Done when |
|---|---|---|
| T-701 | AdMob + UMP consent, non-personalised option, test IDs in debug | Consent flow works for an EEA test device |
| T-702 | In-app purchase: remove ads (₹99/yr vs ₹199 lifetime test), restore, premium flag | FR-SET-04; works with a test account |
| T-703 | Release config: final app ID (Q11), version scheme, Play App Signing, AAB, production pack-verify key embedded | Signed AAB builds in CI |

### Frontend (screens & UI)
| ID | Task | Done when |
|---|---|---|
| T-704 | Ad slots per §20.2: native card below "Coming up" on Today, after observances on Day detail, every 15 rows in the festival list (max 2), banner above nav on Calendar; none on Festival detail | Golden + manual check: nothing above the fold on Today |
| T-705 | Remove-ads screen (§11.18) | Both languages |

### Backend (hosting)
| ID | Task | Done when |
|---|---|---|
| T-706 | Production hosting hardened: CDN, HTTPS, backups, uptime monitor; privacy policy pages (bn + en) at a stable URL | Monitor alert tested; policy URL live |
| T-707 | Production-signed packs published; manifest `min_app_version` set | App imports production packs |

### DevOps
| ID | Task | Done when |
|---|---|---|
| T-708 | `release.yml`: tag → signed AAB → Play internal testing track (upload key from secrets) | Internal track receives a build |

### Design & content
| ID | Task | Done when |
|---|---|---|
| T-709 | Store listing in both languages, feature graphic, screenshots (bn and en sets), release notes in Bengali | §23.2–23.4 |
| T-710 | Data safety form content, permission rationale copy, content rating answers | §19.1 items ticked |

### QA
| ID | Task | Done when |
|---|---|---|
| T-711 | Release build on a physical device: sqlite library present, edge-to-edge, predictive back; Play pre-launch report clean; closed testing | Launch checklist in §23 |

### Human gates
- Play Console, AdMob and merchant accounts; block sensitive ad categories
- Final app ID (Q11); production keys stored offline with two backups (Q12)
- Trademark check of the name; final visual and copy sign-off
- Staged rollout 10 → 50 → 100 % over a week

### Exit criteria
- [ ] 100 % rollout; crash-free sessions ≥ 99.5 %
