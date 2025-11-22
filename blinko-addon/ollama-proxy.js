import express from "express";
import fetch from "node-fetch";
import bodyParser from "body-parser";

const app = express();
app.use(bodyParser.json({ limit: "50mb" }));

// Read host/port from env
const OLLAMA_HOST = process.env.OLLAMA_HOST || "192.168.86.44";
const OLLAMA_PORT = process.env.OLLAMA_PORT || "11434";

// Special route for /v1/api/chat -> /v1/completions
app.all("/v1/api/chat", async (req, res) => {
  try {
    const url = `http://${OLLAMA_HOST}:${OLLAMA_PORT}/v1/completions`;

    const response = await fetch(url, {
      method: req.method,
      headers: { ...req.headers, host: `${OLLAMA_HOST}:${OLLAMA_PORT}` },
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

// Catch-all for /v1/* paths
app.all("/v1/:path(*)", async (req, res) => {
  try {
    const proxiedPath = req.params.path ? `/${req.params.path}` : "";
    const url = `http://${OLLAMA_HOST}:${OLLAMA_PORT}${proxiedPath}`;

    const response = await fetch(url, {
      method: req.method,
      headers: { ...req.headers, host: `${OLLAMA_HOST}:${OLLAMA_PORT}` },
      body:
        req.method !== "GET" && req.method !== "HEAD"
          ? JSON.stringify(req.body)
          : undefined,
    });

    const data = await response.json();
    res.json(data);
  } catch (err) {
    console.error("Error proxying /v1/*:", err);
    res.status(500).json({ error: err.message });
  }
});

const PORT = process.env.OLLAMA_PROXY_PORT || 11435;
app.listen(PORT, () => {
  console.log(`Ollama proxy running on port ${PORT}, forwarding to ${OLLAMA_HOST}:${OLLAMA_PORT}`);
});
