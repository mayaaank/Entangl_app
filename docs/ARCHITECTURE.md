# Architecture

Entangl uses composition, sealed content types, and a content-agnostic masonry engine. The goal is **not** to remove every `if`. The goal is to keep business decisions out of UI widgets.

```
PostModel
    └── ScrapContent (sealed)
            ├── PhotoContent
            ├── TextContent
            └── CollageContent
                    │
                    ▼
            ScrapContentView   ← exhaustive switch
                    │
        ┌───────────┼───────────┐
        ▼           ▼           ▼
    PhotoScrap  TextScrap  CollageScrap
                    │
                    ▼
              MasonryFeed
```

## Architecture rules

1. Follow SOLID, with particular emphasis on Single Responsibility and Open/Closed.
2. New scrap types are added by extending `ScrapContent` and one widget. Do not modify masonry/layout logic for a new type.
3. Keep one source of truth for dimensions (`MediaDimensions`), text height (`TextLayoutCalculator`), collage geometry (`CollageLayout`), masonry metrics (`MasonryConfig`), type (`AppTextStyles`), and color (`EntanglColors`).
4. UI widgets must not contain domain/business calculations.
5. Masonry infrastructure must remain content-agnostic. It only asks `heightFor(width)`.
6. Domain models must not depend on Flutter widgets.
7. Prefer composition over inheritance for UI components.
8. Use Dart sealed classes and exhaustive pattern matching for finite content types.
9. Do not introduce abstractions solely to eliminate simple conditionals.
10. Optimize for readability and maintainability before micro-optimizing object creation.

## Responsibility map

| Component | Responsibility |
| --- | --- |
| `PostModel` | Post data + caption |
| `ScrapContent` | Content type and layout height |
| `MediaDimensions` | Pixel size / aspect ratio |
| `CollageLayout` | Collage geometry |
| `MasonryConfig` | Gaps, columns, card radius |
| `MasonryEngine` | Generic shortest-column placement |
| `MasonryFeed` | Masonry UI |
| `ScrapCard` | Card chrome, like, comments |
| `ScrapContentView` | Content → widget mapping |
| `PhotoScrap` / `TextScrap` / `CollageScrap` | Type-specific rendering |
| Riverpod providers | State / orchestration |

## Adding a type

1. Add a `final class` on `ScrapContent` with `heightFor`.
2. Add a small widget (`QuoteScrap`, `VideoScrap`, …).
3. Add one case in `ScrapContentView`.

Do not touch `MasonryEngine`, `MasonryFeed`, or `MasonryConfig`.
