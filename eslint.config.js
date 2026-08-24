/**
 * ESLint y no oxlint: oxlint no parsea `.astro`, y aqui casi todo el codigo lo es.
 * Las reglas con tipos quedan fuera porque `astro check` ya hace ese analisis.
 */
import js from '@eslint/js';
import astro from 'eslint-plugin-astro';
import globals from 'globals';
import tseslint from 'typescript-eslint';

export default tseslint.config(
  {
    // `ignores` suelto se aplica globalmente.
    ignores: ['dist/**', '.astro/**', '.vercel/**', 'node_modules/**'],
  },

  js.configs.recommended,
  ...tseslint.configs.recommended,
  ...astro.configs['flat/recommended'],
  // Accesibilidad en las plantillas .astro (ver el `overrides` de package.json).
  ...astro.configs['flat/jsx-a11y-recommended'],

  {
    files: ['**/*.{ts,astro}'],
    languageOptions: {
      globals: globals.browser,
    },
    rules: {
      // Las variables de entorno se leen con corchete por
      // `noUncheckedIndexedAccess`; esta regla lo choca de frente.
      '@typescript-eslint/dot-notation': 'off',
      '@typescript-eslint/no-unused-vars': [
        'error',
        { argsIgnorePattern: '^_', varsIgnorePattern: '^_' },
      ],
    },
  },

  {
    // Scripts de mantenimiento: Node, no navegador.
    files: ['scripts/**/*.mjs'],
    languageOptions: {
      globals: globals.node,
    },
  },

  {
    // astro.config.ts corre en Node durante el build: necesita `process`.
    files: ['astro.config.ts'],
    languageOptions: {
      globals: globals.node,
    },
  },
);
