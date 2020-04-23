FROM golang:1.13

WORKDIR /go/src/exercise_parser/server
COPY . .

RUN go install

#CMD /go/bin/exercise_parser start --conf=/go/src/exercise_parser/server/conf/${CONFIG}.toml
CMD tail -f /dev/null