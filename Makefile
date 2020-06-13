STACK_NAME ?= ffmpeg-lambda-layer

### no cleaning if we're using our own ffmpeg
#clean: 
#	rm -rf build

### using an a precompiled ffmpeg 3 
#build/layer/bin/ffmpeg: 
#	mkdir -p build/layer/bin
#	rm -rf build/ffmpeg*
#	cd build && curl https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz | tar xJ
#	mv build/ffmpeg*/ffmpeg build/ffmpeg*/ffprobe build/layer/bin

build/output.yaml: 
  chmod +x build/layer/bin/ffmpeg
  template.yaml build/layer/bin/ffmpeg
	aws cloudformation package --template $< --s3-bucket $(DEPLOYMENT_BUCKET) --output-template-file $@

deploy: build/output.yaml
	aws cloudformation deploy --template $< --stack-name $(STACK_NAME)
	aws cloudformation describe-stacks --stack-name $(STACK_NAME) --query Stacks[].Outputs --output table

deploy-example:
	cd example && \
		make deploy DEPLOYMENT_BUCKET=$(DEPLOYMENT_BUCKET) LAYER_STACK_NAME=$(STACK_NAME)
