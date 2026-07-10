{pkgs, ...}:
pkgs.stdenv.mkDerivation (finalAttrs: {
  pname = "helium-patches";
  version = "0.14.5";
  src = pkgs.fetchFromGitHub {
    owner = "imputnet";
    repo = "helium";
    tag = finalAttrs.version;
    hash = "sha256-QuDtsYck/nBKY9ctFPvZrV88rOYSGW/GZ5nzbzKZ+qY=";
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
})
