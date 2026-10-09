// @ts-check
import { defineConfig } from 'astro/config';
import icon from 'astro-icon';

// https://astro.build/config
export default defineConfig({
  integrations: [
    icon({
      include: {
        'simple-icons': [
          'php',
          'laravel',
          'javascript',
          'mysql',
          'astro',
          'fastapi',
          'python',
          'nodedotjs',
          'react',
          'docker',
          'linux',
          'git',
          'opencode',
          'ollama',
          'github',
          'linkedin'
        ],
        lucide: [
          'network',
          'key-round',
          'server',
          'shield-check',
          'zap',
          'settings',
          'users',
          'code',
          'code-xml',
          'message-square',
          'message-circle',
          'sun',
          'moon',
          'globe',
          'book-open',
          'wrench',
          'info',
          'mail',
          'phone',
          'map-pin'
        ]
      }
    })
  ]
});
