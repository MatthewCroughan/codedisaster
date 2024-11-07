{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  salome-configuration,
  salome-kernel,
  python311,
}:

stdenv.mkDerivation rec {
  pname = "paravis";
  version = "9_13_0";

  CONFIGURATION_ROOT_DIR = salome-configuration;
  KERNEL_ROOT_DIR = salome-kernel;

  src = fetchFromGitHub {
    owner = "SalomePlatform";
    repo = "paravis";
    rev = "V${version}";
    hash = "sha256-UGZkSDymTJYDXXXss9iGwG81sT9Roiyk6baRyHVYQxU=";
  };

  nativeBuildInputs = [
    cmake
    python311
  ];

  meta = {
    description = "SALOME ParaView Interface";
    homepage = "https://github.com/SalomePlatform/paravis.git";
    license = lib.licenses.lgpl21Only;
    maintainers = with lib.maintainers; [ matthewcroughan ];
    mainProgram = "paravis";
    platforms = lib.platforms.all;
  };
}
