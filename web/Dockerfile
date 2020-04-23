FROM node:lts

WORKDIR /app

COPY . .

RUN npm install -g server
RUN npm build

CMD serve -s build
