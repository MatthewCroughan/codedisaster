{
  lib,
  stdenv,
  fetchFromGitHub,
  mpi,
  mumps,
  suitesparse,
  arpack,
  openblas,
  lapack,
  scalapack,
  mkl
}:

stdenv.mkDerivation rec {
  pname = "hpddm";
  version = "2.3.0";

  src = fetchFromGitHub {
    owner = "hpddm";
    repo = "hpddm";
    rev = "v${version}";
    hash = "sha256-rqbsvliYnnHa6YR/iyfJej6bDV3TEajo4SuXGGcMdtQ=";
  };

  buildInputs = [
    mumps
    suitesparse
    arpack
    openblas
    lapack
    scalapack
#    mkl
    mpi
  ];

  meta = {
    description = "A framework for high-performance domain decomposition methods";
    homepage = "https://github.com/hpddm/hpddm";
    license = lib.licenses.lgpl3;
    maintainers = with lib.maintainers; [ matthewcroughan ];
    mainProgram = "hpddm";
    platforms = lib.platforms.all;
  };
}
