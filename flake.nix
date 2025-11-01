{
  description = "Keyball39 ZMK Firmware";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    zmk-nix = {
      url = "github:lilyinstarlight/zmk-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      zmk-nix,
    }:
    let
      forAllSystems = nixpkgs.lib.genAttrs (nixpkgs.lib.attrNames zmk-nix.packages);
    in
    {
      packages = forAllSystems (system: {
        default = zmk-nix.legacyPackages.${system}.buildSplitKeyboard {
          name = "keyball39";

          # Filter source files like the template does
          src = nixpkgs.lib.sourceFilesBySuffices self [
            ".board"
            ".cmake"
            ".conf"
            ".defconfig"
            ".dts"
            ".dtsi"
            ".json"
            ".keymap"
            ".overlay"
            ".shield"
            ".yml"
            "_defconfig"
          ];

          board = "nice_nano_v2";
          # Builds keyball39_left and keyball39_right with nice!view display support
          shield = "keyball39_%PART% nice_view_adapter nice_view";

          # Hash of Zephyr dependencies from west.yml in config/
          # The config parameter defaults to "config" which is where our west.yml lives
          # Includes: ZMK main + zmk-pmw3610-driver for trackball support
          zephyrDepsHash = "sha256-MjjLh+k6hIRGz3IbClbKPo6PAuRur4bURSTmys5R0+U=";
        };
      });

      # Convenience outputs for building and flashing
      apps = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          buildAndCopy = pkgs.writeShellScriptBin "build-and-copy" ''
            set -euo pipefail

            echo "🔨 Building Keyball39 firmware..."
            ${pkgs.nix}/bin/nix build

            echo "📦 Preparing firmware files..."
            ${pkgs.coreutils}/bin/mkdir -p ./uf2
            ${pkgs.coreutils}/bin/rm -f ./uf2/*.uf2

            echo "📋 Copying firmware files (dereferencing symlinks)..."
            ${pkgs.coreutils}/bin/cp -L result/*.uf2 ./uf2/

            echo ""
            echo "✅ Build complete! Firmware files in uf2/:"
            ${pkgs.coreutils}/bin/ls -lh uf2/*.uf2
          '';
        in
        {
          default = {
            type = "app";
            program = "${buildAndCopy}/bin/build-and-copy";
          };

          build = {
            type = "app";
            program = "${buildAndCopy}/bin/build-and-copy";
          };

          flash = {
            type = "app";
            program = "${self.packages.${system}.default}/bin/flash";
          };

          update = zmk-nix.apps.${system}.update;
        }
      );

      # Dev shell for local development
      devShells = forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.mkShell {
          name = "keyball39-dev";
          inputsFrom = [ self.packages.${system}.default ];
        };
      });
    };
}
