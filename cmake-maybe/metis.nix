{ lib, stdenv, fetchFromGitHub, fetchpatch, cmake, gklib, llvmPackages }:

stdenv.mkDerivation (finalAttrs: {
  pname = "metis";
  version = "5.2.1";

  src = fetchFromGitHub {
    owner = "scivision";
    repo = "METIS";
    rev = "225cc33d89ed46c42d10629de6f892af67bea1df";
#    hash = "sha256-4+i9X4GhGTeJ7tecatswkBW+U6LGjREhyXss8fXHM38=";
    hash = "sha256-CnsP1c9Plna2Wp85pgQrHMKNWbi6Mbd4554RbHDS/mg=";
    postFetch = ''
      substituteInPlace $out/include/metis.h --replace-fail '//#define IDXTYPEWIDTH 32' '#define IDXTYPEWIDTH 64'
      substituteInPlace $out/include/metis.h --replace-fail '//#define REALTYPEWIDTH 32' '#define REALTYPEWIDTH 32'
    '';
  };

#  patches = [
#    # fix gklib link error
#    (fetchpatch {
#      url = "https://gitweb.gentoo.org/repo/gentoo.git/plain/sci-libs/metis/files/metis-5.2.1-add-gklib-as-required.patch?id=c78ecbd3fdf9b33e307023baf0de12c4448dd283";
#      hash = "sha256-uoXMi6pMs5VrzUmjsLlQYFLob1A8NAt9CbFi8qhQXVQ=";
#    })
#  ];

#  prePatch = ''
#    substituteInPlace CMakeLists.txt --replace-fail ',32' ',64'
#  '';

  nativeBuildInputs = [ cmake ];

  buildInputs = [ gklib ] ++ lib.optional stdenv.hostPlatform.isDarwin llvmPackages.openmp;


#  preConfigure = ''

#    make config
#  '';

  cmakeFlags = [
    "-DIDXTYPEWIDTH=64"
#    "-DREALTYPEWIDTH=64"
    "-DFETCHCONTENT_FULLY_DISCONNECTED=ON"
    "-DFETCHCONTENT_QUIET=OFF"
    (lib.cmakeFeature "GKLIB_PATH" "${gklib}")
    (lib.cmakeBool "OPENMP" true)
    (lib.cmakeBool "SHARED" (!stdenv.hostPlatform.isStatic))
  ];

  meta = {
    description = "Serial graph partitioning and fill-reducing matrix ordering";
    homepage = "http://glaros.dtc.umn.edu/gkhome/metis/metis/overview";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
  };
})

#{ lib, stdenv, fetchFromGitHub, unzip, cmake }:
#
#stdenv.mkDerivation {
#  pname = "metis";
#  version = "5.1.1";
#
#  src = fetchFromGitHub {
#    owner = "KarypisLab";
#    repo = "METIS";
#    rev = "8a0ea2c3011b8bbe2186dd0294acea763f757e04";
#    fetchSubmodules = true;
#    hash = "sha256-a9UcS5JK4qX3dAdpVnAx8caWTdRTBEM66+G/h4lYiAY=";
#    postFetch = ''
#      substituteInPlace $out/include/metis.h --replace-fail '#define IDXTYPEWIDTH 32' '#define IDXTYPEWIDTH 64'
#    '';
#  };
#
#  cmakeFlags = [
#    "-DGKLIB_PATH=../GKlib"
#    # remove once updated past https://github.com/KarypisLab/METIS/commit/521a2c360dc21ace5c4feb6dc0b7992433e3cb0f
#    "-DCMAKE_SKIP_BUILD_RPATH=ON"
#  ];
#  nativeBuildInputs = [ unzip cmake ];
#
#  meta = {
#    description = "Serial graph partitioning and fill-reducing matrix ordering";
#    homepage = "http://glaros.dtc.umn.edu/gkhome/metis/metis/overview";
#    license = lib.licenses.asl20;
#    platforms = lib.platforms.all;
#  };
#}
