export function renderPlacementBanner(isPlacing: boolean): string {
  return isPlacing
    ? `<div class="placement-banner" data-testid="placement-banner">
        <strong>Placement Mode</strong>
        <span>Move the cursor to valid ground, left-click to place, or right-click/Esc to cancel.</span>
      </div>`
    : "";
}
