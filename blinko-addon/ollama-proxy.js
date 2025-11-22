import express from "express";
import fetch from "node-fetch";
import bodyParser from "body-parser";

const app = express();
const PORT = 11435;

// Read host/port from environment variables or defaults
const OLLAMA_HOST = process.env.OLLAMA_HOST || "192.168.86.44";
const OLLAMA_PORT = process.env.OLLAMA_PORT || "11434";

app.use(bodyParser.json());

// Special route for /v1/api/chat
app.all("/v1/api/chat", async (req, res) => {
  try {
    const url = `http://${OLLAMA_HOST}:${OLLAMA_PORT}/v1/completions`;
    const response = await fetch(url, {
      method: req.method,
      headers: { ...req.headers, host: `${OLLAMA_HOST}:${OLLAMA_PORT}` },
      body: JSON.stringify(req.body),
    });

    const data = await response.json();
    res.json(data);
  } catch (err) {
    console.error("Error in Ollama proxy (/v1/api/chat):", err);
    res.status(500).json({ error: err.message });
  }
});

// Catch-all route for other /v1/* requests
app.all("/v1/*", async (req, res) => {
  try {
    const proxiedPath = req.originalUrl.replace(/^\/v1/, "");
    const url = `http://${OLLAMA_HOST}:${OLLAMA_PORT}${proxiedPath}`;

    const response = await fetch(url, {
      method: req.method,
      headers: { ...req.headers, host: `${OLLAMA_HOST}:${OLLAMA_PORT}` },
      body: req.method !== "GET" && req.method !== "HEAD" ? JSON.stringify(req.body) : undefined,
    });

    const data = await response.json();
    res.json(data);
  } catch (err) {
    console.error("Error in Ollama proxy (/v1/*):", err);
    res.status(500).json({ error: err.message });
  }
});

app.listen(PORT, () => {
  console.log(`Ollama proxy running on http://localhost:${PORT}`);
});
