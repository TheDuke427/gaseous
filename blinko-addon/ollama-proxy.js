// /app/ollama-proxy.js
const express = require("express");
const fetch = require("node-fetch");

const app = express();
app.use(express.json({ limit: "10mb" }));

// Read environment variables for Ollama
const OLLAMA_HOST = process.env.OLLAMA_HOST || "192.168.86.44";
const OLLAMA_PORT = process.env.OLLAMA_PORT || 11434;
const OLLAMA_URL = `http://${OLLAMA_HOST}:${OLLAMA_PORT}/v1/completions`;

app.post("/v1/api/chat", async (req, res) => {
  try {
    // Forward the incoming request to Ollama
    const response = await fetch(OLLAMA_URL, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(req.body),
    });

    const data = await response.json();

    // Normalize response for Blinko
    const normalized = {
      id: data.id || "cmpl-unknown",
      object: data.object || "chat.completion",
      choices: (data.choices || []).map((c, i) => ({
        index: i,
        message:
          c.message ||
          (c.text ? { role: "assistant", content: c.text } : { role: "assistant", content: "" }),
        finish_reason: c.finish_reason || "stop",
      })),
      usage:
        data.usage || { prompt_tokens: 0, completion_tokens: 0, total_tokens: 0 },
    };

    res.json(normalized);
  } catch (err) {
    console.error("Error in Ollama proxy:", err);
    res.status(500).json({ error: "Failed to forward request to Ollama" });
  }
});

// Optional: health check
app.get("/health", (req, res) => {
  res.json({ status: "ok" });
});

const PORT = process.env.PROXY_PORT || 11435;
app.listen(PORT, () => {
  console.log(`Ollama Node proxy listening on port ${PORT}`);
  console.log(`Forwarding requests to Ollama at ${OLLAMA_URL}`);
});
