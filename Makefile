# Usage:
# 	buf generate -v \
		https://github.com/your/repositry.git \
		--path example/${VERSION}

VERSION = $(or $(word 2,$(subst -, ,$*)), v1)
TARGET = $(word 1,$(subst -, ,$*))
GITHUB = "https://github.com/reiot777/packetapis.git"
TMP_INSTALL_DIR := $(shell mktemp -d)

install:
	@go mod tidy
	@mkdir -p ${TMP_INSTALL_DIR}
	cd ${TMP_INSTALL_DIR} && go get -v \
		github.com/envoyproxy/protoc-gen-validate \
		google.golang.org/protobuf/cmd/protoc-gen-go \
		google.golang.org/grpc/cmd/protoc-gen-go-grpc \
		github.com/bufbuild/buf/cmd/buf
	@rmdir ${TMP_INSTALL_DIR}

	buf mod update -v

	go install \
		github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway \
		github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2 \
		google.golang.org/protobuf/cmd/protoc-gen-go \
		google.golang.org/grpc/cmd/protoc-gen-go-grpc 

proto: clean
	buf generate
	go mod tidy

proto-%: clean
	buf generate -v ${GITHUB} --path ${TARGET}
	go mod tidy

openapi-%:
	buf generate -v --template buf.openapi.yaml --path ${TARGET}/${VERSION}/services -o ${TARGET}/${VERSION}

test:
	go test -short -race ./...

clean:
	find . -type f -name '*.pb.go' -delete
	find . -type f -name '*.pb.gw.go' -delete
	find . -type f -name '*.pb.validate.go' -delete
	find . -type f -name '*.swagger.json' -delete

.PHONY: test clean proto proto-% openapi-% install