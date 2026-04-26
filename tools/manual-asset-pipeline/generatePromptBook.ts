import { mkdir, writeFile } from "node:fs/promises";
import path from "node:path";
import { ART_STYLE_BIBLE } from "./artStyleBible.ts";
import { ASSET_REGISTRY, type ManualAssetEntry } from "./assetRegistry.ts";

interface PromptBookEntry {
  assetId: string;
  displayName: string;
  category: string;
  targetFilename: string;
  targetFolder: string;
  recommendedSize: string;
  mainPrompt: string;
  negativePrompt: string;
  usageNotes: string;
  compositionNotes: string;
  readabilityNotes: string;
  backgroundNotes: string;
  chatGptSteps: string[];
  fileNamingReminder: string;
  transparencyPreferred: boolean;
  flatCleanBackgroundAllowed: boolean;
  assetKind: string;
}

interface PromptBook {
  generatedAt: string;
  gameTitle: string;
  instructions: string[];
  entries: PromptBookEntry[];
}

const outputDir = path.join(process.cwd(), "public", "assets", "manual");
const markdownPath = path.join(outputDir, "ASSET_PROMPT_BOOK.md");
const jsonPath = path.join(outputDir, "ASSET_PROMPT_BOOK.json");

async function main(): Promise<void> {
  await mkdir(outputDir, { recursive: true });

  const entries = ASSET_REGISTRY.slice()
    .sort((a, b) => a.priority - b.priority || a.id.localeCompare(b.id))
    .map((asset) => buildPromptEntry(asset));

  const promptBook: PromptBook = {
    generatedAt: new Date().toISOString(),
    gameTitle: ART_STYLE_BIBLE.gameTitle,
    instructions: [
      "This prompt book is for manual image generation only.",
      "Do not paste API keys anywhere. No API image generation is required.",
      "Copy one MAIN PROMPT and one NEGATIVE PROMPT into ChatGPT image generation.",
      "Generate one asset at a time and reject results that contain text, watermarks, copied symbols, or unclear silhouettes.",
      "Download the image, rename it exactly as instructed, and place it in the listed folder.",
      "After adding images, run npm run assets:manifest and npm run assets:validate."
    ],
    entries
  };

  await writeFile(jsonPath, `${JSON.stringify(promptBook, null, 2)}\n`, "utf8");
  await writeFile(markdownPath, renderMarkdown(promptBook), "utf8");

  console.log(`Generated ${entries.length} asset prompts.`);
  console.log(`Markdown: ${relative(markdownPath)}`);
  console.log(`JSON: ${relative(jsonPath)}`);
}

function buildPromptEntry(asset: ManualAssetEntry): PromptBookEntry {
  const faction = asset.factionId ? ART_STYLE_BIBLE.factions.find((entry) => entry.id === asset.factionId) : undefined;
  const categoryNotes = ART_STYLE_BIBLE.assetStyleNotes.find((entry) => entry.category === normalizedCategory(asset.category));
  const coreStyle = ART_STYLE_BIBLE.coreVisualIdentity.join(", ");
  const visualRules = ART_STYLE_BIBLE.visualRules.join(" ");
  const factionText = faction
    ? `Faction identity: ${faction.name}. Colors: ${faction.colors.join(", ")}. Themes: ${faction.themes.join(", ")}. Shape language: ${faction.shapes.join(", ")}. ${faction.promptNotes}`
    : "Use original Ascendant Realms fantasy identity without referencing existing IP.";
  const categoryText = categoryNotes ? categoryNotes.notes.join(" ") : "";
  const manualGuidance = ART_STYLE_BIBLE.manualGenerationGuidance.join(" ");

  const mainPrompt = [
    `Create one original ${assetKind(asset)} asset for the fantasy strategy RPG ${ART_STYLE_BIBLE.gameTitle}: ${asset.displayName}.`,
    `Subject: ${asset.subject}.`,
    `Composition: ${asset.composition}.`,
    `Shared project style: ${coreStyle}.`,
    factionText,
    categoryText,
    spriteSpecificPrompt(asset),
    iconSpecificPrompt(asset),
    portraitSpecificPrompt(asset),
    uiSpecificPrompt(asset),
    uiKitSpecificPrompt(asset),
    splashSpecificPrompt(asset),
    `Usage: ${asSentenceFragment(asset.usage)}.`,
    `Technical target: ${asset.preferredWidth}x${asset.preferredHeight}px.`,
    asset.transparencyPreferred ? "Transparent background preferred if the tool supports it." : "Do not require transparency.",
    asset.flatBackgroundAllowed ? "A flat clean background is acceptable." : "Use an atmospheric but not cluttered background.",
    manualGuidance,
    visualRules
  ]
    .filter(Boolean)
    .join(" ");

  return {
    assetId: asset.id,
    displayName: asset.displayName,
    category: asset.category,
    targetFilename: asset.filename,
    targetFolder: `public/assets/manual/${asset.targetFolder}`,
    recommendedSize: `${asset.preferredWidth}x${asset.preferredHeight}`,
    mainPrompt,
    negativePrompt: buildNegativePrompt(asset),
    usageNotes: asset.usage,
    compositionNotes: asset.composition,
    readabilityNotes: buildReadabilityNotes(asset),
    backgroundNotes: buildBackgroundNotes(asset),
    chatGptSteps: [
      "Paste the MAIN PROMPT into ChatGPT image generation.",
      "Paste the NEGATIVE PROMPT if the interface provides a negative prompt field; otherwise add it as a final sentence beginning with 'Avoid:'.",
      "After generation, zoom out or view it small. If the main shape is unclear, regenerate before saving.",
      `Save the accepted image as ${asset.filename}.`
    ],
    fileNamingReminder: `Save as public/assets/manual/${asset.targetFolder}/${asset.filename}`,
    transparencyPreferred: asset.transparencyPreferred,
    flatCleanBackgroundAllowed: asset.flatBackgroundAllowed,
    assetKind: assetKind(asset)
  };
}

function iconSpecificPrompt(asset: ManualAssetEntry): string {
  if (!["ability_icon", "resource_icon", "faction_emblem"].includes(asset.category)) {
    return "";
  }
  const emblemText =
    asset.category === "faction_emblem"
      ? "Emblem requirements: simple symbolic mark, no words, no detailed scene, no complex heraldic quartering, no copied real-world heraldry."
      : "";
  return [
    "Icon requirements: centered composition, one dominant symbol, strong silhouette, high contrast, readable at 64x64 and still clear when viewed as a tiny HUD button.",
    "Use thick shapes, controlled lighting, clear outer contour, and 10 to 15 percent padding around the symbol.",
    "Use no more than three main visual ideas. Avoid thin lines, detailed faces, tiny sparks, small runes, and busy texture.",
    emblemText
  ]
    .filter(Boolean)
    .join(" ");
}

function portraitSpecificPrompt(asset: ManualAssetEntry): string {
  if (asset.category !== "portrait") {
    return "";
  }
  return "Portrait requirements: square chest-up or bust framing, face and shoulders readable at UI size, expressive but not exaggerated face, clear class or faction identity through costume and props, simple atmospheric background, rim light separating the silhouette.";
}

function uiSpecificPrompt(asset: ManualAssetEntry): string {
  if (asset.category !== "ui") {
    return "";
  }
  return "UI background requirements: leave calm readable space for overlay panels and buttons, avoid busy focal details in the center, keep important detail near edges, no text, no logo, no UI mockup embedded in the art.";
}

function uiKitSpecificPrompt(asset: ManualAssetEntry): string {
  if (asset.category !== "ui_kit") {
    return "";
  }
  return [
    "UI kit requirements: create a reusable interface asset, not a screenshot and not a complete UI layout.",
    "Transparent PNG is strongly preferred. Keep the center transparent or extremely quiet for live browser text, icons, and numbers.",
    "For frame and button assets, design for nine-slice use: distinct decorated corners, repeatable edge bands, no important detail in the stretch zones, and no visual elements that would look wrong at different widths.",
    "Decoration should live on the border or slot edge. Avoid a painted full background, noisy center texture, fake labels, fake numbers, baked icons, or sample menu text.",
    "The result must still look clean when scaled down inside the battle HUD."
  ].join(" ");
}

function splashSpecificPrompt(asset: ManualAssetEntry): string {
  if (asset.category !== "splash") {
    return "";
  }
  return "Splash art requirements: cinematic original key art, strong foreground-middle-background hierarchy, readable fantasy strategy scale, visible hero and army fantasy, room for future title treatment, no text.";
}

function spriteSpecificPrompt(asset: ManualAssetEntry): string {
  if (asset.category !== "unit_sprite" && asset.category !== "building_sprite") {
    return "";
  }
  return "Current battle sprite requirements: single-frame static PNG only, one pose only, not an animation sheet, not a sprite strip, no frame grid, no multiple poses. The current game moves the image in code and does not yet load multi-frame animations.";
}

function buildNegativePrompt(asset: ManualAssetEntry): string {
  const categoryNegatives =
    asset.category === "icon" || asset.category.endsWith("_icon") || asset.category === "faction_emblem"
      ? ["no busy background", "no detailed face closeup", "no low contrast", "no tiny filigree", "no thin line art", "no illegible thumbnail", "no multi-object clutter"]
      : [];
  const spriteNegatives =
    asset.category === "unit_sprite" || asset.category === "building_sprite"
      ? ["no animation sheet", "no sprite strip", "no frame grid", "no multiple poses", "no turnaround sheet", "no character sheet"]
      : [];
  const uiNegatives = asset.category === "ui" ? ["no title text", "no menu labels", "no centered clutter", "no fake buttons", "no fake interface"] : [];
  const uiKitNegatives =
    asset.category === "ui_kit"
      ? [
          "no full screen UI mockup",
          "no fake menu",
          "no fake labels",
          "no baked text",
          "no sample icons",
          "no busy center fill",
          "no background scene",
          "no wallpaper texture",
          "no stretched full-panel art",
          "no screenshot look"
        ]
      : [];
  return [...ART_STYLE_BIBLE.globalNegativePrompt, ...categoryNegatives, ...spriteNegatives, ...uiNegatives, ...uiKitNegatives].join(", ");
}

function buildReadabilityNotes(asset: ManualAssetEntry): string {
  if (asset.smallSizeReadable) {
    return "Must remain readable at small UI sizes. Test mentally at 64x64: the outer silhouette, main symbol, and color identity should still be obvious. Prioritize value contrast and one clear focal shape.";
  }
  return "Designed for large presentation. Keep the main focal point readable at a glance.";
}

function buildBackgroundNotes(asset: ManualAssetEntry): string {
  if (asset.transparencyPreferred) {
    return "Transparent background preferred. If transparency is unavailable, use a flat dark neutral background that is easy to remove later.";
  }
  if (asset.flatBackgroundAllowed) {
    return "A simple flat or softly atmospheric background is acceptable.";
  }
  return "Use an atmospheric background, but keep the center readable for UI overlays where relevant.";
}

function normalizedCategory(category: string): string {
  if (category === "ability_icon" || category === "resource_icon" || category === "faction_emblem") {
    return "icon";
  }
  return category;
}

function asSentenceFragment(value: string): string {
  return value.trim().replace(/[.!?]+$/g, "");
}

function assetKind(asset: ManualAssetEntry): string {
  if (asset.category === "ability_icon" || asset.category === "resource_icon" || asset.category === "faction_emblem") {
    return "icon";
  }
  if (asset.category === "ui_kit") {
    return "UI kit";
  }
  return asset.category;
}

function renderMarkdown(book: PromptBook): string {
  const lines: string[] = [
    `# ${book.gameTitle} Manual Asset Prompt Book`,
    "",
    "This file is generated by `npm run assets:prompts`.",
    "",
    "## How To Use",
    "",
    ...book.instructions.map((instruction, index) => `${index + 1}. ${instruction}`),
    "",
    "## Asset Prompts",
    ""
  ];

  book.entries.forEach((entry, index) => {
    lines.push(
      `### ${index + 1}. ${entry.displayName}`,
      "",
      `- Asset ID: \`${entry.assetId}\``,
      `- Category: \`${entry.category}\``,
      `- Target filename: \`${entry.targetFilename}\``,
      `- Target folder: \`${entry.targetFolder}\``,
      `- Recommended size: \`${entry.recommendedSize}\``,
      `- Transparency preferred: \`${entry.transparencyPreferred ? "yes" : "no"}\``,
      `- Flat clean background allowed: \`${entry.flatCleanBackgroundAllowed ? "yes" : "no"}\``,
      `- Asset kind: \`${entry.assetKind}\``,
      "",
      "**MAIN PROMPT**",
      "",
      entry.mainPrompt,
      "",
      "**NEGATIVE PROMPT**",
      "",
      entry.negativePrompt,
      "",
      "**Usage Notes**",
      "",
      entry.usageNotes,
      "",
      "**Composition Notes**",
      "",
      entry.compositionNotes,
      "",
      "**Readability Notes**",
      "",
      entry.readabilityNotes,
      "",
      "**Background Notes**",
      "",
      entry.backgroundNotes,
      "",
      "**Manual ChatGPT Steps**",
      "",
      ...entry.chatGptSteps.map((step, stepIndex) => `${stepIndex + 1}. ${step}`),
      "",
      "**File Naming Reminder**",
      "",
      entry.fileNamingReminder,
      "",
      "---",
      ""
    );
  });

  return `${lines.join("\n")}\n`;
}

function relative(filePath: string): string {
  return path.relative(process.cwd(), filePath).replaceAll(path.sep, "/");
}

main().catch((error: unknown) => {
  console.error(error instanceof Error ? error.message : error);
  process.exitCode = 1;
});
