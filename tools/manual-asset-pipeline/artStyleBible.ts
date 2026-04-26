export interface FactionVisualIdentity {
  id: string;
  name: string;
  colors: string[];
  themes: string[];
  shapes: string[];
  promptNotes: string;
}

export interface AssetStyleNotes {
  category: string;
  notes: string[];
}

export interface ArtStyleBible {
  gameTitle: string;
  coreVisualIdentity: string[];
  manualGenerationGuidance: string[];
  visualRules: string[];
  globalNegativePrompt: string[];
  factions: FactionVisualIdentity[];
  assetStyleNotes: AssetStyleNotes[];
}

export const ART_STYLE_BIBLE: ArtStyleBible = {
  gameTitle: "Ascendant Realms",
  coreVisualIdentity: [
    "dark heroic fantasy",
    "fully original IP",
    "readable RTS silhouettes",
    "slightly painterly fantasy look for portraits and splash art",
    "crisp stylized icons",
    "strong shape language",
    "high readability",
    "not overly cartoonish",
    "not photorealistic for game icons",
    "suitable for a fantasy strategy RPG",
    "clean and consistent"
  ],
  manualGenerationGuidance: [
    "Generate one asset at a time.",
    "Use the exact target aspect ratio when possible.",
    "If ChatGPT cannot create transparency, use a flat dark neutral background that can be removed later.",
    "After generation, inspect the image at thumbnail size before accepting it.",
    "Reject outputs with text, watermarks, copied logos, unclear silhouettes, or overly busy detail."
  ],
  visualRules: [
    "Do not imitate any existing game, franchise, movie, book, logo, character, faction, user interface, or map.",
    "Do not use existing IP names, copyrighted symbols, or recognizable proprietary designs.",
    "Do not request the style of a living artist.",
    "No watermark, no signature, no creator mark, and no text in the image unless explicitly requested.",
    "Use strong contrast and readable silhouettes.",
    "Keep important forms clear at small sizes when the asset is an icon or UI element.",
    "Use simple backgrounds when the asset must be readable in an interface.",
    "Keep the image original, commercially safe, and suitable for later replacement by commissioned final art."
  ],
  globalNegativePrompt: [
    "no copyrighted characters",
    "no existing game logos",
    "no existing faction symbols",
    "no watermark",
    "no signature",
    "no readable text",
    "no modern guns",
    "no sci-fi technology",
    "no photorealistic UI icon rendering",
    "no realistic photography",
    "no cluttered composition",
    "no tiny unreadable details",
    "no extra weapons or symbols not requested",
    "no border frame unless explicitly requested",
    "no imitation of any living artist"
  ],
  factions: [
    {
      id: "free_marches",
      name: "Free Marches",
      colors: ["deep blue", "worn silver", "muted gold"],
      themes: ["frontier kingdom", "militias", "banners", "chapels", "stone keeps", "rangers"],
      shapes: ["shields", "towers", "practical armor", "banners"],
      promptNotes:
        "A grounded frontier alliance with practical soldiers, old stone fortifications, worn heraldry, chapel bells, and disciplined but not ornate military design. Use practical materials, clean military silhouettes, and restrained nobility rather than royal excess."
    },
    {
      id: "ashen_covenant",
      name: "Ashen Covenant",
      colors: ["black", "ember red", "burnt bronze"],
      themes: ["volcanic cult", "raiders", "iron", "smoke", "braziers", "ash priests"],
      shapes: ["spikes", "jagged metal", "heavy silhouettes"],
      promptNotes:
        "A harsh volcanic war cult with soot, ember light, jagged iron, heavy raider silhouettes, ritual braziers, and intimidating priest-warrior motifs. Use brutal asymmetry, scorched materials, and ember glow without copying any known dark-fantasy faction."
    },
    {
      id: "sylvan_concord",
      name: "Sylvan Concord",
      colors: ["forest green", "moon white", "bark brown"],
      themes: ["enchanted forest", "mystics", "roots", "moon wells", "living wood"],
      shapes: ["flowing curves", "roots", "crescents", "vines"],
      promptNotes:
        "An ancient forest pact with moonlit magic, living wood, root patterns, crescent shapes, quiet mystics, and organic structures grown rather than built. Use elegant organic forms and calm ancient power, not cute woodland imagery."
    }
  ],
  assetStyleNotes: [
    {
      category: "portrait",
      notes: [
        "Slightly painterly fantasy bust portrait.",
        "Chest-up or bust framing, clear face, expressive but restrained mood.",
        "Readable class identity through costume, props, color, and silhouette.",
        "Simple background with atmosphere, not a busy battle scene.",
        "Face and upper torso should remain readable when cropped into a square UI portrait.",
        "Use rim light and value contrast to separate the character from the background."
      ]
    },
    {
      category: "icon",
      notes: [
        "Crisp stylized game icon, centered composition.",
        "Must remain readable at 64x64.",
        "Use one dominant symbol, strong silhouette, high contrast, and limited detail.",
        "Transparent background is preferred for ability, resource, and faction icons.",
        "Keep 10 to 15 percent padding around the symbol.",
        "Use at most three main shapes or visual ideas.",
        "Avoid thin lines, detailed faces, small runes, tiny sparks, and low-contrast gradients."
      ]
    },
    {
      category: "unit_concept",
      notes: [
        "Readable full-body or three-quarter fantasy strategy unit concept.",
        "Clear weapon, armor, role, and faction identity.",
        "Neutral simple background is acceptable.",
        "Prioritize silhouette over render polish.",
        "Use a pose that could later become an RTS sprite."
      ]
    },
    {
      category: "building_concept",
      notes: [
        "Readable fantasy strategy building concept.",
        "Three-quarter view or slightly top-down concept view.",
        "Clear scale, function, faction materials, and silhouette.",
        "Simple ground plane or transparent background is acceptable.",
        "Avoid tiny props that will disappear at game scale."
      ]
    },
    {
      category: "ui",
      notes: [
        "Dark fantasy UI support art with room for readable text overlays.",
        "Avoid busy centers where menus or results panels will sit.",
        "Use soft contrast and atmospheric edges.",
        "No embedded text or logos.",
        "Keep center safe zones quieter than corners and edges."
      ]
    },
    {
      category: "ui_kit",
      notes: [
        "Reusable dark fantasy interface kit art, not a full screen mockup.",
        "Transparent PNG is strongly preferred.",
        "For frames, leave the center transparent or extremely quiet so live text and icons stay readable.",
        "Design corners and edges for nine-slice use: distinct corners, repeatable edges, no important detail in the stretch zone.",
        "Use worn silver, blackened iron, dark leather, muted gold accents, and restrained blue aether glints.",
        "No text, no labels, no logo, no embedded icons unless the specific asset asks for one.",
        "Keep decoration on the edge; do not paint a busy center."
      ]
    },
    {
      category: "splash",
      notes: [
        "Original key art for a fantasy RTS/RPG.",
        "Cinematic composition with a strong focal point.",
        "Must communicate hero, army, realm, and magic without copying any existing IP.",
        "Leave room for later title/logo treatment if needed.",
        "Use a clear foreground, middle ground, and background so it reads at store-capsule size."
      ]
    }
  ]
};
