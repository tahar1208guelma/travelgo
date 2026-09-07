import { Pool, QueryResult, QueryResultRow } from 'pg';
import { ENV } from './env';

export const dbPool = new Pool({
  connectionString: ENV.DATABASE_URL,
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 5000,
});

export const db = {
  query: async <T extends QueryResultRow = any>(text: string, params?: any[]): Promise<QueryResult<T>> => {
    const start = Date.now();
    try {
      const res = await dbPool.query<T>(text, params);
      const duration = Date.now() - start;
      if (ENV.NODE_ENV === 'development') {
        // Query logged safely without secrets
      }
      return res;
    } catch (err) {
      console.error('[Database Error]', { text, error: err });
      throw err;
    }
  },
  getClient: () => dbPool.connect(),
};
