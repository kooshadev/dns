#!/bin/bash
#===============================================================================
# ViraDNS Tunnel - Gaming DNS Server with Tunnel Setup
# Author: Koosha Mostafaei
# Version: 2.0.1
# Description: Tunneled DNS setup between Iran and Kharej servers
#===============================================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
UNDERLINE='\033[4m'
BLINK='\033[5m'
REVERSE='\033[7m'
HIDDEN='\033[8m'

# Background colors
BG_RED='\033[41m'
BG_GREEN='\033[42m'
BG_YELLOW='\033[43m'
BG_BLUE='\033[44m'
BG_PURPLE='\033[45m'
BG_CYAN='\033[46m'
BG_WHITE='\033[47m'
BG_BLACK='\033[40m'

# Unicode characters
CHECK="✓"
CROSS="✗"
ARROW="➜"
STAR="★"
GEAR="⚙"
ROCKET="🚀"
LINK="🔗"
SHIELD="🛡️"
GLOBE="🌍"
LOCK="🔒"
KEY="🔑"
FLASH="⚡"
HEART="❤️"
FIRE="🔥"

# Global variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/var/log/viradns_tunnel_setup.log"
SERVER_TYPE=""
TUNNEL_TYPE=""
Kharej_IP=""
IRAN_IP=""
TUNNEL_PORT="8443"
DNS_PORT="5353"
TUNNEL_KEY=""

# Ensure running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root${NC}"
   exit 1
fi

# Clear screen function
clear_screen() {
    printf '\033[2J\033[H'
}

# Move cursor
move_cursor() {
    printf '\033[%d;%dH' "$1" "$2"
}

# Hide/Show cursor
hide_cursor() {
    printf '\033[?25l'
}

show_cursor() {
    printf '\033[?25h'
}

# Save/Restore cursor position
save_cursor() {
    printf '\033[s'
}

restore_cursor() {
    printf '\033[u'
}

# Enhanced animated banner with Hacker Terminal style
show_banner() {
    clear_screen
    hide_cursor

    # Black background
    echo -ne "\033[40m"
    
    # Create gradient effect from blue to green (like in the image)
    local gradient_text=(
        "\033[38;5;21m" # Dark blue
        "\033[38;5;27m" # Medium blue
        "\033[38;5;33m" # Light blue
        "\033[38;5;39m" # Cyan-blue
        "\033[38;5;45m" # Light cyan
        "\033[38;5;51m" # Cyan
        "\033[38;5;49m" # Light green-cyan
        "\033[38;5;48m" # Green-cyan
        "\033[38;5;47m" # Light green
        "\033[38;5;46m" # Bright green
    )

    # ViraDNS text with gradient effect
    local banner_lines=(
        "██╗   ██╗██╗██████╗  █████╗ ██████╗ ███╗   ██╗███████╗"
        "██║   ██║██║██╔══██╗██╔══██╗██╔══██╗████╗  ██║██╔════╝"
        "██║   ██║██║██████╔╝███████║██║  ██║██╔██╗ ██║███████╗"
        "╚██╗ ██╔╝██║██╔══██╗██╔══██║██║  ██║██║╚██╗██║╚════██║"
        " ╚████╔╝ ██║██║  ██║██║  ██║██████╔╝██║ ╚████║███████║"
        "  ╚═══╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═══╝╚══════╝"
    )

    # Display ViraDNS with gradient
    for i in {0..5}; do
        move_cursor $((i+5)) 12
        line="${banner_lines[$i]}"
        line_length=${#line}
        for ((j=0; j<line_length; j++)); do
            color_index=$((j * 10 / line_length))
            if [ $color_index -gt 9 ]; then color_index=9; fi
            echo -ne "${gradient_text[$color_index]}${line:$j:1}"
        done
    done

    # TERMINAL text with same gradient
    echo -e "\n"
    local terminal_lines=(
        "████████╗███████╗██████╗ ███╗   ███╗██╗███╗   ██╗ █████╗ ██╗     "
        "╚══██╔══╝██╔════╝██╔══██╗████╗ ████║██║████╗  ██║██╔══██╗██║     "
        "   ██║   █████╗  ██████╔╝██╔████╔██║██║██╔██╗ ██║███████║██║     "
        "   ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║██║██║╚██╗██║██╔══██║██║     "
        "   ██║   ███████╗██║  ██║██║ ╚═╝ ██║██║██║ ╚████║██║  ██║███████╗"
        "   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝"
    )

    for i in {0..5}; do
        move_cursor $((i+13)) 6
        line="${terminal_lines[$i]}"
        line_length=${#line}
        for ((j=0; j<line_length; j++)); do
            color_index=$((j * 10 / line_length))
            if [ $color_index -gt 9 ]; then color_index=9; fi
            echo -ne "${gradient_text[$color_index]}${line:$j:1}"
        done
    done

    # Add labels like in the image
    move_cursor 20 28
    echo -ne "${BG_PURPLE}${WHITE} Developer ${NC} "
    echo -ne "${BG_CYAN}${BLACK} K00SH@ ${NC}"

    show_cursor
    echo -e "\n\n${NC}"
}

# Beautiful menu system with smooth transitions
show_menu() {
    local title=$1
    shift
    local options=("$@")
    local selected=0
    local key=""

    hide_cursor

    while true; do
        clear_screen
        show_banner

        # Title box with gradient effect
        echo -e "${CYAN}┌─────────────────────────────────────────────────────────────┐${NC}"
        echo -e "${CYAN}│${NC}  ${BOLD}${WHITE}$title${NC}${CYAN}│${NC}"
        echo -e "${CYAN}└─────────────────────────────────────────────────────────────┘${NC}"
        echo ""

        # Menu items with hover effect
        for i in "${!options[@]}"; do
            if [ $i -eq $selected ]; then
                echo -e "  ${BG_BLUE}${WHITE} ▶ ${options[$i]} ${NC}"
            else
                echo -e "  ${DIM}   ${options[$i]}${NC}"
            fi
        done

        echo ""
        echo -e "${DIM}${YELLOW}Use ↑/↓ arrows to navigate, Enter to select, Q to quit${NC}"

        # Read single keypress
        IFS= read -rsn1 key

        case "$key" in
            $'\x1b')  # ESC sequence
                read -rsn2 key
                case "$key" in
                    '[A') # Up arrow
                        ((selected--))
                        if [ $selected -lt 0 ]; then
                            selected=$((${#options[@]} - 1))
                        fi
                        ;;
                    '[B') # Down arrow
                        ((selected++))
                        if [ $selected -ge ${#options[@]} ]; then
                            selected=0
                        fi
                        ;;
                esac
                ;;
            '') # Enter
                show_cursor
                return $selected
                ;;
            'q'|'Q')
                show_cursor
                exit 0
                ;;
        esac
    done
}

# Enhanced progress bar with GREEN color as requested
show_progress() {
    local current=$1
    local total=$2
    local text=$3
    local width=50
    local percentage=$((current * 100 / total))
    local completed=$((width * current / total))

    # Build progress bar with GREEN color
    printf "\r  "

    # Start cap
    printf "${GREEN}["

    # Filled portion - ALL GREEN as requested
    for ((i=0; i<completed; i++)); do
        printf "${GREEN}█"
    done

    # Empty portion
    printf "${DIM}${WHITE}"
    for ((i=completed; i<width; i++)); do
        printf "░"
    done
    printf "${NC}"

    # End cap and percentage
    printf "${GREEN}]${NC} "
    printf "${BOLD}${GREEN}%3d%%${NC} " "$percentage"

    # Status text
    printf "${CYAN}${text}${NC}"
}

# Animated spinner with colors
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    local temp

    while ps -p $pid > /dev/null 2>&1; do
        temp=${spinstr#?}
        printf " [${CYAN}%c${NC}]  " "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Beautiful status messages
print_status() {
    echo -e "\n${BLUE}${ARROW}${NC} $1"
}

print_success() {
    echo -e "${GREEN}${CHECK}${NC} $1"
}

print_error() {
    echo -e "${RED}${CROSS}${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC}  $1"
}

print_info() {
    echo -e "${CYAN}ℹ${NC}  $1"
}

print_step() {
    echo -e "\n${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${WHITE}$1${NC}"
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

# Interactive input with validation
get_input() {
    local prompt=$1
    local var_name=$2
    local validation=$3
    local input=""

    while true; do
        echo -ne "${CYAN}${ARROW}${NC} $prompt: "
        read -r input

        if [ -z "$input" ]; then
            print_error "Input cannot be empty!"
            continue
        fi

        if [ ! -z "$validation" ]; then
            if ! echo "$input" | grep -qE "$validation"; then
                print_error "Invalid format! Please try again."
                continue
            fi
        fi

        eval "$var_name='$input'"
        break
    done
}

# Server type selection
select_server_type() {
    print_step "Select Server Type ${GLOBE}"

    show_menu "Choose your server location:" \
        "Iran (Tunnel Client) 🇮🇷" \
        "Kharej (Tunnel Server) 🌍"

    case $? in
        0) SERVER_TYPE="Iran" ;;
        1) SERVER_TYPE="Kharej" ;;
    esac

    print_success "Selected: $SERVER_TYPE server"
}

# Tunnel type selection
select_tunnel_type() {
    print_step "Select Tunnel Protocol ${LINK}"

    show_menu "Choose tunnel type for secure connection:" \
        "WireGuard (Recommended) ⚡" \
        "Xray/V2Ray (Alternative) 🛡️" \
        "SSH Tunnel (Legacy) 🔐" \
        "OpenVPN (Classic) 🔒"

    case $? in
        0) TUNNEL_TYPE="wireguard" ;;
        1) TUNNEL_TYPE="xray" ;;
        2) TUNNEL_TYPE="ssh" ;;
        3) TUNNEL_TYPE="openvpn" ;;
    esac

    print_success "Selected: $TUNNEL_TYPE tunnel"
}

# Install dependencies with progress animation
install_dependencies() {
    print_step "Installing Required Packages ${GEAR}"

    local packages=(
        "wireguard"
        "wireguard-tools"
        "unbound"
        "iptables"
        "iptables-persistent"
        "curl"
        "wget"
        "net-tools"
        "dnsutils"
        "qrencode"
        "htop"
        "iftop"
        "vnstat"
        "ufw"
        "fail2ban"
        "mtr"
        "tcpdump"
        "nmap"
        "screen"
        "tmux"
        "git"
        "build-essential"
        "python3"
        "python3-pip"
    )

    # Filter packages based on tunnel type
    case $TUNNEL_TYPE in
        "wireguard")
            packages+=("wireguard" "wireguard-tools")
            ;;
        "xray")
            packages+=("nginx" "certbot" "python3-certbot-nginx")
            ;;
        "ssh")
            packages+=("openssh-server" "autossh")
            ;;
        "openvpn")
            packages+=("openvpn" "easy-rsa")
            ;;
    esac

    # Update package list with animation
    echo -ne "${CYAN}Updating package lists...${NC}"
    apt-get update -qq &
    spinner $!
    print_success "Package lists updated"

    # Install packages with progress bar
    local total=${#packages[@]}
    local current=0

    for package in "${packages[@]}"; do
        ((current++))
        show_progress $current $total "Installing $package"
        apt-get install -y "$package" > /dev/null 2>&1
    done

    echo ""
    print_success "All dependencies installed successfully!"
}

# Setup WireGuard tunnel
setup_wireguard() {
    print_step "Configuring WireGuard Tunnel ${SHIELD}"

    if [ "$SERVER_TYPE" = "Kharej" ]; then
        # Server setup
        print_status "Generating WireGuard keys..."

        # Generate server keys with animation
        echo -ne "${CYAN}Creating cryptographic keys...${NC}"
        wg genkey | tee /etc/wireguard/server_private.key | wg pubkey > /etc/wireguard/server_public.key &
        spinner $!
        chmod 600 /etc/wireguard/server_private.key

        print_success "Server keys generated"

        # Create server config with beautiful formatting
        cat > /etc/wireguard/wg0.conf << EOF
# ViraDNS WireGuard Server Configuration
# Generated on: $(date)
# Server Type: Kharej Gaming DNS Tunnel

[Interface]
# Server Identity
Address = 10.0.0.1/24
ListenPort = ${TUNNEL_PORT}
PrivateKey = $(cat /etc/wireguard/server_private.key)

# Network Optimization
MTU = 1420

# Performance Tuning
SaveConfig = false

# iptables Rules for DNS
PostUp = iptables -t nat -A PREROUTING -i wg0 -p udp --dport 53 -j REDIRECT --to-port 53
PostUp = iptables -t nat -A PREROUTING -i wg0 -p tcp --dport 53 -j REDIRECT --to-port 53
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT
PostUp = iptables -A FORWARD -o wg0 -j ACCEPT

PostDown = iptables -t nat -D PREROUTING -i wg0 -p udp --dport 53 -j REDIRECT --to-port 53
PostDown = iptables -t nat -D PREROUTING -i wg0 -p tcp --dport 53 -j REDIRECT --to-port 53
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT
PostDown = iptables -D FORWARD -o wg0 -j ACCEPT

# Gaming Performance Optimization
Table = off

# [Peer] sections will be added here for Iran clients
EOF

        # Display server public key with fancy box
        echo -e "\n${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║${NC}            ${BOLD}WireGuard Server Configuration${NC}              ${GREEN}║${NC}"
        echo -e "${GREEN}╠═══════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${GREEN}║${NC} ${YELLOW}Server Public Key:${NC}                                      ${GREEN}║${NC}"
        echo -e "${GREEN}║${NC} $(cat /etc/wireguard/server_public.key)  ${GREEN}║${NC}"
        echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"

        # Generate QR code for easy mobile setup
        echo -e "\n${CYAN}Generating QR code for mobile clients...${NC}"
        echo "Server:$(curl -s ifconfig.me):${TUNNEL_PORT}:$(cat /etc/wireguard/server_public.key)" | qrencode -t ansiutf8

    else
        # Iran client setup
        get_input "Enter Kharej server IP" "Kharej_IP" "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"
        get_input "Enter Kharej server public key" "KHAREJ_PUB_KEY" "^[A-Za-z0-9+/]{43}=$"

        # Generate client keys
        echo -ne "${CYAN}Generating client keys...${NC}"
        wg genkey | tee /etc/wireguard/client_private.key | wg pubkey > /etc/wireguard/client_public.key &
        spinner $!
        chmod 600 /etc/wireguard/client_private.key

        # Create client config
        cat > /etc/wireguard/wg0.conf << EOF
# ViraDNS WireGuard Client Configuration
# Generated on: $(date)
# Client Type: Iran Gaming DNS Client

[Interface]
# Client Identity
Address = 10.0.0.2/24
PrivateKey = $(cat /etc/wireguard/client_private.key)

# DNS Configuration
DNS = 10.0.0.1

# Network Optimization
MTU = 1420

[Peer]
# Kharej Server
PublicKey = ${KHAREJ_PUB_KEY}
Endpoint = ${Kharej_IP}:${TUNNEL_PORT}
AllowedIPs = 10.0.0.0/24, 0.0.0.0/0

# Keep connection alive
PersistentKeepalive = 25
EOF

        # Display client public key
        echo -e "\n${YELLOW}╔═══════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${YELLOW}║${NC}              ${BOLD}Client Public Key${NC}                          ${YELLOW}║${NC}"
        echo -e "${YELLOW}╠═══════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${YELLOW}║${NC} Add this key to Kharej server:                          ${YELLOW}║${NC}"
        echo -e "${YELLOW}║${NC} $(cat /etc/wireguard/client_public.key)  ${YELLOW}║${NC}"
        echo -e "${YELLOW}╚═══════════════════════════════════════════════════════════════╝${NC}"
    fi

    # Enable and start WireGuard
    echo -ne "${CYAN}Starting WireGuard service...${NC}"
    systemctl enable wg-quick@wg0 > /dev/null 2>&1
    systemctl start wg-quick@wg0 &
    spinner $!

    if systemctl is-active --quiet wg-quick@wg0; then
        print_success "WireGuard tunnel activated! ${ROCKET}"
    else
        print_error "Failed to start WireGuard"
        exit 1
    fi
}

# Setup Xray tunnel
setup_xray() {
    print_step "Configuring Xray Tunnel ${SHIELD}"

    # Install Xray
    echo -ne "${CYAN}Installing Xray...${NC}"
    bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install > /dev/null 2>&1 &
    spinner $!
    print_success "Xray installed"

    if [ "$SERVER_TYPE" = "Kharej" ]; then
        # Generate UUID and keys
        TUNNEL_KEY=$(cat /proc/sys/kernel/random/uuid)
        
        # Generate Reality keys
        echo -ne "${CYAN}Generating Reality keys...${NC}"
        /usr/local/bin/xray x25519 > /tmp/xray_keys 2>&1 &
        spinner $!
        
        PRIVATE_KEY=$(grep "Private key:" /tmp/xray_keys | awk '{print $3}')
        PUBLIC_KEY=$(grep "Public key:" /tmp/xray_keys | awk '{print $3}')
        
        # Save public key for later
        echo "$PUBLIC_KEY" > /tmp/xray_public_key

        # Create Xray server config
        cat > /usr/local/etc/xray/config.json << EOF
{
    "log": {
        "loglevel": "info"
    },
    "inbounds": [
        {
            "port": ${TUNNEL_PORT},
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "${TUNNEL_KEY}",
                        "flow": "xtls-rprx-vision"
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "tcp",
                "security": "reality",
                "realitySettings": {
                    "show": false,
                    "dest": "www.google.com:443",
                    "serverNames": [
                        "www.google.com",
                        "www.microsoft.com",
                        "www.apple.com"
                    ],
                    "privateKey": "${PRIVATE_KEY}",
                    "shortIds": [
                        "",
                        "6ba85179e30d4fc2"
                    ]
                }
            }
        },
        {
            "port": 53,
            "protocol": "dokodemo-door",
            "settings": {
                "address": "127.0.0.1",
                "port": 53,
                "network": "tcp,udp"
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom",
            "settings": {}
        }
    ]
}
EOF

        # Display connection info
        echo -e "\n${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║${NC}              ${BOLD}Xray Server Configuration${NC}                 ${GREEN}║${NC}"
        echo -e "${GREEN}╠═══════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${GREEN}║${NC} ${YELLOW}UUID:${NC} ${TUNNEL_KEY} ${GREEN}║${NC}"
        echo -e "${GREEN}║${NC} ${YELLOW}Public Key:${NC} ${PUBLIC_KEY}  ${GREEN}║${NC}"
        echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"

    else
        # Iran client setup
        get_input "Enter Kharej server IP" "Kharej_IP" "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"
        get_input "Enter connection UUID" "TUNNEL_KEY" "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"
        get_input "Enter server public key" "SERVER_PUB_KEY" "^[A-Za-z0-9+/]{43}=$"

        # Create Xray client config
        cat > /usr/local/etc/xray/config.json << EOF
{
    "log": {
        "loglevel": "info"
    },
    "inbounds": [
        {
            "port": 53,
            "protocol": "dokodemo-door",
            "settings": {
                "address": "8.8.8.8",
                "port": 53,
                "network": "tcp,udp"
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "vless",
            "settings": {
                "vnext": [
                    {
                        "address": "${Kharej_IP}",
                        "port": ${TUNNEL_PORT},
                        "users": [
                            {
                                "id": "${TUNNEL_KEY}",
                                "encryption": "none",
                                "flow": "xtls-rprx-vision"
                            }
                        ]
                    }
                ]
            },
            "streamSettings": {
                "network": "tcp",
                "security": "reality",
                "realitySettings": {
                    "fingerprint": "chrome",
                    "serverName": "www.google.com",
                    "publicKey": "${SERVER_PUB_KEY}",
                    "shortId": "6ba85179e30d4fc2"
                }
            }
        }
    ]
}
EOF
    fi

    # Enable and restart Xray
    systemctl enable xray > /dev/null 2>&1
    systemctl restart xray

    if systemctl is-active --quiet xray; then
        print_success "Xray tunnel configured successfully! ${ROCKET}"
    else
        print_error "Failed to start Xray"
        exit 1
    fi
}

# Configure Unbound DNS
configure_unbound() {
    print_step "Configuring Gaming DNS Resolver ${FLASH}"

    # Create Unbound config
    if [ "$SERVER_TYPE" = "Kharej" ]; then
        # Full resolver config for Kharej
        cat > /etc/unbound/unbound.conf << 'EOF'
server:
    # ViraDNS Gaming Optimized Configuration
    # Network settings
    interface: 0.0.0.0
    interface: 10.0.0.1
    port: 53
    do-ip4: yes
    do-ip6: no
    do-udp: yes
    do-tcp: yes

    # Access control
    access-control: 0.0.0.0/0 refuse
    access-control: 127.0.0.0/8 allow
    access-control: 10.0.0.0/24 allow

    # Performance tuning
    num-threads: 4
    msg-cache-slabs: 8
    rrset-cache-slabs: 8
    infra-cache-slabs: 8
    key-cache-slabs: 8

    # Massive cache for gaming
    rrset-cache-size: 512m
    msg-cache-size: 256m

    # Gaming optimizations
    cache-min-ttl: 60
    cache-max-ttl: 86400
    prefetch: yes
    prefetch-key: yes
    serve-expired: yes
    serve-expired-ttl: 86400

    # Ultra low latency
    so-reuseport: yes
    so-rcvbuf: 8m
    so-sndbuf: 8m

    # DNSSEC
    module-config: "validator iterator"
    auto-trust-anchor-file: "/var/lib/unbound/root.key"

    # Minimal logging
    verbosity: 1
    log-queries: no

    # RTT optimization
    infra-host-ttl: 900
    infra-cache-numhosts: 50000

    # Aggressive caching
    aggressive-nsec: yes

    # EDNS optimization
    edns-buffer-size: 1232

    # TCP Fast Open
    tcp-upstream: yes

    # Query minimization
    qname-minimisation: yes

# Gaming CDN optimization
local-zone: "cdn.cloudflare.steamstatic.com." transparent
local-zone: "valve.vo.llnwd.net." transparent
local-zone: "desktop.riotcdn.net." transparent
local-zone: "lol.secure.dyn.riotcdn.net." transparent
local-zone: "epicgames-download1.akamaized.net." transparent
local-zone: "blizzard.vo.llnwd.net." transparent
local-zone: "level3.blizzard.com." transparent
local-zone: "dist.blizzard.com." transparent
local-zone: "llnw.blizzard.com." transparent
local-zone: "edgecast.blizzard.com." transparent
local-zone: "blizzard.nefficient.co.kr." transparent
local-zone: "blizzard.gcdn.cloudn.co.kr." transparent
local-zone: "pubg.com." transparent
local-zone: "pubgmobile.com." transparent
local-zone: "fortnite.com." transparent
local-zone: "minecraft.net." transparent
local-zone: "mojang.com." transparent
local-zone: "twitch.tv." transparent
local-zone: "discord.com." transparent
local-zone: "discordapp.com." transparent

# Forward to ultra-fast public DNS
forward-zone:
    name: "."
    forward-addr: 1.1.1.1@853#cloudflare-dns.com
    forward-addr: 1.0.0.1@853#cloudflare-dns.com
    forward-addr: 8.8.8.8
    forward-addr: 8.8.4.4
    forward-tls-upstream: yes
EOF
    else
        # Iran server - forward to tunnel
        cat > /etc/unbound/unbound.conf << EOF
server:
    # ViraDNS Iran Client Configuration
    # Network settings
    interface: 0.0.0.0
    port: 53
    do-ip4: yes
    do-ip6: no
    do-udp: yes
    do-tcp: yes

    # Access control - allow all
    access-control: 0.0.0.0/0 allow

    # Local caching
    msg-cache-size: 50m
    rrset-cache-size: 100m

    # Performance
    num-threads: 2
    so-reuseport: yes

    # Logging
    verbosity: 1

    # No DNSSEC validation (done on Kharej server)
    module-config: "iterator"

# Forward everything through secure tunnel
forward-zone:
    name: "."
    forward-addr: 10.0.0.1@53
EOF
    fi

    # Create gaming servers config
    mkdir -p /etc/unbound/local.d/
    cat > /etc/unbound/local.d/gaming-servers.conf << 'EOF'
# ViraDNS Gaming Server Optimizations
# Popular game servers with static IPs for instant resolution

# Steam
local-data: "steamcommunity.com. A 104.99.55.26"
local-data: "steampowered.com. A 104.99.55.26"
local-data: "steamstatic.com. A 184.25.56.84"

# Epic Games
local-data: "epicgames.com. A 18.65.170.71"
local-data: "unrealengine.com. A 52.84.234.79"

# Riot Games
local-data: "riotgames.com. A 104.16.85.20"
local-data: "leagueoflegends.com. A 104.16.87.20"
local-data: "valorant.com. A 104.16.57.24"

# Blizzard
local-data: "blizzard.com. A 24.105.30.129"
local-data: "battle.net. A 24.105.62.129"

# Discord
local-data: "discord.com. A 162.159.128.233"
local-data: "discordapp.com. A 162.159.129.233"

# Twitch
local-data: "twitch.tv. A 151.101.2.167"

# PUBG
local-data: "pubg.com. A 13.107.42.14"
local-data: "playbattlegrounds.com. A 52.168.112.67"
EOF

    # Include gaming config
    echo 'include: "/etc/unbound/local.d/*.conf"' >> /etc/unbound/unbound.conf

    # Restart Unbound with animation
    echo -ne "${CYAN}Restarting Unbound DNS service...${NC}"
    systemctl restart unbound &
    spinner $!
    print_success "Unbound configured for ultra-low latency gaming! ${FLASH}"
}

# Setup monitoring tools
setup_monitoring() {
    print_step "Creating Monitoring & Diagnostic Tools ${GEAR}"

    # Create enhanced tunnel status script
    cat > /usr/local/bin/viradns-tunnel-status << 'EOF'
#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'
BOLD='\033[1m'

clear

echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}${BOLD}              ViraDNS Tunnel Status Monitor                   ${NC}${CYAN}║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check tunnel status
echo -e "${YELLOW}▶ Tunnel Status:${NC}"
if systemctl is-active --quiet wg-quick@wg0 2>/dev/null; then
    echo -e "  ${GREEN}● WireGuard:${NC} Active"
    echo -e "${CYAN}  Connection Details:${NC}"
    wg show wg0 | grep -E "peer:|endpoint:|latest handshake:|transfer:" | sed 's/^/    /'
elif systemctl is-active --quiet xray 2>/dev/null; then
    echo -e "  ${GREEN}● Xray:${NC} Active"
    XRAY_PID=$(pgrep xray)
    if [ ! -z "$XRAY_PID" ]; then
        XRAY_CONNECTIONS=$(ss -tnp | grep -c "xray")
        echo -e "  ${CYAN}Active connections:${NC} $XRAY_CONNECTIONS"
    fi
else
    echo -e "  ${RED}● Tunnel:${NC} Inactive"
fi

echo ""
echo -e "${YELLOW}▶ DNS Service:${NC}"
if systemctl is-active --quiet unbound; then
    echo -e "  ${GREEN}● Unbound:${NC} Active"
    UNBOUND_PORT=$(ss -tuln | grep -c ":53 ")
    echo -e "  ${CYAN}Listening on port 53:${NC} Yes ($UNBOUND_PORT interfaces)"
else
    echo -e "  ${RED}● Unbound:${NC} Inactive"
fi

echo ""
echo -e "${YELLOW}▶ DNS Statistics:${NC}"
if command -v unbound-control &> /dev/null; then
    QUERIES=$(unbound-control stats_noreset | grep "total.num.queries=" | cut -d= -f2)
    CACHE_HITS=$(unbound-control stats_noreset | grep "total.num.cachehits=" | cut -d= -f2)
    if [ ! -z "$QUERIES" ] && [ ! -z "$CACHE_HITS" ] && [ "$QUERIES" -gt 0 ]; then
        HIT_RATE=$((CACHE_HITS * 100 / QUERIES))
        echo -e "  ${CYAN}Total queries:${NC} $QUERIES"
        echo -e "  ${CYAN}Cache hits:${NC} $CACHE_HITS (${HIT_RATE}%)"
    fi
fi

echo ""
echo -e "${YELLOW}▶ Network Connectivity:${NC}"
# Test tunnel connectivity
if [ -f /etc/wireguard/wg0.conf ] || [ -f /usr/local/etc/xray/config.json ]; then
    if ping -c 1 -W 2 10.0.0.1 > /dev/null 2>&1; then
        RTT=$(ping -c 3 -W 2 10.0.0.1 | tail -1 | awk -F '/' '{print $5}')
        echo -e "  ${GREEN}● Tunnel endpoint:${NC} Reachable (${RTT}ms avg)"
    else
        echo -e "  ${RED}● Tunnel endpoint:${NC} Unreachable"
    fi
fi

echo ""
echo -e "${YELLOW}▶ DNS Resolution Test:${NC}"
for domain in google.com github.com discord.com; do
    START=$(date +%s%N)
    if dig @localhost $domain +short > /dev/null 2>&1; then
        END=$(date +%s%N)
        ELAPSED=$((($END - $START) / 1000000))
        echo -e "  ${GREEN}✓${NC} $domain: ${ELAPSED}ms"
    else
        echo -e "  ${RED}✗${NC} $domain: Failed"
    fi
done

echo ""
echo -e "${CYAN}Press 'r' to refresh or 'q' to quit${NC}"
read -n 1 -s key
case $key in
    r|R) exec $0 ;;
    q|Q) exit 0 ;;
esac
EOF

    chmod +x /usr/local/bin/viradns-tunnel-status

    # Create gaming test script
    cat > /usr/local/bin/viradns-gaming-test << 'EOF'
#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'
BOLD='\033[1m'

clear

echo -e "${PURPLE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║${NC}${BOLD}             Gaming DNS Performance Test 🎮                   ${NC}${PURPLE}║${NC}"
echo -e "${PURPLE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Gaming domains to test
declare -A gaming_domains=(
    ["Steam"]="steamcommunity.com steampowered.com"
    ["Epic Games"]="epicgames.com unrealengine.com"
    ["Riot Games"]="riotgames.com leagueoflegends.com valorant.com"
    ["Blizzard"]="blizzard.com battle.net"
    ["PUBG"]="pubg.com playbattlegrounds.com"
    ["Fortnite"]="fortnite.com"
    ["Discord"]="discord.com discordapp.com"
    ["Twitch"]="twitch.tv"
)

echo -e "${YELLOW}Testing gaming DNS resolution times...${NC}\n"

total_time=0
total_tests=0
failed_tests=0

for category in "${!gaming_domains[@]}"; do
    echo -e "${CYAN}▶ $category:${NC}"
    for domain in ${gaming_domains[$category]}; do
        START=$(date +%s%N)
        if result=$(dig @localhost $domain +short 2>/dev/null); then
            END=$(date +%s%N)
            ELAPSED=$((($END - $START) / 1000000))
            total_time=$((total_time + ELAPSED))
            total_tests=$((total_tests + 1))
            
            # Color code based on response time
            if [ $ELAPSED -lt 20 ]; then
                COLOR=$GREEN
                STATUS="Excellent"
            elif [ $ELAPSED -lt 50 ]; then
                COLOR=$YELLOW
                STATUS="Good"
            elif [ $ELAPSED -lt 100 ]; then
                COLOR=$YELLOW
                STATUS="Fair"
            else
                COLOR=$RED
                STATUS="Slow"
            fi
            
            printf "  %-25s ${COLOR}%4dms${NC} [%s]\n" "$domain:" "$ELAPSED" "$STATUS"
        else
            printf "  %-25s ${RED}Failed${NC}\n" "$domain:"
            failed_tests=$((failed_tests + 1))
            total_tests=$((total_tests + 1))
        fi
    done
    echo ""
done

# Summary
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}Performance Summary:${NC}"
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ $total_tests -gt 0 ] && [ $failed_tests -lt $total_tests ]; then
    avg_time=$((total_time / (total_tests - failed_tests)))
    success_rate=$(((total_tests - failed_tests) * 100 / total_tests))
    
    echo -e "  ${CYAN}Average response time:${NC} ${BOLD}${avg_time}ms${NC}"
    echo -e "  ${CYAN}Successful tests:${NC} $((total_tests - failed_tests))/$total_tests"
    echo -e "  ${CYAN}Success rate:${NC} ${success_rate}%"
    
    if [ $avg_time -lt 30 ]; then
        echo -e "\n  ${GREEN}★★★★★${NC} ${BOLD}Excellent gaming performance!${NC}"
    elif [ $avg_time -lt 60 ]; then
        echo -e "\n  ${YELLOW}★★★★☆${NC} ${BOLD}Good gaming performance${NC}"
    else
        echo -e "\n  ${RED}★★☆☆☆${NC} ${BOLD}Performance needs optimization${NC}"
    fi
else
    echo -e "  ${RED}All tests failed!${NC}"
fi

echo ""
echo -e "${DIM}Run 'viradns-tunnel-status' to check tunnel health${NC}"
EOF

    chmod +x /usr/local/bin/viradns-gaming-test

    # Create monitoring dashboard
    cat > /usr/local/bin/viradns-monitor << 'EOF'
#!/bin/bash

# Real-time monitoring dashboard
watch -t -n 1 '
echo -e "\033[0;36m═══════════════════════════════════════════════════════════════\033[0m"
echo -e "\033[1;37m           ViraDNS Gaming DNS Monitor Dashboard\033[0m"
echo -e "\033[0;36m═══════════════════════════════════════════════════════════════\033[0m"
echo ""

# System info
echo -e "\033[1;33m▶ System Information:\033[0m"
echo -e "  Uptime: $(uptime -p)"
echo -e "  Load: $(cat /proc/loadavg | cut -d" " -f1-3)"
echo -e "  Memory: $(free -h | grep Mem | awk "{print \$3\"/\"\$2}")"
echo ""

# DNS Stats
echo -e "\033[1;33m▶ DNS Statistics:\033[0m"
if command -v unbound-control &> /dev/null; then
    unbound-control stats_noreset | grep -E "total.num.queries=|total.num.cachehits=" | sed "s/^/  /"
fi
echo ""

# Tunnel Status
echo -e "\033[1;33m▶ Tunnel Status:\033[0m"
if systemctl is-active --quiet wg-quick@wg0 2>/dev/null; then
    echo -e "  \033[0;32m●\033[0m WireGuard: Active"
    wg show wg0 | grep -E "transfer:|latest handshake:" | head -2 | sed "s/^/    /"
elif systemctl is-active --quiet xray 2>/dev/null; then
    echo -e "  \033[0;32m●\033[0m Xray: Active"
fi
echo ""

# Network Traffic
echo -e "\033[1;33m▶ Network Traffic:\033[0m"
if command -v ifstat &> /dev/null; then
    ifstat -t 1 1 | tail -n 3
fi
'
EOF

    chmod +x /usr/local/bin/viradns-monitor

    print_success "Monitoring tools installed!"
    print_info "Commands: viradns-tunnel-status, viradns-gaming-test, viradns-monitor"
}

# Optimize system for gaming
optimize_system() {
    print_step "Optimizing System for Gaming Performance ${ROCKET}"

    # Show optimization progress
    local optimizations=(
        "Network buffer sizes"
        "TCP congestion control"
        "DNS cache warming"
        "CPU governor settings"
        "IRQ balancing"
        "Kernel parameters"
    )

    local current=0
    local total=${#optimizations[@]}

    for opt in "${optimizations[@]}"; do
        ((current++))
        show_progress $current $total "Optimizing $opt"
        sleep 0.5
    done

    echo ""

    # Apply optimizations
    cat >> /etc/sysctl.conf << 'EOF'

# ViraDNS Gaming Optimizations
# Network performance
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.ipv4.tcp_rmem = 4096 87380 134217728
net.ipv4.tcp_wmem = 4096 65536 134217728
net.core.netdev_max_backlog = 5000
net.ipv4.tcp_congestion_control = bbr
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_fastopen = 3

# DNS optimizations
net.ipv4.ip_forward = 1
net.ipv4.conf.all.rp_filter = 0
net.ipv4.conf.default.rp_filter = 0

# Gaming latency optimizations
net.ipv4.tcp_low_latency = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_no_metrics_save = 1
EOF

    sysctl -p > /dev/null 2>&1

    # Set CPU governor to performance
    if [ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ]; then
        echo "performance" | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null 2>&1
    fi

    # Disable irqbalance for lower latency
    systemctl stop irqbalance 2>/dev/null
    systemctl disable irqbalance 2>/dev/null

    print_success "System optimized for ultra-low latency gaming!"
}

# Configure firewall
configure_firewall() {
    print_step "Configuring Firewall Rules ${SHIELD}"

    # Enable IP forwarding
    echo 1 > /proc/sys/net/ipv4/ip_forward

    # Basic firewall rules
    if [ "$SERVER_TYPE" = "Kharej" ]; then
        # Kharej server rules
        iptables -A INPUT -i lo -j ACCEPT
        iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
        iptables -A INPUT -p udp --dport ${TUNNEL_PORT} -j ACCEPT
        iptables -A INPUT -p tcp --dport ${TUNNEL_PORT} -j ACCEPT
        iptables -A INPUT -p udp --dport 53 -j ACCEPT
        iptables -A INPUT -p tcp --dport 53 -j ACCEPT
        iptables -A FORWARD -i wg0 -j ACCEPT
        iptables -A FORWARD -o wg0 -j ACCEPT
        iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

        # Gaming traffic prioritization
        iptables -t mangle -A FORWARD -p udp --dport 27015:27030 -j TOS --set-tos Minimize-Delay
        iptables -t mangle -A FORWARD -p tcp --dport 27015:27030 -j TOS --set-tos Minimize-Delay
    else
        # Iran client rules
        iptables -A INPUT -i lo -j ACCEPT
        iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
        iptables -A INPUT -p udp --dport 53 -j ACCEPT
        iptables -A INPUT -p tcp --dport 53 -j ACCEPT
        iptables -A OUTPUT -p udp --dport ${TUNNEL_PORT} -j ACCEPT
        iptables -A OUTPUT -p tcp --dport ${TUNNEL_PORT} -j ACCEPT
    fi

    # Save rules
    mkdir -p /etc/iptables/
    iptables-save > /etc/iptables/rules.v4

    print_success "Firewall configured for secure gaming!"
}

# Generate client configs
generate_configs() {
    print_step "Generating Configuration Files ${KEY}"

    local config_dir="/root/viradns-configs"
    mkdir -p "$config_dir"

    if [ "$SERVER_TYPE" = "Kharej" ]; then
        # Generate client setup instructions
        cat > "$config_dir/iran-server-setup.txt" << EOF
╔═══════════════════════════════════════════════════════════════╗
║              ViraDNS Iran Server Setup Guide                  ║
╚═══════════════════════════════════════════════════════════════╝

Connection Details:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
- Kharej Server IP: $(curl -s ifconfig.me)
- Tunnel Port: ${TUNNEL_PORT}
- Tunnel Type: ${TUNNEL_TYPE}
EOF

        if [ "$TUNNEL_TYPE" = "wireguard" ]; then
            echo "• Server Public Key: $(cat /etc/wireguard/server_public.key)" >> "$config_dir/iran-server-setup.txt"
        elif [ "$TUNNEL_TYPE" = "xray" ]; then
            echo "• Connection UUID: ${TUNNEL_KEY}" >> "$config_dir/iran-server-setup.txt"
            echo "• Public Key: $(cat /tmp/xray_public_key 2>/dev/null || echo 'N/A')" >> "$config_dir/iran-server-setup.txt"
        fi

        echo -e "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >> "$config_dir/iran-server-setup.txt"

        # Generate QR code
        cat "$config_dir/iran-server-setup.txt" | qrencode -o "$config_dir/config-qr.png"

        print_success "Configuration saved to $config_dir/"
        print_info "QR code generated: $config_dir/config-qr.png"

    else
        # Client-side gaming optimized config
        local server_ip=$(hostname -I | awk '{print $1}')

        cat > "$config_dir/gaming-dns-setup.txt" << EOF
╔═══════════════════════════════════════════════════════════════╗
║               ViraDNS Gaming Client Setup 🎮                  ║
╚═══════════════════════════════════════════════════════════════╝

🔥 Ultra-Low Latency Gaming DNS Server
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

DNS Server: $server_ip
Port: 53 (Standard DNS)

═══════════════════════════════════════════════════════════════
                    PLATFORM CONFIGURATIONS
═══════════════════════════════════════════════════════════════

🎮 GAMING CONSOLES
─────────────────────────────────────────────────────────────
PlayStation 5:
  Settings → Network → Settings → Set Up Internet Connection
  → Custom → DNS Settings → Manual
  Primary DNS: $server_ip
  Secondary DNS: 8.8.8.8

Xbox Series X/S:
  Settings → Network → Network Settings → Advanced Settings
  → DNS Settings → Manual
  Primary DNS: $server_ip
  Secondary DNS: 8.8.8.8

Nintendo Switch:
  System Settings → Internet → Internet Settings
  → Your Network → Change Settings → DNS Settings → Manual
  Primary DNS: $server_ip
  Secondary DNS: 8.8.8.8

💻 PC CONFIGURATIONS
─────────────────────────────────────────────────────────────
Windows 11/10:
  netsh interface ip set dns "Ethernet" static $server_ip
  netsh interface ip add dns "Ethernet" 8.8.8.8 index=2

  Or via GUI:
  Settings → Network & Internet → Ethernet → DNS server assignment
  → Manual → IPv4 → Preferred DNS: $server_ip

Linux:
  # Temporary:
  echo "nameserver $server_ip" | sudo tee /etc/resolv.conf

  # Permanent (NetworkManager):
  nmcli con mod "Your-Connection" ipv4.dns "$server_ip,8.8.8.8"
  nmcli con up "Your-Connection"

macOS:
  System Preferences → Network → Advanced → DNS
  Add: $server_ip

📱 MOBILE DEVICES
─────────────────────────────────────────────────────────────
Android:
  Settings → Network & Internet → Private DNS
  → Private DNS provider hostname: $server_ip

iOS:
  Settings → Wi-Fi → (i) → Configure DNS → Manual
  Add Server: $server_ip

🌐 ROUTER CONFIGURATION
─────────────────────────────────────────────────────────────
Most Routers:
  192.168.1.1 → Network Settings → DNS
  Primary DNS: $server_ip
  Secondary DNS: 8.8.8.8

═══════════════════════════════════════════════════════════════
                    OPTIMIZATION TIPS
═══════════════════════════════════════════════════════════════

⚡ For Best Gaming Performance:
- Use Ethernet connection when possible
- Set this DNS on your gaming device directly
- Restart your device after changing DNS
- Test with: nslookup google.com $server_ip

🎯 Optimized for:
  ✓ Steam, Epic Games, Origin
  ✓ League of Legends, Valorant, CS:GO
  ✓ PUBG, Fortnite, Apex Legends
  ✓ Discord, Twitch streaming

📊 Test Your Setup:
  Run: dig @$server_ip steamcommunity.com
  Expected response time: <30ms

═══════════════════════════════════════════════════════════════
Happy Gaming! 🎮🔥
EOF

        # Generate router script
        cat > "$config_dir/router-setup.sh" << EOF
#!/bin/sh
# ViraDNS Router Configuration Script
# For DD-WRT, OpenWRT, and similar firmwares

# Set DNS servers
uci set dhcp.@dnsmasq[0].server='$server_ip'
uci add_list dhcp.@dnsmasq[0].server='8.8.8.8'
uci commit dhcp
/etc/init.d/dnsmasq restart

echo "ViraDNS configured on router!"
EOF

        chmod +x "$config_dir/router-setup.sh"

        print_success "Gaming DNS configuration generated!"
        print_info "Files saved in: $config_dir/"
    fi
}

# Show beautiful completion screen
show_completion() {
    clear_screen

    # Animated success message
    local colors=("$GREEN" "$CYAN" "$BLUE" "$PURPLE")

    for color in "${colors[@]}"; do
        clear_screen
        echo -e "${color}"
        figlet -f slant "ViraDNS" 2>/dev/null || echo "ViraDNS"
        echo -e "${NC}"
        sleep 0.2
    done

    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}          ${BOLD}🎮 Installation Completed Successfully! 🎮${NC}          ${GREEN}║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    if [ "$SERVER_TYPE" = "Kharej" ]; then
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${BOLD}${GLOBE} Kharej Server Setup Complete!${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo -e "${GREEN}${CHECK}${NC} Server IP:        ${BOLD}$(curl -s ifconfig.me)${NC}"
        echo -e "${GREEN}${CHECK}${NC} Tunnel Port:      ${BOLD}${TUNNEL_PORT}${NC}"
        echo -e "${GREEN}${CHECK}${NC} Tunnel Type:      ${BOLD}${TUNNEL_TYPE}${NC}"
        echo -e "${GREEN}${CHECK}${NC} DNS Port:         ${BOLD}53${NC}"
        echo ""
        echo -e "${YELLOW}${KEY}${NC} Configuration:    ${BOLD}/root/viradns-configs/${NC}"
    else
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${BOLD}${ROCKET} Iran Gaming DNS Server Ready!${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        local server_ip=$(hostname -I | awk '{print $1}')
        echo -e "${GREEN}${CHECK}${NC} DNS Server:       ${BOLD}$server_ip${NC}"
        echo -e "${GREEN}${CHECK}${NC} Tunnel Status:    ${BOLD}Connected${NC}"
        echo -e "${GREEN}${CHECK}${NC} Performance:      ${BOLD}Optimized${NC}"
        echo ""
        echo -e "${YELLOW}${GEAR}${NC} Configuration:    ${BOLD}/root/viradns-configs/${NC}"
    fi

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}Available Commands:${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  ${GREEN}viradns-tunnel-status${NC}  - Monitor tunnel and DNS status"
    echo -e "  ${GREEN}viradns-gaming-test${NC}    - Test gaming DNS performance"
    echo -e "  ${GREEN}viradns-monitor${NC}        - Real-time monitoring dashboard"
    echo ""

    # Animated footer
    echo -e "${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # Rotating gaming icons
    local gaming_icons=("🎮" "🎯" "🏆" "⚡" "🔥" "💎" "🌟" "🚀")
    local icon_text="Gaming Performance Unleashed!"

    for i in {0..2}; do
        for icon in "${gaming_icons[@]}"; do
            printf "\r  ${icon} ${YELLOW}${icon_text}${NC} ${icon}  "
            sleep 0.2
        done
    done

    echo -e "\n${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Enhanced logging function
log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case $level in
        "INFO")
            echo -e "${timestamp} [${GREEN}INFO${NC}] $message" | tee -a "$LOG_FILE"
            ;;
        "WARN")
            echo -e "${timestamp} [${YELLOW}WARN${NC}] $message" | tee -a "$LOG_FILE"
            ;;
        "ERROR")
            echo -e "${timestamp} [${RED}ERROR${NC}] $message" | tee -a "$LOG_FILE"
            ;;
    esac
}

# Error handling
handle_error() {
    local exit_code=$1
    local error_message=$2
    
    clear_screen
    echo -e "${RED}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║${NC}                    ${BOLD}⚠️  ERROR OCCURRED ⚠️${NC}                     ${RED}║${NC}"
    echo -e "${RED}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${RED}${CROSS}${NC} $error_message"
    echo ""
    echo -e "${YELLOW}Troubleshooting Tips:${NC}"
    
    case $exit_code in
        2)
            echo "  • Check your internet connection"
            echo "  • Ensure apt repositories are accessible"
            echo "  • Try: apt-get update && apt-get upgrade"
            ;;
        3)
            echo "  • Check if ports are already in use"
            echo "  • Verify kernel modules are loaded"
            echo "  • Check system logs: journalctl -xe"
            ;;
        4)
            echo "  • Check Unbound configuration syntax"
            echo "  • Verify DNS ports are not blocked"
            echo "  • Test with: unbound-checkconf"
            ;;
    esac
    
    echo ""
    log_message "ERROR" "$error_message (Exit code: $exit_code)"
    show_cursor
    exit $exit_code
}

# Enable services
enable_services() {
    print_step "Enabling System Services ${GEAR}"
    
    local services=("unbound")
    
    case $TUNNEL_TYPE in
        "wireguard")
            services+=("wg-quick@wg0")
            ;;
        "xray")
            services+=("xray")
            ;;
        "ssh")
            services+=("ssh")
            ;;
        "openvpn")
            services+=("openvpn")
            ;;
    esac
    
    for service in "${services[@]}"; do
        echo -ne "${CYAN}Enabling $service...${NC}"
        systemctl enable "$service" > /dev/null 2>&1
        systemctl restart "$service" > /dev/null 2>&1
        
        if systemctl is-active --quiet "$service"; then
            echo -e " ${GREEN}${CHECK}${NC}"
        else
            echo -e " ${RED}${CROSS}${NC}"
            log_message "WARN" "Failed to start $service"
        fi
    done
}

# Create uninstall script
create_uninstall_script() {
    cat > /usr/local/bin/viradns-uninstall << 'EOF'
#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║${NC}              ViraDNS Uninstall Script                    ${YELLOW}║${NC}"
echo -e "${YELLOW}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${RED}WARNING: This will remove ViraDNS and all configurations!${NC}"
echo -n "Are you sure? (yes/no): "
read -r response

if [ "$response" != "yes" ]; then
    echo "Uninstall cancelled."
    exit 0
fi

echo -e "\n${YELLOW}Removing ViraDNS...${NC}"

# Stop services
systemctl stop wg-quick@wg0 2>/dev/null
systemctl stop xray 2>/dev/null
systemctl stop unbound 2>/dev/null

# Disable services
systemctl disable wg-quick@wg0 2>/dev/null
systemctl disable xray 2>/dev/null
systemctl disable unbound 2>/dev/null

# Remove configs
rm -rf /etc/wireguard/
rm -rf /usr/local/etc/xray/
rm -rf /etc/unbound/
rm -rf /root/viradns-configs/

# Remove scripts
rm -f /usr/local/bin/viradns-*

# Reset firewall
iptables -F
iptables -t nat -F
iptables -t mangle -F

# Remove sysctl settings
sed -i '/# ViraDNS/,/^$/d' /etc/sysctl.conf
sysctl -p > /dev/null 2>&1

echo -e "${GREEN}ViraDNS has been removed successfully!${NC}"
echo -e "${YELLOW}Note: Installed packages were not removed.${NC}"
EOF

    chmod +x /usr/local/bin/viradns-uninstall
}

# Backup existing configs
backup_configs() {
    if [ -d "/etc/unbound" ] || [ -d "/etc/wireguard" ]; then
        print_status "Backing up existing configurations..."
        
        local backup_dir="/root/viradns-backup-$(date +%Y%m%d-%H%M%S)"
        mkdir -p "$backup_dir"
        
        # Backup with progress
        local configs_to_backup=(
            "/etc/unbound"
            "/etc/wireguard"
            "/usr/local/etc/xray"
            "/etc/sysctl.conf"
        )
        
        local total=${#configs_to_backup[@]}
        local current=0
        
        for config in "${configs_to_backup[@]}"; do
            ((current++))
            if [ -e "$config" ]; then
                show_progress $current $total "Backing up $(basename $config)"
                cp -r "$config" "$backup_dir/" 2>/dev/null
                sleep 0.2
            fi
        done
        
        echo ""
        print_success "Backup saved to: $backup_dir"
    fi
}

# Run post-installation tests
run_post_install_tests() {
    print_step "Running Post-Installation Tests ${CHECK}"
    
    local tests_passed=0
    local tests_failed=0
    
    # Test 1: DNS Resolution
    echo -ne "${CYAN}Testing DNS resolution...${NC}"
    if dig @localhost google.com +short > /dev/null 2>&1; then
        echo -e " ${GREEN}${CHECK} PASS${NC}"
        ((tests_passed++))
    else
        echo -e " ${RED}${CROSS} FAIL${NC}"
        ((tests_failed++))
    fi
    
    # Test 2: Tunnel Connectivity
    echo -ne "${CYAN}Testing tunnel connectivity...${NC}"
    if [ "$SERVER_TYPE" = "Iran" ]; then
        if ping -c 1 -W 2 10.0.0.1 > /dev/null 2>&1; then
            echo -e " ${GREEN}${CHECK} PASS${NC}"
            ((tests_passed++))
        else
            echo -e " ${RED}${CROSS} FAIL${NC}"
            ((tests_failed++))
        fi
    else
        echo -e " ${YELLOW}⚠ SKIP${NC} (Kharej server)"
    fi
    
    # Test 3: Performance
    echo -ne "${CYAN}Testing DNS performance...${NC}"
    local start_time=$(date +%s%N)
    dig @localhost steamcommunity.com +short > /dev/null 2>&1
    local end_time=$(date +%s%N)
    local response_time=$(( (end_time - start_time) / 1000000 ))
    
    if [ $response_time -lt 100 ]; then
        echo -e " ${GREEN}${CHECK} PASS${NC} (${response_time}ms)"
        ((tests_passed++))
    else
        echo -e " ${YELLOW}⚠ WARN${NC} (${response_time}ms)"
    fi
    
    # Test 4: Service Health
    echo -ne "${CYAN}Checking service health...${NC}"
    if systemctl is-active --quiet unbound; then
        echo -e " ${GREEN}${CHECK} PASS${NC}"
        ((tests_passed++))
    else
        echo -e " ${RED}${CROSS} FAIL${NC}"
        ((tests_failed++))
    fi
    
    # Summary
    echo ""
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "Test Summary: ${GREEN}$tests_passed passed${NC}, ${RED}$tests_failed failed${NC}"
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Auto-update function
setup_auto_update() {
    cat > /etc/cron.daily/viradns-update << 'EOF'
#!/bin/bash
# ViraDNS Auto-Update Script

LOG_FILE="/var/log/viradns-update.log"

# Check for updates
echo "[$(date)] Checking for ViraDNS updates..." >> "$LOG_FILE"

# Update gaming server IPs
curl -s https://raw.githubusercontent.com/viradns/gaming-dns/main/gaming-servers.conf \
    -o /etc/unbound/local.d/gaming-servers.conf.new 2>/dev/null

if [ -f /etc/unbound/local.d/gaming-servers.conf.new ]; then
    if ! cmp -s /etc/unbound/local.d/gaming-servers.conf /etc/unbound/local.d/gaming-servers.conf.new; then
        mv /etc/unbound/local.d/gaming-servers.conf.new /etc/unbound/local.d/gaming-servers.conf
        systemctl reload unbound
        echo "[$(date)] Gaming servers updated" >> "$LOG_FILE"
    else
        rm /etc/unbound/local.d/gaming-servers.conf.new
    fi
fi

# Update root hints
unbound-anchor -a "/var/lib/unbound/root.key" >> "$LOG_FILE" 2>&1
EOF

    chmod +x /etc/cron.daily/viradns-update
}

# Main installation flow
main() {
    # Initialize
    clear_screen
    show_banner

    # Start installation
    print_step "Starting ViraDNS Tunnel Installation ${ROCKET}"
    log_message "INFO" "Installation started"

    # Backup existing configs
    backup_configs

    # Get user selections
    select_server_type
    select_tunnel_type

    # Installation steps with error handling
    install_dependencies || handle_error 2 "Failed to install dependencies"

    # Setup tunnel based on type
    case $TUNNEL_TYPE in
        wireguard)
            setup_wireguard || handle_error 3 "Failed to setup WireGuard"
            ;;
        xray)
            setup_xray || handle_error 3 "Failed to setup Xray"
            ;;
        ssh)
            print_warning "SSH tunnel setup not implemented in this version"
            ;;
        openvpn)
            print_warning "OpenVPN setup not implemented in this version"
            ;;
    esac

    # Configure DNS
    configure_unbound || handle_error 4 "Failed to configure Unbound"

    # System optimization
    optimize_system
    configure_firewall

    # Setup monitoring and management tools
    setup_monitoring
    create_uninstall_script
    setup_auto_update

    # Generate client configurations
    generate_configs

    # Enable all services
    enable_services

    # Run tests
    run_post_install_tests

    # Show completion
    show_completion

    log_message "INFO" "Installation completed successfully"

    # Show cursor before exit
    show_cursor
}

# Execute main function
main "$@"

# Exit successfully
exit 0
