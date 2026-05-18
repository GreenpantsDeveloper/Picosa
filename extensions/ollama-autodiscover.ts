import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import fs from "fs";
import os from "os";
import path from "path";

export default async function (pi: ExtensionAPI) {
  const agentDir = path.join(os.homedir(), ".pi", "agent");
  const settingsPath = path.join(agentDir, "settings.json");

  let defaultModelId: string | undefined;
  try {
    const settings = JSON.parse(fs.readFileSync(settingsPath, "utf8")) as {
      defaultModel?: string;
      defaultProvider?: string;
    };
    if (settings.defaultModel && settings.defaultProvider === "ollama") {
      defaultModelId = settings.defaultModel;
    }
  } catch {
  }

  pi.on("session_start", async (event, ctx) => {
    try {
      const ollamaBaseUrl = process.env.OLLAMA_BASE_URL || "http://host.docker.internal:11434/v1";
      const ollamaApiUrl = ollamaBaseUrl.replace(/\/v1$/, "");
      const response = await fetch(ollamaApiUrl + "/api/tags");
      const payload = (await response.json()) as {
        models: Array<{
          name: string;
          model?: string;
          modified_at: string;
          size: number;
          digest: string;
          details?: {
            parent_model?: string;
            format?: string;
            family?: string;
            families?: string[];
            parameter_size?: string;
            quantization_level?: string;
          };
        }>;
      };

      const ollamaModels = payload.models.map((m) => ({
        id: m.name,
        name: m.name,
        reasoning: false,
        input: ["text"] as const,
        cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
        contextWindow: 128000,
        maxTokens: 4096,
      }));

      const knownIds = new Set(ctx.modelRegistry.getAll().map((model) => model.id));
      const newModels = ollamaModels.filter((m) => !knownIds.has(m.id));

      if (newModels.length > 0) {
        pi.registerProvider("ollama", {
          baseUrl: ollamaBaseUrl,
          apiKey: "ollama",
          api: "openai-completions",
          models: newModels,
        });
      }
    } catch (err) {
      console.error("Ollama auto-discover failed:", err);
    }
  });
}
