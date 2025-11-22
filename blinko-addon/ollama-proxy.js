// /app/ollama-proxy.js
import express from "express";
import fetch from "node-fetch";
import bodyParser from "body-parser";

const app = express();

const PORT = 11435;
const OLLAMA_HOST = process.env.OLLAMA_HOST || "192.168.86.44";
const OLLAMA_PORT = process.env.OLLAMA_PORT || "11434";

app.use(bodyParser.json({ limit: "10mb" }));

// Match ANY /v1/... request without using wildcard patterns
app.use(async (req, res, next) => {
  if (!req.originalUrl.startsWith("/v1")) return next();

  const targetUrl = `http://${OLLAMA_HOST}:${OLLAMA_PORT}${req.originalUrl}`;
  console.log("Proxying:", req.method, targetUrl);

  try {
    const upstream = await fetch(targetUrl, {
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

    // Copy headers
    upstream.headers.forEach((value, key) => {
      res.setHeader(key, value);
    });

    // Stream directly (no JSON.parse)
    upstream.body.pipe(res);
  } catch (err) {
    console.error("Proxy error:", err);
    res.status(500).json({ error: err.message });
  }
});

app.listen(PORT, () => {
  console.log(`Ollama proxy running on http://0.0.0.0:${PORT}`);
  console.log(`Forwarding to http://${OLLAMA_HOST}:${OLLAMA_PORT}`);
});
