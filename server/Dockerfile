FROM golang:1.13

WORKDIR /go/src/exercise_parser/server
COPY . .
COPY ./supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN go install
RUN chmod +x /go/src/exercise_parser/server/launch.sh

RUN apt-get update && apt-get install -y supervisor

CMD /usr/bin/supervisord
