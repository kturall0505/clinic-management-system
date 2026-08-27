import { AI_ENDPOINT } from './config';

const OFFLINE_ANSWERS: Array<{ keywords: string[]; answer: string }> = [
  {
    keywords: ['randevu'],
    answer:
      'Randevu yaratmaq üçün "Randevular" bölməsinə keçin və "+" düyməsinə basın. Pasient və həkim seçib tarixi təyin edin.',
  },
  {
    keywords: ['pasient', 'xəste', 'xeste', 'xəstə'],
    answer:
      'Pasient əlavə etmək üçün "Pasientlər" bölməsində "+" düyməsinə basın. Allergiya və xroniki xəstəlikləri qeyd etməyi unutmayın.',
  },
  {
    keywords: ['həkim', 'hekim'],
    answer:
      '"Həkimlər" bölməsində həkim profili yarada, ixtisas və qəbul haqqını təyin edə bilərsiniz.',
  },
  {
    keywords: ['lisenziya', 'internet'],
    answer:
      'Sistem lokal işləyir, lakin gündə bir dəfə lisenziya serverinə qoşulmalıdır. Bu yoxlama zamanı heç bir pasient məlumatı göndərilmir.',
  },
];

const FALLBACK =
  'Salam! Randevu, pasient, həkim və lisenziya mövzularında kömək edə bilərəm. Sualınızı daha dəqiq yaza bilərsinizmi?';

export function offlineAnswer(question: string): string {
  const q = question.toLowerCase();
  for (const entry of OFFLINE_ANSWERS) {
    if (entry.keywords.some((k) => q.includes(k))) return entry.answer;
  }
  return FALLBACK;
}

export async function askAssistant(question: string): Promise<string> {
  if (!AI_ENDPOINT) return offlineAnswer(question);
  try {
    const res = await fetch(AI_ENDPOINT, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ question }),
    });
    if (!res.ok) return offlineAnswer(question);
    const data: unknown = await res.json();
    if (
      typeof data === 'object' &&
      data !== null &&
      'answer' in data &&
      typeof (data as { answer: unknown }).answer === 'string'
    ) {
      return (data as { answer: string }).answer;
    }
    return offlineAnswer(question);
  } catch {
    return offlineAnswer(question);
  }
}
