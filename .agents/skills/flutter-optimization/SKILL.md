---
name: flutter-optimization
description: Flutter performance tuning, memory profiling, and architecture optimization. Use this skill when diagnosing UI jank or dropped frames, reducing widget rebuilds, optimizing Riverpod state selectors, eliminating memory leaks, optimizing image/asset caching, and reducing app binary size.
---

# Flutter Performance & Architecture Optimization

This skill provides a systematic engineering guide for optimizing Flutter applications to achieve smooth 60/120 FPS rendering, minimize memory overhead, eliminate leaks, and structure scalable Clean Architecture state.

---

## 1. Objectives & Scope

- **Frame Rate & Jank Elimination**: Maintain consistent 16ms (60fps) or 8ms (120fps) frame budgets during animations and scrolling.
- **Granular Rebuild Scope**: Prevent unnecessary parent-to-child widget rebuild cascades using `const` constructors and targeted Riverpod `.select()` queries.
- **Memory & Resource Management**: Systematically eliminate leaks caused by orphaned controllers, stream subscriptions, timers, and uncompressed image caches.
- **Image & Asset Efficiency**: Optimize network images with explicit memory cache bounds (`memCacheWidth`, `memCacheHeight`).
- **Binary Size Reduction**: Shrink APK/AAB and iOS IPA bundles through icon tree-shaking, code shrinking, and asset cleanup.

---

## 2. Execution Instructions

### Step 1: Profiling with Flutter DevTools
1. Run application in **Profile Mode** (never optimize based on Debug mode metrics):
   ```bash
   flutter run --profile
   ```
2. Open Flutter DevTools:
   - **Performance Tab**: Record UI and Raster thread timings; inspect frame timeline to detect shader compilation jank or heavy build passes.
   - **CPU Profiler Tab**: Identify expensive synchronous operations executed on the main UI thread.
   - **Memory Tab**: Take memory snapshots before and after screen navigation to detect retained objects or leaked closures.

### Step 2: Widget Rebuild Optimization
1. **Aggressive `const` Enforcement**:
   - Add `const` to all static constructors to enable widget tree caching by the Flutter framework.
2. **Granular Widget Decomposition**:
   - Extract dynamic UI elements into dedicated sub-widgets so that only the leaf node rebuilds on state change.
3. **Riverpod `.select()` Filtering**:
   - In Riverpod consumers, avoid watching broad state objects if the widget only cares about a single field:
     ```dart
     // BAD: Rebuilds when any field in FlightState changes
     final state = ref.watch(flightSearchProvider);

     // GOOD: Only rebuilds when `totalResults` changes
     final count = ref.watch(flightSearchProvider.select((s) => s.totalResults));
     ```

### Step 3: Eliminating Memory Leaks & Retained Controllers
1. Ensure every instantiated controller has a corresponding disposal lifecycle:
   - `TextEditingController`
   - `ScrollController`
   - `AnimationController`
   - `StreamSubscription`
2. In Riverpod `StateNotifier` or provider definitions, utilize `ref.onDispose()`:
   ```dart
   ref.onDispose(() {
     timer.cancel();
     controller.dispose();
   });
   ```

### Step 4: List & Scroll View Tuning
1. Always use lazy builders (`ListView.builder`, `GridView.builder`) instead of passing `children: [...]` lists.
2. Provide `itemExtent` or `prototypeItem` whenever items have uniform heights to avoid expensive dynamic layout calculations:
   ```dart
   ListView.builder(
     itemExtent: 72.0, // Fixed height saves layout passes
     itemCount: items.length,
     itemBuilder: (context, index) => ItemTile(item: items[index]),
   );
   ```
3. Assign unique, stable `Key`s (e.g., `ValueKey(item.id)`) to stateful list items to maintain correct element mapping.

### Step 5: Image & Asset Memory Optimization
1. Constrain image decoding dimensions in memory:
   - Decoding a 4000x3000px photo into a 100x100 thumbnail consumes ~48MB of uncompressed RAM.
   - Use `ResizeImage` or `cached_network_image` with bounds:
     ```dart
     CachedNetworkImage(
       imageUrl: hotel.thumbnailUrl,
       memCacheWidth: 200, // Decodes only to required display resolution
       fit: BoxFit.cover,
     );
     ```
2. Pre-cache critical local SVGs and assets during splash screen loading.

### Step 6: Binary Size Reduction
1. Enable ProGuard / R8 code shrinking and resource shrinking on Android (`android/app/build.gradle`).
2. Verify font and icon tree-shaking is active:
   ```bash
   flutter build appbundle --target-platform android-arm64 --analyze-size
   ```

---

## 3. Practical Checklists

### Pre-Optimization Checklist
- [ ] Reproduce performance issue on real physical devices in `--profile` mode.
- [ ] Baseline memory footprint and FPS timeline recorded.
- [ ] DevTools Performance & Memory tabs connected.

### Optimization Execution Checklist
- [ ] All static widgets marked with `const`.
- [ ] Rebuilds isolated to small leaf widgets using `ref.watch(provider.select(...))`.
- [ ] No heavy computation (JSON parsing, encryption, sorting large lists) executed on UI thread; offloaded to `compute()` / background isolate.
- [ ] All `ScrollController`, `TextEditingController`, and `AnimationController` instances disposed.
- [ ] Network images decode with `memCacheWidth` / `memCacheHeight` constraints.
- [ ] `ListView.builder` configured with `itemExtent` or `prototypeItem` where heights are fixed.

### Verification Checklist
- [ ] 60fps / 120fps maintained during active list scrolling.
- [ ] Memory snapshots confirm zero retained screens/controllers after pop navigation.
- [ ] Build size verified and documented.

---

## 4. Error-Handling & Troubleshooting Matrix

| Performance Issue | Root Cause | Remediation Procedure |
| :--- | :--- | :--- |
| **Dropped Frames on Scroll** | Expensive widget build or lack of `itemExtent` in list | Extract list tile to `const` sub-widget, specify `itemExtent`, downsample images. |
| **High Memory Growth (OOM)** | Full-resolution network images retained in image cache | Add `memCacheWidth`/`memCacheHeight` constraints; clear cache on memory warnings. |
| **UI Freeze on Data Load** | Massive JSON decoding or filtering on main isolate | Offload parsing to background isolate using Dart's `compute(parseJson, rawData)`. |
| **Widget Rebuilt Continuously** | Provider state modified within `build()` method | Move state modifications to user event callbacks or `useEffect` / `WidgetsBinding.addPostFrameCallback`. |

---

## 5. Security Guardrails

- **Do Not Disable TLS for Speed**: Never bypass certificate validation or HTTP security headers in the name of latency reduction.
- **Secure Memory Cleaning**: Wipe sensitive credentials or biometric keys from memory variables immediately after use.
- **Local Cache Encryption**: Ensure offline cached responses containing user details are stored in encrypted caches, not world-readable temporary directories.

---

## 6. Examples & Optimization Snippets

### Isolate Offloading for Heavy Computation
```dart
// Offload large flight search filter/sort processing off the UI thread
Future<List<FlightOffer>> filterAndSortFlightsInBackground(
  List<FlightOffer> offers, 
  FilterCriteria criteria,
) async {
  return await compute(_filterWorker, _FilterParams(offers, criteria));
}

List<FlightOffer> _filterWorker(_FilterParams params) {
  return params.offers
      .where((f) => f.price <= params.criteria.maxPrice)
      .toList()
    ..sort((a, b) => a.price.compareTo(b.price));
}
```

### Granular Riverpod Selection Pattern
```dart
class FlightPriceBadge extends ConsumerWidget {
  final String flightId;
  const FlightPriceBadge({super.key, required this.flightId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only rebuilds when this specific flight's formatted price changes
    final price = ref.watch(
      flightListProvider.select((list) => list.firstWhere((f) => f.id == flightId).formattedPrice),
    );

    return Text(
      price,
      style: Theme.of(context).textTheme.titleMedium,
    );
  }
}
```
