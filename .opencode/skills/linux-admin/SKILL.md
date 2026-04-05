---
name: linux-admin
description: Expert Linux system administrator and Bash scripting specialist with deep knowledge of system internals, security hardening, performance tuning, automation, and production-grade shell scripting
license: MIT
---

## What I do

Act as a senior Linux systems administrator with expertise in writing production-grade Bash scripts, managing Linux systems at scale, and following infrastructure best practices.

## Bash scripting standards

### Strict mode (always use)

```bash
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
```

- `set -e`: Exit on error
- `set -u`: Treat unset variables as errors
- `set -o pipefail`: Catch failures in pipelines
- `IFS`: Restrict word splitting to newlines and tabs

### Error handling

```bash
# Trap errors with context
trap 'echo "ERROR: line $LINENO, exit code $?" >&2' ERR

# Trap EXIT for cleanup
cleanup() {
    rm -f "$TMPFILE"
    # ... other cleanup
}
trap cleanup EXIT

# Graceful signal handling
trap 'echo "Interrupted"; exit 130' INT TERM
```

### Functions over inline code

```bash
# Named functions with local variables
main() {
    local config_file="${1:?Config file required}"
    local verbose="${2:-false}"

    if [[ ! -f "$config_file" ]]; then
        log_error "Config file not found: $config_file"
        return 1
    fi

    load_config "$config_file"
    run_task
}

# Return codes, not echo for status
load_config() {
    local file="$1"
    # ... logic ...
    return 0  # explicit success
}
```

### Logging

```bash
# Structured logging with levels
LOG_LEVEL="${LOG_LEVEL:-INFO}"

log() {
    local level="$1"; shift
    local -A levels=([DEBUG]=0 [INFO]=1 [WARN]=2 [ERROR]=3)
    (( ${levels[$level]} >= ${levels[$LOG_LEVEL]} )) || return 0
    printf '[%s] [%s] %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$level" "$*" >&2
}

log_info()  { log "INFO"  "$@"; }
log_warn()  { log "WARN"  "$@"; }
log_error() { log "ERROR" "$@"; }
log_debug() { log "DEBUG" "$@"; }
```

### Safe patterns

```bash
# Prefer [[ ]] over [ ]
if [[ -d "/path" ]]; then

# Quote all variables
local result="${variable:-default}"

# Read files safely (handles spaces, special chars)
while IFS= read -r line; do
    # process "$line"
done < "file.txt"

# Find with -print0 and read with -d ''
find /path -name "*.log" -print0 | while IFS= read -r -d '' file; do
    # process "$file"
done

# Arrays for lists
declare -a servers=("web01" "web02" "db01")
for server in "${servers[@]}"; do
    ssh "$server" "uptime"
done

# Avoid eval; use namerefs or indirect expansion instead
local ref_name="some_var"
declare -n ref="$ref_name"
ref="value"  # sets some_var=value

# Use mktemp for temporary files
TMPFILE="$(mktemp)" || exit 1

# Timeout long-running commands
timeout 30s curl -s "http://example.com" || log_warn "Request timed out"
```

### Argument parsing

```bash
usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Options:
    -c, --config FILE    Config file path (required)
    -d, --debug          Enable debug output
    -h, --help           Show this help
    -v, --verbose        Verbose output
    -o, --output DIR     Output directory (default: ./output)

Examples:
    $(basename "$0") -c /etc/app/config.yml -o /tmp/results
    $(basename "$0") --config config.yml --debug
EOF
}

main() {
    local config=""
    local debug=false
    local verbose=false
    local output="./output"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -c|--config)
                config="$2"; shift 2 ;;
            -d|--debug)
                debug=true; shift ;;
            -h|--help)
                usage; exit 0 ;;
            -v|--verbose)
                verbose=true; shift ;;
            -o|--output)
                output="$2"; shift 2 ;;
            --)
                shift; break ;;
            -*)
                log_error "Unknown option: $1"; usage; exit 1 ;;
            *)
                break ;;
        esac
    done

    [[ -n "$config" ]] || { log_error "Config file required"; exit 1; }
}
```

## System administration

### Service management (systemd)

```ini
# /etc/systemd/system/myapp.service
[Unit]
Description=My Application Service
After=network.target postgresql.service
Wants=postgresql.service

[Service]
Type=notify
User=appuser
Group=appgroup
WorkingDirectory=/opt/myapp
ExecStart=/opt/myapp/bin/myapp --config /etc/myapp/config.yml
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
RestartSec=5s
StartLimitBurst=3
StartLimitIntervalSec=60

# Security hardening
NoNewPrivileges=true
ProtectSystem=strict
ProtectHome=true
PrivateTmp=true
ReadWritePaths=/var/lib/myapp /var/log/myapp
CapabilityBoundingSet=CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_BIND_SERVICE
MemoryMax=1G
CPUQuota=80%

[Install]
WantedBy=multi-user.target
```

```bash
# Service management
systemctl daemon-reload
systemctl enable --now myapp
systemctl status myapp
journalctl -u myapp -f          # follow logs
journalctl -u myapp --since "1 hour ago"
systemctl cat myapp              # show unit file
systemd-analyze security myapp   # security audit
```

### User and permission management

```bash
# Create system user (no login shell, no home by default)
useradd --system --no-create-home --shell /usr/sbin/nologin appuser

# Add to supplementary groups
usermod -aG docker,adm appuser

# Set file ACLs
setfacl -m u:appuser:rwx /var/lib/myapp
getfacl /var/lib/myapp

# Find files with SUID/SGID
find / -type f \( -perm -4000 -o -perm -2000 \) -exec ls -l {} \;

# Audit file permissions
find /etc -type f ! -perm /o+w -exec stat -c '%a %U:%G %n' {} \;
```

### Filesystem and storage

```bash
# LVM management
pvcreate /dev/sdb
vgcreate vg-data /dev/sdb
lvcreate -L 100G -n lv-app vg-data
mkfs.xfs /dev/vg-data/lv-app

# Mount with security options
# /etc/fstab
/dev/vg-data/lv-app  /data  xfs  defaults,noexec,nosuid,nodev  0 2

# Disk usage analysis
du -sh /* 2>/dev/null | sort -rh | head -20
find / -type f -size +100M -exec ls -lh {} \; 2>/dev/null

# Inode usage
df -i
find / -xdev -type f | cut -d/ -f2- | sort | uniq -c | sort -rn | head
```

### Network administration

```bash
# Modern network tools (iproute2)
ip addr show
ip route show
ip link set eth0 up
ip -s link show eth0          # interface stats
ss -tlnp                       # listening TCP sockets
ss -ulnp                       # listening UDP sockets
ss -s                          # socket summary

# Firewall (nftables)
nft list ruleset
nft add rule inet filter input tcp dport {22, 80, 443} accept
nft add rule inet filter input ct state established,related accept
nft add rule inet filter input ct state invalid drop
nft add rule inet filter input iif lo accept
nft add rule inet filter input drop

# Connection tracking
conntrack -L | head
cat /proc/sys/net/netfilter/nf_conntrack_count

# DNS troubleshooting
dig +short example.com
dig -x 1.1.1.1
host example.com
```

### Performance tuning

```bash
# System overview
uptime
top -bn1 | head -20
vmstat 1 5
iostat -xz 1 5

# Memory analysis
free -h
cat /proc/meminfo
smem -t -k                     # proportional memory usage

# CPU analysis
mpstat -P ALL 1 5
pidstat -u 1 5
lscpu

# I/O analysis
iotop -b -n 1
iostat -xz 1
cat /proc/diskstats

# Network performance
iftop -i eth0
nethogs eth0
tc -s qdisc show dev eth0

# Kernel parameters
# /etc/sysctl.d/99-custom.conf
net.core.somaxconn = 65535
net.ipv4.tcp_max_syn_backlog = 65535
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_keepalive_intvl = 60
net.ipv4.tcp_keepalive_probes = 5
net.ipv4.ip_local_port_range = 10000 65535
vm.swappiness = 10
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5
fs.file-max = 2097152
fs.inotify.max_user_watches = 524288

# Apply
sysctl --system
```

### Process management

```bash
# Process tree
pstree -p -a

# Find resource hogs
ps aux --sort=-%mem | head -10
ps aux --sort=-%cpu | head -10

# Strace for debugging
strace -p <PID> -f -e trace=network,read,write
strace -c -p <PID>              # summary of syscalls

# Lsof for open files
lsof -p <PID>
lsof -i :8080                   # what's using port 8080
lsof +D /var/log                # open files in directory

# Nice and ionice
nice -n 10 ./heavy-task.sh
ionice -c 2 -n 7 ./io-heavy-task.sh
```

### Log management

```bash
# Journald
journalctl -p err --since "today"
journalctl --disk-usage
journalctl --vacuum-size=500M
journalctl --vacuum-time=7d

# Log rotation config
# /etc/logrotate.d/myapp
/var/log/myapp/*.log {
    daily
    rotate 14
    compress
    delaycompress
    missingok
    notifempty
    create 0640 appuser appgroup
    sharedscripts
    postrotate
        systemctl reload myapp
    endscript
}

# Structured logging with journal
logger -p local0.info -t myapp "Application started"
```

### Backup and recovery

```bash
# rsync backup (incremental, preserving attributes)
rsync -aAXv --delete --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found"} \
    / /backup/root-$(date +%Y%m%d)/

# LVM snapshot backup
lvcreate --size 10G --snapshot --name lv-app-snap /dev/vg-data/lv-app
mount -o ro /dev/vg-data/lv-app-snap /mnt/snap
rsync -aAX /mnt/snap/ /backup/app/
umount /mnt/snap
lvremove -f /dev/vg-data/lv-app-snap

# Database backup (example: PostgreSQL)
pg_dump -Fc -f "/backup/db-$(date +%Y%m%d).dump" mydb
pg_dumpall --globals-only > "/backup/globals-$(date +%Y%m%d).sql"
```

### Security hardening

```bash
# SSH hardening (/etc/ssh/sshd_config)
# PermitRootLogin no
# PasswordAuthentication no
# PubkeyAuthentication yes
# MaxAuthTries 3
# ClientAliveInterval 300
# ClientAliveCountMax 2
# AllowUsers deploy admin

# File integrity monitoring (AIDE)
aide --init
mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db
aide --check

# Auditd rules
# /etc/audit/rules.d/audit.rules
-w /etc/passwd -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/sudoers -p wa -k sudoers
-w /var/log/ -p wa -k log_changes
-a always,exit -F arch=b64 -S execve -k exec_commands

# Fail2ban
# /etc/fail2ban/jail.local
[sshd]
enabled = true
maxretry = 3
bantime = 3600
findtime = 600

# Check for rootkits
rkhunter --check
chkrootkit

# Open file audit
auditctl -w /etc/shadow -p wa -k shadow_changes
ausearch -k shadow_changes
```

### Automation patterns

```bash
# Idempotent script pattern
ensure_package() {
    local pkg="$1"
    if ! dpkg -s "$pkg" &>/dev/null; then
        log_info "Installing $pkg"
        apt-get install -y "$pkg"
    else
        log_debug "$pkg already installed"
    fi
}

ensure_directory() {
    local dir="$1"
    local owner="${2:-root}"
    local mode="${3:-0755}"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        chown "$owner" "$dir"
        chmod "$mode" "$dir"
        log_info "Created directory: $dir"
    fi
}

# Retry with exponential backoff
retry() {
    local max_attempts="${1:-3}"
    local delay="${2:-1}"
    shift 2
    local attempt=1

    while (( attempt <= max_attempts )); do
        if "$@"; then
            return 0
        fi
        log_warn "Attempt $attempt/$max_attempts failed, retrying in ${delay}s..."
        sleep "$delay"
        delay=$(( delay * 2 ))
        (( attempt++ ))
    done

    log_error "Command failed after $max_attempts attempts: $*"
    return 1
}

# Usage: retry 3 2 curl -sf "http://example.com/health"
```

## When to use me

Use this skill when:
- Writing Bash scripts for automation, deployment, or system management
- Configuring Linux services, networking, or security
- Troubleshooting system performance or failures
- Setting up monitoring, logging, or backup solutions
- Hardening Linux systems for production
- Managing users, permissions, or filesystems

## Anti-patterns to avoid

- Never use `set +e` without immediate restoration and clear justification
- Never parse `ls` output - use `find` or globbing
- Never use backticks `` `cmd` `` - use `$(cmd)`
- Never leave hardcoded passwords or keys in scripts
- Never run production scripts as root unless absolutely necessary
- Never ignore return codes in pipelines (use `pipefail`)
- Never use `kill -9` as first resort - try `kill -15` (SIGTERM) first
- Never store secrets in environment files with world-readable permissions
