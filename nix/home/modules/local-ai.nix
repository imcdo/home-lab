{ pkgs, lib, ... }:

{
  # Local AI tooling for personal macOS machines.
  home.packages =
    lib.optionals (pkgs ? ollama) [
      pkgs.ollama
    ]
    ++ lib.optionals (pkgs ? aichat) [
      pkgs.aichat
    ]
    ++ lib.optionals (pkgs ? "llama-cpp") [
      pkgs."llama-cpp"
    ];

  programs.zsh.shellAliases = {
    oa = "ollama";
    oa-serve = "ollama serve";
    oa-ps = "ollama ps";
    oa-pull-chat = "ollama pull qwen2.5:7b";
    oa-run-chat = "ollama run qwen2.5:7b";
    oa-pull-code = "ollama pull qwen2.5-coder:7b";
    oa-run-code = "ollama run qwen2.5-coder:7b";
  };
}
