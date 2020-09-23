{ broken ? false }:

let
  nixpkgsPinWorks = {
    url = https://github.com/nixos/nixpkgs/archive/edf2541f02c6b24ea791710d5cadeae36f9b1a3a.tar.gz;
    sha256 = "1ssisvdqj3xwg5q0n7sdx27glnfx6p0a1jgi4labfylxlalc7bzm";
  };
  nixpkgsPinBroken = {
    url = https://github.com/nixos/nixpkgs/archive/1179840f9a88b8a548f4b11d1a03aa25a790c379.tar.gz;
    sha256 = "00jy37wj04bvh299xgal2iik2my9l0nq6cw50r1b2kdfrji8d563";
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
