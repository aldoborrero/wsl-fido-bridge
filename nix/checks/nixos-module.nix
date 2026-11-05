# Evaluates the NixOS module and checks what it wires up, without building a system.
{
  flake,
  inputs,
  pkgs,
  system,
  ...
}:
let
  eval =
    modules:
    (inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      modules = modules ++ [
        {
          programs.ssh.startAgent = true;
          boot.isContainer = true;
          system.stateVersion = "26.05";
        }
      ];
    }).config;
  cfg = eval [
    flake.nixosModules.wsl-fido-bridge
    {
      programs.wsl-fido-bridge.enable = true;
      programs.wsl-fido-bridge.age.enable = true;
    }
  ];
  # The names before 0.2.0, next to the new module name: same result, plus deprecation warnings.
  legacy = eval [
    flake.nixosModules.wsl-fido-bridge
    flake.nixosModules.windows-fido-bridge
    { programs.windows-fido-bridge.enable = true; }
  ];
  package = flake.packages.${system}.wsl-fido-bridge;
  agePackage = flake.packages.${system}.age-plugin-yubikey-wsl;
in
assert cfg.environment.variables.SSH_SK_PROVIDER == "${package}/lib/libwslfidobridge.so";
# hasInfix builds a regex, which may not carry store-path context.
assert pkgs.lib.hasInfix (builtins.unsafeDiscardStringContext "-P ${package}/lib/*") (
  builtins.unsafeDiscardStringContext cfg.systemd.user.services.ssh-agent.serviceConfig.ExecStart
);
# The age shim is on PATH, raised above any other age-plugin-yubikey.
assert builtins.any (
  p: p.outPath == agePackage.outPath && p.meta.priority < 5
) cfg.environment.systemPackages;
assert legacy.environment.variables.SSH_SK_PROVIDER == cfg.environment.variables.SSH_SK_PROVIDER;
assert builtins.any (pkgs.lib.hasInfix "programs.windows-fido-bridge") legacy.warnings;
assert builtins.any (pkgs.lib.hasInfix "nixosModules.wsl-fido-bridge") legacy.warnings;
assert flake.packages.${system}.windows-fido-bridge.outPath == package.outPath;
pkgs.runCommand "nixos-module-check" { } "touch $out"
