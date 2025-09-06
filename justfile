name := "invoice-generator"

# Default recipe
default: install

# Get version info
sha := `git rev-parse --short HEAD 2>/dev/null || cat SHA 2>/dev/null | tr -d ' \n' || echo "unknown"`

# Get base version (just the tag, without commit count)
version := `git describe --tags --abbrev=0 2>/dev/null | tr -d 'v \n' || echo "dev"`

# Add .dev suffix if git is dirty
dirty := `git diff --shortstat 2>/dev/null | tail -n1 | tr -d ' \n'`
final_version := if dirty != "" { version + ".dev" } else { version }

# Random ID for build
build_id := `head -c15 /dev/urandom 2>/dev/null | od -An -tx1 2>/dev/null | tr -d ' \n' || echo "0"`

# Common ldflags
ldflags := '-s -w -extldflags "-static" -X "main.ver=' + final_version + '" -X "main.sha=' + sha + '" -B 0x' + build_id

# Install locally
install:
    go install -ldflags '{{ldflags}}' .

# Build all targets
build: bin-linux-amd64 bin-linux-arm bin-windows-amd64 bin-windows-arm bin-darwin-amd64 bin-darwin-arm64

# Linux AMD64 build
bin-linux-amd64:
    CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -x -v -ldflags '{{ldflags}}' -o bin/{{name}}.linux-amd64 .

# Linux ARM build  
bin-linux-arm:
    CGO_ENABLED=0 GOOS=linux GOARCH=arm go build -ldflags '{{ldflags}}' -o bin/{{name}}.linux-arm .

# Windows AMD64 build
bin-windows-amd64:
    CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build -ldflags '{{ldflags}}' -o bin/{{name}}.windows-amd64.exe .

# Windows ARM build
bin-windows-arm:
    CGO_ENABLED=0 GOOS=windows GOARCH=arm GOARM=7 go build -ldflags '{{ldflags}}' -o bin/{{name}}.windows-arm.exe .

# Darwin AMD64 build
bin-darwin-amd64:
    CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 go build -ldflags '{{ldflags}}' -o bin/{{name}}.darwin-amd64 .

# Darwin ARM64 build
bin-darwin-arm64:
    CGO_ENABLED=0 GOOS=darwin GOARCH=arm64 go build -ldflags '{{ldflags}}' -o bin/{{name}}.darwin-arm64 .

# Clean build artifacts
clean:
    rm -f bin/*

# Show version
version:
    @echo "{{final_version}}"
