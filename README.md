# dotfiles

Repository for my dot files.

Whenever I create a new Ubuntu VM I need to install bunch of stuff on it. This will help automate this process.

The following files should be installed in this order

- setupUbuntu.sh

```bash
sudo sh -c "$(curl -fsSL https://raw.githubusercontent.com/nitinkunte/dotfiles/main/setupUbuntu.sh)"
```

- setupDotfiles.sh

```bash
sudo sh -c "$(curl -fsSL https://raw.githubusercontent.com/nitinkunte/dotfiles/main/setupDotfiles.sh)"
```

- setupDesktop.sh

```bash
sudo sh -c "$(curl -fsSL https://raw.githubusercontent.com/nitinkunte/dotfiles/main/setupDesktop.sh)"
```