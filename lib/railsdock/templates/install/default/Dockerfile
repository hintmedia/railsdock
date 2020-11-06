ARG RAILSDOCK_RUBY_VERSION=2.6

FROM ruby:$RAILSDOCK_RUBY_VERSION

LABEL maintainer="Nate Vick <nate.vick@hint.io>"

ARG DEBIAN_FRONTEND=noninteractive

###############################################################################
# Base Software Install
###############################################################################

ARG RAILSDOCK_NODE_VERSION=12

RUN curl -sL https://deb.nodesource.com/setup_$RAILSDOCK_NODE_VERSION.x | bash -

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update && apt-get install -y \
    build-essential \
    nodejs \
    yarn \
    locales \
    git \
    netcat \
    vim \
    sudo

###############################################################################
# Railsdock non-root user
###############################################################################

ARG RUBY_UID
ENV RUBY_UID $RUBY_UID
ARG RUBY_GID
ENV RUBY_GID $RUBY_GID
ARG USER=ruby
ENV USER $USER

RUN groupadd -g $RUBY_GID $USER && \
    useradd -u $RUBY_UID -g $USER -m $USER && \
    usermod -p "*" $USER && \
    usermod -aG sudo $USER && \
    echo "$USER ALL=NOPASSWD: ALL" >> /etc/sudoers.d/50-$USER

###############################################################################
# Ruby, Rubygems, and Bundler Defaults
###############################################################################

ENV LANG C.UTF-8

# Update Rubygems to latest
RUN gem update --system

# Increase how many threads Bundler uses when installing. Optional!
ARG RAILSDOCK_BUNDLE_JOBS=20
ENV BUNDLE_JOBS $RAILSDOCK_BUNDLE_JOBS

# How many times Bundler will retry a gem download. Optional!
ARG RAILSDOCK_BUNDLE_RETRY=5
ENV BUNDLE_RETRY $RAILSDOCK_BUNDLE_RETRY

# Where Rubygems will look for gems.
ENV GEM_HOME /gems
ENV GEM_PATH /gems

# Add /gems/bin to the path so any installed gem binaries are runnable from bash.
ENV PATH ${GEM_HOME}/bin:${GEM_HOME}/gems/bin:$PATH

###############################################################################
# Optional Software Install
###############################################################################

#------------------------------------------------------------------------------
# Postgres Client:
#------------------------------------------------------------------------------

ARG INSTALL_PG_CLIENT=false

RUN if [ "$INSTALL_PG_CLIENT" = true ]; then \
    # Install the pgsql client
    apt-get install -y postgresql-client \
;fi

###############################################################################
# Final Touches
###############################################################################

RUN mkdir -p "$GEM_HOME" && chown $USER:$USER "$GEM_HOME"
RUN mkdir -p /app && chown $USER:$USER /app

WORKDIR /app

RUN mkdir -p node_modules && chown $USER:$USER node_modules
RUN mkdir -p public/packs && chown $USER:$USER public/packs
RUN mkdir -p tmp/cache && chown $USER:$USER tmp/cache

USER $USER

# Install latest bundler
RUN gem install bundler
