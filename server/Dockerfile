FROM golang:1.13

WORKDIR /server
COPY . .

RUN go install

CMD /go/bin/exercise_parser start
