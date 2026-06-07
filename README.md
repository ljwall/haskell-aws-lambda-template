# lambda-hello-world

A skeleton project showing how to build and deploy a **Haskell** AWS Lambda
function using Docker, Cabal, and the Serverless Framework.

The Lambda runs on the `provided.al2023` (Amazon Linux 2023) custom runtime.
The Haskell binary is compiled inside a matching Docker container so the
resulting executable is fully compatible with the Lambda execution environment.

### Project layout

```
app/
  src/Main.hs          -- Lambda handler (uses hal + katip)
  bootstrap.cabal      -- Cabal project file
Dockerfile             -- Amazon Linux 2023 build image (GHC via ghcup)
Makefile               -- build orchestration
serverless.yml         -- Serverless Framework service definition
package.json           -- npm scripts for build / deploy / remove
```

### Prerequisites

* Docker with `buildx` support
* Node.js (see `.nvmrc` — LTS/Jod, i.e. v22)
* npm
* AWS credentials configured (`aws configure` or environment variables)

Install the Serverless Framework locally:

```bash
npm install
```

### Build

```bash
make bootstrap
```

This will:

1. Run a multi-stage Docker build based on Amazon Linux 2023 with GHC 9.6.7 and Cabal 3.12.1.
2. Resolve Haskell dependencies and compile the project entirely inside Docker.
3. Export the resulting `bootstrap` binary directly to the project root with `docker buildx build --output`.

### Deploy

```bash
npm run deploy
```

Runs `npm run build` and then `serverless deploy`, which packages the
`bootstrap` binary and deploys it to AWS Lambda in `us-west-2`.

### Remove

```bash
npm run remove
```

Tears down the CloudFormation stack created by Serverless.

### Test

Invoke the deployed function from the CLI:

```bash
npx serverless invoke -f lambda-hello-world -d '{"eventName":"test","eventValue":42}'
```

You should receive:

```json
{"resultMessage":"Success!"}
```

### Customisation

* Edit `app/src/Main.hs` to change the handler logic.
* Edit `serverless.yml` to add API Gateway triggers, environment variables, etc.
* Adjust GHC / Cabal versions in the `Makefile`.
