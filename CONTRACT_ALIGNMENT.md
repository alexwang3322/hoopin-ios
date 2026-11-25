# mobile-ios ↔ API_CONTRACT.md Alignment

Tracks gaps found comparing `mobile-ios/` against `../API_CONTRACT.md` (root). Check items off as they're fixed. Re-verify against the contract when done, not just against this list — the contract is the source of truth.

Legend: **P1** = contract-specified field/behavior missing · **P2** = product-level inconsistency (app promises something it doesn't enforce) · **P3** = cosmetic/UX gap · **Info** = expected mock-app simplification, not a bug — noted so whoever wires up real networking knows it's still open.

All P1/P2/P3 items below are **mobile-ios fixes**. Nothing found requires changing `API_CONTRACT.md` itself — the contract already anticipates or explicitly flags every case that looks like a contract-side question (city filter wiring, auth mechanism, pagination).

---

## P1 — contract-specified field missing from Create-Run

- [ ] **Every new run hardcodes `city: .sf`; there's no way to create an OAK run.**
  Contract: §2 — `CreateRunRequest.city: "SF" | "OAK"` is required.
  Where: `ViewModels/CreateRunFormViewModel.swift` `CreateRunFormValues` has no `city` property; `Views/CreateRun/CreateRunView.swift` has Format and Visibility pickers but no City picker; `makeRun(...)` hardcodes `city: .sf` (line ~56).
  Fix: add `var city: City = .sf` to `CreateRunFormValues`, add a `Picker("City", ...)` (mirroring the existing `RunVisibility` picker), thread it through `makeRun`/`from(run:)`.
  (Same gap independently flagged in `frontend/CONTRACT_ALIGNMENT.md`.)

## P2 — visibility is stored but not enforced

- [ ] **Private runs still show up in the public Discover feed.**
  Contract: §7 Open Q4 leaves the exact *access* mechanism for private runs undecided, but the minimum assumed behavior either way is "not listed" — and the app's own copy (`RunVisibility.displayName` = *"Private — invite link only"*) promises exactly that.
  Where: `Services/RunStore.swift` `discoverRuns` (line ~34-36) filters only `!$0.isDraft` — no `visibility` check at all.
  Fix: exclude `.privateVisibility` runs from `discoverRuns` (unless hosted by the viewer), so the picker's own label stops being false.

## P3 — cosmetic/UX gaps

- [ ] **Host has no way to attach a `decline_reason` when declining a request.**
  Contract: `DeclineJoinRequestRequest.decline_reason` is optional, and the read side already round-trips it — `MyRunRowView` and `EventDetailView`'s `.declined` action-panel branch both render `declineReason` when present, and `MockData` seeds one fixture with a reason (`"Full this month — try the October run."`).
  Where: `Views/EventDetail/RequestCardView.swift` Decline button calls `onDecline` with no text input; `EventDetailView.requestsSection` always calls `store.decline(requestId:reason:)` with `reason: nil` (line ~104).
  Fix: not required by the contract (reason is optional), but the write path can currently never produce what the read path already displays — worth a small text field/confirmation sheet before declining.

## Info — expected simplifications of a mock, single-user app (no contract change needed)

- **City filter picker in Discover is cosmetic.** `Views/Discover/DiscoverView.swift`'s `selectedCity` state is never consulted by `discoverRuns`/`DiscoverFilterViewModel.matches`. This is *expected* — `API_CONTRACT.md` §2 says so explicitly: `RunSummary.city` "backs the (currently unwired) city filter toggle." Matches `ui/index.html`'s original cosmetic toggle too. No action needed.
- **No pagination.** `RunStore` holds flat in-memory arrays; nothing models `CursorPage<T>`/`cursor`/`limit`. Fine for a mock with ~7 fixture runs — flag for whoever adds a real `GET /runs` client later.
- **No auth / no signed-out state.** Single hardcoded viewer (`MockData.currentUserId`, "Jamie Tran" equivalent); `ViewerAction.signedOut` is deliberately omitted (see comment in `Models/Enums.swift`). Contract itself marks auth issuance as TBD/out of scope, so nothing to reconcile yet — just the obvious next piece of work once real networking lands.
- **`exact_address` has no non-empty validation on publish**, unlike `title`/`venue_name` (which fall back to "Untitled run"/"Venue TBD"). Contract types it as a required `string` but doesn't mandate client-side validation — low priority, easy to add alongside the P1 city fix if touching that form anyway.
