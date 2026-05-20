import type { ExtensionAPI, Theme } from "@earendil-works/pi-coding-agent";
import { VERSION } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.on("session_start", async (_event, ctx) => {
    if (ctx.hasUI) {
      ctx.ui.setHeader((_tui, theme) => ({
        render(_width: number): string[] {
          const mode = process.env.PRIVATE_MODE;
          const color = mode === "1" ? "accent" : "warning";
          const cwd = process.cwd();
          const dir = cwd.split(/[/\\]/).pop() || cwd;
          const modeLine =
            color === "accent"
              ? theme.fg("accent", "🔒 Offline mode") +
                theme.fg("muted", " — firewall active & iptables binaries removed")
              : theme.fg("warning", "🌐 Online mode") +
                theme.fg("muted", " — sandbox-restricted network access allowed");
          const scopeLine = theme.fg("muted", "Scope: ") + theme.fg("accent", `${dir}/`);
          return [
            theme.bold(theme.fg("warning", "Welcome to Picosa 🌶️")),
            theme.fg("success", "Your AI coding assistant ") +
              theme.fg("muted", `(pi ${VERSION})`),
            "",
            modeLine,
            scopeLine,
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
