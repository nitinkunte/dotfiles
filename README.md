# DotFiles and Instructions for Setup



> **NOTE**: The scripts have issues. Till they are fixed, follow the guides given below:

1. [Setup Ubuntu on Fusion](./Ubuntu%24.04.01%Setup%-%Fusion.md)
2. [Setup Ubuntu on UTM](./Ubuntu%2024.04.01%20Setup%-%UTM.md)
3. [Useful Linux Commands](./Useful%20Linux%20Commands.md)


---

## Older instructions for Ubuntu Setup
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
