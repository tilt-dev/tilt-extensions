{
    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-22.05";
        flake-utils.url = "github:numtide/flake-utils";
    };

    outputs = { self, flake-utils, nixpkgs, ... }:
        flake-utils.lib.eachDefaultSystem (system:
            let
                pkgs = import nixpkgs {
                    inherit system;
                };
            in {
                packages = {
                    container = pkgs.dockerTools.buildImage {
                        name = "hello-world";
                        config = {
                        Cmd = [
                            "${pkgs.python3}/bin/python" "-m" "http.server" "8000"
                        ];
                        ExposedPorts = {
                            "8000/tcp" = { };
                        };
                        };
                    };
                };
            }
        );
}
