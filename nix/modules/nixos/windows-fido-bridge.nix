# The module's name before 0.2.0: imports wsl-fido-bridge and asks to switch.
{ flake, ... }:
{
  imports = [ flake.nixosModules.wsl-fido-bridge ];

  warnings = [
    "nixosModules.windows-fido-bridge is renamed to nixosModules.wsl-fido-bridge; import the new name."
  ];
}
