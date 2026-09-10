jest.mock('../src/config/database', () => ({
  db: {
    query: jest.fn().mockResolvedValue({ rows: [] }),
    getClient: jest.fn(),
  },
  dbPool: {
    query: jest.fn().mockResolvedValue({ rows: [] }),
    connect: jest.fn(),
  }
}));
