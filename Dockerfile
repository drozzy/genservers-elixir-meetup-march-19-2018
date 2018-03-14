FROM elixir:1.5.2

# Install local Elixir hex and rebar
RUN /usr/local/bin/mix local.hex --force
RUN /usr/local/bin/mix local.rebar --force 

# Set proper time-zone
ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Expose the port
EXPOSE 8080

WORKDIR /app
CMD /bin/bash

