{ lib, stdenv, fetchurl, cmake, hdf5, mpi }:

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

  # CMAKE_Fortran_COMPILER
  preConfigure = ''
    export FC=mpif90
  '';

  cmakeFlags = [
    "-DMEDFILE_USE_MPI=ON"
    "-DMED_MEDINT_TYPE=long"
    ''-DCMAKE_Fortran_FLAGS="-fdefault-integer-8"''
  ];

  nativeBuildInputs = [ cmake mpi ];
  buildInputs = [ hdf5 ];

  checkPhase = "make test";

  postInstall = "rm -r $out/bin/testc";

  meta = with lib; {
    description = "Library to read and write MED files";
    homepage = "http://salome-platform.org/";
    platforms = platforms.linux;
    license = licenses.lgpl3Plus;
  };
}

