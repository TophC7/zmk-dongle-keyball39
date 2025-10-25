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
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          name = "keyball39-dev";

          buildInputs = with pkgs; [
            # Version control
            git

            # GitHub Actions local runner (requires Docker)
            act

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
