{ pkgs ? import <nixpkgs> { }, ... }:
let
  lib = pkgs.lib;
in
pkgs.stdenv.mkDerivation rec {
  pname = "kerio-control-vpnclient";
  version = "9.4.4-8434";

  src = pkgs.fetchurl {
    url = "https://cdn.kerio.com/dwn/control/control-${version}/${pname}-${version}-linux-amd64.deb";
    # sha256sum kerio-control-vpnclient-9.4.4-8434-linux-amd64.deb
    # nix hash to-sri --type sha256 ad04c68c2af9928534ea769f2bf2d6aa7784742d24658616c1399407b31783f8
    hash = "sha256-rQTGjCr5koU06nafK/LWqneEdC0kZYYWwTmUB7MXg/g=";
  };

  nativeBuildInputs = with pkgs; [
    dpkg
  ];

  buildInputs = with pkgs; [
    procps
    dialog
    util-linux
    libxcrypt-legacy
    openssl
  ];

  installPhase = ''
    ls -lah
      mkdir -p $out/lib
      mkdir -p $out/bin

      cp -r ./usr/lib/* $out/lib/
      cp -r ./usr/sbin/* $out/bin/
  '';

  meta = with lib; {
    homepage = "http://www.kerio.com/control";
    description = "Kerio Control VPN client for corporate networks.";
    licencse = licenses.mit;
    platforms = with platforms; linux;
  };
}
