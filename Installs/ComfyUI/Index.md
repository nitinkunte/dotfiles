# Steps to install ComyUI on Mac Silicon

## Install `pyenv`. 

## clone the repo
``` sh
cd ~/Documents/Projects/Other && git clone https://github.com/comfyanonymous/ComfyUI.git
```

##  Navigate to the ComfyUI directory
``` sh
cd ~/Documents/Projects/Other/ComfyUI
```

## Create a virtual environment named 'venv'
``` sh
python3 -m venv venv
```
## Activate the virtual environment
``` sh
source venv/bin/activate  
```
## Install PyTorch nightly
``` sh
pip3 install --pre torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/nightly/cpu
```
## Verify PyTorch installation
``` sh
python3 -c "import torch; print(torch.__version__)"
```

## Once done with the session you can deactivate the venv using 
``` sh
deactivate
```
