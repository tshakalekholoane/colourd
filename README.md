# `colourd`

`colourd` is a daemon that observes when the theme changes on macOS and executes all the files in the `~/Library/Application Support/colourd/` directory.

## Installation

The application can be built from source by cloning the repository and running the following command which requires working versions of [Make](https://www.gnu.org/software/make/) and [Swift](https://www.swift.org) which come bundled with most macOS installations.

```shell
git clone https://github.com/tshakalekholoane/colourd && cd colourd
make release
```

## Example

The following illustrates how to use `colourd` to automatically switch the background in Neovim on macOS using Python and [pynvim](https://github.com/neovim/pynvim). 

Create and place the following file in the `$HOME/.config/colourd/` directory and be sure to check that it has executable permission by running the command  `chmod +x $filename` where `$filename` is the name of the script that `colourd` will execute every time the theme changes.

```python
#!/usr/bin/env python3
import sys

import pynvim

try:
    nvim = pynvim.attach("socket", path="/tmp/nvim")
except FileNotFoundError:
    print("Socket not found.", file=sys.stderr)
    sys.exit(1)

# colourd passes in the appearance value ("dark" or "light") as the 
# first argument to the script.
background = sys.argv[1]
nvim.command(f"set background={background}")
```

Start `colourd` using the following command:

```shell
# Assuming the binary is in the current directory.
nohup ./colourd >> colourd.log &
```

This will run `colourd` in the background and write error messages to a file named `colourd.log` in the same directory.

Next, start Neovim using this command to open a socket where Neovim will listen for incoming commands.

```shell
NVIM_LISTEN_ADDRESS=/tmp/nvim nvim 
```

Now when the theme changes, `colourd` should execute the script above which will send a command to Neovim via the socket to change the `background` to the current macOS appearance.
