#!/bin/bash

# GitLab CLI (glab) Installation Script
# Based on official GitLab CLI documentation
# Supports macOS, Linux (Ubuntu/Debian, CentOS/RHEL), and Windows (via WSL)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macOS"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Check for distribution
        if [[ -f /etc/os-release ]]; then
            . /etc/os-release
            echo "$ID"
        else
            echo "linux"
        fi
    else
        echo "unknown"
    fi
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install prerequisites
install_prerequisites() {
    local os="$1"
    print_info "Installing prerequisites for $os..."
    
    case "$os" in
        "macos")
            if ! command_exists brew; then
                print_warning "Homebrew not found. Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            if ! command_exists git; then
                print_info "Installing Git via Homebrew..."
                brew install git
            fi
            ;;
        "ubuntu"|"debian")
            print_info "Updating package list..."
            sudo apt-get update
            print_info "Installing prerequisites..."
            sudo apt-get install -y git curl wget
            ;;
        "centos"|"rhel"|"fedora")
            print_info "Updating package list..."
            sudo yum update -y || sudo dnf update -y
            print_info "Installing prerequisites..."
            sudo yum install -y git curl wget || sudo dnf install -y git curl wget
            ;;
        *)
            print_warning "Unknown OS $os. Installing git and curl manually..."
            if ! command_exists git; then
                print_error "Git is not installed and automatic installation is not supported for $os"
                exit 1
            fi
            if ! command_exists curl && ! command_exists wget; then
                print_error "Neither curl nor wget is installed and automatic installation is not supported for $os"
                exit 1
            fi
            ;;
    esac
}

# Function to install via Go (if Go is installed)
install_via_go() {
    print_info "Installing GitLab CLI via Go..."
    
    if ! command_exists go; then
        print_warning "Go is not installed. Please install Go first."
        print_info "Download Go from: https://golang.org/dl/"
        return 1
    fi
    
    # Get latest version
    latest_version=$(curl -s "https://api.github.com/repos/gitlab-org/cli/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    
    if [[ -z "$latest_version" ]]; then
        print_error "Failed to get latest version"
        return 1
    fi
    
    print_info "Installing version $latest_version"
    go install gitlab.com/gitlab-org/cli@latest
    
    # Add to PATH if not already there
    go_path="$HOME/go/bin"
    if [[ ":$PATH:" != *":$go_path:"* ]]; then
        echo 'export PATH="$PATH:'"$go_path"'"' >> "$HOME/.bashrc"
        echo 'export PATH="$PATH:'"$go_path"'"' >> "$HOME/.zshrc"
        export PATH="$PATH:$go_path"
        print_info "Added $go_path to your PATH"
    fi
    
    # Verify installation
    if command_exists glab; then
        print_success "GitLab CLI installed successfully!"
        glab --version
        return 0
    else
        print_error "GitLab CLI installation failed"
        return 1
    fi
}

# Function to install via Homebrew (macOS)
install_via_homebrew() {
    print_info "Installing GitLab CLI via Homebrew..."
    
    brew install gitlab-org/cli/glab
    
    if command_exists glab; then
        print_success "GitLab CLI installed successfully!"
        glab --version
        return 0
    else
        print_error "GitLab CLI installation failed"
        return 1
    fi
}

# Function to install via package manager (Linux)
install_via_package_manager() {
    local os="$1"
    print_info "Installing GitLab CLI via package manager for $os..."
    
    case "$os" in
        "ubuntu"|"debian")
            # Add GitLab repository
            curl -fsSL https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash
            
            # Install glab
            sudo apt-get install -y glab
            ;;
        "centos"|"rhel"|"fedora")
            # Add GitLab repository
            curl -fsSL https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.rpm.sh | sudo bash
            
            # Install glab
            sudo yum install -y glab || sudo dnf install -y glab
            ;;
        *)
            print_error "Package manager installation not supported for $os"
            return 1
            ;;
    esac
    
    if command_exists glab; then
        print_success "GitLab CLI installed successfully!"
        glab --version
        return 0
    else
        print_error "GitLab CLI installation failed"
        return 1
    fi
}

# Function to install via binary download
install_via_binary() {
    print_info "Installing GitLab CLI via binary download..."
    
    # Detect architecture
    arch=$(uname -m)
    case "$arch" in
        x86_64)
            arch="amd64"
            ;;
        aarch64)
            arch="arm64"
            ;;
        armv7l|armv6l)
            arch="arm"
            ;;
        *)
            print_error "Unsupported architecture: $arch"
            return 1
            ;;
    esac
    
    # Detect OS
    os=$(detect_os)
    case "$os" in
        "macos")
            binary_os="Darwin"
            ;;
        "ubuntu"|"debian"|"centos"|"rhel"|"fedora"|"linux")
            binary_os="Linux"
            ;;
        *)
            print_error "Unsupported OS: $os"
            return 1
            ;;
    esac
    
    # Get latest version
    latest_version=$(curl -s "https://api.github.com/repos/gitlab-org/cli/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    
    if [[ -z "$latest_version" ]]; then
        print_error "Failed to get latest version"
        return 1
    fi
    
    # Download URL
    download_url="https://gitlab.com/gitlab-org/cli/-/releases/${latest_version}/downloads/glab_${latest_version#v}_${binary_os}_${arch}.tar.gz"
    
    # Download and install
    temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    print_info "Downloading glab $latest_version..."
    if command_exists curl; then
        curl -L -o glab.tar.gz "$download_url"
    elif command_exists wget; then
        wget -O glab.tar.gz "$download_url"
    else
        print_error "Neither curl nor wget is available"
        return 1
    fi
    
    # Extract
    tar -xzf glab.tar.gz
    
    # Move to bin
    sudo mv glab /usr/local/bin/
    
    # Clean up
    cd /
    rm -rf "$temp_dir"
    
    if command_exists glab; then
        print_success "GitLab CLI installed successfully!"
        glab --version
        return 0
    else
        print_error "GitLab CLI installation failed"
        return 1
    fi
}

# Function to install via snap (Linux)
install_via_snap() {
    print_info "Installing GitLab CLI via Snap..."
    
    if ! command_exists snap; then
        print_warning "Snap is not installed. Please install Snap first."
        print_info "For Ubuntu: sudo apt install snapd"
        print_info "For other distributions: https://snapcraft.io/docs/installing-snapd"
        return 1
    fi
    
    sudo snap install glab
    
    if command_exists glab; then
        print_success "GitLab CLI installed successfully!"
        glab --version
        return 0
    else
        print_error "GitLab CLI installation failed"
        return 1
    fi
}

# Function to install via Docker
install_via_docker() {
    print_info "Installing GitLab CLI via Docker..."
    
    if ! command_exists docker; then
        print_warning "Docker is not installed. Please install Docker first."
        print_info "Download Docker from: https://docs.docker.com/get-docker/"
        return 1
    fi
    
    # Pull the latest image
    docker pull gitlab/cli:latest
    
    # Create alias or script
    cat > "$HOME/.local/bin/glab" << 'EOF'
#!/bin/bash
docker run -it --rm -v "$PWD":/app -w /app gitlab/cli glab "$@"
EOF
    
    chmod +x "$HOME/.local/bin/glab"
    
    # Add to PATH if not already there
    local_bin="$HOME/.local/bin"
    if [[ ":$PATH:" != *":$local_bin:"* ]]; then
        echo 'export PATH="$PATH:'"$local_bin"'"' >> "$HOME/.bashrc"
        echo 'export PATH="$PATH:'"$local_bin"'"' >> "$HOME/.zshrc"
        export PATH="$PATH:$local_bin"
        print_info "Added $local_bin to your PATH"
    fi
    
    if command_exists glab; then
        print_success "GitLab CLI installed successfully!"
        glab --version
        return 0
    else
        print_error "GitLab CLI installation failed"
        return 1
    fi
}

# Function to authenticate with GitLab
authenticate_with_gitlab() {
    print_info "To authenticate with GitLab, run: glab auth login"
    print_info "This will guide you through the authentication process."
}

# Main installation function
main() {
    print_info "GitLab CLI (glab) Installation Script"
    print_info "====================================="
    
    # Detect OS
    os=$(detect_os)
    print_info "Detected OS: $os"
    
    # Install prerequisites
    install_prerequisites "$os"
    
    # Installation methods in order of preference
    methods=()
    
    case "$os" in
        "macos")
            methods=("homebrew" "go" "binary")
            ;;
        "ubuntu"|"debian")
            methods=("package_manager" "snap" "go" "binary")
            ;;
        "centos"|"rhel"|"fedora")
            methods=("package_manager" "go" "binary")
            ;;
        *)
            methods=("go" "binary")
            ;;
    esac
    
    # Try each method
    for method in "${methods[@]}"; do
        print_info "Trying installation method: $method"
        
        case "$method" in
            "homebrew")
                if install_via_homebrew; then
                    authenticate_with_gitlab
                    exit 0
                fi
                ;;
            "package_manager")
                if install_via_package_manager "$os"; then
                    authenticate_with_gitlab
                    exit 0
                fi
                ;;
            "go")
                if install_via_go; then
                    authenticate_with_gitlab
                    exit 0
                fi
                ;;
            "binary")
                if install_via_binary; then
                    authenticate_with_gitlab
                    exit 0
                fi
                ;;
            "snap")
                if install_via_snap; then
                    authenticate_with_gitlab
                    exit 0
                fi
                ;;
        esac
        
        print_warning "$method installation failed, trying next method..."
    done
    
    # If all methods failed
    print_error "All installation methods failed. Please try installing manually:"
    print_info "1. Via Go: go install gitlab.com/gitlab-org/cli@latest"
    print_info "2. Via Homebrew: brew install gitlab-org/cli/glab"
    print_info "3. Download binary from: https://gitlab.com/gitlab-org/cli/-/releases"
    print_info "4. Via Docker: docker run -it --rm -v \"\$PWD\":/app -w /app gitlab/cli glab"
    exit 1
}

# Show help
show_help() {
    cat << EOF
GitLab CLI (glab) Installation Script

Usage: $0 [OPTIONS]

OPTIONS:
    -h, --help          Show this help message
    -m, --method METHOD Specify installation method (homebrew, package_manager, go, binary, snap, docker)
    -v, --version       Show version information

SUPPORTED METHODS:
    homebrew            Install via Homebrew (macOS only)
    package_manager     Install via system package manager (Linux)
    go                  Install via Go (requires Go installed)
    binary              Install via direct binary download
    snap                Install via Snap (Linux)
    docker              Install via Docker (requires Docker)

EXAMPLES:
    $0                                  # Auto-detect best method
    $0 -m go                            # Install via Go
    $0 --method binary                 # Install via binary download

EOF
}

# Parse command line arguments
method=""
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -m|--method)
            method="$2"
            shift 2
            ;;
        -v|--version)
            echo "GitLab CLI Installation Script v1.0.0"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# If method is specified, use only that method
if [[ -n "$method" ]]; then
    case "$method" in
        "homebrew"|"package_manager"|"go"|"binary"|"snap"|"docker")
            print_info "Using specified method: $method"
            # Detect OS
            os=$(detect_os)
            case "$method" in
                "homebrew")
                    if [[ "$os" != "macos" ]]; then
                        print_error "Homebrew method is only supported on macOS"
                        exit 1
                    fi
                    install_via_homebrew
                    ;;
                "package_manager")
                    if [[ "$os" != "ubuntu" && "$os" != "debian" && "$os" != "centos" && "$os" != "rhel" && "$os" != "fedora" ]]; then
                        print_error "Package manager method is only supported on Linux distributions"
                        exit 1
                    fi
                    install_via_package_manager "$os"
                    ;;
                "go")
                    install_via_go
                    ;;
                "binary")
                    install_via_binary
                    ;;
                "snap")
                    if [[ "$os" != "linux" ]]; then
                        print_error "Snap method is only supported on Linux"
                        exit 1
                    fi
                    install_via_snap
                    ;;
                "docker")
                    install_via_docker
                    ;;
            esac
            authenticate_with_gitlab
            ;;
        *)
            print_error "Unknown method: $method"
            show_help
            exit 1
            ;;
    esac
else
    # Auto-detect best method
    main
fi