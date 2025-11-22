// /app/ollama-proxy.js
const express = require("express");
const fetch = (...args) => import('node-fetch').then(({default: fetch}) => fetch(...args));
const bodyParser = require("body-parser");

const app = express();

const PORT = 11435;
const OLLAMA_HOST = process.env.OLLAMA_HOST || "192.168.86.44";
const OLLAMA_PORT = process.env.OLLAMA_PORT || "11434";

app.use(bodyParser.json({ limit: "10mb" }));

app.use(/^\/v1\/.*/, async (req, res) => {
  const startTime = Date.now();
  const ollamaPath = req.originalUrl.replace(/^\/v1/, '');
  const targetUrl = `http://${OLLAMA_HOST}:${OLLAMA_PORT}${ollamaPath}`;
  
  console.log(`\n========== PROXY REQUEST ==========`);
  console.log(`[PROXY] ${req.method} ${req.originalUrl} -> ${targetUrl}`);

  try {
    const fetchOptions = {
      method: req.method,
      headers: { 'Content-Type': 'application/json' },
    };

    if (req.method !== "GET" && req.method !== "HEAD" && req.body) {
      const bodyToSend = { ...req.body };
      
      console.log(`[PROXY] Request has tools: ${!!bodyToSend.tools}`);
      
      if (bodyToSend.tools) {
        console.log("[PROXY] ⚠️  Stripping tools parameter");
        delete bodyToSend.tools;
      }
      
      fetchOptions.body = JSON.stringify(bodyToSend);
    }

    const upstream = await fetch(targetUrl, fetchOptions);
    const elapsed = ((Date.now() - startTime) / 1000).toFixed(2);
    
    console.log(`[PROXY] ✓ Response: ${upstream.status} (${elapsed}s)`);

    res.status(upstream.status);
    upstream.headers.forEach((value, key) => {
      res.setHeader(key, value);
    });

    const body = await upstream.text();
    
    console.log(`[PROXY] Response body (${body.length} chars):`);
    console.log(body.substring(0, 800));
    if (body.length > 800) console.log(`... (truncated ${body.length - 800} chars)`);
    
    res.send(body);
    
    console.log(`[PROXY] ✓ Sent to client`);
    console.log(`========================================\n`);

  } catch (err) {
    const elapsed = ((Date.now() - startTime) / 1000).toFixed(2);
    console.error(`[PROXY] ✗ Error after ${elapsed}s: ${err.message}`);
    console.error(err.stack);
    res.status(500).json({ error: err.message });
  }
});

app.get("/health", (req, res) => {
  res.json({ status: "ok", target: `${OLLAMA_HOST}:${OLLAMA_PORT}` });
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(`\n🚀 [PROXY] Ollama proxy running`);
  console.log(`   Listen: 0.0.0.0:${PORT}`);
  console.log(`   Target: ${OLLAMA_HOST}:${OLLAMA_PORT}`);
  console.log(`   Tools stripping: enabled\n`);
});
