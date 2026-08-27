export type UserRole = 'admin' | 'doctor' | 'receptionist' | 'patient';

export interface AppUser {
  id: string;
  username: string;
  passwordHash: string;
  salt: string;
  role: UserRole;
  fullName: string;
}

export interface Patient {
  id: string;
  fullName: string;
  birthDate: string;
  phone: string;
  allergies: string;
  chronicConditions: string;
  notes: string;
}

export interface Doctor {
  id: string;
  fullName: string;
  specialty: string;
  phone: string;
  consultationFee: number;
  schedule: string;
}

export type AppointmentStatus = 'scheduled' | 'completed' | 'cancelled' | 'noShow';

export const APPOINTMENT_STATUS_LABELS: Record<AppointmentStatus, string> = {
  scheduled: 'Planlaşdırılıb',
  completed: 'Tamamlanıb',
  cancelled: 'Ləğv edilib',
  noShow: 'Gəlmədi',
};

export interface Appointment {
  id: string;
  patientId: string;
  doctorId: string;
  dateTime: string;
  status: AppointmentStatus;
  reason: string;
}
