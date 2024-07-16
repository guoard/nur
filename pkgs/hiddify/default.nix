{ fetchurl, lib, pkgs, libepoxy, dpkg, makeWrapper, patchelf, harfbuzz, atk, cairo, gdk-pixbuf, glib, gtk3, ayatana-ido }:

pkgs.stdenv.mkDerivation rec {
  name = "hiddify";
  version = "1.6.3";

  src = fetchurl {
    url = "https://github.com/hiddify/hiddify-next/releases/download/v${version}/Hiddify-Debian-x64.deb";
    sha256 = "sha256-V/M5Qjo0zD1+Hqo7rmudXDtRB1H6fai9jfy3ZSe02vA=";
  };


  nativeBuildInputs = [
    makeWrapper
    dpkg
    pkgs.tree
  ];

  buildInputs = [ dpkg patchelf harfbuzz atk cairo gdk-pixbuf glib gtk3 ayatana-ido ];

  runLibDeps = [ harfbuzz atk cairo gdk-pixbuf glib gtk3 ayatana-ido ];


  runBinDeps = [
    libepoxy
  ];

#   unpackPhase = "dpkg-deb -x $src $out";

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r usr/share $out/share

    mkdir -p $out/bin
    cp usr/share/hiddify/hiddify $out/bin/hiddify

    wrapProgram $out/bin/hiddify \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runLibDeps} \
      --prefix PATH : ${lib.makeBinPath runBinDeps}

    runHook postInstall
  '';

  meta = with lib; {
    description = "A multi-platform proxy client based on Sing-box universal proxy tool-chain";
    homepage = https://github.com/hiddify/hiddify-next;
    license = licenses.cc-by-nc-sa-40;
    platforms = with platforms; [
      "x86_64-linux"
    ];
  };
}
