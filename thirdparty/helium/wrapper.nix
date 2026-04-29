{
  nixpkgsChromiumPath,
  helium-patches,
  ...
}: {
  newScope,
  config,
  stdenv,
  makeWrapper,
  buildPackages,
  ed,
  gnugrep,
  coreutils,
  xdg-utils,
  glib,
  gtk3,
  gtk4,
  adwaita-icon-theme,
  gsettings-desktop-schemas,
  fetchgit,
  libva,
  pipewire,
  wayland,
  lib,
  # package customization
  # Note: enable* flags should not require full rebuilds (i.e. only affect the wrapper)
  upstream-info ? (lib.importJSON ./sources.json),
  proprietaryCodecs ? true,
  cupsSupport ? true,
  pulseSupport ? config.pulseaudio or stdenv.hostPlatform.isLinux,
  commandLineArgs ? "",
  pkgs,
}: let
  stdenv = pkgs.rustc.llvmPackages.stdenv;

  callPackageChromium = newScope chromium;

  chromium = rec {
    inherit stdenv upstream-info helium-patches;

    mkChromiumDerivation = callPackageChromium ./common.nix {
      nixpkgs = nixpkgsChromiumPath;
      inherit
        proprietaryCodecs
        cupsSupport
        pulseSupport
        ;

      gnChromium = buildPackages.gn.overrideAttrs (_: {
        version =
          if (upstream-info.deps.gn ? "version")
          then upstream-info.deps.gn.version
          else "0";
        src = fetchgit {
          url = "https://gn.googlesource.com/gn";
          inherit (upstream-info.deps.gn) rev hash;
        };
      });
    };

    browser = callPackageChromium ./browser.nix {};
  };

  sandboxExecutableName = chromium.browser.passthru.sandboxExecutableName;
in
  stdenv.mkDerivation {
    pname = "helium-browser";
    inherit (chromium.browser) version;

    nativeBuildInputs = [
      makeWrapper
      ed
    ];

    buildInputs = [
      # needed for GSETTINGS_SCHEMAS_PATH
      gsettings-desktop-schemas
      glib
      gtk3
      gtk4

      # needed for XDG_ICON_DIRS
      adwaita-icon-theme
    ];

    outputs = [
      "out"
      "sandbox"
    ];

    buildCommand = let
      browserBinary = "${chromium.browser}/libexec/chromium/chromium";
      libPath = lib.makeLibraryPath [
        libva
        pipewire
        wayland
        gtk3
        gtk4
      ];
    in
      ''
        mkdir -p "$out/bin"

        makeWrapper "${browserBinary}" "$out/bin/chromium" \
          --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
          --add-flags ${lib.escapeShellArg commandLineArgs}

        ed -v -s "$out/bin/chromium" << EOF
        2i

        if [ -x "/run/wrappers/bin/${sandboxExecutableName}" ]
        then
          export CHROME_DEVEL_SANDBOX="/run/wrappers/bin/${sandboxExecutableName}"
        else
          export CHROME_DEVEL_SANDBOX="$sandbox/bin/${sandboxExecutableName}"
        fi

        # Make generated desktop shortcuts have a valid executable name.
        export CHROME_WRAPPER='chromium'

      ''
      + lib.optionalString (libPath != "") ''
        # To avoid loading .so files from cwd, LD_LIBRARY_PATH here must not
        # contain an empty section before or after a colon.
        export LD_LIBRARY_PATH="\$LD_LIBRARY_PATH\''${LD_LIBRARY_PATH:+:}${libPath}"
      ''
      + ''

        # libredirect causes chromium to deadlock on startup
        export LD_PRELOAD="\$(echo -n "\$LD_PRELOAD" | ${coreutils}/bin/tr ':' '\n' | ${gnugrep}/bin/grep -v /lib/libredirect\\\\.so$ | ${coreutils}/bin/tr '\n' ':')"

        export XDG_DATA_DIRS=$XDG_ICON_DIRS:$GSETTINGS_SCHEMAS_PATH\''${XDG_DATA_DIRS:+:}\$XDG_DATA_DIRS

      ''
      + lib.optionalString (!xdg-utils.meta.broken) ''
        # Mainly for xdg-open but also other xdg-* tools (this is only a fallback; \$PATH is suffixed so that other implementations can be used):
        export PATH="\$PATH\''${PATH:+:}${xdg-utils}/bin"
      ''
      + ''

        .
        w
        EOF

        ln -sv "${chromium.browser.sandbox}" "$sandbox"

        ln -s "$out/bin/chromium" "$out/bin/chromium-browser"

        mkdir -p "$out/share"
        for f in '${chromium.browser}'/share/*; do # hello emacs */
          ln -s -t "$out/share/" "$f"
        done
      '';

    inherit (chromium.browser) packageName;
    meta = chromium.browser.meta;
    passthru = {
      inherit (chromium) upstream-info browser;
      mkDerivation = chromium.mkChromiumDerivation;
      inherit sandboxExecutableName;
    };
  }
