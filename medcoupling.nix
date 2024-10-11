{ lib
, stdenv
, libtirpc
, swig
, cppunit
, libxml2
, metis
, scotch
, parmetis
, boost
, python311
, graphviz
, cmake
, pkg-config
, hdf5-mpi
, mpi
, medfile
, salome-configuration
}:
stdenv.mkDerivation {
  pname = "medcoupling";
  version = "9_11_0";

  CONFIGURATION_ROOT_DIR = salome-configuration;

  src = builtins.fetchGit {
    url = "http://git.salome-platform.org/gitpub/tools/medcoupling.git";
    rev = "1b5fb5650409b0ad3a61da3215496f2adf2dae02"; # V9_11_0
  };

#  prePatch = ''
#    for i in $(grep -rl 'ParMETIS_')
#    do
#      substituteInPlace $i \
#        --replace-fail 'ParMETIS_' 'ParMETIS_V3_'
#    done
#  '';

#  env.NIX_CFLAGS_COMPILE = "-std=c++11 -DMED_INT_IS_LONG";

  cmakeFlags = [
    "-DSALOME_USE_MPI=ON"

    "-DMEDCOUPLING_USE_MPI=ON"
    "-DCMAKE_Fortran_COMPILER=mpif90"

#    "-DMEDCOUPLING_MICROMED=ON"
#    "-DMEDCOUPLING_ENABLE_PYTHON=ON"

    "-DMEDCOUPLING_BUILD_DOC=OFF"

    "-DMEDCOUPLING_ENABLE_PARTITIONER=ON" # Need to make a choice of scotch or ptscotch
    "-DMEDCOUPLING_PARTITIONER_PARMETIS=OFF"
    "-DMEDCOUPLING_PARTITIONER_METIS=OFF"
    "-DMEDCOUPLING_PARTITIONER_SCOTCH=OFF"
    "-DMEDCOUPLING_PARTITIONER_PTSCOTCH=ON"

    "-DLIBXML2_INCLUDE_DIR=${libxml2.dev}/include/libxml2"
    "-DLIBXML2_LIBRARY=${libxml2.out}/lib/libxml2${stdenv.hostPlatform.extensions.sharedLibrary}"
    "-DMEDCOUPLING_USE_64BIT_IDS=ON"
    "-Wno-dev"
  ];


  nativeBuildInputs = [
    swig
    cmake
    pkg-config
  ];

  buildInputs = [
    hdf5-mpi
    parmetis
    mpi
#    parmetis
    scotch
    libtirpc
    medfile
    cppunit
    libxml2
    metis
#    scotch
    boost
#    sphinx
#    doxygen
    graphviz
    (python311.withPackages (p: with p; [ numpy scipy ]))
  ];

  meta = with lib; {
    description = "";
    homepage = "http://git.salome-platform.org/gitpub/tools/medcoupling.git";
    license = licenses.lgpl21Only;
    maintainers = with maintainers; [ matthewcroughan ];
    mainProgram = "medcoupling";
    platforms = platforms.all;
  };
}
