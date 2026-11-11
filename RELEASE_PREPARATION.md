> **Release decision (2026-11-11): Apex One Venu 2 v1 will be 100% FREE.** Do not enroll or pay $100/year for Garmin Merchant Account. Do not add external payment, paywall, trial or donation prompt in v1. Retain all currently implemented features and themes. Consider monetization only after gathering install/review data. Supersedes earlier paid-plan references below.

# Apex One — Connect IQ Store release preparation

**Status:** Release candidate undergoing Venu 2 physical testing. **Do not publish until gates pass.**
**Baseline app commit:** `c73707344d3927878ad0d2887b0a4bb520b4ba23`
**Branch:** `product/apex-one-v1`
**Primary device:** Garmin Venu 2 (416 × 416, Connect IQ System 5.0)
**Commercial target:** premium paid watch face, target around USD 4.99.

## 1. Release blockers / evidence

- [ ] Confirm battery ring is *cyan* and filled ~90% when battery is 90%.
- [ ] Confirm step-goal ring is *gold* and filled only ~1.5% at 150 / 10,000 steps.
- [ ] Confirm 100% ring, zero ring, missing step goal, step count 99,999.
- [ ] Confirm date/time rollover (23:59 → 00:00), time zone, and long step values do not clip.
- [ ] Verify heart-rate reading after sensor stabilizes; confirm `--` fallback when unavailable.
- [ ] Confirm weather from Garmin cache, no reading when unavailable, and delayed refresh behavior.
- [ ] Confirm notification count appears at >0 and disappears at zero; check badge at 9+.
- [ ] Confirm Orbit Gold, Titanium and Electric palette settings work without unreadable text.
- [ ] Check previously approved AOD (time, arcs, burn-in offset) and wake/sleep transitions.
- [ ] Record a minimum full day of normal wear: starting / ending battery percentage, AOD setting, usual device activity. Avoid claims about battery life without a baseline.
- [ ] Confirm no unexpected crashes, severe rendering latency, or resets.

**Important:** Garmin CI validates compilation but **not** simulator appearance or physical-watch operation. Do not call the release complete based only on CI.

## 2. Store listing (draft, English)

**Name:** Apex One — Precision Luxury

**Short description:**
Refined timekeeping. Real-time essentials. A distinctive luxury watch face for Garmin.

**Long description:**

Apex One — Precision Luxury is an elegant everyday watch face crafted around a clear clock and understated details.

- Distinctive serif-inspired digital clock, refined emerald-graphite mineral texture, and champagne-gold accents.
- Two meaningful progress rings: daily steps versus your step goal, and remaining watch battery.
- Weather temperature and a compact notification indicator, using available Garmin device information.
- Daily steps and recent heart rate at a glance.
- Three coordinated color themes: Orbit Gold, Titanium, and Electric.
- Carefully simplified Always-On Display on supported devices.

Designed for legibility and measured visual detail, with no unnecessary animations.

**Notes to include / verify before publishing:**
Weather and notifications require device-provided data and may not be available at all times. Heart rate may be temporarily unavailable. Do not claim continuous live HR or instant weather refresh. Device list must exactly match actual tested targets.

**Keywords (draft):** luxury, elegant, digital, watchface, activity, weather, steps, premium, minimal.

## 3. Export and submission

1. After physical test passes, change the app display string from `GarminFaceFactory` to `Apex One — Precision Luxury` if accepted by the Store's naming constraints, then test once again.
2. Decide the final production signing key. **Keep it secure and backed up**: the same key is needed for future updates. Never commit signing keys or upload them to a public repository.
3. Use VS Code **Monkey C: Export Project** for the selected supported devices to produce a signed `.iq` package. The sideloaded `.prg` is not the Store submission package.
4. Submit the `.iq` to Connect IQ developer portal; after binary validation, enter listing text and upload real screenshots.
5. Complete Garmin merchant onboarding if not already enabled, then select a supported paid-app price point close to target USD 4.99.
6. Review listing and submit to Garmin approval; do not assume automatic publication.

## 4. Store media plan

- Main app icon: 500 × 500 px, sRGB, with padding; use original Apex One watch-face-inspired artwork (do not use Garmin logo or misrepresent a simulated screen as a live screenshot).
- Optional on-device store icon: 128 × 128 px.
- Optional hero art: 1440 × 720 px.
- Accurate watch-face screenshots: primary face at a useful realistic step count and charge; alternate Titanium and Electric themes; optional AOD.
- Capture these after final UI approval from the Connect IQ simulator or physical Venu 2. Do not represent generated concept images as actual app screenshots.

## 5. Commercial constraints verified 2026-11-11

- Garmin's native paid-app supported-product list includes Venu 2 at API 5.0.
- Poland is listed among supported countries for native Connect IQ purchases.
- Garmin describes set price points; the Store merchant account determines available choices.
- Garmin's stated commission: 15% of tax-exclusive price before other possible deductions.

**Official Garmin guidance:**
- https://developer.garmin.com/connect-iq/submit-an-app/
- https://developer.garmin.com/connect-iq/monetization/app-sales/
- https://developer.garmin.com/brand-guidelines/connect-iq/
- https://developer.garmin.com/connect-iq/device-reference/venu2/
- https://developer.garmin.com/connect-iq/connect-iq-basics/getting-started/

## 6. Next action

While Venu 2 is being tested, prepare listing screenshots and asset artwork only from the verified working layout. After test evidence is available, finish signing/export, store metadata, merchant setup, then submit. **No code or AOD changes are part of this document-only preparation.**
