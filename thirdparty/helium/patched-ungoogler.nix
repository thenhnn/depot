{
  ungoogledRev,
  pkgs,
  ...
}:
pkgs.stdenv.mkDerivation {
  pname = "helium-ungoogled-chromium";
  version = "helium-${ungoogledRev.rev}";
  src = pkgs.fetchFromGitHub {
    inherit (ungoogledRev) owner repo rev hash;
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
