# syntax=docker/dockerfile:1

FROM amazonlinux:2023 AS builder

ARG GHCUP_VERSION=0.1.22.0
ARG GHC_VERSION
ARG CABAL_VERSION

RUN dnf install -y \
    gcc \
    gmp \
    gmp-devel \
    make \
    ncurses \
    ncurses-compat-libs \
    perl \
    tar \
    xz \
    zlib \
    zlib-devel && \
    dnf clean all && \
    rm -rf /var/cache/dnf

RUN curl -fsSL "https://downloads.haskell.org/~ghcup/${GHCUP_VERSION}/x86_64-linux-ghcup-${GHCUP_VERSION}" \
    -o /usr/local/bin/ghcup && \
    chmod 0755 /usr/local/bin/ghcup

ENV PATH="${PATH}:/root/.ghcup/bin"

RUN ghcup install ghc "${GHC_VERSION}" && \
    ghcup set ghc "${GHC_VERSION}" && \
    ghcup install cabal "${CABAL_VERSION}" && \
    ghcup set cabal "${CABAL_VERSION}" && \
    cabal update

WORKDIR /workspace/app

COPY app/bootstrap.cabal ./bootstrap.cabal

RUN touch LICENSE CHANGELOG.md && \
    mkdir -p src && \
    printf 'module Main where\n\nmain :: IO ()\nmain = putStrLn "warming Cabal dependency cache"\n' > src/Main.hs && \
    cabal build --only-dependencies exe:bootstrap

COPY app/src ./src

RUN cabal build exe:bootstrap && \
    install -D "$(cabal list-bin exe:bootstrap)" /out/bootstrap

FROM scratch AS artifact

COPY --from=builder /out/bootstrap /bootstrap

ENTRYPOINT ["/bootstrap"]
