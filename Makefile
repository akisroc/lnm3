GOPATH = $(shell go env GOPATH)
export PATH := $(GOPATH)/bin:$(HOME)/.mix/escripts:$(PATH)

PROTO_DIR = protos
AUTH_OUT  = services/auth/pb
PLAT_OUT  = services/platform/lib/pb

.PHONY: proto-clean proto-gen proto

# Launch once
install-tools:
	go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
	go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
	mix escript.install hex protobuf --force

# Main command
proto: proto-clean proto-gen

proto-clean:
	@echo "Clean old..."
	@rm -rf $(AUTH_OUT)/*.go
	@rm -rf $(PLAT_OUT)/*.ex

proto-gen:
	@echo "Generating Go and Elixir files..."
	@mkdir -p $(AUTH_OUT)
	@mkdir -p $(PLAT_OUT)
	
	# Generation for Go (Service Auth)
	protoc --proto_path=$(PROTO_DIR) \
		--go_out=$(AUTH_OUT) --go_opt=paths=source_relative \
		--go-grpc_out=$(AUTH_OUT) --go-grpc_opt=paths=source_relative \
		$(PROTO_DIR)/*.proto

	# Generatio for Elixir (Service Platform)
	protoc --proto_path=$(PROTO_DIR) \
		--elixir_out=plugins=grpc:$(PLAT_OUT) \
		$(PROTO_DIR)/*.proto

	@echo "✅ Protos successfully generated."
