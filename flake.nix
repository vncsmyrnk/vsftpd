{
  description = "vsftpd image";

  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      entrypoint =
        pkgs.writeScriptBin "entrypoint.sh" (builtins.readFile ./entrypoint.sh);

      vsftpdConfig = pkgs.writeTextFile {
        name = "vsftpd.conf";
        text = builtins.readFile ./vsftpd.conf;
        destination = "/etc/vsftpd.conf";
      };

      dockerImage = pkgs.dockerTools.buildImage {
        name = "vsftpd";
        tag = pkgs.vsftpd.version;

        copyToRoot = pkgs.buildEnv {
          name = "image-root";
          paths = with pkgs; [
            vsftpd
            bash
            coreutils
            shadow
            entrypoint
            vsftpdConfig
          ];
          pathsToLink = [ "/bin" "/etc" ];
        };

        config = {
          Entrypoint = [ "${entrypoint}/bin/entrypoint.sh" ];
          ExposedPorts = {
            "20/tcp" = { };
            "21/tcp" = { };
          };
          WorkingDir = "/";
        };
      };
    in {
      packages.${system} = {
        default = dockerImage;
        docker = dockerImage;
      };
    };
}
