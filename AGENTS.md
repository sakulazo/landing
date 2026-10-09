# AGENTS.md

Sitio estático monopackage con Astro 7 para sakulazo.com. Totalmente estático; la única
integración es `astro-icon` (iconos build-time, salida estática). No hay tests, linter,
script de typecheck ni CI.

## Comandos

- `pnpm install` — instalar dependencias. pnpm es el gestor de paquetes (pnpm-lock.yaml);
  nunca ejecutar `npm install` (crearía un segundo lockfile).
- `npm run dev` — servidor de desarrollo en http://localhost:4321 (la mezcla npm/pnpm es
  intencional; los scripts y el Makefile llaman a `npm run ...`).
- `npm run build` → `dist/` (gitignored); `npm run preview` para previsualizar.
- Se requiere Node >= 22.12 (engines de package.json).
- No existe comando de lint/typecheck/test — no inventes uno.
  `astro check` requeriría instalar `@astrojs/check` primero.

## Deploy — leer antes de ejecutar nada

- `make deploy MSG="..."` es el único comando de publicación. Ejecuta:
  build → `git add -A` + commit → push a `origin main` → subida de `dist/` al VPS
  (sakulito@185.214.134.40:42932, necesita `~/.ssh/id_ed25519`) → verificación HTTP 200.
- **Commitea todos los archivos sucios del árbol de trabajo.** Revisa `git status` antes;
  nunca lo ejecutes solo para "comprobar el build" — usa `npm run build` para eso.
- Más granular: `make build`, `make push MSG="..."`, `make verify`, `make help`.
- El Makefile es un contrato fijo de la plantilla `infra-vps/templates/Makefile.static`
  (ADR-0004: help/build/push/deploy/verify). No cambies los targets; nunca añadas
  comentarios inline en líneas de variables (los espacios rompen el parseo owner:group).
  `REMOTE_DIR` debe empezar por `/srv/` (enforced).
- Flujo de deploy completo, tabla de acceso al VPS y solución de problemas (403 por
  permisos, etc.): ver README.md.

## Estructura y convenciones

- Entrada: `src/pages/index.astro` → `src/layouts/Layout.astro` → componentes en
  `src/components/` (Header, Hero, Services, About, TechStack, Contact, Footer).
  Una sola página; estilos globales en `src/styles/global.css`.
- Iconos: `astro-icon` + sets `@iconify-json/simple-icons` (marcas) y `@iconify-json/lucide`
  (genéricos). Los sets a incluir se declaran en `astro.config.mjs` (`integrations.icon.include`);
  al añadir un icono nuevo hay que registrarlo ahí o el build falla.
- `2026_curriculum_agosto.html` en la raíz es un CV sin relación, intencionadamente
  trackeado — no tocarlo.
- `pnpm-workspace.yaml` contiene ajustes de pnpm (allowBuilds para esbuild/sharp), no
  es un workspace con paquetes — no eliminarlo.
- README y mensajes de commit en español; los commits usan prefijos convencionales
  (`fix:`, `chore:`). Mantener ambos.
