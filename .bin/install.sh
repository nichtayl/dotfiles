# Dotfiles install script

# Install packages
sudo apt update
sudo apt install -y curl git i3 i3lock imagemagick maim xss-lock zsh

# Make zsh the default shell
chsh -s $(which zsh)

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Set up dotfiles bare repo
cd ~
git clone --bare git@github.com:nichtayl/dotfiles.git $HOME/.dotfiles

# Setup dotfiles-git command so we don't invoke "regular" git
function dotfiles-git {
  $(which git) --git-dir=$HOME/.dotfiles/ --work-tree=$HOME $@
}

# Preemptively make backup directory
mkdir -p $HOME/.config-backup

# Attempt to checkout, if an error happens then backup the offending files 
# $? checks status last command -- 0 means success, 1 means failure
dotfiles-git checkout
if [ $? = 0 ]; then
  echo "Checked out dotfiles.";
else
  echo "Backing up pre-existing dotfiles in .config-backup";
  dotfiles-git checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .config-backup/{}
fi;

# Checkout the dotfiles repo
dotfiles-git checkout

# Set showUntrackedFiles to 'no' so the whole home dir doesn't show up
dotfiles-git config status.showUntrackedFiles no
