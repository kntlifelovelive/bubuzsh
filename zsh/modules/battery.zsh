# ~/.config/zsh/functions/battery.zsh

battery_status() {
    if [[ -f /sys/class/power_supply/BAT0/capacity ]]; then
        local cap=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)
        local bat_status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null)
        
        if [[ -z "$cap" ]]; then
            echo ""
            return
        fi
        
        # Select icon based on percentage
        local icon=""
        if [[ $cap -ge 95 ]]; then
            icon="󰁹"   # Full
        elif [[ $cap -ge 90 ]]; then
            icon="󰂁"   # 90-95%
        elif [[ $cap -ge 80 ]]; then
            icon="󰂀"   # 80-90%
        elif [[ $cap -ge 70 ]]; then
            icon="󰁿"   # 70-80%
        elif [[ $cap -ge 60 ]]; then
            icon="󰁾"   # 60-70%
        elif [[ $cap -ge 50 ]]; then
            icon="󰁽"   # 50-60%
        elif [[ $cap -ge 40 ]]; then
            icon="󰁼"   # 40-50%
        elif [[ $cap -ge 30 ]]; then
            icon="󰁻"   # 30-40%
        elif [[ $cap -ge 20 ]]; then
            icon="󰁺"   # 20-30%
        elif [[ $cap -ge 10 ]]; then
            icon="󰂉"   # 10-20%
        else
            icon="󰂎"   # <10% Critical
        fi
        
        # Color coding based on battery level and status
        if [[ "$bat_status" == "Charging" ]]; then
            icon="󰂄"   # Charging lightning bolt
            echo "%F{green}${icon}%f"           # Green for charging
        elif [[ "$bat_status" == "Full" ]]; then
            echo "%F{green}${icon}%f"           # Green for full
        elif [[ $cap -lt 10 ]]; then
            echo "%F{red}${icon}%f"             # Red for critical
        elif [[ $cap -lt 20 ]]; then
            echo "%F{yellow}${icon}%f"          # Yellow for low
        elif [[ $cap -lt 30 ]]; then
            echo "%F{208}${icon}%f"             # Orange for warning
        else
            echo "%F{cyan}${icon}%f"            # Cyan for normal
        fi
    else
        # No battery (desktop)
        echo "%F{blue}󰒒%f"                     # Blue plug icon
    fi
}
