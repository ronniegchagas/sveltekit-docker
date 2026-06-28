# svelte-app

This project uses Docker Compose to develop and run a Svelte application (located in the `svelte-app` directory) locally, without the need for Node or other development tools.

## Prerequisites

- Docker
- Docker Compose
- Add the local domain `frontend.local` to your hosts file:

```bash
127.0.0.1 frontend.local
```

> On macOS and Linux, edit `/etc/hosts`. On Windows, edit `C:\Windows\System32\drivers\etc\hosts`.

## Initial setup

The setup compose service creates the project in `svelte-app` and installs dependencies:

```bash
docker compose run --rm setup
```

## Local HTTPS

Docker Compose already includes a certificate service called `certs`. It generates a self-signed certificate for `frontend.local` and stores the files in a named volume.

To start the certificate service:

```bash
docker compose run --rm certs
```

This generates or renews the certificate locally. If the service is started again, it recreates the files in `/certs`.

### Vite configuration

Configure `vite.config.ts` to match the example below:

```ts
import { defineConfig } from 'vite'
import { svelte } from '@sveltejs/vite-plugin-svelte'

const useHttps = process.env.VITE_HTTPS === 'true'
const httpsOptions = useHttps
  ? {
      key: process.env.HTTPS_KEY || '/certs/frontend.local-key.pem',
      cert: process.env.HTTPS_CERT || '/certs/frontend.local.pem',
    }
  : undefined

// https://vite.dev/config/
export default defineConfig({
  plugins: [svelte()],
  server: {
    host: '0.0.0.0',
    port: 5173,
    https: httpsOptions,
  },
})
```

### Trusting the certificate

Because the certificate is self-signed, the browser may show a security warning. On macOS, import `frontend.local.pem` into Keychain and mark it as trusted. On other operating systems, add the certificate to the system's trusted certificate store.

## Development

Use the `frontend-dev` service to run the app with Vite over HTTPS:

```bash
docker compose up frontend-dev
```

The application will be available at:

- `https://frontend.local:5173`

### Notes

- The development service mounts `./svelte-app` to `/app/svelte-app`.
- Vite is started with `--host 0.0.0.0 --port 5173 --https` using the certificate files in `/certs`.

## Production

The `frontend-prod` service builds the application and serves the static files with Nginx over HTTPS.

To run it in the background:

```bash
docker compose up frontend-prod
```

The application will be available at:

- `https://frontend.local`

Nginx also redirects `http://frontend.local` to `https://frontend.local`.

## Note about volumes

The `certs` volume is shared between the `certs`, `frontend-dev`, and `frontend-prod` services. This ensures that both environments use the same key pair and certificate.

## Relevant structure

- `docker-compose.yaml` — defines `setup`, `certs`, `frontend-dev`, and `frontend-prod`
- `docker/Dockerfile.setup` — configures the project
- `docker/Dockerfile.dev` — build and dev setup for the app in `svelte-app`
- `docker/Dockerfile.prod` — production build and HTTPS Nginx setup
- `docker/Dockerfile.certs` — container that generates the local certificate
- `generate-cert.sh` — script for generating/renewing the certificate
