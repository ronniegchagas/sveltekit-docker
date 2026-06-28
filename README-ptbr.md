# svelte-app

Este projeto usa Docker Compose para desenvolver e rodar localmente uma aplicação svelte-app em `svelte-app`.

## Pré-requisitos

- Docker
- Docker Compose
- Adicionar o domínio local `frontend.local` ao arquivo de hosts:

```bash
127.0.0.1 frontend.local
```

> No macOS e Linux, edite `/etc/hosts`. No Windows, edite `C:\Windows\System32\drivers\etc\hosts`.

## Setup inicial

O compose de setup cria o projeto em `svelte-app` e instala dependências:

```bash
docker compose run --rm setup
```

## HTTPS local

O Docker Compose já inclui um serviço de certificados chamado `certs`. Ele gera um certificado self-signed para `frontend.local` e mantém os arquivos em um volume nomeado.

Para iniciar o serviço de certificados:

```bash
docker compose run --rm certs
```

Isso gera ou renova o certificado localmente. Se o serviço for iniciado novamente, ele recria os arquivos em `/certs`.

### Configuração do vite

Configure o vite.config.ts para que fique como no exemplo abaixo

```Typescript
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

### Confiança do certificado

Como o certificado é autoassinado, o navegador pode mostrar aviso de segurança. No macOS, importe `frontend.local.pem` no Keychain e marque como confiável. Para outros sistemas operacionais, adicione o certificado à lista de certificados confiáveis do sistema.

## Desenvolvimento

Use o serviço `frontend-dev` para rodar o app em HTTPS com Vite:

```bash
docker compose up frontend-dev
```

A aplicação ficará disponível em:

- `https://frontend.local:5173`

### Observações

- O serviço de desenvolvimento monta `./svelte-app` em `/app/svelte-app`.
- O Vite é iniciado com `--host 0.0.0.0 --port 5173 --https` usando os arquivos de certificado em `/certs`.

## Produção

O serviço `frontend-prod` constrói a aplicação e serve os arquivos estáticos com Nginx em HTTPS.

Para rodar em background:

```bash
docker compose up frontend-prod
```

A aplicação ficará disponível em:

- `https://frontend.local`

O Nginx também redireciona `http://frontend.local` para `https://frontend.local`.

## Nota sobre volumes

O volume `certs:` é compartilhado entre o serviço `certs`, `frontend-dev` e `frontend-prod`. Isso garante que ambos os ambientes usem o mesmo par de chaves e certificado.

## Estrutura relevante

- `docker-compose.yaml` — define `setup`, `certs`, `frontend-dev` e `frontend-prod`
- `docker/Dockerfile.setup` - configura o projeto
- `docker/Dockerfile.dev` — build e dev do app em `svelte-app`
- `docker/Dockerfile.prod` — build de produção e Nginx HTTPS
- `docker/Dockerfile.certs` — container que gera o certificado local
- `generate-cert.sh` — script de geração/renovação do certificado
