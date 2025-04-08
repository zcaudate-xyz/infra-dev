.PHONY: push build-dev-ci build-dev-main build-clean
 
push:                                                   
	git add -A && git commit -m "code update" && git push                                                                       

build-dev-ci: push
	gh workflow run build-dev-ci.yml --repo zcaudate-xyz/infra-dev
                                                                       
build-dev-main: push
	gh workflow run build-dev-main.yml --repo zcaudate-xyz/infra-dev
	                                                      
build-clean: push
	gh workflow run build-clean.yml --repo zcaudate-xyz/infra-dev