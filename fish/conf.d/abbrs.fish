# support ... go up
abbr -a dotdot --regex '^\.\.+$' --function multicd

# general abbrs
abbr -a xdg xdg-open
abbr -a rot rpm-ostree
abbr -a flat flatpak
abbr -a tlr 'toolbox run'

# file with fuzzy finder
abbr -a kopen 'kate (fzf)'
abbr -a hxf 'hx (fzf)'

# git abbrs
abbr -a gad 'git add'
abbr -a gb 'git branch'
abbr -a gcm 'git commit'
abbr -a gco 'git checkout'
abbr -a gcob 'git checkout -b'
abbr -a gdh 'git diff HEAD'
abbr -a gdm 'git diff master'
abbr -a gll 'git pull --no-rebase'
abbr -a gmg 'git merge'
abbr -a graph 'git log --all --graph --decorate --oneline'
abbr -a grh 'git reset HEAD'
abbr -a grhh 'git reset --hard HEAD'
abbr -a gst 'git status -sb'
abbr -a gsh 'git push'
abbr -a gsta 'git stash'
abbr -a gstaa 'git stash apply'
abbr -a gstd 'git stash drop'
abbr -a gstl 'git stash list'
abbr -a gstp 'git stash pop'
abbr -a gwch 'git whatchanged -p --abbrev-commit --pretty=medium'

# bind ls to eza
# abbr -a la 'eza -alF --time-style iso'
# abbr -a lg 'eza -lFa --git --git-repos --git-ignore --time-style iso'
# abbr -a ll 'eza -lF --time-style iso'

# distrobox is too long to type
abbr -a dbx distrobox

# Add abbr for systemctl suspend but suspend is not available
abbr -a pause 'systemctl suspend'
