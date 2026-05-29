{pkgs, ...}:
pkgs.stdenv.mkDerivation {
  pname = "helium-patches";
  version = "0.12.5";
  src = pkgs.fetchFromGitHub {
    owner = "imputnet";
    repo = "helium";
    rev = "a14223c48ad57bf3963b0b225574ef65bef0ca27";
    hash = "sha256-B+DUPq3/k3p5seZ4EWs6NbLv9KzhU/b9+7/UfrrTLsc=";
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
