{ pkgs ? import <nixpkgs> { }
, pkgsLinux ? import <nixpkgs> { system = "x86_64-linux"; }
}:
{
  hello-world-image = pkgs.dockerTools.buildLayeredImage {
    name = "hello-world";
    config = {
      Cmd = [
        "${pkgsLinux.python3}/bin/python" "-m" "http.server" "8000"
      ];
      ExposedPorts = {
        "8000/tcp" = { };
      };
    };
  };
}
