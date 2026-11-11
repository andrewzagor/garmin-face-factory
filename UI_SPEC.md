# Apex One / Orbit — Frozen UI Specification

**Product:** Apex One · premium everyday Garmin watch face · target price $4.99  
**Selected direction:** Orbit's functional circular progress rings + Precision's clean information hierarchy  
**Primary target:** Garmin Venu 2 · 416 × 416 round AMOLED  
**Status:** UI specification baseline frozen for implementation; no code authorized by this document  
**Companion requirements:** `PRODUCT_BRIEF.md` and `GARMIN_FACTORY.md`

## 1. Product and experience contract

Apex One / Orbit must be instantly legible, polished, original, and useful throughout everyday work, casual activity, and fitness. The viewer should identify the time and essential status in approximately one second. Premium quality comes from proportion, typography, negative space, smooth functional rings, and reliability—not decoration or excessive data.

**No product name, logo, “APEX ONE” heading, shadows, gradients, animations, or decorative rings on the actual watch face.** Branding belongs to the Connect IQ Store listing, not the display.

This specification describes the **single excellent default v1 configuration**. It must look finished without user configuration. Future settings are architectural considerations, not a requirement to implement them all in v1.

## 2. Canvas, coordinates, palette, and safe areas

| Property | Value |
| --- | --- |
| Display | 416 × 416 px, round AMOLED |
| Coordinate origin | Top-left (0, 0) |
| Display center | **(208, 208)** |
| Background | **#000000**, true black |
| Safe content radius | **178 px** from (208, 208) |
| Text horizontal bounds | **x = 45..371**, with further circular-edge constraints at each y |
| Primary text | **#F4F1E8** warm white |
| Secondary text | **#BFC5CC** muted cool gray |
| Accent 1 | **#E5A84B** gold — daily step-goal progress |
| Accent 2 | **#55D6CF** cyan — battery percentage progress |

The safe radius is a **circular boundary**, not a rectangular guarantee. All glyph bounding boxes, icons, ring strokes, and end caps must remain inside the circle of radius 178. For any element at vertical coordinate y, its horizontal clearance is limited by the circular boundary; simply keeping its x coordinate between 45 and 371 is insufficient.

Design around the central vertical axis. Allow minor intentional asymmetry only when it improves legibility. Keep breathing room between all text zones and rings. All coordinates below are **design anchors**, not a license to clip: adjust measured font baselines, widths, and exact glyph boxes in the simulator.

## 3. Functional progress-ring system — signature identity

**Two default functional rings**, visually distinct and separated:

| Ring | Data meaning | Color | Proposed centerline radius | Proposed stroke |
| --- | --- | --- | --- | --- |
| Outer | Daily steps / daily step goal | Gold #E5A84B | **169 px** | **7 px** |
| Inner | Battery remaining / 100% | Cyan #55D6CF | **153 px** | **6 px** |

The proposed geometry leaves the outer stroke and rounded cap within the 178 px safe radius; the radial separation is 16 px center-to-center, with a visible gap. Exact widths/radii may be tuned only to improve smoothness, separation, clipping, or legibility during simulator review. **Do not move either ring into text or make the strokes merge.** Unfilled tracks should be subdued, thin or low-contrast dark gray; tracks communicate available scale and are not separate decorative rings.

### Progress semantics

- Both arcs begin at **12 o'clock** and advance **clockwise**.
- **Outer ring:** progress = clamp(steps / stepGoal, 0, 1), only when valid steps and positive goal are available. Steps may exceed the goal numerically; the visible ring caps at 100% without wrapping or showing misleading extra laps.
- **Inner ring:** progress = clamp(batteryPercent / 100, 0, 1), only when a valid battery percentage is available. The inner cyan ring is an additional visualization of the same battery value displayed numerically at bottom right, not a new or invented metric.
- Clamp and validate all input values before converting to angular sweeps; prevent divide-by-zero, negative angles, and out-of-range values.
- Zero progress should show no filled segment; 100% should show a complete circle with no visible overdraw seam where feasible.
- Use rounded arc ends **if practical with supported native drawing APIs**. If unavailable, prioritize smooth, accurate arcs over expensive emulation.
- Prefer efficient native graphics operations to bitmap rings. Avoid continuous animation and unnecessary redraws. Rendering must remain visually smooth at 416 × 416.
- Color and position convey each ring's identity; never use the rings as generic decoration or encode heart rate as an arbitrary progress fraction.
- The inner ring represents **battery**, not heart rate, because battery has a truthful 0–100% scale; a heart-rate progress ring would require an explicit validated target.

### Ring missing-data states

- If step goal is zero, unknown, or unavailable, **do not display a fabricated progress arc**. Render a subdued unfilled track or omit that ring and show steps independently if valid.
- If steps are unavailable, use a subtle `--` fallback and no filled outer arc.
- If battery data is unavailable or invalid, show `--` in its numeric field and omit the filled inner arc.
- Ring fills and numeric readouts must agree; refresh from consistent data snapshots as practical.
- Do not substitute stale sensor values without explicitly defined freshness behavior.

## 4. Time zone — highest priority

| Property | Requirement |
| --- | --- |
| Anchor | Horizontally centered at x = 208; visual center approximately **y = 185** |
| Format | **HH:MM**; support 12-hour and 24-hour settings |
| Color | #F4F1E8 |
| Typography | Bold, clean, geometric numerals; largest element |
| Target visible glyph height | **70–82 px** |
| Style | Flat, sharp, high contrast; no shadows, gradients, or glow |

Use a font actually available in the project/device or a deliberately bundled, supported font when implementation is authorized. A named style is a visual goal, not a claim that a specific Monkey C font exists. Measure real text width and glyph bounds, including `00:00`, `11:11`, `12:59`, `23:59`, and the longest 12-hour representation. Keep time unmistakably dominant and visually separated from date and steps. If 12-hour mode uses AM/PM, keep that marker secondary and safely positioned; never shrink the clock excessively or let it overlap other content.

## 5. Date zone

- Centered at x = 208, approximately **y = 125**.
- Format **SUN 01 NOV** (uppercase weekday, two-digit day, abbreviated month); localization is a later feasibility decision.
- Preferred color #BFC5CC; warm white #F4F1E8 is acceptable only if hierarchy remains clear.
- Target visible height **18–22 px**.
- Leave generous vertical space before the time.
- Never show `APEX ONE` or any other product branding.

## 6. Steps zone

- Centered at x = 208, approximately **y = 260**.
- Display a prominent numeric count, e.g. **8,420**; smaller label **STEPS**.
- Steps are the most important numeric metric after the time.
- Gold #E5A84B may be used selectively to connect the value to the outer ring without overwhelming the clock.
- Use locale-aware digit grouping where practical; prioritize predictable rendering and width measurement.
- Handle `0`, `999`, `9,999`, and `99,999` without overlap, truncation, or clipping.
- **Do not show redundant step-percentage text** when the outer progress ring already communicates goal progress. Numeric step count remains required.
- Arrange numeric value and label within the steps zone so neither collides with time, bottom metrics, or ring strokes.

## 7. Bottom metrics — balanced pair

### Heart rate — left
- Approximate center **(145, 315)**.
- Display heart icon when a supported, legible rendering is practical; otherwise use a clear small text label.
- Display numeric heart rate, e.g. **72**, with optional small `BPM` suffix.
- Use a supported Garmin heart-rate data source. An unavailable or unsuitable reading displays **--**; never invent a reading.
- Heart rate is a **numeric metric**, not a third progress ring.

### Battery — right
- Approximate center **(270, 315)**.
- Display numeric remaining battery, e.g. **86%**.
- Avoid the redundant word `BATTERY` unless testing demonstrates it is necessary.
- Read battery from supported `SystemStats` information; validate bounds before display.
- The inner cyan ring must correspond to this exact battery percentage.

Keep the two blocks optically balanced, separated from one another, and fully inside the **round** safe region. The bottom corners of a round display have less usable width than the center. Test heart icon, BPM suffix, percent symbol, and unavailable states together.

## 8. Fixed visual hierarchy

1. **Time**
2. **Step-goal ring / step count**
3. **Date**
4. **Heart rate**
5. **Battery**

Battery has its own cyan ring but must remain visually secondary; the gold step-goal ring should be the stronger accent. The rings should frame the information rather than compete with the large clock. Symmetry is preferred, with small deliberate asymmetry permitted for readability. Preserve negative space instead of filling unused regions.

## 9. Data contracts and fallback behavior

| Data | Intended source | Validation / fallback |
| --- | --- | --- |
| Time | Garmin system clock | Correct 12/24-hour formatting; valid date/time changes |
| Weekday/date | Supported Garmin date/time APIs | Correct calendar transitions; safe uppercase abbreviation |
| Steps | Garmin activity information | Nonnegative count; `--` if unavailable |
| Daily step goal | Available Garmin activity-goal information | Must be >0 to calculate ring; otherwise no filled arc |
| Heart rate | Supported Garmin heart-rate information | `--` for null, unsupported, or unavailable readings |
| Battery | `SystemStats` | Clamp valid percentage; `--` for unavailable/invalid values |

Actual API symbols and field availability must be confirmed against the project's minimum Connect IQ API level and Venu 2 SDK before coding. Never assume a field exists based solely on the visual specification. No sensor absence, missing activity goal, null, or unexpected value may crash the face.

## 10. AMOLED, rendering, and performance

- True black #000000 background.
- Avoid large continuously lit regions and unnecessary high-brightness fills.
- Prefer supported native drawing operations, efficient font choices, and predictable allocations.
- No animation in v1.
- Refresh the clock and metrics no more often than necessary under device/platform rules.
- Avoid full redraw work when data is unchanged where the platform allows; honor Connect IQ watch-face lifecycle behavior.
- Keep the two rings smooth and legible without expensive bitmap assets or per-frame effects.
- Normal active display prioritizes visual quality while remaining battery-conscious.
- Battery efficiency and responsiveness are release criteria, not optional polish.

## 11. Always-On Display (AOD) / low-power state

Design an **intentional simplified low-power presentation**, subject to the supported Venu 2 capabilities and Connect IQ watch-face lifecycle:

- Keep the time readable and visually consistent with Orbit × Precision.
- Remove or greatly simplify progress rings, especially the brighter gold/cyan fills.
- Reduce secondary information and the illuminated pixel footprint.
- Avoid persistent large bright areas and unnecessary redraws.
- Preserve identity through typography, composition, and restrained accent use rather than full rings.
- Follow the platform's supported low-power update cadence and burn-in mitigation constraints.
- Verify AOD behavior in the simulator where possible and on a real Venu 2 before claiming completion.

AOD must look deliberately designed, **not** like a broken or partially rendered normal face. If device/API constraints prevent a proposed behavior, document and resolve the limitation before release.

## 12. Customization architecture — future-ready, not v1 scope creep

Design data, palette, and layout logic so future releases can support:

- **Default:** gold/cyan.
- **Titanium/silver** theme.
- **Electric blue** theme.
- Configurable metric fields where practical.
- Optional secondary metrics.
- 12/24-hour format selection.

The first implementation must focus on **one excellent default configuration**. Do not implement every customization in v1. Future settings must preserve ring meanings, text contrast, safe margins, and overall premium balance. No configuration should require users to fix an unfinished default appearance.

## 13. Quality gates and test matrix

### Visual geometry
- No clipped text, icons, arcs, end caps, or graphics on the Venu 2 circular display.
- No overlaps between rings and text or between text zones.
- Inspect representative normal values, maximum expected values, missing-data fallbacks, and supported time formats.
- Confirm all elements stay within the **178 px circular safe radius**, and all text within x=45..371 as well.
- Verify outer and inner rings are visually separated and each accurately represents its metric.

### Required scenarios
- **Time:** `00:00`, `11:11`, `12:59`, `23:59` (plus 12-hour format).
- **Steps:** `0`, `999`, `9,999`, `99,999`.
- **Battery:** `5%`, `50%`, `100%`.
- **Heart rate:** valid reading and unavailable/null.
- **Step goal:** valid goal, zero/unknown goal, 0% progress, partial progress, 100%, and over-goal.
- **Display states:** normal and supported AOD/low-power behavior.
- **Date:** weekday/month changes and representative label lengths.

### Release gates
1. Garmin Build CI must pass for the Venu 2 implementation branch.
2. Complete final visual review in the **Venu 2 simulator**.
3. Validate battery/performance and low-power behavior.
4. Complete later **physical Venu 2 testing** before commercial release.
5. Do not call the product release-ready until validation evidence exists.

## 14. Store-quality acceptance

- The default screen is polished enough to serve as the **primary Connect IQ Store screenshot** without requiring customization.
- Time and essential information are understood within approximately **one second**.
- The **two truthful functional rings** create a recognizable Orbit identity even in a small Store thumbnail.
- The display remains balanced, professional, and readable in work, casual, and fitness settings.
- The design is original and does not copy a recognizable existing commercial watch face.
- The commercial $4.99 value proposition rests on polish, usability, reliability, and thoughtful customization—not feature count.

## 15. Conflict resolution and freeze rules

- The progress-ring requirements were supplied twice; they are consolidated here once without losing any constraints.
- **Two rings vs. one defined goal:** The **outer gold ring is step-goal progress**, and the **inner cyan ring is battery remaining**. Both have real denominators and numeric counterparts; neither is decorative.
- **Clamping vs. raw values:** Only ring progress is capped at 100%; numeric steps can exceed the goal and battery remains a bounded percentage.
- **Suggested coordinates vs. circular safety:** Safe margins, measured font bounds, and one-second readability override approximate x/y anchors, font height, and ring geometry when they conflict.
- **Rounded ends / geometric font vs. API limitations:** Use the closest supported, efficient native approach; never introduce unsupported APIs or performance-heavy effects to achieve a cosmetic detail.
- **AOD appearance vs. power constraints:** Platform low-power rules and battery safety override full-detail ring rendering.
- **Product name vs. on-screen space:** `Apex One` remains the product/listing name but is **never drawn on the watch face**.
- **Two rings vs. minimalist hierarchy:** Both rings must remain truthful and visually subordinate to the time; if simulator testing reveals crowding, adjust stroke widths, spacing, and geometry before adding any new UI elements.

**Freeze boundary:** This document defines the approved UI baseline. Implementation must occur only after explicit authorization, in a separate dedicated design branch. Any material departure from these decisions requires a documented spec revision before implementation. No Monkey C code, resources, manifest, workflow, or `GARMIN_FACTORY.md` changes are authorized by this step.

## 16. Approved AOD implementation baseline — 2026-11-02

**AOD VISUALLY APPROVED AND FROZEN.** The user approved the current Always-On Display appearance in the Venu 2 simulator. Section 11 remains the general design rationale; the *implemented and visually approved* AOD on `product/apex-one-v1` is now the controlling baseline. Do not alter its layout, colors, fonts, geometry, update behavior, or low-power content unless explicitly requested by the user.

The approved implementation in `source/GarminFaceFactoryView.mc` is characterized by:

- True-black background (`#000000`), with no active-mode metrics, date, or full progress rings in low-power mode.
- Centered time in `Graphics.FONT_MEDIUM`, subdued gray `#777B7D`, positioned at `(cx + dx, cy - 13 + dy)` with center justification.
- Two short, one-pixel Orbit fingerprint arcs at radius 95: muted gold `#4D3920` with clockwise angles 96 to 84, and muted cyan `#1B4442` with clockwise angles 276 to 264. These are identity accents, not progress indicators.
- A minute-driven 5×5 offset cycle: `phase = minute % 25`, `dx = (phase % 5) - 2`, `dy = (phase / 5).toNumber() - 2`. The clock and arcs shift together.
- Low-power entry/exit through `onEnterSleep` and `onExitSleep`, with `WatchUi.requestUpdate()`; the platform controls low-power update cadence.

**Change control:** Preserve this approved AOD exactly in future implementation tasks, even if normal-mode design, metrics, or settings change. Only an explicit AOD change request permits revising it. Visual approval does not imply physical-device burn-in, battery, or release validation. This documentation update does not authorize source-code changes.


## 17. Superseding active-mode direction — Precision Luxury (approved 2026-11-11)

**Scope:** This section supersedes older active-screen-only decisions that require a flat black background, prohibit small decorative geometry, or require numerical battery percentage and English field labels. It does **not** supersede any technical requirements for truthful progress rings, safe margins, sensor handling, energy efficiency, or the frozen AOD in §16.

**Approved visual reference:** Deep emerald/graphite stone with subtle natural mineral veining, elegant high-contrast serif time numerals, understated champagne-gold geometric signature, slim dividers, and tiny heart/footstep indicators.

**Active screen composition at 416×416:**

- Thin signature motif around y=80; date centered around y=105.
- Large four-digit 24-hour time dominates the screen, using a single Garmin-supported BMFont raster atlas (digits 0–9 and colon) with consistent dimensions. A known-good Garmin native time font remains as a fallback if bitmap rendering fails.
- Horizontal separator near y=252. Heart rate with icon on the left and step count with footprints on the right, inside the inner progress ring. No literal HR/STEPS/BAT field labels.
- Outer gold ring = live steps divided by the actual daily goal (capped at 100%). Inner cyan ring = validated battery divided by 100. The battery number is intentionally omitted to reduce clutter; the ring remains functional.
- Normal mode uses a still, dark, low-brightness emerald mineral bitmap. It must not be drawn in low-power mode.
- Orbit Gold, Titanium, and Electric continue to control functional ring colors; no additional metrics or animation in this revision.

**Reliability principles:** Do not use untested runtime vector primitives for the critical time display. Do not load static graphical resources each frame; load the BMFont and pictograms once in onLayout and draw only updated clock/metrics on onUpdate. Always provide readable clock fallback. No visual polish may make the time disappear.

**Validation state:** Garmin CI compiles the new resources and source on the `product/apex-one-v1` branch. A separate pixel-level desktop composition preview was reviewed at 09:46, 10:15, and 23:59, with 0 to 99,999 steps, variable battery levels, and unavailable heart rate. **This preview is not a Venu 2 Simulator execution.** Full device simulator verification, performance measurements, and subsequent physical Venu 2 testing remain acceptance gates. The AOD in §16 stays unchanged.

### Implementation correction — 2026-11-11

The first SVG-based clock rendered as dots in the actual Venu 2 simulator despite a successful CI build. The SVG clock and SVG pictograms were therefore retired and replaced with a single BMFont atlas and two transparent PNG icons. A native-font fallback is retained and the font-resource load is guarded. This change fixes the root compatibility risk rather than hiding the affected layer. CI validates compilation only; the new BMFont appearance must still be observed in the real Venu 2 simulator before real-watch deployment. AOD remains frozen.


## 18. Approved Precision Luxury v2 active-mode extension — 2026-11-11

The user approved a **single consolidated v2**: wider functional Orbit rings, native Garmin weather, and a small notification badge, while preserving premium minimalism and the frozen AOD (§16).

- **Rings:** outer steps radius 190 px, stroke 9 px; inner battery radius 172 px, stroke 7 px. Both stay inside the 208px physical screen radius with a visible separation. This supersedes v1's 169/153px geometry and its 178px *decorative* content-radius constraint for rings only. All text and metrics remain inside their safe zone.
- **Bottom row:** heart rate left, current outdoor temperature center, steps right; small icons instead of field names. Battery remains on the cyan ring only, without duplicate percentage.
- **Weather:** `Toybox.Weather.getCurrentConditions()`; temperature supplied in Celsius. Reject null conditions, null observation time, readings older than 3 hours, and implausible temperatures; fallback `--` when unavailable. No extra permissions or external API keys.
- **Notifications:** `System.getDeviceSettings().notificationCount`, meaning Garmin *active* device notifications, not a guaranteed count of unread messages on the phone. No badge at zero; compact numeric badge 1–9, then `9+`.
- **No change to AOD.** Weather, notifications, and extra rings are active-only. Preserve existing icon resources, serif clock, and native-font fallback.
- **Acceptance:** Garmin CI compile plus one simulator screenshot testing clock, bottom row, ring clearance; on-device weather may require Garmin Connect weather sync, so no synthetic placeholder temperatures.
