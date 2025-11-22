// /app/ollama-proxy.js
const express = require("express");
const fetch = (...args) => import('node-fetch').then(({default: fetch}) => fetch(...args));
const bodyParser = require("body-parser");

const app = express();

const PORT = 11435;
const OLLAMA_HOST = process.env.OLLAMA_HOST || "192.168.86.44";
const OLLAMA_PORT = process.env.OLLAMA_PORT || "11434";

app.use(bodyParser.json({ limit: "10mb" }));

// Proxy all /v1 requests to Ollama (using regex route)
app.use(/^\/v1\/.*/, async (req, res) => {
  // Remove /v1 prefix: /v1/api/chat -> /api/chat
  const ollamaPath = req.originalUrl.replace(/^\/v1/, '');
  const targetUrl = `http://${OLLAMA_HOST}:${OLLAMA_PORT}${ollamaPath}`;
  
  console.log(`[PROXY] ${req.method} ${req.originalUrl} -> ${targetUrl}`);

  try {
    const fetchOptions = {
      method: req.method,
      headers: {
        'Content-Type': 'application/json',
        'Accept': '*/*',
      },
    };

    // Add body for POST/PUT/PATCH
    if (req.method !== "GET" && req.method !== "HEAD" && req.body) {
      fetchOptions.body = JSON.stringify(req.body);
      console.log("[PROXY] Request body:", JSON.stringify(req.body, null, 2));
    }

    const upstream = await fetch(targetUrl, fetchOptions);

    console.log(`[PROXY] Response status: ${upstream.status}`);

    // Set response status
    res.status(upstream.status);

    // Copy relevant headers
    const contentType = upstream.headers.get('content-type');
    if (contentType) {
      res.setHeader('content-type', contentType);
    }

    // Check if response is streaming (text/event-stream or chunked)
    const isStream = contentType && (
      contentType.includes('text/event-stream') ||
      contentType.includes('application/x-ndjson')
    );

    if (isStream) {
      console.log("[PROXY] Streaming response");
      // Stream response
      upstream.body.pipe(res);
    } else {
      // Buffer and send
      const text = await upstream.text();
      console.log("[PROXY] Response:", text.substring(0, 200) + (text.length > 200 ? '...' : ''));
      res.send(text);
    }

  } catch (err) {
    console.error("[PROXY] Error:", err.message);
    res.status(500).json({ error: err.message });
  }
});

// Health check
app.get("/health", (req, res) => {
  res.json({ status: "ok", target: `${OLLAMA_HOST}:${OLLAMA_PORT}` });
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(`[PROXY] Ollama proxy running on http://0.0.0.0:${PORT}`);
  console.log(`[PROXY] Forwarding to http://${OLLAMA_HOST}:${OLLAMA_PORT}`);
  console.log(`[PROXY] /v1/api/chat -> /api/chat (Ollama native)`);
});
});

// Health check
app.get("/health", (req, res) => {
  res.json({ status: "ok", target: `${OLLAMA_HOST}:${OLLAMA_PORT}` });
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(`[PROXY] Ollama proxy running on http://0.0.0.0:${PORT}`);
  console.log(`[PROXY] Forwarding to http://${OLLAMA_HOST}:${OLLAMA_PORT}`);
  console.log(`[PROXY] /v1/api/chat -> /api/chat (Ollama native)`);
});
