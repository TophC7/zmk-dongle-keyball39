{
  description = "Keyball39 ZMK Firmware Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            permittedInsecurePackages = [
              "segger-jlink-qt4-824"
              "segger-jlink-qt4-874"
            ];
            segger-jlink.acceptLicense = true;
          };
        };
      in
      {
        devShells.default = pkgs.mkShell {
          name = "keyball39-dev";

          buildInputs = with pkgs; [
            # Version control
            git

            # GitHub Actions local runner (requires Docker)
            act

            # nRF52 firmware flashing tools
            nrf-command-line-tools  # nrfjprog and mergehex
            openocd                 # Open On-Chip Debugger
            adafruit-nrfutil        # Adafruit's nRF52 DFU utility

            # Optional: If you want to build locally without Docker
            # Uncomment these lines:
            # python3
            # python3Packages.west
            # cmake
            # ninja
            # gcc-arm-embedded
            # dtc
          ];
        };
      }
    );
}
