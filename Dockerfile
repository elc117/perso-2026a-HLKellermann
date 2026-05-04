FROM haskell:9.8.4

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    libsqlite3-dev \
    pkg-config \
 && rm -rf /var/lib/apt/lists/*

COPY . .

RUN cabal update && \
    cabal build exe:perso-2026a-HLKellermann

RUN cp "$(cabal list-bin exe:perso-2026a-HLKellermann)" /usr/local/bin/app

ENV PORT=10000

EXPOSE 10000

CMD ["app"]