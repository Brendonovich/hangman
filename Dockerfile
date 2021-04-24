# STEP 1 - BUILD RELEASE 
FROM hexpm/elixir:1.11.3-erlang-23.2.7-alpine-3.13.2 AS deps-getter

# Install build dependencies
RUN apk update && \
    apk upgrade --no-cache && \
    apk add --no-cache \
    git \
    build-base \
    nodejs-current \
    nodejs-npm \ 
    python3 && \ 
    mix local.rebar --force && \
    mix local.hex --force && \
    npm install --global yarn

RUN mkdir /app
WORKDIR /app

ENV MIX_ENV=prod
RUN mkdir \ 
    /app/_build/ \
    /app/config/ \
    /app/lib/ \
    /app/priv/ \ 
    /app/deps/ \
    /app/rel/ \
    /app/assets

# Install elixir package dependencies
COPY mix.exs /app/mix.exs
COPY mix.lock /app/mix.lock

# install deps and compile deps
COPY mix.exs /app/mix.exs
COPY mix.lock /app/mix.lock
RUN mix do deps.get --only $MIX_ENV, deps.compile
RUN mix compile

# STEP 2 - ASSET BUILDER
FROM node:12 AS asset-builder

RUN mkdir /app
WORKDIR /app

# install latest version of yarn
RUN npm i -g yarn --force

COPY --from=deps-getter /app/assets /app/assets
COPY --from=deps-getter /app/priv /app/priv
COPY --from=deps-getter /app/deps /app/deps

# assets -- install javascript deps
COPY assets/package.json /app/assets/package.json
COPY assets/yarn.lock /app/assets/yarn.lock
RUN cd /app/assets && \
    yarn install 

# assets -- copy asset files so purgecss doesnt remove css files
COPY lib/hangman_web/templates/ /app/lib/hangman_web/templates/
COPY lib/hangman_web/views/ /app/lib/hangman_web/views/

# assets -- build assets
COPY assets /app/assets
RUN cd /app/assets && yarn deploy  


################################################################################
# STEP 3 - RELEASE BUILDER
FROM hexpm/elixir:1.11.3-erlang-23.2.7-alpine-3.13.2  AS release-builder

ENV MIX_ENV=prod

RUN mkdir /app
WORKDIR /app

# need to install deps again to run mix phx.digest
RUN apk update && \
    apk upgrade --no-cache && \
    apk add --no-cache \
    git \
    build-base && \
    mix local.rebar --force && \
    mix local.hex --force

# copy elixir deps
COPY --from=deps-getter /app /app

# copy config, priv and release directories
COPY config /app/config
COPY priv /app/priv
COPY rel /app/rel

# copy built assets
COPY --from=asset-builder /app/priv/static /app/priv/static

RUN mix phx.digest

# copy application code
COPY lib /app/lib

# create release
RUN mkdir -p /opt/built &&\
    mix release &&\
    cp -r _build/prod/rel/hangman /opt/built

################################################################################
## STEP 4 - FINAL
FROM alpine:3.11.3

ENV MIX_ENV=prod

RUN apk update && \
    apk add --no-cache \
    bash \
    openssl-dev

COPY --from=release-builder /opt/built /app
WORKDIR /app

EXPOSE 4000

CMD ["/app/hangman/bin/hangman", "start"]