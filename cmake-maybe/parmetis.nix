{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  metis,
  gklib,
  mpi,
}:

stdenv.mkDerivation {
  pname = "parmetis";
  version = "4.0.3";

  src = fetchFromGitHub {
    owner = "scivision";
    repo = "ParMETIS";
    rev = "c498ce4c742a6e89befe8050473ffed83622fe7e";
    hash = "sha256-veOvM1yjR+shMorWNlWsROnM6mIyWdsOWvUvtP3sqhI=";
  };

  nativeBuildInputs = [ cmake ];
  enableParallelBuilding = true;
  buildInputs = [ mpi gklib metis ];

  prePatch = ''
#    substituteInPlace CMakeLists.txt --replace-fail 'set(REALTYPEWIDTH 32)' 'set(REALTYPEWIDTH 64)'
    substituteInPlace CMakeLists.txt --replace-fail 'set(IDXTYPEWIDTH 32)' 'set(IDXTYPEWIDTH 64)'
  '';

  cmakeFlags = [
    "-DIDXTYPEWIDTH=64"
    #"-DREALTYPEWIDTH=64"
    "-DFETCHCONTENT_FULLY_DISCONNECTED=ON"
    "-DFETCHCONTENT_QUIET=OFF"
    (lib.cmakeBool "SHARED" (!stdenv.hostPlatform.isStatic))
  ];


#  configurePhase = ''
#    make config metis_path=metis gklib_path=gklib prefix=$out
#  '';

#  configurePhase = ''
#    cp --no-preserve=mode -r ${metis.src} ./metis
#    cp --no-preserve=mode -r ${gklib.src} ./metis/GKlib
#    make config metis_path=metis gklib_path=metis/GKlib prefix=$out
#
#    substituteInPlace metis-*/include/metis.h --replace-fail 'IDXTYPEWIDTH 32' 'IDXTYPEWIDTH 64'
#    substituteInPlace metis-*/include/metis.h --replace-fail 'REALTYPEWIDTH 32' 'REALTYPEWIDTH 64'
#
#
#  '';

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

