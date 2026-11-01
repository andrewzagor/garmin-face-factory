# Product Brief — Apex One

**Product name:** Apex One  
**Target price:** USD $4.99  
**Product type:** Premium everyday Garmin watch face for the Connect IQ Store  
**Primary device:** Garmin Venu 2  
**Selected design direction:** Concept 2 — Apex One / Orbit (with Precision information hierarchy)  
**Status:** Design direction selected / pre-implementation

## Product vision

Create **one exceptionally polished watch face** that combines premium visual design, fast readability, useful daily data, reliability, and battery efficiency. Apex One should feel like a complete, distinctive everyday product—not a complicated dashboard or a collection of near-identical designs.

**Core experience target:** Users should understand the most important information within approximately **one second** of glancing at their wrist.

## Target user and use cases

Garmin users who want one attractive, dependable everyday watch face instead of a complicated dashboard. Apex One must feel appropriate at work, during casual activities, and in fitness contexts, without requiring the user to change faces throughout the day.

## Design philosophy

- **Premium and modern:** Refined, intentional aesthetics with a recognizable identity.
- **Clean, not empty:** Use space purposefully without sacrificing helpful information.
- **Data-rich, not cluttered:** Surface useful daily metrics while preserving immediate comprehension.
- **AMOLED-friendly:** Prefer true-black or otherwise power-conscious backgrounds and restrained illumination.
- **Optimized for a round display:** Keep every label, number, and indicator within safe circular margins.
- **Strong visual hierarchy:** Time is unmistakably dominant; secondary metrics remain easy to scan.
- **Originality:** Do not copy existing Garmin watch faces or recognizable competitor designs. Make Apex One meaningfully different from Minimal Green V1 and Sport Pulse.

**Selected direction:** Orbit's circular progress-ring identity, combined with Concept 1 / Precision's clean, restrained information hierarchy. The time remains the primary focal point, and rings must never reduce the readability of essential numbers. **Do not render the product name “APEX ONE” anywhere on the actual watch-face display**; the name belongs in store listings and product materials only. Reclaim the display space for meaningful information and breathing room.

The default configuration must look finished, balanced, and premium immediately. Users must not need to customize it to obtain a high-quality appearance.

## Selected visual concept — Orbit × Precision

**Decision:** Adopt **Concept 2 / Orbit** as the sole Apex One product direction. Borrow **Concept 1 / Precision**'s disciplined alignment, spacing, typography, and one-second readability. This is one coherent flagship design, not two separate watch faces.

### Layout and information hierarchy

- Use a round, AMOLED-friendly composition with a prominent, large digital time in the center.
- Place the weekday and date in a compact, legible position above or near the time.
- Arrange steps, heart rate, and battery as clearly labeled secondary readouts within the inner safe area; avoid crowding the clock or the circular edge.
- Display daily step-goal progress as the **primary functional outer ring**, with a clearly distinguishable completed segment and track.
- Any additional concentric ring must have its **own explicit, useful, current metric** and a clear visual interpretation. Do not introduce a second ring simply for symmetry.
- Favor a small number of well-spaced data groups over dense micro-labels. Preserve the hierarchy: **time → goal progress / steps → heart rate → date / battery**, with exact positioning subject to simulator review.
- Respect the Venu 2 circular safe area at all times, including long values and 12/24-hour formats.

### Functional ring rules

- **No decorative progress rings.** Every visible progress ring must represent a meaningful metric sourced from actual available device data.
- The default outer ring represents **daily steps completed relative to the user's daily steps goal**; the arc and accompanying numeric readout must agree.
- Ring progress should update when underlying data changes, not animate continuously or redraw unnecessarily.
- Define behavior for zero/unknown goals, missing activity data, and progress exceeding 100%; never imply valid progress when the data is unavailable.
- If another ring is proposed, first specify its data source, denominator/target, user value, refresh behavior, and fallback. A heart-rate value alone must not be depicted as an arbitrary percentage of an invented target.
- Keep ring strokes and gaps legible but restrained; arcs must not crowd the clock or touch the screen edge.
- Evaluate simplified rings or removal of nonessential indicators for low-power / Always-On Display operation, subject to device support.

### Visual signature and palette

- **Signature:** A precise, purposeful circular progress ring integrated with a calm, high-contrast digital dashboard.
- **Default palette direction:** Obsidian black, warm white, restrained champagne-gold for step-goal progress, and muted cool accents for secondary information.
- Apply Precision's clean typography, balanced negative space, and minimal separators rather than adding decorative ornamentation.
- The face must **not display “APEX ONE,” a logo, or redundant branding**. Product identity is communicated by the ring geometry, proportions, typography, and premium themes.
- Optional themes may change coordinated colors without altering data meaning or reducing contrast.
- Ensure the default arrangement is complete and visually premium before adding customization.

### Design review checkpoints

- Verify the one-second time-reading goal and immediate comprehension of the progress ring.
- Confirm every ring has a truthful, understandable live-data meaning.
- Check circular-edge clipping, large step values, unavailable heart-rate readings, and different time formats.
- Evaluate contrast, visual balance, simulator rendering quality, and battery-conscious update strategy.
- Do not begin Monkey C implementation until the selected layout is reviewed and implementation is explicitly requested.

## Core information — required

All of the following belong in the core product experience, with layout and hierarchy designed to avoid crowding:

1. **Time:** The dominant visual element.
2. **Date and weekday:** Quickly recognizable and legible.
3. **Battery percentage:** Clear and unobtrusive.
4. **Steps:** Current daily count.
5. **Heart rate:** Display reliable available heart-rate data and handle unavailable readings gracefully.
6. **Daily steps goal progress:** Visually communicate progress without competing with the time.

The information architecture must make the time readable first, then guide the eye naturally to the most useful daily data.

## Optional information — evaluate later

- Calories.
- Floors climbed.
- Distance.
- Notifications.
- Bluetooth / phone connection status.

**Inclusion rule:** Do not add optional metrics if they make the display crowded, reduce one-second readability, or weaken the premium aesthetic. Optional data is not a requirement for the initial default design.

## Customization goals

- Multiple carefully designed premium color themes.
- 12-hour and 24-hour time support.
- Configurable data fields where technically practical.
- Ability to hide secondary information.
- Maintain strong layout, spacing, contrast, and visual balance under every supported configuration.

Customization must enhance the product without becoming necessary to make the default design attractive. Prioritize a smaller set of well-executed options over excessive settings. Validate feasibility against the target device and supported Connect IQ APIs.

## Quality and reliability requirements

- **Excellent readability:** Critical information understandable at a glance, including in typical indoor and outdoor use.
- **No clipping:** All text, metrics, and indicators remain within the circular Venu 2 display, including with large values and alternate settings.
- **Stable Monkey C implementation:** Simple, maintainable code using supported APIs.
- **Efficient rendering:** Avoid unnecessary redraws, allocations, and expensive computations.
- **Battery-conscious design:** Optimize update behavior, graphics, and active/low-power states.
- **Reliable data handling:** Correct display of time, steps, goal progress, heart rate, and battery information.
- **Graceful degradation:** Unavailable or stale sensor/activity data must never crash the watch face or display misleading values.
- **Always-On Display (AOD):** Treat AOD as a product requirement to evaluate and implement where supported; design a readable, low-power presentation and validate device-specific constraints.
- **Build gate:** Garmin Build CI must pass before release or merge.
- **Validation:** Review in the Venu 2 simulator, test edge cases and customization combinations, and perform real-device testing before publication when hardware is available.

## Commercial positioning

**Target price: $4.99.** Apex One should justify its price through visual polish, usefulness, customization, and dependable daily operation—not through excessive features.

The Connect IQ Store listing must communicate premium quality immediately. Prepare compelling, truthful screenshots showing the best default configuration, strong time readability, clean metric presentation, and selected premium themes if implemented. Review current Connect IQ Store commercial, publishing, and asset requirements before committing to a sales or distribution mechanism.

## Scope and constraints

- **One flagship product first:** Create the strongest possible default Apex One design for Garmin Venu 2.
- **No mass production yet:** Do not create batches of watch faces or superficial variants.
- Use the existing Connect IQ project structure; check `manifest.xml` for the current minimum API level before implementation.
- Preserve previously approved watch faces and use a dedicated Apex One implementation branch.
- Never commit directly to `main`.
- Do not modify `.github/workflows/garmin-build.yml` without explicit authorization.
- Follow `GARMIN_FACTORY.md` and keep changes scoped to the requested task.

## Development strategy

Proceed iteratively, with explicit quality gates:

1. **Concept:** Establish a distinctive premium visual concept and an excellent default layout.
2. **Implementation:** Build only the approved Apex One design in its own branch.
3. **Garmin CI:** Compile for Venu 2; investigate and fix errors on the same branch until the build passes.
4. **Simulator review:** Inspect readability, circular margins, representative data, and settings combinations.
5. **Visual refinement:** Improve typography, spacing, hierarchy, colors, and micro-details.
6. **Battery / performance optimization:** Validate update efficiency and AOD behavior where supported.
7. **Real-device testing:** Assess actual visibility, responsiveness, stability, and battery impact.
8. **Store preparation:** Finalize screenshots, listing, compatibility, and release readiness.

**Sequence:** concept → implementation → Garmin CI → simulator review → visual refinement → battery/performance optimization → real-device testing → store preparation.

## Release acceptance criteria

Apex One is ready for commercial release consideration when:

- Its default appearance is distinctive, complete, and convincingly premium.
- Time and critical daily information are understandable within approximately one second.
- All required core metrics are implemented or any device/API limitation is explicitly resolved.
- No clipping occurs on Venu 2, including extreme values and supported configurations.
- All customization combinations remain legible and visually coherent.
- Missing data and low-power states are handled reliably.
- Garmin Build CI passes and simulator checks are completed.
- Battery/performance behavior and AOD requirements are validated.
- Real-device testing is completed, or any remaining limitation is documented before release decision.
- Store screenshots and listing accurately represent the product and communicate its $4.99 value.

## Open decisions for design review

- Detailed Orbit × Precision layout geometry, typography, and final premium theme palette (overall direction selected).
- Exact arrangement of heart rate, steps, goal progress, battery, and date/weekday.
- Heart-rate refresh and unavailable-data behavior.
- Step-goal source, ring scaling for values above goal, and missing-data behavior.
- AOD support and device-specific rendering strategy.
- Initial customization scope and configuration UI.
- Localization and 12/24-hour defaults.
- Connect IQ Store pricing/distribution feasibility and release assets.

---

**Document purpose:** This product brief defines requirements and commercial intent only. It does not authorize source-code changes or a release.
