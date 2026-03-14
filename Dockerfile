FROM amazonlinux:2023

ARG UID
ARG GID
ARG USER
ARG GHC_VERSION
ARG CABAL_VERSION

RUN dnf install -y \
    gcc \
    gmp \
    gmp-devel \
    ncurses \
    ncurses-compat-libs \
    perl \
    shadow-utils \
    xz \
    zlib \
    zlib-devel

RUN curl https://downloads.haskell.org/~ghcup/0.1.22.0/x86_64-linux-ghcup-0.1.22.0 \
    -o /usr/local/bin/ghcup && \
    chmod a+x /usr/local/bin/ghcup

RUN groupadd -g $GID $USER
RUN useradd -m -u $UID -g $GID $USER

USER $USER

RUN ghcup install ghc ${GHC_VERSION} && \
    ghcup set ghc ${GHC_VERSION} && \
    ghcup install cabal ${CABAL_VERSION} && \
    ghcup set cabal ${CABAL_VERSION}

ENV PATH="${PATH}:/home/${USER}/.ghcup/bin"
RUN cabal v2-update

WORKDIR /app
