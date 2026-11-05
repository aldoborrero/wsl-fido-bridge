# The module's name before 0.2.0: imports wsl-fido-bridge and asks to switch.
{ flake, ... }:
{
  imports = [ flake.homeModules.wsl-fido-bridge ];

  warnings = [
    "homeModules.windows-fido-bridge is renamed to homeModules.wsl-fido-bridge; import the new name."
  ];
}
