import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
  // Sustituir por el dominio real del cliente antes del primer deploy.
  site: 'https://mysite.example.com',

  // Estas dos van juntas con cleanUrls/trailingSlash de vercel.json: cambiar una
  // sin las otras genera cadenas de redirects.
  trailingSlash: 'never',
  build: { format: 'file' },

  // Sitio 100% estatico: Vercel sirve dist/ y no hace falta adapter.
  output: 'static',

  vite: {
    plugins: [tailwindcss()],
  },
});
