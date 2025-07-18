# ~/.bash_it/themes/lambda/lambda.theme.bash
# -------------------------------------------------------------------
# Lambda Theme (Custom)
# Clean, 2-line Bash prompt with:
# - Active virtual/conda environment (indigo color)
# - Username (bold red)
# - Working directory (purple)
# - Git branch (cyan)
# - Command duration (green)
# - Clock (blue)
# -------------------------------------------------------------------

# ⏱️ Start timing each command
trap 'export __START_TIME=$(date +%s%3N)' DEBUG

# Hook into command execution
PROMPT_COMMAND='__update_prompt'

# -------------------------------------------------------------------
# Update prompt and calculate duration
# -------------------------------------------------------------------
function __update_prompt() {
    local now end_time duration
    now=$(date +%s%3N)
    end_time=${__START_TIME:-$now}
    duration=$((now - end_time))

    export CMD_DURATION=$duration
    set_prompt
}

# -------------------------------------------------------------------
# Main prompt function
# -------------------------------------------------------------------
function set_prompt {
    # --- Color Definitions ---
    local user_color="\[\033[1;31m\]"          # Bold red
    local in_color="\[\033[1;37m\]"            # Bold white
    local dir_color="\[\033[1;35m\]"           # Bold purple
    local git_color="\[\033[1;36m\]"           # Bold cyan
    local time_color="\[\033[1;32m\]"          # Bold green
    local clock_color="\[\033[1;34m\]"         # Bold blue
    local env_color="\[\033[38;5;61m\]"        # Indigo (Truecolor not needed)
    local prompt_symbol_color="\[\033[1;31m\]" # Bold red
    local reset_color="\[\033[0m\]"            # Reset all attributes

    # --- Username with virtualenv/conda environment ---
    local username_part=""
    if [[ -n "$CONDA_DEFAULT_ENV" ]]; then
        username_part="${env_color}(${CONDA_DEFAULT_ENV})${reset_color}${user_color}\\u"
    elif [[ -n "$VIRTUAL_ENV" ]]; then
        username_part="${env_color}($(basename "$VIRTUAL_ENV"))${reset_color}${user_color}\\u"
    else
        username_part="${user_color}\\u"
    fi

    # --- Assemble PS1 ---
    PS1="${user_color}╭─${username_part}${in_color} in${dir_color} \\w"        # Line 1: env + user + path
    PS1+=" ${git_color}\$(__git_ps1 '[%s]')${reset_color}"        # Git info

    if [[ -n "$CMD_DURATION" && "$CMD_DURATION" -gt 0 ]]; then
        PS1+=" ${time_color}took ${CMD_DURATION}ms${reset_color}" # Command time
    fi

    PS1+=" ${clock_color}\A${reset_color}"                        # Clock

    PS1+="\n${prompt_symbol_color}╰─⌭${reset_color} "             # Line 2: prompt symbol
}

