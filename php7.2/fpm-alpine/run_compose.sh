echo "Running under mode: $MODE"

echo "$(date) Obtaining current git sha for tagging the docker image"
headsha=$(git rev-parse --verify HEAD)

echo "Starting wordpress with docker compose"
headsha=$headsha MODE=$1 docker-compose up
