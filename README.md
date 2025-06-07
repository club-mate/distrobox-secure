# Distrobox Secure

A comprehensive security-first wrapper for Distrobox that creates hardened container instances with isolated home directories, complete namespace isolation, and a granular opt-in permission system.

## 🔒 Security Philosophy

Traditional Distrobox containers have access to your entire home directory, network, and system resources by default. **Distrobox Secure** implements a zero-trust model:

- **Maximum isolation by default**: All namespaces isolated (network, process, IPC, groups, dev/sys)
- **Isolated environments**: Each container gets its own home directory
- **Opt-in permissions**: Every access must be explicitly granted
- **Comprehensive control**: Manage all aspects of container security

## ✨ Enhanced Features

### 🛡️ Complete Security Hardening
- **Isolated home directories** - No access to your real home folder
- **Network namespace isolation** - Containers start completely network-isolated
- **Process isolation** - Containers can't see host processes
- **IPC isolation** - No inter-process communication with host
- **Device/System isolation** - No access to /dev and /sys
- **Group isolation** - Container groups isolated from host
- **Capability dropping** - Removes all Linux capabilities by default
- **Privilege restrictions** - Prevents privilege escalation attacks

### 🎛️ Comprehensive Permission Management
- **Filesystem access** - Grant access to specific folders only
- **Network control** - Enable host or bridge networking when needed
- **Hardware access** - Opt-in GPU, audio, USB, and webcam support
- **Display forwarding** - Controlled X11/Wayland access
- **Custom mounts** - Mount external drives securely
- **Namespace controls** - Fine-tune isolation levels
- **Security options** - Advanced capability and security management

### 📋 Easy Management
- Simple command-line interface
- Comprehensive configuration file
- Container recreation with current permissions
- Permission auditing and validation

## 🚀 Quick Start

### Installation

1. **Prerequisites**: Ensure you have `distrobox` and `podman` installed
2. **Download**: Save the script as `distrobox-secure`
3. **Make executable**: `chmod +x distrobox-secure`
4. **Optional**: Move to your PATH for global access

### Basic Usage

```bash
# Create a new secure container (Ubuntu 22.04 by default)
./distrobox-secure create myproject

# Grant access to your Documents folder
./distrobox-secure grant myproject home_folder /home/user/Documents

# Enable networking (disabled by default)
./distrobox-secure grant myproject network host

# Enable GUI applications
./distrobox-secure grant myproject x11 enable

# Apply the new permissions
./distrobox-secure recreate myproject

# Enter your secure container
distrobox enter myproject
```

## 📖 Comprehensive Permission System

### Filesystem Permissions

| Permission | Value | Description |
|------------|-------|-------------|
| `home_folder` | `/path/to/folder` | Mount specific host directory |
| `mount` | `/src/path:/dst/path` | Mount with custom destination |

### Network Permissions

| Permission | Value | Description |
|------------|-------|-------------|
| `network` | `host` | Enable host networking |
| `network` | `bridge` | Enable bridge networking |

### Display Permissions

| Permission | Value | Description |
|------------|-------|-------------|
| `x11` | `enable` | Enable X11 forwarding for GUI apps |
| `wayland` | `enable` | Enable Wayland support |

### Hardware Permissions

| Permission | Value | Description |
|------------|-------|-------------|
| `audio` | `enable` | Enable audio passthrough |
| `gpu` | `enable` | Enable GPU access (NVIDIA + AMD) |
| `usb` | `enable` | Enable USB device access |
| `webcam` | `enable` | Enable webcam access |

### Namespace Isolation Controls

| Permission | Value | Description |
|------------|-------|-------------|
| `unshare_netns` | `false` | Disable network namespace isolation |
| `unshare_devsys` | `false` | Disable /dev and /sys isolation |
| `unshare_groups` | `false` | Disable group isolation |
| `unshare_ipc` | `false` | Disable IPC isolation |
| `unshare_process` | `false` | Disable process isolation |
| `unshare_all` | `false` | Disable all namespace isolation |

### Security Permissions (Use with Caution)

| Permission | Value | Description |
|------------|-------|-------------|
| `privileged` | `enable` | Run in privileged mode |
| `root` | `enable` | Allow root access |
| `init` | `enable` | Enable init system |
| `hostname` | `custom_name` | Set custom hostname |
| `cap_add` | `SYS_ADMIN` | Add specific capabilities |
| `security_opt` | `seccomp=unconfined` | Modify security options |

## 🛠️ Detailed Usage Examples

### AI Development Environment
```bash
# Create secure AI development container
distrobox-secure create ai-dev

# Grant access to projects and datasets
distrobox-secure grant ai-dev home_folder /home/user/AI-Projects
distrobox-secure grant ai-dev home_folder /home/user/Datasets

# Enable networking for package installation
distrobox-secure grant ai-dev network host

# Enable GPU for ML workloads
distrobox-secure grant ai-dev gpu enable

# Apply and enter
distrobox-secure recreate ai-dev
distrobox enter ai-dev
```

### Secure Development Environment
```bash
# Create with specific distribution
distrobox-secure create webdev docker.io/library/node:18

# Grant minimal access
distrobox-secure grant webdev home_folder /home/user/WebProjects
distrobox-secure grant webdev network bridge

# Keep maximum isolation for other namespaces
distrobox-secure recreate webdev
```

### Media Processing Container
```bash
distrobox-secure create media

# Grant access to media folders
distrobox-secure grant media home_folder /home/user/Videos
distrobox-secure grant media home_folder /home/user/Pictures

# Enable hardware acceleration
distrobox-secure grant media gpu enable
distrobox-secure grant media audio enable

# Enable GUI for media apps
distrobox-secure grant media x11 enable

distrobox-secure recreate media
```

### Maximum Security Browser
```bash
distrobox-secure create browser

# Enable only essential permissions
distrobox-secure grant browser x11 enable
distrobox-secure grant browser audio enable
distrobox-secure grant browser network host

# Grant access to Downloads only
distrobox-secure grant browser home_folder /home/user/Downloads

# Keep all other isolations active
distrobox-secure recreate browser
```

### Debugging/Development Container
```bash
distrobox-secure create debug

# Grant broader access for debugging
distrobox-secure grant debug unshare_process false
distrobox-secure grant debug unshare_ipc false
distrobox-secure grant debug network host

# Add debugging capabilities
distrobox-secure grant debug cap_add SYS_PTRACE

distrobox-secure recreate debug
```

## 🏗️ Architecture & Configuration

### Directory Structure
```
~/.local/share/distrobox-secure/
├── container1-home/          # Isolated home for container1
├── container2-home/          # Isolated home for container2
└── ...

~/.config/distrobox-secure/
└── permissions.conf          # Permission configuration
```

### Permission Configuration File

The `permissions.conf` file supports comprehensive permission management:

```bash
# Filesystem access
mycontainer:home_folder:/home/user/Documents
mycontainer:mount:/media/external:/mnt/external

# Network access
mycontainer:network:host

# Hardware access
mycontainer:audio:enable
mycontainer:gpu:enable

# Reduce isolation (enable host access)
mycontainer:unshare_netns:false
mycontainer:unshare_process:false

# Security modifications (use carefully)
mycontainer:cap_add:SYS_ADMIN
```

## 🎯 Advanced Use Cases

### Isolated Development with Selective Access
```bash
# Create container with custom image
distrobox-secure create backend docker.io/library/golang:1.21

# Grant access to specific project only
distrobox-secure grant backend home_folder /home/user/go-projects/backend-api

# Enable network but keep other isolations
distrobox-secure grant backend network bridge

# Keep process isolation for security
# (unshare_process stays true by default)

distrobox-secure recreate backend
```

### Security Research Environment
```bash
distrobox-secure create research

# Enable broader system access for research
distrobox-secure grant research unshare_devsys false
distrobox-secure grant research cap_add SYS_ADMIN
distrobox-secure grant research network host

# But keep home directory isolated
# (no home_folder grants)

distrobox-secure recreate research
```

## 🔍 Security Model

### Default Isolation (Maximum Security)
- ✅ **Network**: Completely isolated (no internet access)
- ✅ **Processes**: Cannot see host processes
- ✅ **IPC**: No inter-process communication with host
- ✅ **Groups**: Container groups isolated from host
- ✅ **Devices**: No access to /dev or /sys
- ✅ **Home**: Isolated home directory
- ✅ **Capabilities**: All Linux capabilities dropped
- ✅ **Privileges**: No privilege escalation possible

### What Requires Explicit Permission
- 🔐 Network access (any kind)
- 🔐 Access to any host directory
- 🔐 GUI applications (X11/Wayland)
- 🔐 Audio devices
- 🔐 GPU/Hardware acceleration
- 🔐 USB devices
- 🔐 System capabilities
- 🔐 Process visibility
- 🔐 IPC communication

### Security Considerations
- 🤔 Containers still share the kernel (use gVisor/Kata for stronger isolation)
- 🤔 Root inside container is still root (use rootless podman)
