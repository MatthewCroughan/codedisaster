{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  salome-configuration,
}:

stdenv.mkDerivation rec {
  pname = "salome-bootstrap";
  version = "9_13_0";

  CONFIGURATION_ROOT_DIR = salome-configuration;

  src = fetchFromGitHub {
    owner = "SalomePlatform";
    repo = "salome_bootstrap";
    rev = "V${version}";
    hash = "sha256-vOtvCjV1QWeu61fe9QnC5jUFvwYd7oPKYZHRPsfu/kI=";
  };

  nativeBuildInputs = [
    cmake
  ];

  meta = {
    description = "";
    homepage = "https://github.com/SalomePlatform/salome_bootstrap";
    license = lib.licenses.lgpl21Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "salome-bootstrap";
    platforms = lib.platforms.all;
  };
}
