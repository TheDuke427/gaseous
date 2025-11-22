// /app/ollama-proxy.js
const express = require("express");
const fetch = (...args) => import('node-fetch').then(({default: fetch}) => fetch(...args));
const bodyParser = require("body-parser");

const app = express();

const PORT = 11435;
const OLLAMA_HOST = process.env.OLLAMA_HOST || "192.168.86.44";
const OLLAMA_PORT = process.env.OLLAMA_PORT || "11434";

app.use(bodyParser.json({ limit: "10mb" }));

// Transform Ollama response to OpenAI format
function transformToOpenAI(ollamaResponse) {
  return {
    id: `chatcmpl-${Date.now()}`,
    object: "chat.completion",
    created: Math.floor(Date.now() / 1000),
    model: ollamaResponse.model,
    choices: [{
      index: 0,
      message: {
        role: ollamaResponse.message.role,
        content: ollamaResponse.message.content
      },
      finish_reason: ollamaResponse.done_reason || "stop"
    }],
    usage: {
      prompt_tokens: ollamaResponse.prompt_eval_count || 0,
      completion_tokens: ollamaResponse.eval_count || 0,
      total_tokens: (ollamaResponse.prompt_eval_count || 0) + (ollamaResponse.eval_count || 0)
    }
  };
}

// Proxy all /v1 requests to Ollama
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
      console.log("[PROXY] Request body model:", req.body.model);
    }

    const upstream = await fetch(targetUrl, fetchOptions);
    console.log(`[PROXY] Response status: ${upstream.status}`);

    // Get content type
    const contentType = upstream.headers.get('content-type');
    
    // Check if this is a chat completion request
    const isChatCompletion = ollamaPath.includes('/api/chat');

    if (isChatCompletion && upstream.status === 200) {
      // Parse Ollama response
      const ollamaResponse = await upstream.json();
      console.log("[PROXY] Ollama response received, transforming to OpenAI format");
      
      // Transform to OpenAI format
      const openAIResponse = transformToOpenAI(ollamaResponse);
      
      // Send transformed response
      res.status(200).json(openAIResponse);
      console.log("[PROXY] Sent OpenAI-formatted response");
    } else {
      // For non-chat endpoints (like /api/tags), pass through as-is
      res.status(upstream.status);
      if (contentType) {
        res.setHeader('content-type', contentType);
      }
      
      const text = await upstream.text();
      res.send(text);
    }

  } catch (err) {
    console.error("[PROXY] Error:", err.message);
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
