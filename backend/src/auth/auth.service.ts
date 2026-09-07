import bcrypt from 'bcrypt';
import { db } from '../config/database';
import { JwtHelper } from './jwt';
import { ApiError } from '../errors/api.error';
import { AuditService } from '../services/audit.service';

export interface RegisterDto {
  email: string;
  password: string;
  firstName: string;
  lastName: string;
  phone?: string;
  country?: string;
  dateOfBirth?: string;
}

export interface LoginDto {
  email: string;
  password: string;
}

export class AuthService {
  static async register(dto: RegisterDto, ip?: string) {
    // 1. Check if email exists
    const existing = await db.query('SELECT id FROM users WHERE email = $1', [dto.email.toLowerCase()]);
    if (existing.rows.length > 0) {
      throw ApiError.badRequest('An account with this email address already exists');
    }

    // 2. Hash password
    const salt = await bcrypt.genSalt(12);
    const passwordHash = await bcrypt.hash(dto.password, salt);

    // 3. Create user
    const res = await db.query(
      `INSERT INTO users (email, password_hash, first_name, last_name, phone, country, date_of_birth, is_active)
       VALUES ($1, $2, $3, $4, $5, $6, $7, TRUE)
       RETURNING id, email, first_name, last_name, phone, country, created_at`,
      [
        dto.email.toLowerCase(),
        passwordHash,
        dto.firstName,
        dto.lastName,
        dto.phone || null,
        dto.country || 'Algeria',
        dto.dateOfBirth || null,
      ]
    );

    const user = res.rows[0];

    // 4. Assign default 'customer' role
    const roleRes = await db.query("SELECT id FROM roles WHERE name = 'customer'");
    if (roleRes.rows.length > 0) {
      await db.query('INSERT INTO user_roles (user_id, role_id) VALUES ($1, $2)', [user.id, roleRes.rows[0].id]);
    }

    // 5. Audit log & JWT
    await AuditService.log('USER_REGISTERED', 'users', user.id, user.id, { email: user.email }, ip);
    const token = JwtHelper.sign({ userId: user.id, email: user.email, roles: ['customer'] });

    return { user, token };
  }

  static async login(dto: LoginDto, ip?: string) {
    const res = await db.query(
      `SELECT u.id, u.email, u.password_hash, u.first_name, u.last_name, u.phone, u.country, u.is_active,
              COALESCE(json_agg(r.name) FILTER (WHERE r.name IS NOT NULL), '["customer"]') as roles
       FROM users u
       LEFT JOIN user_roles ur ON u.id = ur.user_id
       LEFT JOIN roles r ON ur.role_id = r.id
       WHERE u.email = $1
       GROUP BY u.id`,
      [dto.email.toLowerCase()]
    );

    if (res.rows.length === 0) {
      throw ApiError.unauthorized('Invalid email or password credentials');
    }

    const user = res.rows[0];
    if (!user.is_active) {
      throw ApiError.forbidden('This user account has been disabled. Please contact support.');
    }

    const isMatch = await bcrypt.compare(dto.password, user.password_hash);
    if (!isMatch) {
      await AuditService.log('LOGIN_FAILED', 'users', user.id, user.id, { reason: 'bad_password' }, ip);
      throw ApiError.unauthorized('Invalid email or password credentials');
    }

    const roles: string[] = typeof user.roles === 'string' ? JSON.parse(user.roles) : user.roles;
    const token = JwtHelper.sign({ userId: user.id, email: user.email, roles });

    await AuditService.log('LOGIN_SUCCESS', 'users', user.id, user.id, {}, ip);

    return {
      user: {
        id: user.id,
        email: user.email,
        firstName: user.first_name,
        lastName: user.last_name,
        phone: user.phone,
        country: user.country,
        roles,
      },
      token,
    };
  }

  static async getProfile(userId: string) {
    const res = await db.query(
      `SELECT u.id, u.email, u.first_name, u.last_name, u.phone, u.country, u.date_of_birth, u.preferred_currency, u.preferred_language,
              COALESCE(json_agg(r.name) FILTER (WHERE r.name IS NOT NULL), '["customer"]') as roles
       FROM users u
       LEFT JOIN user_roles ur ON u.id = ur.user_id
       LEFT JOIN roles r ON ur.role_id = r.id
       WHERE u.id = $1
       GROUP BY u.id`,
      [userId]
    );

    if (res.rows.length === 0) {
      throw ApiError.notFound('User not found');
    }

    return res.rows[0];
  }
}
