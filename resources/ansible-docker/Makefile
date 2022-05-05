CURRENT_TIME = $(shell date +'%y.%m.%d %H:%M:%S')
CURRENT_TAG = "v0.1build1"

build: 
	docker build -t emhavis/pkc_ansible:${CURRENT_TAG} --no-cache .

buildAndPush:
	docker build -t emhavis/pkc_ansible:${CURRENT_TAG} .
	docker push emhavis/pkc_ansible:${CURRENT_TAG}

push:
	docker push emhavis/pkc_ansible:${CURRENT_TAG}

buildMulti:
	docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 -t emhavis/pkc_ansible:${CURRENT_TAG} --no-cache --push .

