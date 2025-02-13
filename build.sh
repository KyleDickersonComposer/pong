set -e

mkdir -p bin
odin build . -out:bin/pong
./bin/pong
