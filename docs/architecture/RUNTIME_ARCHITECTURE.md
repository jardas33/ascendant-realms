# Runtime architecture

The browser app is a TypeScript/Vite build with Phaser presentation. Pure rules, view models, serializers, and simulation logic should remain testable without a browser. Scene orchestration translates state into entities and UI; it should not hide gameplay semantics in DOM-only presentation.

The Godot tree is an opt-in parallel lane. A Godot scene, capture, or validator is not proof that the browser runtime changed. Reports must state which runtime was exercised.

Preserve saves and stable IDs. New presentation layers should be adapters around existing state, not alternate sources of truth.
