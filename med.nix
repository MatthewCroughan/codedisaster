{ lib
, stdenv
, mpi
, omniorb
, omniorbpy
, gfortran
, medcoupling
, fetchgit
, cmake
, libtirpc
, python311
, cppunit
, pkg-config
, swig
, hdf5-mpi
, medfile
, salome-kernel
, salome-configuration
}:
stdenv.mkDerivation rec {
  pname = "med";
  version = "9_11_0";

  cmakeFlags = [
    "-Wno-dev"

    "-DSALOME_FIELDS_ENABLE_PYTHON=ON"
    "-DSALOME_USE_MPI=ON"
    "-DMED_ENABLE_PYTHON=ON"

    "-DSALOME_BUILD_GUI=0"
    "-DSALOME_BUILD_DOC=0"

#    "-DMEDCOUPLING_USE_64BIT_IDS=0"
    "-DMEDCOUPLING_ROOT_DIR=${medcoupling}"
  ];

#  prePatch = ''
#    substituteInPlace src/MEDCalculator/Swig/SPythonParser.cxx --replace-fail \
#      'PyUnicode_AS_UNICODE' 'Py_UCS4'
#  '';

  CONFIGURATION_ROOT_DIR = salome-configuration;
  KERNEL_ROOT_DIR = salome-kernel;

#  OMNIORB_ROOT_DIR = "${omniorb}";
#  OMNIORBPY_ROOT_DIR = "${omniorbpy}";

  src = fetchgit {
    url = "http://git.salome-platform.org/gitpub/modules/med.git";
    rev = "V${version}";
    hash = "sha256-GkILRk3uUfgAGLYycnfM3L8EgEwce6baSiDibE5reEs=";
#    rev = "V9_13";
#    hash = "sha256-BnbxFmUIJCCRfVCa2X8tnLyz9suHjoIzlc8HtAbexiM=";
  };

  nativeBuildInputs = [
    gfortran
    cmake
    pkg-config
    swig
    (python311.withPackages (p: with p; [ numpy scipy ]))
  ];

  buildInputs = [
    hdf5-mpi
    libtirpc
    cppunit
    omniorb
    omniorbpy
    medfile
  ];

  postFixup = ''
    cd $out/lib/python3*/site-packages/salome
    ln -s $(pwd)/SALOME_MED $(pwd)/med
    cd -
  '';

  meta = with lib; {
    description = "";
    homepage = "http://git.salome-platform.org/gitpub/modules/med.git";
    license = licenses.lgpl21Only;
    maintainers = with maintainers; [ ];
    mainProgram = "med";
    platforms = platforms.all;
  };
}
