{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gfortran,
  blas,
  lapack,
  scalapack,
  metis,
  scotch,
  mpi
}:
let
  srcTarball = fetchTarball {
    url = "https://mumps-solver.org/MUMPS_5.7.3.tar.gz";
    sha256 = "174xbs17h9p58qam1nlpdsfgvgfjmiailjibm3c9016fxc11ywk6";
  };
in
stdenv.mkDerivation {
  pname = "mumps";
  version = "unstable-2024-09-30";

  src = fetchFromGitHub {
    owner = "scivision";
    repo = "mumps";
    rev = "f998b0743c0b94d474b4c32a60f0d60f1708e2c8";
    hash = "sha256-Hv0UqloM8gfWQt23XajdkCRg9JXgUpOzt5vSlesPOWE=";
  };

  nativeBuildInputs = [
    cmake
    gfortran
  ];

  preConfigure = ''
    substituteInPlace CMakeLists.txt --replace-fail 'FetchContent_Populate(''${PROJECT_NAME} URL ''${url})' ""
    cp -r --no-preserve=mode ${srcTarball} /build/mumps-src
  '';

  cmakeFlags = [
    (lib.cmakeBool "BUILD_SHARED_LIBS" (!stdenv.hostPlatform.isStatic))
    "-Dmumps_SOURCE_DIR=/build/mumps-src"
  ];

  buildInputs = [
    mpi
    blas
    lapack
    metis
    scotch
    scalapack
  ];

  meta = {
    description = "MUMPS via CMake";
    homepage = "https://github.com/scivision/mumps.git";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "mumps";
    platforms = lib.platforms.all;
  };
}
