CURRENT_TIME = $(shell date +'%y.%m.%d %H:%M:%S')
CURRENT_TAG = "v0.1"

build: 
	docker build -t emhavis/pkc_dockeransible:${CURRENT_TAG} .

buildMulti:
	docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7,linux/arm/v6 -t emhavis/pkc_dockeransible:${CURRENT_TAG} --push . 