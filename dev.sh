docker build -f Dockerfile -t genservers .
docker run -it --rm -v $(pwd):/app genservers