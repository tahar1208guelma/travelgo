import { db } from '../config/database';
import { ApiError } from '../errors/api.error';

export interface UpdateProfileDto {
  firstName?: string;
  lastName?: string;
  phone?: string;
  country?: string;
  dateOfBirth?: string;
  preferredCurrency?: string;
  preferredLanguage?: string;
}

export class UsersService {
  static async updateProfile(userId: string, dto: UpdateProfileDto) {
    const res = await db.query(
      `UPDATE users 
       SET first_name = COALESCE($1, first_name),
           last_name = COALESCE($2, last_name),
           phone = COALESCE($3, phone),
           country = COALESCE($4, country),
           date_of_birth = COALESCE($5, date_of_birth),
           preferred_currency = COALESCE($6, preferred_currency),
           preferred_language = COALESCE($7, preferred_language),
           updated_at = CURRENT_TIMESTAMP
       WHERE id = $8
       RETURNING id, email, first_name, last_name, phone, country, date_of_birth, preferred_currency, preferred_language`,
      [dto.firstName, dto.lastName, dto.phone, dto.country, dto.dateOfBirth, dto.preferredCurrency, dto.preferredLanguage, userId]
    );

    if (res.rows.length === 0) throw ApiError.notFound('User not found');
    return res.rows[0];
  }

  static async getPassengers(userId: string) {
    const res = await db.query('SELECT * FROM passengers WHERE user_id = $1 ORDER BY created_at DESC', [userId]);
    return res.rows;
  }

  static async addPassenger(userId: string, data: any) {
    const res = await db.query(
      `INSERT INTO passengers (user_id, first_name, last_name, passport_number, nationality, passport_expiry, date_of_birth, gender)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
       RETURNING *`,
      [userId, data.firstName, data.lastName, data.passportNumber, data.nationality, data.passportExpiry, data.dateOfBirth, data.gender]
    );
    return res.rows[0];
  }
}
