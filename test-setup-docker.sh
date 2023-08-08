docker stop ubuntu_test
docker rm ubuntu_test

docker run -it -v $(pwd):/home --name ubuntu_test ubuntu:22.04 bash