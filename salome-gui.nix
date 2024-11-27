{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  salome-kernel,
  salome-bootstrap,
  salome-configuration,
  python311,
  cppunit,
  pkg-config,
  opencascade-occt,
  libGLU,
  qt5,
  libsForQt5,
  tbb,
  vtk,
  boost,
  graphviz,
  hdf5-mpi,
  paraview,
  toybox,
  runCommand,
  xorg,
  gdal,
}:
let
  # https://www.mail-archive.com/debian-bugs-dist@lists.debian.org/msg1828544.html
  # https://github.com/ros-noetic-arch/ros-noetic-python-qt-binding/issues/7#issuecomment-1086668525
  patched-pyqt5 = runCommand "patched-pyqt5" {} ''
    cp -r ${python311.pkgs.pyqt5.out} $out
    chmod -R +w $out
    substituteInPlace $out/${python311.pkgs.python.sitePackages}/PyQt5/bindings/QtCore/QtCoremod.sip \
      --replace-fail ', py_ssize_t_clean=True' ""
  '';
in

stdenv.mkDerivation rec {
  pname = "gui";
  version = "9_13_0";

  CONFIGURATION_ROOT_DIR = salome-configuration;
  KERNEL_ROOT_DIR = salome-kernel;
  SALOMEBOOTSTRAP_ROOT_DIR = salome-bootstrap;

  cmakeFlags = [
    "-DSALOME_CMAKE_DEBUG=ON"
    "-Wno-dev"
#    "-DSALOME_USE_VTKVIEWER=OFF"
    "-DSALOME_BUILD_DOC=OFF"
    "-DVTK_DIR=${vtk.out}/lib/cmake/vtk"
    "-DVTK_ROOT_DIR=${vtk.out}/lib/cmake/vtk"
    "-DPYQT_SIPS_DIR=${patched-pyqt5}/${python311.pkgs.python.sitePackages}/PyQt5/bindings"
    "-DPYQT5_SIP_DIR=${patched-pyqt5}/${python311.pkgs.python.sitePackages}/PyQt5/bindings"
    "-DPYQT_SIP_DIR_OVERRIDE=${patched-pyqt5}/${python311.pkgs.python.sitePackages}/PyQt5/bindings"

  ];

  postConfigure = ''
    for i in $(grep -rl '/usr/bin/env')
    do
      substituteInPlace $i \
        --replace-fail '/usr/bin/env' '${toybox}/bin/env'
    done
  '';

  src = fetchFromGitHub {
    owner = "SalomePlatform";
    repo = "gui";
    rev = "V${version}";
    hash = "sha256-+w1z5R18G4Mv4rEcVd5+htDEjwqnTx0TAZ3jFsmanBQ=";
  };

  NIX_CFLAGS_COMPILE = "-Wno-error=format-security";
  #NIX_CFLAGS_COMPILE = "-I${paraview.out}/include/paraview-5.11 -Wno-error=format-security -L${vtk.out}/lib";

  buildInputs = [
    hdf5-mpi
    cppunit
    opencascade-occt
    libGLU
    python311.pkgs.omniorb
    python311.pkgs.omniorbpy
#    python311.pkgs.pyqt5
#    python311.pkgs.pyqt5_with_qtmultimedia
#    python311.pkgs.pyqtwebengine
#    python311.pkgs.numpy
    qt5.qtwayland
    qt5.qtmultimedia
    qt5.qtwebengine
    qt5.qtx11extras
    qt5.qttools
    vtk
    graphviz
    boost
    tbb
    paraview
#    libsForQt5.qwt
    libsForQt5.qwt6_1
    xorg.libXmu
    gdal
  ];

  nativeBuildInputs = [
    qt5.wrapQtAppsHook
    cmake
    pkg-config
    (python311.withPackages (p: with p; [
      numpy
      patched-pyqt5
      pyqtwebengine
      sip4
    ]))
  ];

  meta = {
    description = "GUI module implements general user interface services of SALOME platform";
    homepage = "https://github.com/SalomePlatform/gui";
    license = lib.licenses.lgpl21Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "gui";
    platforms = lib.platforms.all;
  };
}
