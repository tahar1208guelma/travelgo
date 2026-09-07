import { Request, Response, NextFunction } from 'express';
import { JwtHelper, TokenPayload } from './jwt';
import { ApiError } from '../errors/api.error';

declare global {
  namespace Express {
    interface Request {
      user?: TokenPayload;
    }
  }
}

export const authenticateJwt = (req: Request, res: Response, next: NextFunction) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return next(ApiError.unauthorized('Bearer authentication token is required'));
  }

  const token = authHeader.split(' ')[1];
  try {
    const decoded = JwtHelper.verify(token);
    req.user = decoded;
    next();
  } catch (err) {
    return next(ApiError.unauthorized('Invalid, expired or tampered authentication token'));
  }
};

export const requireRole = (requiredRole: string) => {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user) {
      return next(ApiError.unauthorized());
    }
    if (!req.user.roles.includes(requiredRole) && !req.user.roles.includes('admin')) {
      return next(ApiError.forbidden(`Requires '${requiredRole}' administrative privileges`));
    }
    next();
  };
};
