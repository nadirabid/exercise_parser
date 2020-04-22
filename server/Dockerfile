FROM golang:1.13

WORKDIR /server
COPY . .

RUN go install

cmd /go/bin/exercise_parser start
