{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  llvmPackages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gklib";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "scivision";
    repo = "GKlib";
    rev = "078042614ff5192ab4c9bde0575bfef0d4572687";
    hash = "sha256-+XDJq+df12Gvks+PVyMg9V4Z2zaQWLomgZTrL7PNqHA=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = lib.optional stdenv.hostPlatform.isDarwin llvmPackages.openmp;

  cmakeFlags = [
    "-DIDXTYPEWIDTH=64" "-DREALTYPEWIDTH=64"
    (lib.cmakeBool "OPENMP" true)
    (lib.cmakeBool "BUILD_SHARED_LIBS" (!stdenv.hostPlatform.isStatic))
    # https://github.com/KarypisLab/GKlib/issues/11#issuecomment-1532597211
    (lib.cmakeBool "NO_X86" (!stdenv.hostPlatform.isx86_64))
  ];

  meta = {
    description = "Library of various helper routines and frameworks used by many of the lab's software";
    homepage = "https://github.com/KarypisLab/GKlib";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ natsukium ];
    platforms = lib.platforms.all;
  };
})

