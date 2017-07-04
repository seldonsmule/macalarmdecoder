docker stop alarmdecoder
docker rm alarmdecoder
docker rmi -f smartpig/macalarmdecoder_base
docker rmi -f smartpig/macalarmdecoder_nginx
docker rmi -f smartpig/macalarmdecoder_ad
docker rmi -f smartpig/macalarmdecoder_start
docker rmi -f python:2.7
docker volume prune
