{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  metis,
  mpi,
}:

stdenv.mkDerivation {
  pname = "parmetis";
  version = "4.0.3";

  src = fetchFromGitHub {
    owner = "KarypisLab";
    repo = "ParMETIS";
    rev = "d90a2a6cf08d1d35422e060daa28718376213659";
    hash = "sha256-22YQxwC0phdMLX660wokRgmAif/9tRbUmQWwNMZ//7M=";
  };

  nativeBuildInputs = [ cmake ];
  enableParallelBuilding = true;
  buildInputs = [ mpi ];

  configurePhase = ''
    tar xf ${metis.src}
    substituteInPlace Makefile --replace-fail \
       'CONFIG_FLAGS = -DCMAKE_VERBOSE_MAKEFILE=1' 'CONFIG_FLAGS = -DCMAKE_VERBOSE_MAKEFILE=1 -DIDXTYPEWIDTH=64 -DCMAKE_C_FLAGS="-DINTSIZE64 -DIDXTYPEWIDTH64" -DCMAKE_CXX_FLAGS="-DIDXTYPEWIDTH64 -DINTSIZE64"'
    mv metis-* metis
    make config metis_path=metis gklib_path=metis/GKlib prefix=$out

#    substituteInPlace metis-*/include/metis.h --replace-fail 'IDXTYPEWIDTH 32' 'IDXTYPEWIDTH 64'
#    substituteInPlace metis-*/include/metis.h --replace-fail 'REALTYPEWIDTH 32' 'REALTYPEWIDTH 64'
#

  '';

  meta = with lib; {
    description = "Parallel Graph Partitioning and Fill-reducing Matrix Ordering";
    longDescription = ''
      MPI-based parallel library that implements a variety of algorithms for
      partitioning unstructured graphs, meshes, and for computing fill-reducing
      orderings of sparse matrices.
      The algorithms implemented in ParMETIS are based on the multilevel
      recursive-bisection, multilevel k-way, and multi-constraint partitioning
      schemes
    '';
    homepage = "http://glaros.dtc.umn.edu/gkhome/metis/parmetis/overview";
    platforms = platforms.all;
    license = licenses.unfree;
    maintainers = [ maintainers.costrouc ];
  };
}

