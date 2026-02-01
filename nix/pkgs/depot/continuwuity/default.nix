# Adapted from https://github.com/NixOS/nixpkgs/blob/nixos-25.11/pkgs/by-name/ma/matrix-continuwuity/package.nix
{
  lib,
  rustPlatform,
  pkg-config,
  bzip2,
  zstd,
  rocksdb,
  applyPatches,
  continuwuitySrc,
  rocksdbSrc,
}: let
  rocksdb' =
    (rocksdb.overrideAttrs (old: {
      src = rocksdbSrc;
      version = "continuwuity";
      postPatch = ''
        sed -e '1i #include <cstdint>' -i db/compaction/compaction_iteration_stats.h
        sed -e '1i #include <cstdint>' -i table/block_based/data_block_hash_index.h
        sed -e '1i #include <cstdint>' -i util/string_util.h
        sed -e '1i #include <cstdint>' -i include/rocksdb/utilities/checkpoint.h
      '';
    })).override {
      enableLiburing = false;
    };
in
  rustPlatform.buildRustPackage {
    pname = "continuwuity";
    version = "main";

    src = applyPatches {
      name = "continuwuity";
      src = continuwuitySrc;
      patches = [./systemd-fds.patch];
    };

    cargoHash = "sha256-PGDHb5QjjdoGhoj+2HAt5JyLqB5sX5r/n1sBi8Goo4k=";

    nativeBuildInputs = [
      pkg-config
      rustPlatform.bindgenHook
    ];

    buildInputs = [
      bzip2
      zstd
    ];

    env = {
      ZSTD_SYS_USE_PKG_CONFIG = true;
      ROCKSDB_INCLUDE_DIR = "${rocksdb'}/include";
      ROCKSDB_LIB_DIR = "${rocksdb'}/lib";
    };

    doCheck = false;

    buildNoDefaultFeatures = true;

    # https://forgejo.ellis.link/continuwuation/continuwuity/src/branch/main/Cargo.toml
    buildFeatures = [
      "brotli_compression"
      "element_hacks"
      "gzip_compression"
      "release_max_log_level"
      "systemd"
      "zstd_compression"
      "journald"
      #"url_preview"
      "otlp_telemetry"
      "media_thumbnail"
      "blurhashing"
    ];

    meta = {
      description = "Matrix homeserver written in Rust, forked from conduwuit";
      license = lib.licenses.asl20;
      mainProgram = "conduwuit";
    };
  }
