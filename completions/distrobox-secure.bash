# Bash completion script for distrobox-secure

_distrobox_secure_completions() {
    local cur prev words cword
    COMPREPLY=()
    cur="${WORDS[cword]}"
    prev="${WORDS[cword-1]}"

    # Available commands
    local commands="create grant revoke list recreate edit help"

    # Get existing containers for completion
    local containers=""
    if command -v distrobox &> /dev/null; then
        containers=$(distrobox list 2>/dev/null | tail -n +2 | awk '{print $1}' || echo "")
    fi

    # Permission types
    local perm_types="home_folder mount network x11 wayland audio gpu usb webcam unshare_netns unshare_devsys unshare_groups unshare_ipc unshare_process unshare_all privileged root init hostname cap_add security_opt"

    # Handle completion based on command and position
    if [[ $cword -eq 1 ]]; then
        # Complete first argument (commands)
        COMPREPLY=($(compgen -W "$commands" -- "$cur"))
    else
        case "$prev" in
            create)
                # Complete container name or show containers
                if [[ $cword -eq 2 ]]; then
                    # Allow custom names (no completion)
                    return 0
                fi
                ;;
            grant|revoke|list|recreate)
                if [[ $cword -eq 2 ]]; then
                    # Complete container name
                    COMPREPLY=($(compgen -W "$containers" -- "$cur"))
                elif [[ $cword -eq 3 ]] && [[ "$prev" == "grant" ]]; then
                    # Complete permission type for grant
                    COMPREPLY=($(compgen -W "$perm_types" -- "$cur"))
                fi
                ;;
        esac
    fi

    return 0
}

# Register the completion function
complete -o bashdefault -o default -o nospace -F _distrobox_secure_completions distrobox-secure
