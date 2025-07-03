.PHONY: amplify-run , amplify-install, amplify-init, amplify-auth, amplify-push, amplify-pull

amplify-run:
	

amplify-install:
	@npm install -g @aws-amplify/cli

amplify-init:
	@amplify init;amplify add auth

amplify-auth:
	@amplify add auth

amplify-push:
	@amplify push

amplify-pull:
	@amplify pull
	