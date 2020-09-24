{ broken ? false }:

let
  /* 00a9d3f261d7da2891801abe35728ab93794644a: broken */
  /* 1f2c19f1581f1450eaf28b4095df203c9e38aeee: broken, HarfBuzz.FeatureT.feature_T */
  nixpkgsPinWorks = {
    url = https://github.com/nixos/nixpkgs/archive/7d51e48d2ff9bdccd0cb174968f4f290ee7b1578.tar.gz;
    sha256 = "0472njdlsbbx8hgp111qff9c5wwd3ahadhpgjgip7li9qbxl4cnj";
  };
  nixpkgsPinBroken = {
    url = https://github.com/nixos/nixpkgs/archive/00a9d3f261d7da2891801abe35728ab93794644a.tar.gz;
    sha256 = "0im0d4rspdla352rn2ls17sakzfr27mliw3jyixmwwgi6i3jwd78";
  };

  nixpkgsPin = if broken then nixpkgsPinBroken else nixpkgsPinWorks;
  pkgs = import (builtins.fetchTarball nixpkgsPin) {};

in


pkgs.stdenv.mkDerivation rec {
  name = "trigger-gvalue-bug-app";
  src = ./.;
  buildInputs = [
    (pkgs.haskell.packages.ghc8101.ghcWithPackages (p : [ p.gi-gtk ]))
    pkgs.zlib
    pkgs.gtk3
    pkgs.pkgconfig
  ];
  shellHook = ''
    export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath buildInputs}:$LD_LIBRARY_PATH
    export LANG=en_US.UTF-8
  '';
  LOCALE_ARCHIVE =
    if pkgs.stdenv.isLinux
    then "${pkgs.glibcLocales}/lib/locale/locale-archive"
    else "";
}
