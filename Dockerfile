FROM ruby:3.1.2

# Set up working directory
WORKDIR /app

ENV RAILS_DIR "/app" 

# Install dependencies
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
RUN apt-get update -qq && apt-get install -qq --no-install-recommends \
    nano \
    nodejs \
    postgresql-client \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Install gems
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install --jobs 4 --retry 3

# Copy the application code
COPY . /app

# Set environment variables
ENV RAILS_ENV=development

# Compile assets
RUN bundle exec rails assets:precompile

# make docker-entrypoint.sh executable
RUN ["chmod", "+x", "./docker-entrypoint.sh"]

# assign docker entry point file
ENTRYPOINT ["./docker-entrypoint.sh"]

EXPOSE 3000
