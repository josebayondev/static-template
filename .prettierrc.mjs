/**
 * `prettier-plugin-tailwindcss` DEBE ir el ultimo del array. Si va antes que
 * `prettier-plugin-astro` no ve las clases dentro de los `.astro` y deja de
 * ordenarlas, sin dar ningun error.
 */

/** @type {import('prettier').Config} */
export default {
  printWidth: 100,
  singleQuote: true,
  semi: true,
  trailingComma: 'all',

  plugins: ['prettier-plugin-astro', 'prettier-plugin-tailwindcss'],

  // Lee los tokens de @theme para ordenar tambien bg-surface, text-content...
  tailwindStylesheet: './src/styles/global.css',
  tailwindFunctions: ['clsx', 'cn'],

  overrides: [
    {
      files: '*.astro',
      options: { parser: 'astro' },
    },
  ],
};
