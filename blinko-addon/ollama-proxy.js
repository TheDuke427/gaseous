// /app/ollama-proxy.js
import express from "express";
import fetch from "node-fetch";
import bodyParser from "body-parser";

// Read Ollama host/port from env variables or default
const OLLAMA_HOST = process.env.OLLAMA_HOST || "192.168.86.44";
const OLLAMA_PORT = process.env.OLLAMA_PORT || "11434";

const app = express();
app.use(bodyParser.json());

// Proxy /v1/api/chat specifically
app.all("/v1/api/chat", async (req, res) => {
  try {
    const url = `http://${OLLAMA_HOST}:${OLLAMA_PORT}/v1/completions`;
    const response = await fetch(url, {
      method: req.method,
      headers: { ...req.headers, host: `${OLLAMA_HOST}:${OLLAMA_PORT}` },
      body: req.method !== "GET" && req.method !== "HEAD" ? JSON.stringify(req.body) : undefined,
    });

    const data = await response.json();
    res.json(data);
  } catch (err) {
    console.error("Error in Ollama proxy (/v1/api/chat):", err);
    res.status(500).json({ error: err.message });
  }
});

// Proxy everything else under /v1
app.all("/v1/:wildcard(*)", async (req, res) => {
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

// Start the proxy server
const PORT = process.env.OLLAMA_PROXY_PORT || 11435;
app.listen(PORT, () => {
  console.log(`Ollama proxy running on http://localhost:${PORT}, forwarding to ${OLLAMA_HOST}:${OLLAMA_PORT}`);
});
