{ lib, stdenv, fetchurl, cmake, hdf5 }:

stdenv.mkDerivation rec {
  pname = "medfile";
  version = "4.1.1";

  src = fetchurl {
    url = "http://files.salome-platform.org/Salome/other/med-${version}.tar.gz";
    sha256 = "sha256-3CtdVOvwZm4/8ul0BB0qsNqQYGEyNTcCOrFl1XM4ndA=";
  };

  patches = [
    ./hdf5-1.14.patch
  ];

  nativeBuildInputs = [ cmake ];
  buildInputs = [ hdf5 ];

  cmakeFlags = [
    "-DMEDFILE_USE_MPI=ON"
    "-DMED_MEDINT_TYPE=long long"
  ];

  checkPhase = "make test";

  postInstall = "rm -r $out/bin/testc";

  meta = with lib; {
    description = "Library to read and write MED files";
    homepage = "http://salome-platform.org/";
    platforms = platforms.linux;
    license = licenses.lgpl3Plus;
  };
}
#{ lib, stdenv, fetchurl, cmake, mpi, hdf5-mpi, gfortran }:
#
#stdenv.mkDerivation (finalAttrs: {
#  pname = "medfile";
#  version = "5.0.0";
#
#  postFixup = "mv $out/lib/libmedC.so $out/lib/libmed.so";
#
##  env.NIX_CFLAGS_COMPILE = "-DH5_USE_18_API";
#
#  cmakeFlags = [
#    "-DMEDFILE_USE_MPI=ON"
#    "-DMED_MEDINT_TYPE=long"
#    ''-DCMAKE_Fortran_FLAGS="-fdefault-integer-8"''
##    "-DCMAKE_C_COMPILER=mpicc"
##    "-DCMAKE_CXX_COMPILER=mpic++"
##    "-DCMAKE_Fortran_COMPILER=mpif77"
##    "-DCMAKE_C_COMPILER=mpicc"
##    "-DCMAKE_CXX_COMPILER=mpic++"
##    "-DCMAKE_Fortran_COMPILER=mpif90"
#
##    "-DMEDFILE_BUILD_SHARED_LIBS=0"
##    "-DMEDFILE_BUILD_STATIC_LIBS=1"
##    "-DENABLE_FORTRAN=1"
#
#  ];
#
#  src = fetchurl {
#    url = "https://files.salome-platform.org/Salome/medfile/med-${finalAttrs.version}.tar.bz2";
#    hash = "sha256-Jn520MZ+xRwQ4xmUhOwVCLqo1e2EXGKK32YFKdzno9Q=";
#  };
#
#  outputs = [ "out" "doc" "dev" ];
#
#  postPatch = ''
#    # Patch cmake and source files to work with hdf5
#    substituteInPlace config/cmake_files/medMacros.cmake --replace-fail \
#      "IF (NOT HDF_VERSION_MAJOR_REF EQUAL 1 OR NOT HDF_VERSION_MINOR_REF EQUAL 12 OR NOT HDF_VERSION_RELEASE_REF GREATER 0)" \
#      "IF (HDF5_VERSION VERSION_LESS 1.12.0)"
#    substituteInPlace src/*/*.c --replace-warn \
#      "#if H5_VERS_MINOR > 12" \
#      "#if H5_VERS_MINOR > 14"
#  '' + lib.optionalString stdenv.isDarwin ''
#    # Some medfile test files #define _a, which
#    # breaks system header files that use _a as a function parameter
#    substituteInPlace tests/c/*.c \
#      --replace-warn "_a" "_A" \
#      --replace-warn "_b" "_B"
#    # Fix compiler errors in test files
#    substituteInPlace tests/c/*.c \
#      --replace-warn "med_Bool" "med_bool" \
#      --replace-warn "med_Axis_type" "med_axis_type" \
#      --replace-warn "med_Access_mode" "med_access_mode"
#  '';
#
#  nativeBuildInputs = [ cmake gfortran ];
#
#  buildInputs = [ hdf5-mpi mpi ];
#
#  checkPhase = "make test";
#
#  postInstall = "rm -r $out/bin/testc";
#
#  meta = with lib; {
#    description = "Library to read and write MED files";
#    homepage = "https://salome-platform.org/";
#    platforms = platforms.linux ++ platforms.darwin;
#    license = licenses.lgpl3Plus;
#  };
#})
#
