{ stdenv, fetchurl, autoPatchelfHook, lib, system }:

let
  # Unique hashes for each architecture
  # Use lib.fakeHash or "" to find the real hash via the build error
  hashMap = {
    "x86_64-linux" = "sha256-Fp1di/cNDTXZY8zWyNjq8w3lFJJvyqWzlvp4Ai2SxKk=";
    "aarch64-linux" = lib.fakeHash;
    "armv7l-linux" = lib.fakeHash;
  };

  # Mapping Nix system strings to the file names in your URL
  archMap = {
    "x86_64-linux" = "amd64";
    "aarch64-linux" = "arm64";
    "armv7l-linux" = "arm"; # or "arm_hf" depending on your hardware
  };

  binaryArch = archMap.${system} or (throw "Unsupported system: ${system}");
in
stdenv.mkDerivation {
  pname = "exfrpc";
  version = "latest"; # Since the URL doesn't specify a version

  src = fetchurl {
    url = "https://pub-a91abe751f2a41938780d4389c4ccd05.r2.dev/exfrpc/exfrpc_linux_${binaryArch}";
    hash = hashMap.${system} or "";
  };

  # The source is a single binary, not an archive to be extracted
  dontUnpack = true;

  nativeBuildInputs = [ autoPatchelfHook ];

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/exfrpc
    chmod +x $out/bin/exfrpc
  '';

  meta = with lib; {
    description = "Extended Fast Reverse Proxy Client";
    homepage = "https://pub-a91abe751f2a41938780d4389c4ccd05.r2.dev/exfrpc/";
    platforms = platforms.linux;
  };
}