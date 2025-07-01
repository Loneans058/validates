#!/bin/bash

export $(grep -v '^#' .env | xargs)
go run -ldflags "-X 'main.HttpPort=8080'" cmd/main.go