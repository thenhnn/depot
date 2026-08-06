{pkgs, ...}:
pkgs.stdenv.mkDerivation (finalAttrs: {
  pname = "helium-patches";
  version = "0.15.2";
  src = pkgs.fetchFromGitHub {
    owner = "imputnet";
    repo = "helium";
    tag = finalAttrs.version;
    hash = "sha256-CJH3E6irusbYjVG5XE3Z5SeP2Dcqd+b4SQ4wGk/AOwc=";
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
