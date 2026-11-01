# Product Brief — Apex One

**Product name:** Apex One  
**Target price:** USD $4.99  
**Product type:** Premium everyday Garmin watch face for the Connect IQ Store  
**Primary device:** Garmin Venu 2  
**Status:** Product definition / pre-implementation

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

The default configuration must look finished, balanced, and premium immediately. Users must not need to customize it to obtain a high-quality appearance.

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

- Final Apex One visual concept, typography, and premium theme palette.
- Exact arrangement of heart rate, steps, goal progress, battery, and date/weekday.
- Heart-rate refresh and unavailable-data behavior.
- Step-goal source and progress visualization.
- AOD support and device-specific rendering strategy.
- Initial customization scope and configuration UI.
- Localization and 12/24-hour defaults.
- Connect IQ Store pricing/distribution feasibility and release assets.

---

**Document purpose:** This product brief defines requirements and commercial intent only. It does not authorize source-code changes or a release.
