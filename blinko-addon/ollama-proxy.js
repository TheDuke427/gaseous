const express = require("express");
const fetch = require("node-fetch");

const app = express();
app.use(express.json());

const OLLAMA_HOST = process.env.OLLAMA_HOST || "192.168.86.44";
const OLLAMA_PORT = process.env.OLLAMA_PORT || "11434";

// Helper to transform chat completions to text completions
function transformChatToText(data) {
  if (!data.choices) return data;

  return {
    id: data.id,
    object: data.object,
    choices: data.choices.map(c => ({
      text: c.message?.content || "",
      index: c.index,
      finish_reason: c.finish_reason
    })),
    usage: data.usage
  };
}

// Proxy POST /v1/api/chat to Ollama /v1/completions
app.post("/v1/api/chat", async (req, res) => {
  try {
    const response = await fetch(`http://${OLLAMA_HOST}:${OLLAMA_PORT}/v1/completions`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(req.body)
    });

    const data = await response.json();
    const transformed = transformChatToText(data);
    res.json(transformed);
  } catch (err) {
    console.error("Error in Ollama proxy:", err);
    res.status(500).json({ error: err.message });
  }
});

// Pass through other /v1/* requests as-is
app.all("/v1/*", async (req, res) => {
  try {
    const url = `http://${OLLAMA_HOST}:${OLLAMA_PORT}${req.originalUrl.replace(/^\/v1/, "")}`;
    const response = await fetch(url, {
      method: req.method,
      headers: { ...req.headers, host: `${OLLAMA_HOST}:${OLLAMA_PORT}` },
      body: req.method !== "GET" && req.method !== "HEAD" ? JSON.stringify(req.body) : undefined
    });

    const data = await response.json();
    res.json(data);
  } catch (err) {
    console.error("Error in Ollama proxy:", err);
    res.status(500).json({ error: err.message });
  }
});

const PORT = process.env.OLLAMA_PROXY_PORT || 11435;
app.listen(PORT, () => {
  console.log(`Ollama proxy running on http://localhost:${PORT}/v1`);
});
