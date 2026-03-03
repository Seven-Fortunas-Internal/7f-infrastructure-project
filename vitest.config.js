/**
 * Vitest configuration for dashboard component tests (P0-004).
 * Run from project root: npx vitest run --config vitest.config.js
 */
import { defineConfig } from 'vitest/config'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: ['./dashboards/ai/src/test-setup.js'],
    include: [
      'tests/component/dashboard/**/*.{test,spec}.{js,jsx}',
    ],
    alias: {
      // Ensure CSS imports don't break tests
    },
  },
  resolve: {
    alias: {},
  },
})
