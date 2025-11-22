// /app/ollama-proxy.js
import express from "express";
import fetch from "node-fetch";
import bodyParser from "body-parser";

// Read Ollama host and port from environment variables
const OLLAMA_HOST = process.env.OLLAMA_HOST || "192.168.86.44";
const OLLAMA_PORT = process.env.OLLAMA_PORT || "11434";

const app = express();
app.use(bodyParser.json());

// Proxy /v1/api/chat requests to Ollama
app.all("/v1/api/chat", async (req, res) => {
  const url = `http://${OLLAMA_HOST}:${OLLAMA_PORT}/v1/api/chat`;

  try {
    const response = await fetch(url, {
      method: req.method,
      headers: {
        ...req.headers,
        host: `${OLLAMA_HOST}:${OLLAMA_PORT}`, // optional but sometimes helps
      },
      body:
        req.method !== "GET" && req.method !== "HEAD"
          ? JSON.stringify(req.body)
          : undefined,
    });

    const data = await response.json();
    res.json(data);
  } catch (err) {
    console.error("Error proxying /v1/api/chat:", err);
    res.status(500).json({ error: err.message });
  }
});

// Optional: proxy any other /v1/* endpoints
app.all("/v1/*", async (req, res) => {
  const proxiedPath = req.path.replace(/^\/v1/, ""); // strip /v1 prefix
  const url = `http://${OLLAMA_HOST}:${OLLAMA_PORT}${proxiedPath}`;

  try {
    const response = await fetch(url, {
      method: req.method,
      headers: {
        ...req.headers,
        host: `${OLLAMA_HOST}:${OLLAMA_PORT}`,
      },
      body:
        req.method !== "GET" && req.method !== "HEAD"
          ? JSON.stringify(req.body)
          : undefined,
    });

    const data = await response.json();
    res.json(data);
  } catch (err) {
    console.error(`Error proxying ${req.path}:`, err);
    res.status(500).json({ error: err.message });
  }
});

const PORT = 11435; // local proxy port
app.listen(PORT, () => {
  console.log(`Ollama proxy running on http://localhost:${PORT}`);
});
