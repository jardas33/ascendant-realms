export type RuntimeAssetSource = "final" | "manual" | "placeholder" | "runtime";

export interface RuntimeAssetManifestEntry {
  id: string;
  category: string;
  displayName: string;
  filename: string;
  targetFolder: string;
  usage: string;
  priority: number;
  required: boolean;
  available: boolean;
  source: RuntimeAssetSource;
  path: string | null;
  resolvedFilename?: string | null;
  preferredWidth: number;
  preferredHeight: number;
}

export interface RuntimeAssetManifest {
  version: 1;
  generatedAt: string;
  priorityOrder: Array<Exclude<RuntimeAssetSource, "runtime">>;
  assets: Record<string, RuntimeAssetManifestEntry>;
}
