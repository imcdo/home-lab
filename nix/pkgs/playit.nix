{ stdenv, fetchurl, autoPatchelfHook, system }:

let
  # Update version here
  version = "0.17.1";

  # Map Nix system names to Playit's naming convention
  archMap = {
    "x86_64-linux" = "amd64";
    "aarch64-linux" = "arm64";
  };

  # Unique hashes for each architecture
  hashMap = {
    "x86_64-linux" = "sha256-4Y90fA3LPDYfIOnS8L73U9N9HzZf6EWs0Jpbm0X0C7w=";
    "aarch64-linux" = "sha256-insert-arm64-hash-here="; # Get this via nix-prefetch-url
  };

  playitArch = archMap.${system} or (throw "Unsupported system: ${system}");
in
stdenv.mkDerivation {
  pname = "playit";
  inherit version;

  src = fetchurl {
    url = "https://github.com/playit-cloud/playit-agent/releases/download/v${version}/playit-linux-${playitArch}";
    hash = hashMap.${system} or "";
  };

  # Binary is a single file, so we skip standard unpack
  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/playit
    chmod +x $out/bin/playit
  '';

  nativeBuildInputs = [ autoPatchelfHook ];
}
