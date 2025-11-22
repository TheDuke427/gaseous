// /app/ollama-proxy.js
const express = require("express");
const fetch = (...args) => import('node-fetch').then(({default: fetch}) => fetch(...args));
const bodyParser = require("body-parser");

const app = express();

const PORT = 11435;
const OLLAMA_HOST = process.env.OLLAMA_HOST || "192.168.86.44";
const OLLAMA_PORT = process.env.OLLAMA_PORT || "11434";

app.use(bodyParser.json({ limit: "10mb" }));

// Pass-through proxy with tools parameter stripping
app.use(/^\/v1\/.*/, async (req, res) => {
  const startTime = Date.now();
  
  // Remove /v1 prefix: /v1/api/chat -> /api/chat
  const ollamaPath = req.originalUrl.replace(/^\/v1/, '');
  const targetUrl = `http://${OLLAMA_HOST}:${OLLAMA_PORT}${ollamaPath}`;
  
  console.log(`[PROXY] ${req.method} ${req.originalUrl} -> ${targetUrl}`);

  try {
    const fetchOptions = {
      method: req.method,
      headers: {
        'Content-Type': 'application/json',
      },
    };

    if (req.method !== "GET" && req.method !== "HEAD" && req.body) {
      // Remove 'tools' parameter if present (not supported by most Ollama models)
      const bodyToSend = { ...req.body };
      if (bodyToSend.tools) {
        console.log("[PROXY] Stripping 'tools' parameter (not supported)");
        delete bodyToSend.tools;
      }
      
      fetchOptions.body = JSON.stringify(bodyToSend);
    }

    const upstream = await fetch(targetUrl, fetchOptions);
    const elapsed = ((Date.now() - startTime) / 1000).toFixed(2);
    console.log(`[PROXY] Response: ${upstream.status} (${elapsed}s)`);

    // Copy status and headers
    res.status(upstream.status);
    upstream.headers.forEach((value, key) => {
      res.setHeader(key, value);
    });

    // Get response body
    const body = await upstream.text();
    
    // Log response preview for debugging (first 500 chars)
    if (ollamaPath.includes('/api/chat')) {
      console.log(`[PROXY] Response body: ${body.substring(0, 500)}`);
    }
    
    res.send(body);
    
    console.log(`[PROXY] Proxied successfully (${elapsed}s)`);

  } catch (err) {
    const elapsed = ((Date.now() - startTime) / 1000).toFixed(2);
    console.error(`[PROXY] Error after ${elapsed}s:`, err.message);
    res.status(500).json({ error: err.message });
  }
});

app.get("/health", (req, res) => {
  res.json({ status: "ok", target: `${OLLAMA_HOST}:${OLLAMA_PORT}` });
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(`[PROXY] Ollama proxy on http://0.0.0.0:${PORT}`);
  console.log(`[PROXY] Forwarding to http://${OLLAMA_HOST}:${OLLAMA_PORT}`);
  console.log(`[PROXY] Tools parameter stripping enabled`);
});  console.log(`[PROXY] Forwarding to http://${OLLAMA_HOST}:${OLLAMA_PORT}`);
  console.log(`[PROXY] Response logging enabled`);
});
