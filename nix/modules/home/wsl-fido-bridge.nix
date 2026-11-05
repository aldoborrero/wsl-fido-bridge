{ flake, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.wsl-fido-bridge;
in
{
  # Lets the module be imported under both its names (see windows-fido-bridge.nix) without
  # declaring its options twice.
  key = "wsl-fido-bridge/home";

  # The option path before 0.2.0; definitions under it still apply, with a deprecation warning.
  imports = [
    (lib.mkRenamedOptionModule [ "programs" "windows-fido-bridge" ] [ "programs" "wsl-fido-bridge" ])
  ];

  options.programs.wsl-fido-bridge = {
    enable = lib.mkEnableOption "signing with FIDO keys attached to Windows, through WebAuthn, from OpenSSH in WSL";

    package = lib.mkOption {
      type = lib.types.package;
      default = flake.packages.${pkgs.stdenv.hostPlatform.system}.wsl-fido-bridge;
      defaultText = lib.literalExpression "wsl-fido-bridge.packages.\${system}.wsl-fido-bridge";
      description = "Package providing `lib/libwslfidobridge.so` and `lib/wslfidobridge.exe`.";
    };

    age = {
      enable = lib.mkEnableOption "age-plugin-yubikey on PATH, running the Windows build of the plugin so age and sops decrypt with YubiKeys (PIV) attached to Windows";

      package = lib.mkOption {
        type = lib.types.package;
        default = flake.packages.${pkgs.stdenv.hostPlatform.system}.age-plugin-yubikey-wsl;
        defaultText = lib.literalExpression "wsl-fido-bridge.packages.\${system}.age-plugin-yubikey-wsl";
        description = "Package providing `bin/age-plugin-yubikey`, the shim that runs `lib/age-plugin-yubikey.exe`.";
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      # ssh, ssh-keygen and ssh-add use this middleware for every `-sk` key.
      home.sessionVariables.SSH_SK_PROVIDER = "${cfg.package}/lib/libwslfidobridge.so";

      # Only takes effect with home-manager's ssh-agent (services.ssh-agent.enable);
      # it only loads middleware from /usr/lib* unless told otherwise (-P).
      services.ssh-agent.pkcs11Whitelist = [ "${cfg.package}/lib/*" ];
    })

    # hiPrio: age looks the plugin up by name on PATH, so this shim must win over a Linux
    # age-plugin-yubikey, which finds no reader in WSL.
    (lib.mkIf cfg.age.enable {
      home.packages = [ (lib.hiPrio cfg.age.package) ];
    })
  ];
}
