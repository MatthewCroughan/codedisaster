{ lib, stdenv
, fetchurl
, cmake
, mpi
}:

stdenv.mkDerivation rec {
  pname = "parmetis";
  version = "4.0.3";

  src = fetchurl {
    url = "https://github.com/MatthewCroughan/codedisaster/releases/download/lost-archives/parmetis-4.0.3_aster3.tar.gz";
    sha256 = "sha256-pqsYhUZQdzK0Mm3ACpbWer02bIiAUXkEYh4xxQPNwEQ=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ mpi ];

  # metis and GKlib are packaged with distribution
  # AUR https://aur.archlinux.org/packages/parmetis/ has reported that
  # it easier to build with the included packages as opposed to using the metis
  # package. Compilation time is short.
  configurePhase = ''
    make config metis_path=$PWD/metis gklib_path=$PWD/metis/GKlib prefix=$out
  '';

  meta = with lib; {
    description = "An MPI-based parallel library that implements a variety of algorithms for partitioning unstructured graphs, meshes, and for computing fill-reducing orderings of sparse matrices";
    homepage = "http://glaros.dtc.umn.edu/gkhome/metis/parmetis/overview";
    platforms = platforms.all;
    license = licenses.unfree;
    maintainers = [ maintainers.costrouc ];
  };
}

