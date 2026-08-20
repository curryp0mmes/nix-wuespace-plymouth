# WüSpace Plymouth Boot Splash Theme

A custom [Plymouth](https://www.freedesktop.org/wiki/Software/Plymouth/) boot splash theme for NixOS featuring the animated WüSpace loading logo and static prompt display.

## Features

- **Animated Loading Splash**: Renders frames directly from `wuespace_animation.rawr` with Glaxnimate at build time (36 frames, 300x300, looped seamlessly).
- **Gradient Background**: Smooth vertical gradient from `#1E1E2E` (top) to `#182D4A` (bottom).
- **Static Display for Prompts**: Automatically renders `static.svg` to match the animation resolution when waiting for user input (e.g. LUKS disk decryption passphrase).
- **Password & Question Prompts**: Custom centered passphrase prompt with visual bullet dots enclosed in accent-colored brackets (`#F9A877`).
- **Nix Flake & Module**: Built-in NixOS module that handles Plymouth configuration and disables conflicting Stylix targets automatically.

---

## Usage in NixOS Flake Configuration

### 1. Add input in your `flake.nix`

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    # Add WüSpace Plymouth theme
    wuespace-plymouth = {
      url = "github:<your-username>/wuespace-plymouth-theme"; # or path:"/home/simon/Code/other/wuespace-plymouth-theme"
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, wuespace-plymouth, ... }@inputs: {
    nixosConfigurations.your-host = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        wuespace-plymouth.nixosModules.default
        ./configuration.nix
      ];
    };
  };
}
```

### 2. Enable in your system configuration

```nix
{
  theme.wuespace-plymouth.enable = true;
}
```

*Note: Enabling this module automatically sets `stylix.targets.plymouth.enable = false;` to prevent Stylix from overriding the theme.*

---

### Alternative: Manual Configuration

If you prefer to configure `boot.plymouth` manually without using the NixOS module:

```nix
{ inputs, pkgs, ... }:
{
  stylix.targets.plymouth.enable = false;

  boot.plymouth = {
    enable = true;
    theme = "wuespace";
    themePackages = [
      inputs.wuespace-plymouth.packages.${pkgs.system}.default
    ];
  };
}
```

## License

MIT
