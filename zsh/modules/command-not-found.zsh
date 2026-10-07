# ~/.config/zsh/functions/command-not-found.zsh

command_not_found_handler() {
    local cmd="$1"
    
    # Phase 1 Step 5 — CNF safety:
    # Only run the interactive y/N prompt when the shell is interactive AND
    # both stdin and stdout are real terminals. Inside command substitutions
    # $( ... ) stdout is a pipe (invisible) while stdin may still be the
    # terminal — reading there silently blocks startup or the prompt
    # (docs/PHASE-00-AUDIT.md bug #7). In every other context just print a
    # plain message and return 127 without ever reading input.
    if [[ ! -o interactive || ! -t 0 || ! -t 1 ]]; then
        echo -e "󰅙 \e[1;31mCommand not found:\e[0m \e[1;33m$cmd\e[0m" >&2
        return 127
    fi
    
    if command -v pacman &>/dev/null; then
        # Print prompt without newline
        echo -n "󰅙 \e[1;31mCommand not found:\e[0m \e[1;33m$cmd\e[0m"
        echo -n " 󰔟 \e[1;33mSearch Package?\e[0m [\e[1;32my\e[0m/\e[1;31mN\e[0m] "
        
        # Read one character on the same line
        local choice
        read -k1 choice
        echo  # new line after input
        
        # Only proceed if user pressed 'y' or 'Y'
        if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
            echo -e "󰊢 \e[1;34mSearching repositories...\e[0m"
            
            # Search for exact match first
            local results=$(pacman -Ss "^$cmd$" 2>/dev/null | head -3)
            
            # If no exact match, do partial search
            if [[ -z "$results" ]]; then
                results=$(pacman -Ss "$cmd" 2>/dev/null | head -3)
            fi
            
            if [[ -n "$results" ]]; then
                local pkg_name=$(echo "$results" | grep -E "^[^/]+/" | head -1 | awk '{print $1}' | cut -d'/' -f2)
                if [[ -z "$pkg_name" ]]; then
                    pkg_name="$cmd"
                fi
                
                echo -e "󰊄 \e[1;32mFound:\e[0m \e[1;36m$pkg_name\e[0m"
                echo ""
                echo -n "󰔟 \e[1;33mInstall $pkg_name?\e[0m [\e[1;32my\e[0m/\e[1;31mN\e[0m] "
                
                local choice2
                read -k1 choice2
                echo
                
                if [[ "$choice2" == "y" || "$choice2" == "Y" ]]; then
                    echo -e "󰊄 \e[1;32mInstalling $pkg_name...\e[0m"
                    sudo pacman -S "$pkg_name"
                else
                    echo -e "󰅙 \e[1;33mSkipped\e[0m"
                fi
            else
                echo -e "󰅙 \e[1;31mNo packages found for '$cmd'\e[0m"
                echo -e "󰊢 \e[1;34mTry: pacman -Ss $cmd\e[0m"
            fi
        else
            echo -e "󰅙 \e[1;33mCancelled\e[0m"
        fi
    else
        echo -e "󰅙 \e[1;31mCommand not found:\e[0m \e[1;33m$cmd\e[0m"
    fi
    
    return 127
}
