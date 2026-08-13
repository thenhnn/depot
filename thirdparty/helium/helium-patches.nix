{pkgs, ...}:
pkgs.stdenv.mkDerivation (finalAttrs: {
  pname = "helium-patches";
  version = "0.15.4";
  src = pkgs.fetchFromGitHub {
    owner = "imputnet";
    repo = "helium";
    tag = finalAttrs.version;
    hash = "sha256-N8Ncllrxbj9+o401/OYyaneDm2z4LwNyjQ9W5bjHCIU=";
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
