{ broken ? false,
  patched ? false
}:

let
  /*   broken, HarfBuzz.FeatureT.feature_T
     ----------------------------------------
     1f2c19f1581f1450eaf28b4095df203c9e38aeee
     8a78890a08dfa697be21891619f799738b956aa5
  */
  nixpkgsPinWorks = {
    url = https://github.com/nixos/nixpkgs/archive/6a617de2c41eb15dee7c08fccffc0bee9c1ae125.tar.gz;
    sha256 = "0ahxfi4xqvkjzwalxy0lxwimz5ig2b1vcsrfy5wcmm6x6mq4yma2";
  };
  nixpkgsPinBroken = {
    url = https://github.com/nixos/nixpkgs/archive/00a9d3f261d7da2891801abe35728ab93794644a.tar.gz;
    sha256 = "0im0d4rspdla352rn2ls17sakzfr27mliw3jyixmwwgi6i3jwd78";
  };

  nixpkgsPin = if broken then nixpkgsPinBroken else nixpkgsPinWorks;
  pkgs = import (builtins.fetchTarball nixpkgsPin) {};


  haskellPackages =
    if (!patched)
    then pkgs.haskell.packages.ghc8101
    else pkgs.haskell.packages.ghc8101.override {
           overrides = self: super: rec {
             haskell-gi = self.callCabal2nix "haskell-gi" "${haskell_gi_patched}" {};
           };
         };

  haskell_gi_patched =
    pkgs.fetchFromGitHub {
      owner = "haskell-gi";
      repo = "haskell-gi";
      rev = "6fe7fc271095b5b6115b142f72995ebc11840afb";
      sha256 = "1xb3rbavkz9kygv65nw8y2gm5vhbcvgack93y237fxrf7vl1xgdv";
    };
in


pkgs.stdenv.mkDerivation rec {
  name = "trigger-gvalue-bug-app";
  src = ./.;
  buildInputs = [
    (haskellPackages.ghcWithPackages (p : [ p.gi-gtk ]))
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
