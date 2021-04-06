
init:
	./up.sh

down:
	docker-compose down --volumes 

removeAllImages:
	docker-compose down --volumes 
	docker rmi -f $(shell docker images -q)
