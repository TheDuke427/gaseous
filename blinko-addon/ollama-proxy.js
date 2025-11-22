// /app/ollama-proxy.js
import express from "express";
import fetch from "node-fetch"; // make sure node-fetch is installed
import bodyParser from "body-parser";

const app = express();
const PORT = 11435;

// Read environment variables (from run.sh)
const OLLAMA_HOST = process.env.OLLAMA_HOST || "192.168.86.44";
const OLLAMA_PORT = process.env.OLLAMA_PORT || "11434";

// Parse JSON request bodies
app.use(bodyParser.json());

// Optional: log requests for debugging
app.use((req, res, next) => {
  console.log(`[Proxy] ${req.method} ${req.path}`);
  next();
});

// Proxy all /v1/* requests to the Ollama server
app.all("/v1/:path(.*)", async (req, res) => {
  const proxiedPath = req.params.path; // captures everything after /v1/
  const url = `http://${OLLAMA_HOST}:${OLLAMA_PORT}/v1/${proxiedPath}`;

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

    // Ensure response is JSON
    const data = await response.json();
    res.json(data);
  } catch (err) {
    console.error(`Error proxying ${req.path}:`, err);
    res.status(500).json({ error: err.message });
  }
});

// Start the proxy server
app.listen(PORT, () => {
  console.log(`Ollama proxy running on http://0.0.0.0:${PORT}`);
  console.log(`Proxying to Ollama at http://${OLLAMA_HOST}:${OLLAMA_PORT}/v1`);
});
