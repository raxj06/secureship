module.exports = {
  root: true,
  parser: '@typescript-eslint/parser',
  plugins: ['@typescript-eslint', 'security'],
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
    'plugin:security/recommended-legacy',
    'prettier',
  ],
  env: { node: true, es2022: true, jest: true },
  parserOptions: { ecmaVersion: 2022, sourceType: 'module' },
  rules: {
    '@typescript-eslint/no-unused-vars': ['warn', { argsIgnorePattern: '^_' }],
    '@typescript-eslint/no-explicit-any': 'warn',
    'security/detect-object-injection': 'off',
  },
  ignorePatterns: ['dist/', 'node_modules/', 'coverage/'],
};
