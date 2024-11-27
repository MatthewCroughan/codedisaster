{
  lib,
  clangStdenv,
  stdenv,
  fetchFromGitHub,
  cmake,
  salome-configuration,
  salome-kernel,
  salome-gui,
  vtk,
  xorg,
  medcoupling,
  medfile,
  med,
  python311,
  qt5,
  mpi,
  tbb,
  ninja,
  paraview,
  ffmpeg,
  gdal,
  cppunit,
  pkg-config,
  boost,
  hdf5,
}:
stdenv.mkDerivation rec {
  pname = "paravis";
  version = "9_13_0";

  CONFIGURATION_ROOT_DIR = salome-configuration;
  KERNEL_ROOT_DIR = salome-kernel;
  GUI_ROOT_DIR = salome-gui;

  env.CXXFLAGS = "";
  NIX_CFLAGS_COMPILE = "-I${med}/include/salome -Wno-error";

  prePatch = ''
    substituteInPlace src/Plugins/StaticMesh/CMakeLists.txt --replace-fail 'ENABLE_BY_DEFAULT YES' 'ENABLE_BY_DEFAULT NO'
  '';

  src = fetchFromGitHub {
    owner = "SalomePlatform";
    repo = "paravis";
    rev = "V${version}";
    hash = "sha256-UGZkSDymTJYDXXXss9iGwG81sT9Roiyk6baRyHVYQxU=";
  };

  buildInputs = [
    paraview
    ffmpeg
    xorg.libXmu
    vtk
    gdal
    mpi
    hdf5
    boost
    #qt5.qtbase
    #qt5.qttools
    #qt5.qtx11extras
    #qt5.qtwebengine
    #qt5.qtxmlpatterns
    qt5.full
    medfile
    medcoupling
    med
  ];



  cmakeFlags = [
    "-DMEDREADER_USE_MPI=NO"
    "-DSALOME_LIGHT_ONLY=YES"
    "-DSALOME_CXX_STANDARD=20"
    "-DSALOME_USE_MPI=ON"
    "-DSALOME_BUILD_TESTS=OFF"
    "-Wno-dev"
#    "--trace"

# This thing caused major headache..
#"-DVTK_DIR=${vtk.out}/lib/cmake/vtk"

"-DBUILD_SHARED_LIBS=YES"
#    "-DVTK_ROOT_DIR=${vtk.out}/lib/cmake/vtk"
#     "-DTBB_DIR=${tbb.out}/lib"
"-DSALOME_BUILD_DOC=NO"

#"-DPARAVIEW_USE_MPI=ON"
#    "-DVTKm_ENABLE_MPI=ON"

#"-DVTK_USE_64BIT_IDS=ON"

    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DCMAKE_INSTALL_INCLUDEDIR=include"
    "-DCMAKE_INSTALL_BINDIR=bin"
  ];

  nativeBuildInputs = [
    tbb
    cppunit
    pkg-config
    qt5.wrapQtAppsHook
    cmake
    python311
  ];

  meta = {
    description = "SALOME ParaView Interface";
    homepage = "https://github.com/SalomePlatform/paravis.git";
    license = lib.licenses.lgpl21Only;
    maintainers = with lib.maintainers; [ matthewcroughan ];
    mainProgram = "paravis"; platforms = lib.platforms.all;
  };
}
