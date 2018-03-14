#!/bin/bash

#declaring constants
declare -r H1="Accept: application/json" 
declare -r H2="Content-Type: application/json"
declare -r H3="Authorization: SSWS <okta_api_key_here>"
declare -r URI0='https://westfieldlabs.okta.com/api/v1/users?filter=lastUpdated+gt+"2017-07-10T00:00:00.000Z"+and+status+eq+"ACTIVE"'

#if link contains rel="next" then echo the link
getnexturi() {
	#gets first parameter 
	local -r uri="$1"
	#gets the following link
	local -r nexturi="$( \
		curl -s -I -X GET -H "$H1" -H "$H2" -H "$H3" "$uri" \
			| egrep ^Link: \
			| fgrep next \
			| cut -d'<' -f2 \
			| cut -d'>' -f1 \
	)"
	#returns the following link
	echo "$nexturi"
}

#prints the page
getpage() {
	#gets first parameter 
	local -r uri="$1"
	#returns page json
	curl -s -X GET -H "$H1" -H "$H2" -H "$H3" "$uri" \
	    | jq .
}

#function to process profiles
process-user-profiles() {
	#initialziation
	local uri=$URI0
	while [[ -n $uri ]]; do
		#prints the first page, then increments page printing
		getpage "$uri"
		#increment step, updating the uri
		uri="$(getnexturi "$uri")"
	done 
}




# main
process-user-profiles
# SUCCESS!!!!!
exit 0