# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: {
  # example = pkgs.callPackage ./example { };
  playit = pkgs.callPackage ./playit.nix {};
  exfrp = pkgs.callPackage ./exfrp.nix {};
  godot_4_6_1 = pkgs.callPackage ./godot_4_6_1.nix {};
}
