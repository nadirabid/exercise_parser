FROM golang:1.13

WORKDIR /go/src/exercise_parser/server
COPY . .

RUN go install
RUN chmod +x /go/src/exercise_parser/server/launch.sh

#CMD while true; do sleep 30; done;
CMD ./go/src/exercise_parser/server/launch.sh
