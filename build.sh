#!/bin/bash

docker build --tag jackiig/html-mason .

if [[ "$1" == "-push" ]]; then
	docker push jackiig/html-mason
fi
