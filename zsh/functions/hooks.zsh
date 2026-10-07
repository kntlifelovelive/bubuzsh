# ~/.config/zsh/functions/hooks.zsh
# Custom hooks for different events

# Before each command
preexec() {
    # Track command start time (seconds only)
    cmd_start_time=$(date +%s)
}

# After each command
precmd() {
    # Calculate command duration
    if [[ -n $cmd_start_time ]]; then
        local duration=$(($(date +%s) - cmd_start_time))
        
        # Only show if command took more than 5 seconds
        if [[ $duration -gt 5 ]]; then
            # Convert to minutes and seconds
            local minutes=$((duration / 60))
            local seconds=$((duration % 60))
            
            # Choose color for the numeric part based on duration
            local time_color=""
            if [[ $duration -lt 10 ]]; then
                time_color="\e[1;32m"      # Green bold (6-9 sec)
            elif [[ $duration -lt 60 ]]; then
                time_color="\e[1;33m"      # Yellow bold (10-59 sec)
            else
                time_color="\e[1;31m"      # Red bold (>=60 sec)
            fi
            
            # Deep blue bold for the label
            local label_color="\e[1;34m"
            local reset="\e[0m"
            
            # Build the time string with correct plural forms (no parentheses)
            local time_str=""
            if [[ $minutes -gt 0 ]]; then
                local minute_word="minute"
                [[ $minutes -gt 1 ]] && minute_word="minutes"
                local second_word="second"
                [[ $seconds -gt 1 ]] && second_word="seconds"
                time_str="${minutes} ${minute_word} ${seconds} ${second_word}"
            else
                local second_word="second"
                [[ $seconds -gt 1 ]] && second_word="seconds"
                time_str="${seconds} ${second_word}"
            fi
            
            # Output with blank lines (like before)
            echo ""
            echo -e "${time_color}⏱️ ${label_color}Command run time:${reset} ${time_color}${time_str}${reset}"
            echo ""
        fi
        unset cmd_start_time
    fi
}
