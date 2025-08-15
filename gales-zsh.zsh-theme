# Get current time in milliseconds (works everywhere)
get_ms_time() {
    perl -MTime::HiRes=time -e 'printf("%.0f\n", time()*1000)'
}
NEWLINE=$'\n'
# Run before each command
function preexec() {
    __START_TIME=$(get_ms_time)
}

# Run before prompt is drawn
function precmd() {
    local now duration
    now=$(get_ms_time)
    if [[ -n $__START_TIME ]]; then
        duration=$((now - __START_TIME))
        CMD_DURATION="${duration}ms"
    else
        CMD_DURATION=""
    fi
}

# --- Colors ---
user_color="%F{red}%B"       # Bold red
in_color="%F{white}%B"       # Bold white
dir_color="%F{magenta}%B"    # Bold purple
git_color="%F{cyan}%B"       # Bold cyan
time_color="%F{green}%B"     # Bold green
clock_color="%F{blue}%B"     # Bold blue
env_color="%F{61}%B"         # Indigo
prompt_symbol_color="%F{red}%B"
reset_color="%f%b"

# Build the prompt
function build_prompt() {
    local username_part

    if [[ -n "$CONDA_DEFAULT_ENV" ]]; then
        username_part="${env_color}(${CONDA_DEFAULT_ENV})${reset_color}${user_color}%n"
    elif [[ -n "$VIRTUAL_ENV" ]]; then
        username_part="${env_color}($(basename "$VIRTUAL_ENV"))${reset_color}${user_color}%n"
    else
        username_part="${user_color}%n"
    fi

    PROMPT="${user_color}╭─${username_part}@[%m]${in_color} in${dir_color} %~"
    PROMPT+=" ${git_color}\$vcs_info_msg_0_${reset_color}"

    if [[ -n "$CMD_DURATION" ]]; then
        PROMPT+=" ${time_color}took ${CMD_DURATION}${reset_color}"
    fi

    PROMPT+=" ${clock_color}%*${reset_color}${NEWLINE}${prompt_symbol_color}╰─⌭${reset_color} "
}

# Enable git branch display
autoload -Uz vcs_info
zstyle ':vcs_info:git:*' formats '[%b]'
zstyle ':vcs_info:*' enable git

# Hook into Zsh's lifecycle
precmd_functions+=(vcs_info build_prompt)

