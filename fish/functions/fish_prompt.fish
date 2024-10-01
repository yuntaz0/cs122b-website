function fish_prompt --description 'Write out the prompt'
    set -l last_status $status
    set -l normal (set_color normal)
    set -l prompt_color (set_color ff8899) # Anon
    set -l status_color (set_color 77dd77 --bold) # Rena
    set -l vcs_color (set_color ae81ff) # Monokai Rikki
    set -l prompt_status ""
    set -l suffix '$'
    # Color setting for `sed`
    # set -l color_container (printf '\e[38;2;255;216;102m')
    set -l color_reset (printf '\e[0m')
    set -l color_slash (printf '\e[38;2;102;217;239m') # Monokai Tomori
    # Var for `set`
    set -l iam (whoami)

    # Color the prompt in red on error
    if test $last_status -ne 0
        set status_color (set_color f92672 --bold) # Monokai Anon
    end
    # Print # if it is root
    if fish_is_root_user
        set -l suffix '#'
    end

    set prompt_status $status_color "[" $last_status "]" $normal

    set -g __fish_git_prompt_showuntrackedfiles 1
    set -g __fish_git_prompt_show_informative_status 1
    set -g __fish_git_prompt_showupstream verbose
    set -g __fish_git_prompt_char_cleanstate " OK "
    set -g __fish_git_prompt_char_dirtystate " Dirty="
    set -g __fish_git_prompt_char_invalidstate " Invalid "
    set -g __fish_git_prompt_char_stagedstate " Staged="
    set -g __fish_git_prompt_char_stashstate " Stash"
    set -g __fish_git_prompt_char_untrackedfiles " Untracked="

    set -g fish_prompt_pwd_dir_length 3
    set -g fish_prompt_pwd_full_dirs 6

    # New line
    echo ''

    # toolbox environment
    if test -e /run/.toolboxenv && set -l toolbox_name $(string match -rg 'name="(.*)"' </run/.containerenv)
        echo -n -s $prompt_color $iam $normal '@' $prompt_color $toolbox_name ' '
    # AWS cloud environment
    else if test -e /var/log/cloud-init.log
        echo -n -s $prompt_color $iam $normal '@' $prompt_color $hostname ' '
    end
    echo -s $prompt_status ' ' $status_color $suffix $vcs_color (fish_git_prompt) $normal
    # current directory
    echo -s '🧭 ' $normal (prompt_pwd | sed "s#/var/home/$iam#~#" | sed "s#/#$color_slash/$color_reset#g")
    echo ''
end
