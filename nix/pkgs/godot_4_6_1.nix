# nixpkgs only keeps the latest patch per minor (4.6.3), so pin the exact 4.6.1 source.
{
  godotPackages_4_6,
  fetchFromGitHub,
}:
godotPackages_4_6.godot.overrideAttrs (_old: {
  version = "4.6.1-stable";
  src = fetchFromGitHub {
    owner = "godotengine";
    repo = "godot";
    tag = "4.6.1-stable";
    hash = "sha256-70r5RwHtLFGwDBiUuJab6C5OZHmkJ4QwVFnRX+J6PlI=";
    leaveDotGit = true;
    postFetch = ''
      hash=$(git -C "$out" rev-parse HEAD)
      rm -r "$out"/.git
      mkdir "$out"/.git
      echo "$hash" > "$out"/.git/HEAD
    '';
  };
})
