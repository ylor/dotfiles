# dotfiles

This repository configures Arch Linux and macOS with symbolic links and setup scripts.

## Usage

Run the bootstrap command:

```sh
sh -c "$(curl -fsSL boot.roly.sh)"
```

Run the apply script from an existing clone:

```sh
fish main.fish
```

## Layout

Each layer can contain a `home/` directory and a `setup/` directory.

```text
.
├── home/
├── setup/
├── linux/
│   ├── home/
│   ├── setup/
│   └── hosts/<hostname>/
│       ├── home/
│       └── setup/
└── darwin/
    ├── home/
    ├── setup/
    └── hosts/<hostname>/
        ├── home/
        └── setup/
```

The root contains portable configuration. The OS directories contain system-specific configuration.

The apply script uses the lower-case output from `uname -s` as the OS name.
It uses the lower-case output from `hostname -s` as the host name.
On macOS, the short host name can include the `.local` suffix.

## Apply order

The script applies these layers in order:

1. The repository root.
2. The current OS.
3. The current host under the current OS.

For each layer, the script links `home/` first. It then sources the `*.fish` files from `setup/` in name order.

A later layer replaces a complete file from an earlier layer. Use native include features for partial configuration overrides.

Keep portable setup steps in the root `setup/` directory. Keep package manager steps in the applicable OS directory.

Make each setup script safe to run more than one time.
