// /app/ollama-proxy.js
const express = require("express");
const fetch = (...args) => import('node-fetch').then(({default: fetch}) => fetch(...args));
const bodyParser = require("body-parser");

const app = express();

const PORT = 11435;
const OLLAMA_HOST = process.env.OLLAMA_HOST || "192.168.86.44";
const OLLAMA_PORT = process.env.OLLAMA_PORT || "11434";

app.use(bodyParser.json({ limit: "10mb" }));

function cleanTagResponse(content) {
  // Don't clean refusals
  if (content.toLowerCase().includes('cannot') || 
      content.toLowerCase().includes('unable') ||
      content.toLowerCase().includes('sorry')) {
    console.log(`[PROXY] ⚠️  Detected refusal`);
    return content;
  }
  
  // Extract tags - handle both formats:
  // Format 1: #Tag1, #Tag2, #Tag3
  // Format 2: **Tags:** Tag1, Tag2, Tag3
  
  // Try format with # symbols first
  let tagMatches = content.match(/#[\w/-]+(?:\s*,\s*#[\w/-]+)*/g);
  
  if (tagMatches && tagMatches.length > 0) {
    let tags = tagMatches[0].replace(/\s*,\s*/g, ',');
    console.log(`[PROXY] 🏷️  Extracted tags (format 1): ${tags}`);
    return tags;
  }
  
  // Try **Tags:** format
  const tagsMatch = content.match(/\*\*Tags:\*\*\s*([^*\n]+)/i);
  if (tagsMatch) {
    // Extract tag names and add # prefix
    const tagNames = tagsMatch[1].trim().split(/\s*,\s*/);
    const tags = tagNames.map(t => `#${t.trim()}`).join(',');
    console.log(`[PROXY] 🏷️  Extracted tags (format 2): ${tags}`);
    return tags;
  }
  
  console.log(`[PROXY] ℹ️  No tags found`);
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
        console.log("[PROXY] ⚠️  Stripping tools");
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
    
    // Handle potential streaming responses (multiple JSON objects)
    if (body.includes('}\n{')) {
      console.log(`[PROXY] 📡 Detected streaming response, combining...`);
      const lines = body.trim().split('\n');
      const jsons = lines.map(line => {
        try { return JSON.parse(line); } catch { return null; }
      }).filter(Boolean);
      
      if (jsons.length > 0) {
        // Combine all content from chunks
        const lastChunk = jsons[jsons.length - 1];
        const fullContent = jsons.map(j => j.message?.content || '').join('');
        
        // Create single response
        const combined = {
          ...lastChunk,
          message: {
            role: "assistant",
            content: fullContent
          }
        };
        body = JSON.stringify(combined);
        console.log(`[PROXY] ✓ Combined ${jsons.length} chunks`);
      }
    }
    
    // Clean tag responses
    if (ollamaPath.includes('/api/chat') && upstream.status === 200) {
      try {
        const parsed = JSON.parse(body);
        if (parsed.message?.content) {
          const originalContent = parsed.message.content;
          const cleanedContent = cleanTagResponse(originalContent);
          
          if (cleanedContent !== originalContent) {
            console.log(`[PROXY] 🧹 Cleaned`);
            console.log(`[PROXY] Before: ${originalContent.substring(0, 100)}...`);
            console.log(`[PROXY] After: ${cleanedContent}`);
            parsed.message.content = cleanedContent;
            body = JSON.stringify(parsed);
          }
        }
      } catch (e) {
        console.log(`[PROXY] ⚠️  Parse error: ${e.message}`);
      }
    }
    
    console.log(`[PROXY] Body: ${body.substring(0, 300)}...`);
    
    res.send(body);
    console.log(`[PROXY] ✓ Sent`);
    console.log(`========================================\n`);

  } catch (err) {
    console.error(`[PROXY] ✗ Error: ${err.message}`);
    res.status(500).json({ error: err.message });
  }
});

app.get("/health", (req, res) => {
  res.json({ status: "ok", target: `${OLLAMA_HOST}:${OLLAMA_PORT}` });
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(`\n🚀 [PROXY] Ollama proxy (streaming-aware)`);
  console.log(`   :${PORT} -> ${OLLAMA_HOST}:${OLLAMA_PORT}\n`);
});    res.send(body);
    
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
