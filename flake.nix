{
  description = "Kerio Control VPN Client";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "nixpkgs/nixos-24.05";

  outputs = { self, nixpkgs }:
    let

      # to work with older version of flakes
      # lastModifiedDate = self.lastModifiedDate or self.lastModified or "19700101";

      # Generate a user-friendly version number.
      version = "9.4.4-8434";

      # System types to support.
      supportedSystems = [ "x86_64-linux" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [ self.overlay ]; });

    in

    {

      # A Nixpkgs overlay.
      overlay = final: prev: {

        kerio-control-vpnclient = with final; stdenv.mkDerivation rec {
          pname = "kerio-control-vpnclient";
          inherit version;

          src = fetchurl {
            url = "https://cdn.kerio.com/dwn/control/control-${version}/${pname}-${version}-linux-amd64.deb";
            # sha256sum kerio-control-vpnclient-9.4.4-8434-linux-amd64.deb
            # nix hash to-sri --type sha256 ad04c68c2af9928534ea769f2bf2d6aa7784742d24658616c1399407b31783f8
            hash = "sha256-rQTGjCr5koU06nafK/LWqneEdC0kZYYWwTmUB7MXg/g=";
          };

          nativeBuildInputs = [
            dpkg
          ];

          buildInputs = [
          ];

          installPhase = ''
            mkdir -p $out
            cp -r * $out/
          '';
        };

      };

      # Provide some binary packages for selected system types.
      packages = forAllSystems (system:
        {
          inherit (nixpkgsFor.${system}) kerio-control-vpnclient;
        });

      # The default package for 'nix build'. This makes sense if the
      # flake provides only one package or there is a clear "main"
      # package.
      defaultPackage = forAllSystems (system: self.packages.${system}.kerio-control-vpnclient);

      # A NixOS module, if applicable (e.g. if the package provides a system service).
      nixosModules.kerio-control-vpnclient =
        { pkgs, ... }:
        {
          nixpkgs.overlays = [ self.overlay ];

          environment.systemPackages = [ pkgs.kerio-control-vpnclient ];

          #systemd.services = { ... };
        };
    };
}
