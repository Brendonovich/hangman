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
ENV SECRET_KEY_BASE=${SECRET_KEY_BASE}
WORKDIR /app


# Install elixir package dependencies
COPY mix.exs /app/mix.exs
COPY mix.lock /app/mix.lock

RUN mix do deps.get --only $MIX_ENV, deps.compile

# copy config, priv and release and application directories
COPY config /app/config
COPY priv /app/priv
COPY lib /app/lib

# copy assets directory & compile web assets
COPY assets /app/assets
RUN cd assets && yarn && yarn deploy
RUN mix phx.digest

# compile app and create release
RUN mix do compile, release

EXPOSE 4000

CMD mix phx.server