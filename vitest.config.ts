import { defineConfig } from 'vitest/config';
import { loadEnv } from 'vite';

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode || 'test', process.cwd(), '');
  return {
    test: {
      globals: true,
      environment: 'node',
      pool: 'forks',
      env,
      poolOptions: {
        forks: {
          singleFork: true
        }
      },
      coverage: {
        provider: 'v8',
        reporter: ['text', 'json', 'html']
      }
    }
  };
});
