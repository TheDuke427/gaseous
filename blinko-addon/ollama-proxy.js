import express from 'express';
import fetch from 'node-fetch';

const app = express();
app.use(express.json());

const OLLAMA_HOST = process.env.OLLAMA_HOST || '192.168.86.44';
const OLLAMA_PORT = process.env.OLLAMA_PORT || '11434';

app.post('/v1/api/chat', async (req, res) => {
  try {
    const prompt = req.body.prompt || req.body.messages?.map(m => m.content).join('\n') || '';

    const response = await fetch(`http://${OLLAMA_HOST}:${OLLAMA_PORT}/v1/completions`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        model: req.body.model || 'llama3:8b',
        prompt,
        stream: false,
        keep_alive: -1
      })
    });

    const data = await response.json();

    // Transform Ollama TextCompletion → OpenAI ChatCompletion
    const chatJSON = {
      id: data.id || 'cmpl-1',
      object: 'chat.completion',
      choices: [
        {
          message: {
            role: 'assistant',
            content: data.choices[0]?.text || ''
          },
          finish_reason: data.choices[0]?.finish_reason || 'stop'
        }
      ]
    };

    res.json(chatJSON);

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Proxy failed', details: err.message });
  }
});

app.listen(11435, () => {
  console.log('Blinko → Ollama proxy running on http://localhost:11435');
});
