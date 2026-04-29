{pkgs, ...}:
pkgs.stdenv.mkDerivation {
  pname = "helium-patches";
  version = "0.11.7";
  src = pkgs.fetchFromGitHub {
    owner = "imputnet";
    repo = "helium";
    rev = "7330d5770912745a3a208c19c86d75ff42081a69";
    hash = "sha256-87sgs1iv30eD7vRfSV7iMUoz/yKU26Z/1gD27zSA+UU=";
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
