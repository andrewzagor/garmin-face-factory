# Product Brief — Apex One

**Working name:** Apex One  
**Product type:** Premium Garmin Connect IQ watch face  
**Primary device:** Garmin Venu 2  
**Status:** Product definition / pre-implementation

## Product vision

Create **one exceptional watch face** for the Garmin Connect IQ Store: refined enough to feel premium, effortless to read at a glance, and dependable in everyday use. Apex One should be a cohesive, distinctive product—not a collection of minor visual variations.

## Product goal

Deliver a production-ready watch face that excels in three areas:

1. **Usability:** The time and most useful information are immediately readable, with clear visual hierarchy and sensible defaults.
2. **Visual quality:** Polished typography, balanced spacing, restrained accents, and a coherent design tailored to the round AMOLED display.
3. **Reliability:** Stable operation, efficient rendering, accurate data presentation, and successful build and device validation.

## Target audience and use cases

Garmin Venu 2 owners who want a premium-looking everyday watch face that remains practical for work, exercise, and quick wrist checks. Typical checks include the time, date, daily activity, and battery level.

## Design direction

- **Premium minimalism with purpose:** A recognizable visual identity, not an overloaded dashboard.
- **Time first:** Make the current time the dominant element; secondary information should never compete with it.
- **Round-screen composition:** Respect the circular safe area and avoid clipped text, especially near the lower corners.
- **AMOLED-friendly:** Prefer a true-black foundation, deliberate contrast, and restrained use of color.
- **Visual refinement:** Consistent alignment, typography, spacing, and deliberate information grouping.
- **Distinctiveness:** Develop an original concept that is meaningfully different from Minimal Green V1 and Sport Pulse; color swaps alone are insufficient.

The exact layout, type treatment, accent palette, and feature set should be finalized through design review before implementation.

## Initial functional scope (proposed)

**Essential**
- Clear digital time.
- Date.
- Battery percentage.
- Daily step count.

**Consider after validation**
- A restrained progress indicator for daily steps.
- User-configurable accent or data preferences, only if compatible with the target API and worth the added complexity.
- Thoughtful low-power / always-on behavior, where supported.

**Out of scope for the first release**
- Feature-heavy dashboards, unnecessary animations, and experimental dependencies.
- Multiple near-identical designs marketed as separate products.
- Features requiring permissions or APIs not supported by the declared minimum API level.

## Technical constraints

- Reuse the existing Garmin Connect IQ project structure and Monkey C implementation.
- Target Garmin Venu 2 first; check `manifest.xml` for the current minimum API level before coding.
- Use only supported Connect IQ APIs and reliable rendering methods.
- Preserve existing approved designs. Implement Apex One in its own dedicated design branch when development is authorized.
- Never modify `main` directly.
- Do not modify `.github/workflows/garmin-build.yml` unless explicitly requested.
- Treat `GARMIN_FACTORY.md` as the standing agent guidance.

## Quality and acceptance criteria

Apex One is ready for release consideration only when:

- Time and primary information are readable at a glance under typical conditions.
- Text and indicators stay within safe margins on the round Venu 2 display.
- The layout remains visually balanced with realistic data values (including large step counts).
- Battery and activity values render correctly; missing data is handled gracefully.
- Rendering is responsive and avoids unnecessary battery use.
- Garmin Build CI passes on the Apex One implementation branch.
- The face is inspected in the Venu 2 simulator and tested on a physical device when available.
- Store assets, product description, and Connect IQ submission requirements are reviewed before publication.

## Delivery approach

1. **Define:** Confirm essential data, visual concept, and measurable acceptance criteria.
2. **Design:** Review a distinctive layout and round-screen safe areas.
3. **Implement:** Build in a new dedicated Apex One design branch; commit all required files.
4. **Validate:** Run Garmin CI; fix failures in the same branch. Test simulator scenarios and device behavior.
5. **Polish:** Address readability, visual consistency, performance, and edge cases.
6. **Prepare for store:** Finalize screenshots, listing text, compatibility details, and release checklist.

## Open product decisions

- Final layout and visual identity.
- Whether to include a steps progress indicator.
- Whether user settings belong in v1.
- Supported languages and date/time formatting.
- Commercial model and store positioning.
- Physical-device testing availability.

---

**Document purpose:** This is a product brief only. It does not authorize source-code changes or a release.
