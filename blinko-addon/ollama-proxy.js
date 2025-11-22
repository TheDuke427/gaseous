// /app/ollama-proxy.js
const express = require("express");
const fetch = (...args) => import('node-fetch').then(({default: fetch}) => fetch(...args));
const bodyParser = require("body-parser");

const app = express();

const PORT = 11435;
const OLLAMA_HOST = process.env.OLLAMA_HOST || "192.168.86.44";
const OLLAMA_PORT = process.env.OLLAMA_PORT || "11434";

app.use(bodyParser.json({ limit: "10mb" }));

// Function to clean tag responses
function cleanTagResponse(content) {
  // Don't clean if it looks like a refusal/error message
  if (content.toLowerCase().includes('cannot') || 
      content.toLowerCase().includes('unable') ||
      content.toLowerCase().includes('sorry')) {
    console.log(`[PROXY] ⚠️  Detected refusal/error, not cleaning`);
    return content;
  }
  
  // Extract tags that start with # (with or without spaces after commas)
  const tagMatches = content.match(/#[\w/-]+(?:\s*,\s*#[\w/-]+)*/g);
  
  if (tagMatches && tagMatches.length > 0) {
    // Take the first match (usually the main tag list)
    let tags = tagMatches[0];
    // Remove spaces after commas
    tags = tags.replace(/\s*,\s*/g, ',');
    console.log(`[PROXY] 🏷️  Extracted tags: ${tags}`);
    return tags;
  }
  
  // If no tags found, return original
  console.log(`[PROXY] ℹ️  No tags found, returning original`);
  return content;
}

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

    let body = await upstream.text();
    
    // Clean tag responses for /api/chat endpoints
    if (ollamaPath.includes('/api/chat') && upstream.status === 200) {
      try {
        const parsed = JSON.parse(body);
        if (parsed.message && parsed.message.content) {
          const originalContent = parsed.message.content;
          const cleanedContent = cleanTagResponse(originalContent);
          
          if (cleanedContent !== originalContent) {
            console.log(`[PROXY] 🧹 Cleaned response`);
            console.log(`[PROXY] Before: ${originalContent.substring(0, 150)}...`);
            console.log(`[PROXY] After: ${cleanedContent}`);
            parsed.message.content = cleanedContent;
            body = JSON.stringify(parsed);
          }
        }
      } catch (e) {
        console.log(`[PROXY] ⚠️  Could not parse/clean: ${e.message}`);
      }
    }
    
    console.log(`[PROXY] Response body (${body.length} chars):`);
    console.log(body.substring(0, 400));
    if (body.length > 400) console.log(`... (truncated)`);
    
    res.send(body);
    
    console.log(`[PROXY] ✓ Sent to client`);
    console.log(`========================================\n`);

  } catch (err) {
    const elapsed = ((Date.now() - startTime) / 1000).toFixed(2);
    console.error(`[PROXY] ✗ Error after ${elapsed}s: ${err.message}`);
    res.status(500).json({ error: err.message });
  }
});

app.get("/health", (req, res) => {
  res.json({ status: "ok", target: `${OLLAMA_HOST}:${OLLAMA_PORT}` });
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(`\n🚀 [PROXY] Ollama proxy with smart tag cleaning`);
  console.log(`   Listen: 0.0.0.0:${PORT}`);
  console.log(`   Target: ${OLLAMA_HOST}:${OLLAMA_PORT}`);
  console.log(`   Features: tools stripping, tag cleaning, refusal detection\n`);
});
