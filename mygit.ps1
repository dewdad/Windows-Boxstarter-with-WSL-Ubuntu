# Write-Output "**/.history" > $ENV:UserProfile\\.gitignore_global
Write-Output "**/.history" > U:\.gitignore_global
git config --global core.excludesfile ~\.gitignore_global

#--- Symlink home of MSYS2 to your home dir
new-item -itemtype symboliclink -path ~\ -name .gitconfig -value U:\.gitconfig
new-item -itemtype symboliclink -path ~\ -name .gitignore_global -value U:\.gitignore_global