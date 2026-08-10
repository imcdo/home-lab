{pkgs, ...}: {
  home.packages = with pkgs; [
    fira-code
    kitty
    rectangle
    spotify
    gitlab-runner
  ];
}
