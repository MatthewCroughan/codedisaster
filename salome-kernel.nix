{ lib
, stdenv
, cppunit
, mpi
, omniorb
, omniorbpy
, pkg-config
, fetchgit
, cmake
, python311
, libxml2
, swig
, hdf5-mpi
, boost
, salome-configuration
}:
let
  hdf5 = hdf5-mpi;
in
stdenv.mkDerivation rec {
  pname = "kernel";
  version = "9_11_0";

  CONFIGURATION_ROOT_DIR = salome-configuration;

  src = fetchgit {
    url = "http://git.salome-platform.org/gitpub/modules/kernel.git";
    rev = "V${version}";
    hash = "sha256-5tnVdovMhyDNRMX/OGhUu9cr7zC5ElUO+QQWaeUzeEA="; # V9_11_0
#    hash = "sha256-VILB2i7CZ5XLPmnyEVFLyae0drkQwTNnB8AU1VYqlGg="; # V9_12_0
#    hash = "sha256-utGnUsxwxosu7zCwM5nGcpHO5sjDL4pU7aryxDoH+vU="; # V9_13_0
  };

  prePatch = ''
    # include/omniORB4/acconfig.h in omniorb 24.05 defines OMNI_SIZEOF_INT
    # include/omniORB4/acconfig.h in omniorb 20.09 defines SIZEOF_INT So as a
    # result anything depending on omniorb and using the SIZEOF_INT will no
    # longer be able to find it due to this new namespacing
    substituteInPlace src/DSC/DSC_User/Datastream/Calcium/calciumf.c \
      --replace-fail 'SIZEOF_INT' 'OMNI_SIZEOF_INT' \
      --replace-fail 'SIZEOF_LONG' 'OMNI_SIZEOF_LONG'
  '';

  cmakeFlags = [
    "-Wno-dev"

    "-DSALOME_USE_MPI=ON"

    "-DSALOME_BUILD_DOC=no"
    "-DLIBXML2_INCLUDE_DIR=${libxml2.dev}/include/libxml2"
    "-DLIBXML2_LIBRARY=${libxml2.out}/lib/libxml2${stdenv.hostPlatform.extensions.sharedLibrary}"
#    "-DLIBXML2_LIBRARY=${(libxml2.override { enableStatic = true; })}"
#    "-DHDF5_C_INCLUDE_DIR=${hdf5.dev}/include"
#    "-DHDF5_hdf5_LIBRARY=${hdf5.bin}"
#    "-DHDF5_LIBRARY=${hdf5.out}"
#    "-DHDF5_ROOT_DIR=${hdf5.dev}"
#    "-DLIBXML2_ROOT_DIR=${libxml2.src}"
#    "-DBOOST_ROOT_DIR=${boost.dev}"
#    "-DOMNIORB_ROOT_DIR=${omniorb}"
#    "-DOMNIORBPY_ROOT_DIR=${omniorbpy}"
  ];
  nativeBuildInputs = [
    cmake
    cppunit
    pkg-config
    (python311.withPackages (p: with p; [ numpy scipy psutil ]))
    swig
  ];
  buildInputs = [
    mpi
    boost
    hdf5
    omniorb
    omniorbpy
    libxml2
  ];

  meta = with lib; {
    description = "";
    homepage = "http://git.salome-platform.org/gitpub/modules/kernel.git";
    license = licenses.lgpl21Only;
    maintainers = with maintainers; [ matthewcroughan ];
    mainProgram = "kernel";
    platforms = platforms.all;
  };
}
