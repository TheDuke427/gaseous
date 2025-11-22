// /app/ollama-proxy.js
import express from "express";
import fetch from "node-fetch"; // make sure node-fetch is installed
import bodyParser from "body-parser";

const app = express();
const PORT = 11435;

const OLLAMA_HOST = process.env.OLLAMA_HOST || "192.168.86.44";
const OLLAMA_PORT = process.env.OLLAMA_PORT || "11434";

app.use(bodyParser.json());

// Simple proxy for /v1 requests
app.use("/v1", async (req, res) => {
  const url = `http://${OLLAMA_HOST}:${OLLAMA_PORT}${req.originalUrl}`;

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
    console.error(`Error proxying ${req.originalUrl}:`, err);
    res.status(500).json({ error: err.message });
  }
});

app.listen(PORT, () => {
  console.log(`Ollama proxy running on http://0.0.0.0:${PORT}`);
  console.log(`Proxying to Ollama at http://${OLLAMA_HOST}:${OLLAMA_PORT}/v1`);
});
