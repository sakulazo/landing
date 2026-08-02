# Landing — sakulazo.com

Landing page de **sakulazo** construida con [Astro](https://astro.build). Sitio 100% estático.

## Desarrollo local

```bash
pnpm install        # instalar dependencias
npm run dev         # servidor de desarrollo (http://localhost:4321)
npm run build       # build de producción en dist/
npm run preview     # previsualizar la build
```

## Despliegue

El sitio se sirve desde **`sakulazo.com`** mediante **Caddy** corriendo en Docker en el VPS
(`185.214.134.40`). Caddy sirve la build estática desde `/srv/landing/` dentro del contenedor.

### Flujo

```
build local (dist/)  →  commit + push a GitHub  →  subida de dist/ a /srv/landing/ en el VPS
```

Publicar un cambio en producción es **un solo comando**:

```bash
make deploy MSG="descripción del cambio"
```

Esto ejecuta, en orden:

1. `npm run build` — genera `dist/`.
2. `git add -A && git commit -m "$MSG"` — commitea los cambios.
3. `git push origin main` — publica en GitHub (`sakulazo/landing`).
4. Sube `dist/` al VPS con `tar | ssh` y aplica permisos `644`/`755`
   (necesarios para que Caddy, que corre como usuario no-root, pueda leer los archivos).
5. `verify` — comprueba que `https://sakulazo.com/` responde `HTTP 200`.

### Objetivos del Makefile

| Objetivo | Descripción |
|---|---|
| `make build` | Construye la landing en `dist/` |
| `make push MSG="..."` | Commit + push a GitHub |
| `make deploy MSG="..."` | Build + push + subida al VPS + verificación |
| `make verify` | Comprueba que el sitio responde 200 |
| `make help` | Muestra la ayuda |

### Acceso al servidor

| Dato | Valor |
|---|---|
| Host | `185.214.134.40` |
| Usuario de despliegue | `sakulito` (propietario de `/srv/landing`) |
| Puerto SSH | `42932` |
| Clave | `~/.ssh/id_ed25519` (también autentica en GitHub) |

> El usuario `vps-manager` no tiene permisos de escritura sobre `/srv/landing`;
> por eso el despliegue se hace como `sakulito`.

### Solución de problemas

| Síntoma | Causa / Solución |
|---|---|
| `HTTP 403` al cargar el sitio | Permisos incorrectos tras subir archivos: ejecutar `find /srv/landing -type f -exec chmod 644 {} +` y `find /srv/landing -type d -exec chmod 755 {} +` |
| `make` no encontrado | Instalar make: `apt install make` (o usar el binario en `~/.local/bin/make`) |
| `git push` pide credenciales | El remoto debe apuntar a SSH: `git remote set-url origin git@github.com:sakulazo/landing.git` |
| El push falla por falta de `MSG` | El commit necesita mensaje: `make deploy MSG="..."` |

## Estructura del proyecto

```
src/
├── components/   # Hero, About, Services, Contact, etc.
├── layouts/      # Layout principal
├── pages/        # index.astro
└── styles/       # global.css
dist/             # build de producción (generada, no versionada)
Makefile          # automatización de build/push/deploy
```
