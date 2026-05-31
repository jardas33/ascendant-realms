import { generateVisualReviewPack } from "../src/game/playtest/VisualReviewPack";

generateVisualReviewPack()
  .then((result) => {
    console.log("Visual review pack generated.");
    console.log(`Output: ${result.outputDirectory}`);
    console.log(`Index: ${result.indexPath}`);
    console.log(`Manifest: ${result.manifestPath}`);
    console.log(`README: ${result.readmePath}`);
    console.log(`Screenshots: ${result.screenshotCount}`);
    console.log(`Contact sheets: ${result.contactSheetCount}`);
    console.log(`Target viewports: ${result.targetViewports.join(", ")}`);
  })
  .catch((error) => {
    console.error(error instanceof Error ? error.stack ?? error.message : error);
    process.exitCode = 1;
  });
