# STEP 1 - BUILD RELEASE 
FROM hexpm/elixir:1.11.3-erlang-23.2.7-alpine-3.13.2 AS build

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

ENV MIX_ENV=prod

WORKDIR /app

# Install elixir package dependencies
COPY mix.exs /app/mix.exs
COPY mix.lock /app/mix.lock
COPY config /app/config
COPY assets /app/assets

RUN mix do deps.get, deps.compile
RUN cd assets && yarn && yarn deploy

COPY priv /app/priv
RUN mix phx.digest

COPY lib /app/lib

# compile app and create release
RUN mix do compile, release

# prepare release image
FROM alpine:3.9 AS app
RUN apk add --no-cache openssl ncurses-libs

WORKDIR /app

RUN chown nobody:nobody /app

USER nobody:nobody

COPY --from=build --chown=nobody:nobody /app/_build/prod/rel/hangman ./

ENV HOME=/app

EXPOSE 4000

CMD ["bin/hangman", "start"]