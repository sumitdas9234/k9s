# -----------------------------------------------------------------------------
# The base image for building the k9s binary

FROM golang:1.16.2-alpine3.13 AS build

ARG KUBECTL_VERSION="v1.20.5"
WORKDIR /k9s
COPY go.mod go.sum main.go Makefile ./
COPY internal internal
COPY cmd cmd
RUN apk --no-cache add make git gcc libc-dev curl && make build

ADD https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/aws-iam-authenticator ./extras
ADD https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx ./extras
ADD https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens ./extras
ADD https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl ./extras
RUN wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/download/v3.163.1/posh-linux-amd64 -O ./extras/oh-my-posh

# -----------------------------------------------------------------------------
# Build the final Docker image

FROM python:alpine

COPY --from=build /k9s/execs/k9s /bin/k9s
COPY --from=build /k9s/extras /usr/local/bin

RUN apk add --update ca-certificates curl zsh git bash  && rm /var/cache/apk/*
RUN chmod +x /usr/local/bin/*

ENTRYPOINT /bin/zsh
