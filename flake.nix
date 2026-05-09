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
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          commonSrc = nixpkgs.lib.sourceFilesBySuffices self [
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
          # Bump when west.yml changes. If wrong, nix will print the expected hash.
          commonHash = "sha256-tsXPA2PfcaJDpW/lT1bSn23AUPKvfLRi97SgScukmUU=";
        in
        {
          # Build left central with nice!view
          left = zmk-nix.legacyPackages.${system}.buildKeyboard {
            name = "keyball39-left";
            src = commonSrc;
            board = "nice_nano@2.0.0//zmk";
            shield = "keyball39_left nice_view_adapter nice_view";
            zephyrDepsHash = commonHash;
          };

          # Build right peripheral with nice!view
          right = zmk-nix.legacyPackages.${system}.buildKeyboard {
            name = "keyball39-right";
            src = commonSrc;
            board = "nice_nano@2.0.0//zmk";
            shield = "keyball39_right nice_view_adapter nice_view";
            zephyrDepsHash = commonHash;
          };

          # Build settings_reset
          settings_reset = zmk-nix.legacyPackages.${system}.buildKeyboard {
            name = "settings_reset";
            src = commonSrc;
            board = "nice_nano@2.0.0//zmk";
            shield = "settings_reset";
            zephyrDepsHash = commonHash;
          };

          # Combined package that builds left + right
          default = pkgs.symlinkJoin {
            name = "keyball39-all";
            paths = [
              self.packages.${system}.left
              self.packages.${system}.right
            ];
          };
        }
      );

      # Convenience outputs for building and flashing
      apps = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          buildAndCopy = pkgs.writeShellScriptBin "build-and-copy" ''
            set -euo pipefail

            echo "🔨 Building Keyball39 firmware (left central + right peripheral)..."

            ${pkgs.coreutils}/bin/mkdir -p ./uf2
            ${pkgs.coreutils}/bin/rm -f ./uf2/*.uf2

            echo "📦 Building left central..."
            ${pkgs.nix}/bin/nix build .#left -o result-left
            ${pkgs.coreutils}/bin/cp -L result-left/zmk.uf2 ./uf2/keyball39_left.uf2
            ${pkgs.coreutils}/bin/rm result-left

            echo "📦 Building right peripheral..."
            ${pkgs.nix}/bin/nix build .#right -o result-right
            ${pkgs.coreutils}/bin/cp -L result-right/zmk.uf2 ./uf2/keyball39_right.uf2
            ${pkgs.coreutils}/bin/rm result-right

            echo "📦 Building settings_reset..."
            ${pkgs.nix}/bin/nix build .#settings_reset -o result-reset
            ${pkgs.coreutils}/bin/cp -L result-reset/zmk.uf2 ./uf2/settings_reset.uf2
            ${pkgs.coreutils}/bin/rm result-reset

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

      # Dev shell for local development and firmware flashing
      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config = {
              allowUnfree = true;
              permittedInsecurePackages = [
                "segger-jlink-qt4-824"
                "segger-jlink-qt4-874"
                "nrf-command-line-tools"
                "python3.13-ecdsa-0.19.1"
              ];
              segger-jlink.acceptLicense = true;
            };
          };
        in
        {
          default = pkgs.mkShell {
            name = "keyball39-dev";

            buildInputs = with pkgs; [
              # nRF52 firmware flashing and debugging tools
              openocd # Open On-Chip Debugger for various MCUs
              nrf-command-line-tools # nrfjprog, mergehex (Nordic official tools)
              adafruit-nrfutil # Adafruit's nRF52 DFU utility

              # USB device inspection
              usbutils # lsusb for checking USB devices
            ];
          };
        }
      );
    };
}
