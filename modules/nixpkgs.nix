{
  thirdparty,
  lib,
  config,
  builderSystem,
  ...
}: let
  cfg = config.mth.target;

  makeMuslParsedPlatform = parsed: (parsed
    // {
      abi =
        {
          gnu = lib.systems.parse.abis.musl;
          gnueabi = lib.systems.parse.abis.musleabi;
          gnueabihf = lib.systems.parse.abis.musleabihf;
          gnuabin32 = lib.systems.parse.abis.muslabin32;
          gnuabi64 = lib.systems.parse.abis.muslabi64;
          gnuabielfv2 = lib.systems.parse.abis.musl;
          gnuabielfv1 = lib.systems.parse.abis.musl;
          # The following two entries ensure that this function is idempotent.
          musleabi = lib.systems.parse.abis.musleabi;
          musleabihf = lib.systems.parse.abis.musleabihf;
          muslabin32 = lib.systems.parse.abis.muslabin32;
          muslabi64 = lib.systems.parse.abis.muslabi64;
        }
        .${parsed.abi.name}
        or lib.systems.parse.abis.musl;
    });
in {
  options = with lib; {
    mth.target = {
      system = mkOption {
        type = types.enum ["x86_64-linux" "aarch64-linux"];
        description = "Target architecture.";
      };
      extraConfig = mkOption {
        type = mkOptionType {
          name = "nixpkgs crossSystem extra arguments";
          check = x: builtins.typeOf x == "set" && !(x ? "system") && !(x ? "parsed");
        };
        description = "Additional arguments to nixpkgs.crossSystem. Should NOT define system or parsed options.";
      };
    };
  };

  config = let
    llvmToolchain = let
      pkgs = import thirdparty.nixpkgs {
        system = builderSystem;
      };
    in
      pkgs.llvmPackages_latest;
    targetSystem = lib.systems.elaborate {system = cfg.system;};
  in {
    _module.args = {
      pkgs = import thirdparty.nixpkgs {
        localSystem = builderSystem;
        crossSystem =
          {
            parsed =
              makeMuslParsedPlatform targetSystem.parsed;
            useLLVM = true;
            linker = "lld";
            linux-kernel = let
              noBintools = {
                bootBintools = null;
                bootBintoolsNoLibc = null;
              };
              hostLLVM = llvmToolchain.override noBintools;
              buildLLVM = llvmToolchain.override noBintools;
            in
              targetSystem.linux-kernel
              // {
                makeFlags = [
                  "LLVM=1"
                  "LLVM_IAS=1"
                  "CC=${buildLLVM.clangUseLLVM}/bin/clang"
                  "LD=${buildLLVM.lld}/bin/ld.lld"
                  "HOSTLD=${hostLLVM.lld}/bin/ld.lld"
                  "AR=${buildLLVM.llvm}/bin/llvm-ar"
                  "HOSTAR=${hostLLVM.llvm}/bin/llvm-ar"
                  "NM=${buildLLVM.llvm}/bin/llvm-nm"
                  "STRIP=${buildLLVM.llvm}/bin/llvm-strip"
                  "OBJCOPY=${buildLLVM.llvm}/bin/llvm-objcopy"
                  "OBJDUMP=${buildLLVM.llvm}/bin/llvm-objdump"
                  "READELF=${buildLLVM.llvm}/bin/llvm-readelf"
                  "HOSTCC=${hostLLVM.clangUseLLVM}/bin/clang"
                  "HOSTCXX=${hostLLVM.clangUseLLVM}/bin/clang++"
                ];
              };
          }
          // cfg.extraConfig;
      };
    };
  };
}