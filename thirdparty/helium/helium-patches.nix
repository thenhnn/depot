{pkgs, ...}:
pkgs.stdenv.mkDerivation {
  pname = "helium-patches";
  version = "0.12.3";
  src = pkgs.fetchFromGitHub {
    owner = "imputnet";
    repo = "helium";
    rev = "d14e214a34e466852e109407c86b5da544ae23cf";
    hash = "sha256-UosaSVK6xMdIM2Qyl5Qx4th+IbWLVRo6wl/IZA5njVM=";
  };

  dontBuild = true;

  buildInputs = with pkgs; [
    python3Packages.python
    patch
  ];

  nativeBuildInputs = with pkgs; [
    makeWrapper
  ];

  installPhase = ''
    mkdir $out
    cp -R * $out/
    wrapProgram $out/utils/patches.py --add-flags "apply" --prefix PATH : "${pkgs.patch}/bin"
  '';
}
