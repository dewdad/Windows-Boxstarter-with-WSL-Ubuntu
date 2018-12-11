## Description
#
#  Run this script to install dev apps and git configs on your machine
#
## Usage
#
#  If you've not done so already you'll need to set the ExecutionPolicy on the machine:
#
#      Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
#
#  Run this boxstarter by calling the following from an **elevated** command-prompt:
#
#      start http://boxstarter.org/package/nr/url?<URL-TO-RAW-FILE>
#  OR
#      Install-BoxstarterPackage -PackageName <URL-TO-RAW-FILE> -DisableReboots
#
## Credits
#
#  Much of the configuration is taken from Jess Frazelle's gist:
#  https://gist.github.com/jessfraz/7c319b046daa101a4aaef937a20ff41f
#
#  which has some of Nick Craver's gist referenced in it:
#  https://gist.github.com/NickCraver/7ebf9efbfd0c3eab72e9
#
#  and a couple lines come from CJ Kinni's gist:
#  https://gist.github.com/CJKinni/de205822b0dddd2b18054fe7a29f72bc


if ([Environment]::OSVersion.Version.Major -ne 10) {
    Write-Error 'Upgrade to Windows 10 before running this script'
    Exit
}

if (('Unrestricted', 'RemoteSigned') -notcontains (Get-ExecutionPolicy)) {
    Write-Error @'
The execution policy on your machine is Restricted, but it must be opened up for this
installer with:

Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
'@
}

if (!(Get-Command 'boxstarter' -ErrorAction SilentlyContinue)) {
    Write-Error @'
You need Boxstarter to run this script; install with:

. { iwr -useb http://boxstarter.org/bootstrapper.ps1 } | iex; get-boxstarter -Force; refreshenv
'@
    Exit
}
#--- Install Chocolatey if not installed ---#
Write-Output -Category Info -Message "verifying chocolatey is installed"
if (!(Test-Path "$($env:ProgramData)\chocolatey\choco.exe")) {
    Write-FPLog -Category Info -Message "installing chocolatey..."
    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force;
        iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    }
    catch {
        Write-FPLog -Category Error -Message $_.Exception.Message
    }
}
else {
    Write-FPLog -Category Info -Message "chocolatey is already installed"
}
choco upgrade chocolatey
choco upgrade powershell -y

#--- Apps ---
choco upgrade googlechrome -y
choco upgrade firefox -y
choco upgrade docker-desktop -y
choco upgrade cmdermini -y
choco upgrade tortoisegit -y
choco upgrade 7zip -y
# choco upgrade nodejs-lts -y
choco upgrade yarn -y
choco upgrade curl -y
choco upgrade wget -y
choco upgrade linkshellextension -y

#--- Visual Studio Code
# choco install visualstudiocode -y
# refreshenv
# code --install-extension EditorConfig.EditorConfig
# code --install-extension vscodevim.vim
# code --install-extension eamodio.gitlens
# code --install-extension gerane.Theme-Paraisodark
# code --install-extension PeterJausovec.vscode-docker
# code --install-extension ms-vscode.PowerShell
# code --install-extension christian-kohler.path-intellisense
# code --install-extension robertohuertasm.vscode-icons
# code --install-extension streetsidesoftware.code-spell-checker
### change lang to GB in config with "cSpell.language": "en-GB"
### uncomment to install
### node
# code --install-extension eg2.vscode-npm-script
# code --install-extension dbaeumer.vscode-eslint
# code --install-extension christian-kohler.npm-intellisense
# code --install-extension eg2.tslint


#--- Git ---
choco upgrade git -y --params '/GitAndUnixToolsOnPath /NoGitLfs /SChannel /NoAutoCrlf'
refreshenv

git config --global set core.symlinks true
git config --global set core.autocrlf input
git config --global set core.eol lf
git config --global set color.status auto
git config --global set color.diff auto
git config --global set color.branch auto
git config --global set color.interactive auto
git config --global set color.ui true
git config --global set color.pager true
git config --global set color.showbranch auto
git config --global pull.rebase true
git config --global rebase.autoStash true

# Write-Output "**/.history" > $ENV:UserProfile\\.gitignore_global
Write-Output "**/.history" > U:\.gitignore_global
git config --global core.excludesfile ~/.gitignore_global

#--- Symlink home of MSYS2 to your home dir
### mklink %USERPROFILE%\.gitconfig U:\.gitconfig # will onlly work in cmd cosole
### mklink %USERPROFILE%\.gitignore_global U:\.gitignore_global
new-item -itemtype symboliclink -path ~\ -name .gitconfig -value U:\.gitconfig
new-item -itemtype symboliclink -path ~\ -name .gitignore_global -value U:\.gitignore_global

#--- Symlink all subsystems for git
## taken from https://www.onwebsecurity.com/configuration/improving-git-workflow-difference-system-global-git-config-file.html
# mklink %USERPROFILE%\AppData\Local\Packages\TheDebianProject.DebianGNULinux_76v4gfsz19hv4\LocalState\rootfs\home\%USERNAME%\.gitconfig U:\.gitconfig

refreshenv

#-----------------------------------------------------------[Functions]------------------------------------------------------------
function Install-Chocolatey() {
    "Install/upgrading Chocolatey" | Write-Log -UseHost -Path $LogFilePath

    $savedErrorActionPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = "SilentlyContinue"
        $command = Get-Command choco
    }
    finally {
        $ErrorActionPreference = $savedErrorActionPreference
    }
    if ($command) {
        choco upgrade -y chocolatey 2>&1 | Write-Log -UseHost -Path $LogFilePath
    }
    else {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) 2>&1 | Write-Log -UseHost -Path $LogFilePath
    }
}