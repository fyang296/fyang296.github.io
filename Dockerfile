# Base image: Ruby with necessary dependencies for Jekyll
FROM ruby:3.1.7

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    nodejs \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user with UID 1000
RUN groupadd -g 1000 vscode && \
    useradd -m -u 1000 -g vscode vscode

# Set the working directory
WORKDIR /usr/src/app

# Set permissions for the working directory
RUN chown -R vscode:vscode /usr/src/app

# Switch to the non-root user
USER vscode

# Copy Gemfile + lockfile
COPY --chown=vscode:vscode Gemfile Gemfile.lock ./

# Install bundler (Ruby 3.1 is NOT compatible with Bundler 4.x)
RUN gem install connection_pool:2.5.0
RUN gem install bundler:2.4.22

# Bundler config
# - Keep everything inside /usr/local/bundle so bind-mounts don't require write access
# - Frozen so bundler won't try to update Gemfile.lock inside the container
ENV BUNDLE_FROZEN=true \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_APP_CONFIG=/usr/local/bundle \
    BUNDLE_WITHOUT="development:test" \
    PATH="/usr/local/bundle/bin:${PATH}"

RUN bundle _2.4.22_ install

# Command to serve the Jekyll site
CMD ["bundle", "exec", "jekyll", "serve", "-H", "0.0.0.0", "-w", "--config", "_config.yml,_config_docker.yml"]