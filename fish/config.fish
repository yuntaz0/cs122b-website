if status is-interactive
    # Commands to run in interactive sessions can go here
end

# set default text editor
type -q nvim
if test $status -eq 0
    set -gx EDITOR nvim
else
    set -gx EDITOR nano
end

# set command color
set -U fish_color_command a6e22e --bold # Monokai Rena
set -U fish_color_error f92672 --bold # Monokai Anon
set -U fish_color_quote ffdd88 # Soyo
set -U fish_color_redirection ff8899 --bold # Anon
set -U fish_color_end ff8899 --bold
set -U fish_color_comment 7777aa # Rikki
set -U fish_color_param fd971f # Monokai Soyo

set -U fish_color_operator 66d93f --bold # Monokai Tomori
set -U fish_color_escape 66d9ef --bold # Monokai Tomori

# keyboard shortcut: Go to parent dir with ALT + UP
bind \e\[1\;3A "cd ..; commandline -f repaint"

# Add local bin path
fish_add_path ~/.local/bin

set -U fish_greeting
