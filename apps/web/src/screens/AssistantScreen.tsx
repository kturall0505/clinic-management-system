import { useState, type FormEvent } from 'react';

import { askAssistant } from '../core/ai';

interface Message {
  from: 'user' | 'assistant';
  text: string;
}

const GREETING: Message = {
  from: 'assistant',
  text: 'Salam! Mən klinika köməkçisiyəm. Randevu, pasient, həkim və lisenziya mövzularında sual verə bilərsiniz.',
};

export function AssistantScreen() {
  const [messages, setMessages] = useState<Message[]>([GREETING]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    const question = input.trim();
    if (!question || loading) return;
    setInput('');
    setMessages((m) => [...m, { from: 'user', text: question }]);
    setLoading(true);
    try {
      const answer = await askAssistant(question);
      setMessages((m) => [...m, { from: 'assistant', text: answer }]);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="chat">
      <div className="chat-messages">
        {messages.map((m, i) => (
          <div key={i} className={`bubble bubble-${m.from}`}>
            {m.text}
          </div>
        ))}
        {loading && <div className="bubble bubble-assistant">…</div>}
      </div>
      <form className="chat-input" onSubmit={handleSubmit}>
        <input
          value={input}
          onChange={(e) => setInput(e.target.value)}
          placeholder="Sualınızı yazın…"
        />
        <button type="submit" disabled={loading}>
          Göndər
        </button>
      </form>
    </div>
  );
}
