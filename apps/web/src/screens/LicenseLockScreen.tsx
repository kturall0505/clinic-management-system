export function LicenseLockScreen({
  lastSuccess,
  onRetry,
  checking,
}: {
  lastSuccess: Date | null;
  onRetry: () => void;
  checking: boolean;
}) {
  return (
    <div className="centered-page">
      <div className="card login-card">
        <h1>⚠️ Lisenziya yoxlaması tələb olunur</h1>
        <p>
          Sistem lokal işləyir, lakin gündə ən azı bir dəfə lisenziya serverinə
          qoşulmalıdır. Bu yoxlama zamanı heç bir pasient və ya klinik məlumat
          göndərilmir — yalnız lisenziya statusu yoxlanılır.
        </p>
        <p>
          Son uğurlu yoxlama:{' '}
          {lastSuccess ? lastSuccess.toLocaleString('az-AZ') : 'yoxdur'}
        </p>
        <button onClick={onRetry} disabled={checking}>
          {checking ? 'Yoxlanılır…' : 'Yenidən yoxla'}
        </button>
      </div>
    </div>
  );
}
