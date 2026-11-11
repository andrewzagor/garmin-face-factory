> **FREE RELEASE DECISION — 2026-11-11:** Apex One's first Venu 2 Store listing is completely free, all existing capabilities and themes included. Select **No** when the listing asks whether the app requests or requires payment. No Merchant Account, $100 annual fee, licensing gate, time-limited trial, external checkout or donation prompt. Earlier draft USD $4.99 references are obsolete for first release.

# Apex One — Precision Luxury · Store listing copy (draft)

**Listing status:** Pre-release draft. No submission, payment account creation, product renaming, or signing keys are included.
**Device:** Garmin Venu 2 only for first release. **Code baseline:** `c737073` (progress ring direction fix).

## English listing — suggested final wording

**Name:** Apex One — Precision Luxury

**Short description / tagline:**
A refined AMOLED watch face with essential daily insights.

**Long description:**
**Apex One — Precision Luxury**

Time deserves a beautiful display.

Apex One pairs a distinctive serif clock with an emerald-inspired mineral dial, warm metallic accents, and two purposeful progress rings — a premium, balanced look made for everyday wear.

**What you'll see**
- **Time & date** — a bold, easy-to-read central clock.
- **Steps at a glance** — a gold ring showing your progress toward your daily step goal, plus a step count.
- **Watch battery** — a turquoise ring showing remaining charge.
- **Weather** — current temperature and a compact condition symbol when data is available.
- **Heart rate** — a recent reading, when provided by the watch.
- **Notifications** — a subtle indicator of active device notifications, visible only when needed.

**Personalize the look**
Choose from three complementary color themes: Orbit Gold, Titanium, and Electric.

**Designed for AMOLED**
A refined dark palette and a simplified Always-On Display help keep the face readable and understated.

**Compatibility**
Initial release: Garmin Venu 2. Other compatible models may be added after device-specific testing.

**Please note**
Weather requires available Garmin weather information and may be temporarily unavailable. Heart-rate data and notifications depend on the watch's own readings and settings. The notification number reflects *active device notifications*, not necessarily unread phone messages. This watch face does not include third-party weather services.

## Suggested metadata
- **Category:** Watch Face
- **Language:** English
- **Keywords:** premium, elegant, luxury, analog-inspired, digital, AMOLED, weather, steps, heart rate, daily, minimalist
- **Price:** Free (USD $0). No merchant setup required for v1.
- **App ID:** preserve existing ID `045c53dc-42ec-4b6c-8ce5-7d1d1cd17c55` so updates are recognized as the same app

## Visual asset status
- **Store card icon, 500×500 px, sRGB:** concept produced; review against final actual watch screenshot before submission.
- **Device icon, 128×128 px, sRGB:** derived from concept; optional, may need simplification for small screen.
- **Real screenshot(s):** pending post-test capture from Connect IQ simulator / actual device.
- **Optional hero, 1440×720:** not necessary for initial submission; postpone.
- **Never** use a generated artistic concept as evidence of the app's actual rendered UI.

## Final export / release sequence
1. Confirm corrected gold steps / cyan battery arcs on actual Venu 2.
2. Finish 24-hour on-device usability + power observation and theme checks.
3. On release commit change only the display-name string `resources/strings/strings.xml` from `GarminFaceFactory` to `Apex One — Precision Luxury` (or store-compliant shorter name). Do not rename the app ID, rewrite AOD, or change branch `main`.
4. Compile again and confirm that the renamed app does not change any device visuals.
5. From VS Code Command Palette run **Monkey C: Export Project**. Select Garmin Venu 2; use your existing secure developer signing key or create/back up a dedicated production key. Keep the private key outside the repository.
6. Use the Garmin Connect IQ Developer Dashboard **Upload an App** and supply the resulting signed `.iq`. After binary validation, fill in the English listing and actual screenshots. For this free release, declare that the application neither requires nor requests payment; do not set up Garmin Merchant.
7. Complete review and approval before describing the app as published.

## Future monetization — not part of the free release
According to Garmin merchant terms, onboarding may involve a non-refundable annual program fee in addition to the stated 15% sales share and local tax/foreign-exchange adjustments. Verify exact merchant onboarding costs in your account **before** paying; do not guess an amount.

## Verified documentation
- https://developer.garmin.com/connect-iq/submit-an-app/
- https://developer.garmin.com/brand-guidelines/connect-iq/
- https://developer.garmin.com/connect-iq/monetization/app-sales/
- https://developer.garmin.com/connect-iq/monetization/merchant-onboarding/
