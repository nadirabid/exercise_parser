#!/bin/bash

# /go/bin/exercise_parser db seed dict --conf=/go/src/exercise_parser/server/conf/${CONFIG}.toml
/go/bin/exercise_parser db migrate --conf=/go/src/exercise_parser/server/conf/${CONFIG}.toml
/go/bin/exercise_parser start --conf=/go/src/exercise_parser/server/conf/${CONFIG}.toml
