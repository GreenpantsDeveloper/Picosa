import type { ExtensionAPI, Theme } from "@earendil-works/pi-coding-agent";
import { VERSION } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.on("session_start", async (_event, ctx) => {
    if (ctx.hasUI) {
      ctx.ui.setHeader((_tui, theme) => ({
        render(_width: number): string[] {
          return [
            theme.bold(theme.fg("warning", "Welcome to Picosa 🌶️")),
            theme.fg("success", "Your AI coding assistant ") +
              theme.fg("muted", `(pi ${VERSION})`),
            "",
            theme.fg("muted", "You could:"),
            theme.fg("muted", "- ask me what I can do for you;"),
            theme.fg("muted", "- let me write a skill, implement a feature branch or identify security risks;"),
            theme.fg("muted", "- point me to my own repository and ask me to improve myself;"),
            theme.fg("muted", "The sky is the limit 🔥")
          ];
        },
        invalidate() {},
      }));
    }
  });
}
