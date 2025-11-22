// /app/ollama-proxy.js
const express = require("express");
const fetch = (...args) => import('node-fetch').then(({default: fetch}) => fetch(...args));
const bodyParser = require("body-parser");

const app = express();

const PORT = 11435;
const OLLAMA_HOST = process.env.OLLAMA_HOST || "192.168.86.44";
const OLLAMA_PORT = process.env.OLLAMA_PORT || "11434";

app.use(bodyParser.json({ limit: "10mb" }));

// Simple pass-through proxy - NO transformation
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
      fetchOptions.body = JSON.stringify(req.body);
    }

    const upstream = await fetch(targetUrl, fetchOptions);
    const elapsed = ((Date.now() - startTime) / 1000).toFixed(2);
    console.log(`[PROXY] Response: ${upstream.status} (${elapsed}s)`);

    // Copy status and headers
    res.status(upstream.status);
    upstream.headers.forEach((value, key) => {
      res.setHeader(key, value);
    });

    // Pass through response body as-is
    const body = await upstream.text();
    res.send(body);
    
    console.log(`[PROXY] Proxied successfully (${elapsed}s)`);

  } catch (err) {
    const elapsed = ((Date.now() - startTime) / 1000).toFixed(2);
    console.error(`[PROXY] Error after ${elapsed}s:`, err.message);
    res.status(500).json({ error: err.message });
  }
});    if (isChatCompletion && upstream.status === 200) {
      console.log("[PROXY] Parsing Ollama response...");
      
      // Parse Ollama response
      const ollamaResponse = await upstream.json();
      console.log("[PROXY] Ollama response parsed successfully");
      console.log("[PROXY] Response preview:", JSON.stringify(ollamaResponse).substring(0, 200));
      
      // Transform to OpenAI format
      const openAIResponse = transformToOpenAI(ollamaResponse);
      console.log("[PROXY] Transformed to OpenAI format");
      
      // Send transformed response
      res.status(200).json(openAIResponse);
      const totalElapsed = ((Date.now() - startTime) / 1000).toFixed(2);
      console.log(`[PROXY] Response sent successfully (${totalElapsed}s total)`);
    } else {
      console.log("[PROXY] Non-chat endpoint, passing through...");
      
      // For non-chat endpoints (like /api/tags), pass through as-is
      res.status(upstream.status);
      if (contentType) {
        res.setHeader('content-type', contentType);
      }
      
      const text = await upstream.text();
      console.log(`[PROXY] Pass-through response: ${text.substring(0, 100)}`);
      res.send(text);
    }

  } catch (err) {
    const elapsed = ((Date.now() - startTime) / 1000).toFixed(2);
    console.error(`[PROXY] Error after ${elapsed}s:`, err.message);
    console.error("[PROXY] Stack:", err.stack);
    
    res.status(500).json({ 
      error: {
        message: err.message,
        type: "proxy_error"
      }
    });
  }
});

// Health check
app.get("/health", (req, res) => {
  res.json({ 
    status: "ok", 
    target: `${OLLAMA_HOST}:${OLLAMA_PORT}`,
    transforming: "ollama_to_openai"
  });
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(`[PROXY] Ollama-to-OpenAI proxy running on http://0.0.0.0:${PORT}`);
  console.log(`[PROXY] Forwarding to http://${OLLAMA_HOST}:${OLLAMA_PORT}`);
  console.log(`[PROXY] Transforming Ollama responses to OpenAI format`);
});
