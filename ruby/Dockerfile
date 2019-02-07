ARG RAILSDOCK_RUBY_VERSION

FROM ruby:${RAILSDOCK_RUBY_VERSION}

LABEL maintainer="Nate Vick <nate.vick@hint.io>"

ENV DEBIAN_FRONTEND noninteractive

###############################################################################
# Railsdock non-root user
###############################################################################

ARG UID=1000
ENV UID ${UID}
ARG GID=1000
ENV GID ${GID}

RUN groupadd -g ${GID} ruby && \
    useradd -u ${UID} -g ruby -m ruby && \
    usermod -p "*" ruby

###############################################################################
# Base Software Install
###############################################################################

RUN apt-get update && apt-get install -y \
    build-essential \
    nodejs \
    locales \
    git \
    netcat \
    vim

ENV LANG C.UTF-8

# Point Bundler at /gems. This will cause Bundler to re-use gems that have already been installed on the gems volume
ENV BUNDLE_PATH /gems
ENV BUNDLE_HOME /gems

# Increase how many threads Bundler uses when installing. Optional!
ARG RAILSDOCK_BUNDLE_JOBS=20
ENV BUNDLE_JOBS ${RAILSDOCK_BUNDLE_JOBS}

# How many times Bundler will retry a gem download. Optional!
ARG RAILSDOCK_BUNDLE_RETRY=5
ENV BUNDLE_RETRY ${RAILSDOCK_BUNDLE_RETRY}

# Where Rubygems will look for gems, similar to BUNDLE_ equivalents.
ENV GEM_HOME /gems
ENV GEM_PATH /gems

# Add /gems/bin to the path so any installed gem binaries are runnable from bash.
ENV PATH /gems/bin:$PATH

###############################################################################
# Optional Software Install
###############################################################################

#------------------------------------------------------------------------------
# Postgres Client:
#------------------------------------------------------------------------------

ARG INSTALL_PG_CLIENT=false

RUN if [ ${INSTALL_PG_CLIENT} = true ]; then \
    # Install the pgsql client
    apt-get install -y postgresql-client \
;fi

###############################################################################
# Final Touches
###############################################################################

RUN mkdir -p "$GEM_HOME" && chown ruby:ruby "$GEM_HOME"

RUN mkdir -p /app
WORKDIR /app

USER ruby

# Install latest bundler
RUN gem install bundler
