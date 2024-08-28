{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation rec {
  pname = "m-front-generic-interface-support";
  version = "2.2";

  src = fetchFromGitHub {
    owner = "thelfer";
    repo = "MFrontGenericInterfaceSupport";
    rev = "MFrontGenericInterfaceSupport-${version}";
    hash = "sha256-E0GjtCbApGt3vgfFMuNEoNmyyi84R2MH21P9jNU7MgI=";
  };

  nativeBuildInputs = [
    cmake
  ];

  meta = {
    description = "This project aims at providing support for MFront generic behaviours. This project can be embedded in open-source and propriary sofware";
    homepage = "https://github.com/thelfer/MFrontGenericInterfaceSupport";
    license = lib.licenses.cecill-c; # FIXME: nix-init did not find a license
    maintainers = with lib.maintainers; [ matthewcroughan ];
    mainProgram = "m-front-generic-interface-support";
    platforms = lib.platforms.all;
  };
}
