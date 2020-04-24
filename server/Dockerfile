FROM golang:1.13

WORKDIR /go/src/exercise_parser/server
COPY . .

RUN go install
RUN chmod +x /go/bin/launch.sh

#CMD while true; do sleep 30; done;
CMD ./launch.sh
