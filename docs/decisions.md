# Decisions

Architectural decisions for SOON. Each decision has a D-number for reference.

## D1: Two Clocks, One Source of Truth

**Status:** Approved  
**Date:** 2024-01-01

The entire app renders from two streams: a per-second tick and a per-day tick. Nothing else in the codebase reads system time directly. All countdowns, fades, ring angles, milestones, and notification chains are pure functions of stored facts and clock emissions.

**Consequences:**
- Midnight rollover is automatic
- DST changes are irrelevant (we use date-only comparisons)
- Testing is deterministic via FakeClock injection
- Any direct `DateTime.now()` outside clock module is a bug

---

## D2: Store Facts, Derive Everything

**Status:** Approved  
**Date:** 2024-01-01

Persist only what the user entered: title, date, kind, color. Never store countdowns, next-occurrence dates, milestones, opacities, or ranks. Compute at read time.

**Consequences:**
- Single source of truth for all derived values
- No cache invalidation bugs
- Performance concerns addressed only after measurement

---

## D3: One Door for Mutation

**Status:** Approved  
**Date:** 2024-01-01

Every create, edit, delete, and import flows through a single verb-named service. Inside: validate, write, reschedule alarms, log — all-or-nothing, with idempotency keys generated at UI-intent time.

**Consequences:**
- Double-tap cannot duplicate events
- Exactly one place to handle alarm cancellation on delete
- Consistent validation across all entry points

---

## D4: Seams with Teeth

**Status:** Approved  
**Date:** 2024-01-01

Storage and notification SDKs live behind interfaces; their types never appear above the data layer. Design tokens live in exactly one file; raw literals are banned everywhere else. Enforced by `floors.sh` script.

**Consequences:**
- Vendor lock-in prevented
- Visual consistency guaranteed
- Automated enforcement on every gate

---

## D5: State Table Before UI

**Status:** Approved  
**Date:** 2024-01-01

For complex surfaces (grid, year ring), enumerate every state before building widgets. Write exact visual specs for each state combination.

**Consequences:**
- Ambiguity eliminated before coding
- Golden tests derive directly from state table
- UI bugs caught in spec phase

---

## D6: Flutter, Android-First, Portfolio Scope

**Status:** Approved  
**Date:** 2024-01-01

Platform: Flutter targeting Android first. Scope limited to portfolio-quality demo. Three levels: SOON, GRID, YEAR. Pinch navigation with discrete transitions first.

**Consequences:**
- Focused development effort
- Clear MVP boundary
- iOS support deferred

---

## D7: Riverpod + Hive Stack

**Status:** Approved  
**Date:** 2024-01-01

State management: Riverpod. Storage: Hive behind repository seam. This combination provides reactive state with fast local persistence.

**Consequences:**
- Provider-based architecture
- Hive types isolated behind storage interface
- Testable via provider overrides

---

## D8: Permission Asked Once, At Motivating Moment

**Status:** Approved  
**Date:** 2024-01-01

Notification permission requested exactly once: when saving the first event. Three states tracked: never-asked, declined, granted. Never ask again on boot.

**Consequences:**
- Trust preserved with user
- Distinct UX paths for each state
- No annoying permission dialogs on launch

---

## D9: Comet Tail Specification

**Status:** Approved  
**Date:** 2024-01-01

Past dots fade in a comet trail: full brightness today, linear fade over seven days, pinned at fifteen percent (0.15) forever after. Values encoded as tokens (`fadeFloor`, `trailReachDays`), not magic numbers.

**Consequences:**
- Consistent visual language
- Token-driven theming possible
- Easy adjustment via single source

---

## D10: Monday-First Calendar (Dart Native)

**Status:** Approved  
**Date:** 2024-01-01

Week starts on Monday. Dart's `weekday` numbering (Monday=1, Sunday=7) is used directly without conversion. Grid rows represent weeks, Monday-first.

**Consequences:**
- No weekday conversion logic needed
- ISO 8601 compliance
- Natural alignment with Dart's Date class

---

## D11: Discrete Transitions First

**Status:** Approved  
**Date:** 2024-01-01

Pinch navigation between SOON, GRID, YEAR uses discrete animated transitions (300ms scale-and-fade) initially. Continuous morph interpolation is deferred until all other features shine.

**Consequences:**
- Faster time to ship
- Reduced mathematical complexity
- Clean upgrade path to continuous morph later

---

## D12: Versioned Records with Lazy Migration

**Status:** Approved  
**Date:** 2024-01-01

Every persisted record includes a version field from the first write. Migration happens lazily on read — upgrade in the same pass, preserve old fields, default new ones.

**Consequences:**
- Schema evolution supported
- No migration windows required
- Old records upgraded on access

---

## D13: Test Regression Wall

**Status:** Approved  
**Date:** 2024-01-01

Tests built alongside features, never after. Wall includes: fake clock tests, semantic keys on every dot, golden tests per dot state, migration fixtures, double-tap idempotency tests, frame profiling.

**Consequences:**
- Regression prevention automated
- Confidence in refactoring
- Documentation via test cases

---

## D14: Empty Over Fake

**Status:** Approved  
**Date:** 2024-01-01

Empty states teach the next action. Never render invented rows to look busy. Real-but-empty with call-to-action builds trust; fabricated content compounds into skepticism.

**Consequences:**
- Honest UX
- Clear user guidance
- No uncanny valley of fake data

---

## D15: One Formatter For All Numbers

**Status:** Approved  
**Date:** 2024-01-01

One formatter owns all numbers and dates. "47 days" must look identical everywhere. Presentation drift on numbers reads as shadiness.

**Consequences:**
- Consistent number formatting
- Centralized localization point
- No formatting discrepancies
