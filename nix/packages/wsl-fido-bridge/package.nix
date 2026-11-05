{
  lib,
  craneLib,
  commonArgs,
  cargoArtifacts,
  windowsArgs,
  windowsArtifacts,
  runCommand,
}:
let
  # libwslfidobridge.so: the middleware OpenSSH loads via SSH_SK_PROVIDER.
  middleware = craneLib.buildPackage (
    commonArgs
    // {
      inherit cargoArtifacts;
      pname = "wsl-fido-bridge-middleware";
      cargoExtraArgs = "--locked --package sk-middleware";
      doCheck = false; # checks.tests runs the whole workspace's tests
    }
  );

  # wslfidobridge.exe: talks to webauthn.dll; launched through WSL interop.
  bridge = craneLib.buildPackage (windowsArgs // { cargoArtifacts = windowsArtifacts; });
in
# The middleware looks for the executable next to itself, so both land in lib/.
runCommand "wsl-fido-bridge-${middleware.version}"
  {
    passthru = { inherit middleware bridge; };

    meta = {
      description = "OpenSSH security key middleware that signs with FIDO keys through Windows WebAuthn from WSL";
      homepage = "https://github.com/aldoborrero/wsl-fido-bridge";
      license = lib.licenses.asl20;
      sourceProvenance = with lib.sourceTypes; [ fromSource ];
      maintainers = with lib.maintainers; [ aldoborrero ];
      platforms = [ "x86_64-linux" ];
    };
  }
  ''
    install -Dm755 ${middleware}/lib/libwslfidobridge.so $out/lib/libwslfidobridge.so
    install -Dm755 ${bridge}/bin/wslfidobridge.exe $out/lib/wslfidobridge.exe
  ''
