# Apex One — Garmin Device Expansion Matrix

Research date: 2026-11-11. **No additional devices are enabled yet.** Current `manifest.xml` lists only `venu2`. Source implementation targets the 416×416 Garmin Venu 2 and requires simulator/CI validation per added target.

## First-wave candidates: round AMOLED, 416×416

| Family | Models listed by Garmin | API family | Adaptation |
| --- | --- | --- | --- |
| Venu | Venu 2 Plus | 5.0 | Very low; same screen as Venu 2 |
| Forerunner | Forerunner 265 | 5.2 | Low; check weather, notifications, AOD |
| epix | epix (Gen 2); epix Pro (Gen 2) 47 mm; quatix 7 Sapphire/7 Pro | 5.2 | Low-to-moderate |
| fēnix | fēnix 8 43 mm; fēnix E | 6.0 | Low-to-moderate, device-specific AOD |
| Aviation | D2 Air X10; D2 Mach 1 | 5.0/5.2 | Low-to-moderate |
| Instinct | Instinct 3 AMOLED 50 mm | 6.0 | Validate round clipping and AOD |
| Newer watches | fēnix 9 43 mm; fēnix 9 Pro 43 mm; Approach S72 43 mm | 6.0 | Confirm target availability in installed Connect IQ SDK |

**Support criteria:** compile for exact device ID; inspect time glyphs, date, rings, badges, 99,999 steps and fallback HR/weather; exercise AOD; check watch-face memory and performance. Similar resolution does NOT prove automatic compatibility.

## Second-wave AMOLED groups

- **390×390:** Venu 3S, Venu 4 41 mm, vívoactive 5/6, Forerunner 165/165 Music, Forerunner 570 42 mm, epix Pro (Gen 2) 42 mm, Approach S50/S70 42 mm, MARQ Gen 2. Source requires proper sizing and layout profiles.
- **454×454:** Venu 3, Venu 4 45 mm, Forerunner 965/970, Forerunner 570 47 mm, fēnix 8 47/51 mm, epix Pro (Gen 2) 51 mm, MARQ Gen 3, Approach S70 47 mm. Requires its own layout profile and background resource.
- **360×360:** Venu 2S, Forerunner 265S. Smaller face; explicitly review all text and three bottom metrics.

## Technical findings from Apex One current source

1. `PrecisionBackground` bitmap is **fixed 416×416**, drawn at `(0,0)`; it must not be reused unscaled at 360/390/454.
2. Serif BMFont has a fixed clock size and rendering top y=155×height/416. On smaller faces, its width may approach circular safety margins; test or introduce font/resource variants.
3. Date, notifications, heart/steps/weather icon X positions and their text anchors are primarily absolute pixel coordinates; all must become relative to a 416-reference layout profile or scaled with a documented safe-layout method.
4. Progress-ring radii use width scaling, but ring strokes remain 9/7 pixels; adjust both proportionally and check maximum outer radius plus half stroke against the actual round screen.
5. AOD approved for Venu 2 is **frozen**; another device may require a device-specific adaptation, never an accidental change to the Venu 2 AOD.
6. Older MIP displays, square displays, and tiny 200–280px displays should **not** be silently added to this premium AMOLED version; treat separately if demand justifies it.

## Rollout order

1. Confirm Venu 2 functional ring bug fix and full-day test.
2. Add **Venu 2 Plus + Forerunner 265 + epix (Gen 2) + fēnix 8 43 mm** in a dedicated compatibility commit. Compile and visually test each in Garmin Simulator. No Store publication before these pass.
3. Apply device-aware dimensions/resources for **390×390 and 454×454**, then add models per tested resolution family.
4. Add **360×360** as a dedicated small-face variant if text and bottom metrics can remain legible.
5. Only after Store-supported model matrix is certified, export one signed `.iq` containing approved targets.

## Official sources

- Device display, API compatibility and model list: https://developer.garmin.com/connect-iq/compatible-devices/
- Device reference / IDs: https://developer.garmin.com/connect-iq/device-reference/
- Models eligible for native paid-app sales: https://developer.garmin.com/connect-iq/monetization/app-sales/

**Note:** Garmin Merchant Service supported products are a *subset* of Connect IQ compatible devices. Confirm exact product eligibility prior to listing at a paid price. Garmin can change both lists.

**Release constraint:** Do not alter `main`, Garmin CI workflow, signed keys, or the Venu 2 approved AOD when widening target support.
