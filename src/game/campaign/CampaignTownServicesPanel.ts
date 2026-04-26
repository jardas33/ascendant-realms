import type { CampaignNodeDefinition } from "../core/GameTypes";

export function isTownServiceNode(node: CampaignNodeDefinition): boolean {
  return node.nodeType === "town";
}

export function townServiceActionLabel(hasStockItem: boolean): string {
  return hasStockItem ? "Purchase" : "Use Service";
}

export function repeatabilityLabel(choice: NonNullable<CampaignNodeDefinition["choices"]>[number]): string {
  return choice.onceOnly ? "Purchase once." : "Repeatable service.";
}
