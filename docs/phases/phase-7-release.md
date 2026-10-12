# Phase 7 — Release

**Goal:** the app is live on Google Play via a staged rollout, with every launch-checklist item true.

**Read first:** §19 (privacy and licensing checklist), §20 (monetisation, ad rules), §23 (release, store listing, icon, screenshots).

## Tasks

| ID | Task | Done when |
|---|---|---|
| T-701 | AdMob with the §20.2 placement rules + UMP consent; test IDs in debug | No ad above the fold on Today; no interstitials |
| T-702 | In-app purchase: remove ads + restore | §11.18 flow works with a test account |
| T-703 | Store assets in both languages: listing, icon, feature graphic, screenshots | §23.2–23.4 |
| T-704 | Data safety form, privacy policy (bn + en), permission rationale copy | §19.1 items ticked |
| T-705 | Release build check on a physical device (sqlite library, edge-to-edge, predictive back), production-signed pack, staged rollout 10 → 50 → 100 % | Launch checklist in §23 complete |

## Human gates
- Play Console, AdMob and merchant accounts
- Final app ID (Q11), production signing keys stored offline (Q12)
- Final visual and copy sign-off

## Exit criteria
- [ ] 100 % rollout with crash-free sessions ≥ 99.5 %
