{
  description = "WüSpace Plymouth boot splash theme";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "i686-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (pkgs: {
        default = pkgs.callPackage ./default.nix { };
        wuespace-plymouth-theme = self.packages.${pkgs.system}.default;
      });

      nixosModules = {
        default = self.nixosModules.wuespace-plymouth;
        wuespace-plymouth = { config, options, pkgs, lib, ... }: {
          options.theme.wuespace-plymouth = {
            enable = lib.mkEnableOption "WüSpace Plymouth boot splash theme";
          };

          config = lib.mkIf config.theme.wuespace-plymouth.enable (lib.mkMerge [
            {
              boot.plymouth = {
                enable = true;
                theme = "wuespace";
                themePackages = [ self.packages.${pkgs.system}.default ];
                extraConfig = "DeviceScale=1";
              };
            }
            (lib.optionalAttrs (options ? stylix.targets.plymouth.enable) {
              # If stylix is installed disable Stylix's Plymouth target so Stylix does not override this theme
              stylix.targets.plymouth.enable = lib.mkDefault false;
            })
          ]);
        };
      };
    };
}
