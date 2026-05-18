export function isEditableElementFocused(): boolean {
  if (typeof document === "undefined") {
    return false;
  }
  return isEditableElement(document.activeElement);
}

export function shouldIgnoreGameKeyboardEvent(event?: KeyboardEvent): boolean {
  return isEditableElement(event?.target) || isEditableElementFocused();
}

export function stopKeyboardEventForEditableTarget(event: KeyboardEvent): void {
  if (isEditableElement(event.target)) {
    event.stopPropagation();
  }
}

function isEditableElement(target: EventTarget | null | undefined): boolean {
  if (!(target instanceof Element)) {
    return false;
  }
  if (target.closest("[contenteditable='true'], [contenteditable='plaintext-only']")) {
    return true;
  }
  const editable = target.closest("input, textarea, select");
  return editable instanceof HTMLElement && !isReadOnlyInput(editable);
}

function isReadOnlyInput(element: HTMLElement): boolean {
  if (!(element instanceof HTMLInputElement) && !(element instanceof HTMLTextAreaElement)) {
    return false;
  }
  return element.readOnly || element.disabled;
}
