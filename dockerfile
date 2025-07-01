FROM golang:1.22-bookworm AS build

# install all needed stuff
RUN apt-get update 
RUN apt-get install -y curl git wget unzip libgconf-2-4 gdb libstdc++6 libglu1-mesa fonts-droid-fallback lib32stdc++6
RUN apt-get clean

# Add a new user "dev" with user id 8877
RUN useradd -u 8877 dev
# Change to non-root privilege
USER dev

WORKDIR /home/dev

ARG SSH_PRIVATE_KEY
ARG VERSION
ARG COMMIT_HASH
ARG BUILD_TIMESTAMP
ARG FLUTTER_SDK=/home/dev/flutter
ARG FLUTTER_VERSION=3.22.2

RUN mkdir -p -m 0700 /home/dev/.ssh

# Add the keys and set permissions
RUN echo "$SSH_PRIVATE_KEY" > /home/dev/.ssh/id_rsa && chmod 600 /home/dev/.ssh/id_rsa
RUN ssh-keyscan github.com >> /home/dev/.ssh/known_hosts

#clone flutter
RUN git clone --progress git@github.com:flutter/flutter.git $FLUTTER_SDK
# change dir to current flutter folder and make a checkout to the specific version
RUN cd $FLUTTER_SDK && git fetch && git checkout $FLUTTER_VERSION

# setup the flutter path as an enviromental variable
ENV PATH="$FLUTTER_SDK/bin:$FLUTTER_SDK/bin/cache/dart-sdk/bin:${PATH}"

# Start to run Flutter commands
# doctor to see if all was installes ok
RUN flutter doctor -v

RUN git config --global url.ssh://git@github.com/.insteadOf https://github.com/

COPY go.mod ./
COPY go.sum ./
RUN go mod download

COPY . .

USER root

RUN chown -R dev:dev .

USER dev

RUN chmod -R 755 .

RUN chmod -R 700 /home/dev/.ssh

RUN make build

RUN go mod tidy

RUN cp -r build/web/* ./assets
RUN cp ./cmd/main.go main.go

RUN go build -ldflags "-X 'main.Version=${VERSION}' -X 'main.CommitHash=${COMMIT_HASH}' -X 'main.BuildTimestamp=${BUILD_TIMESTAMP}' -X 'main.HttpPort=8080'" -o /home/dev/smartshieldverify

##
## Deploy
##
FROM gcr.io/distroless/base-debian12:nonroot

WORKDIR /home/nonroot

COPY --from=build /home/dev/smartshieldverify .

EXPOSE 8080

ENTRYPOINT ["./smartshieldverify"]
