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
}:

stdenv.mkDerivation rec {
  pname = "gui";
  version = "9_13_0";

  CONFIGURATION_ROOT_DIR = salome-configuration;
  KERNEL_ROOT_DIR = salome-kernel;
  SALOMEBOOTSTRAP_ROOT_DIR = salome-bootstrap;

  cmakeFlags = [
    "-DSALOME_CMAKE_DEBUG=ON"
    "-DPYQT_SIPS_DIR=${python311.pkgs.pyqt5}/${python311.pkgs.python.sitePackages}/PyQt5/bindings"
  ];

  src = fetchFromGitHub {
    owner = "SalomePlatform";
    repo = "gui";
    rev = "V${version}";
    hash = "sha256-+w1z5R18G4Mv4rEcVd5+htDEjwqnTx0TAZ3jFsmanBQ=";
  };

  buildInputs = [
    cppunit
    opencascade-occt
    libGLU
    python311.pkgs.omniorb
    python311.pkgs.pyqt5
    python311.pkgs.pyqt5_with_qtmultimedia
    python311.pkgs.pyqt5-sip
    python311.pkgs.omniorbpy
    python311.pkgs.sip4
    python311.pkgs.pyqtwebengine
    qt5.qtwayland
    qt5.qtmultimedia
    qt5.qtwebengine
    qt5.qtx11extras
    qt5.qttools
  ];

  nativeBuildInputs = [
    qt5.wrapQtAppsHook
    cmake
    pkg-config
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
