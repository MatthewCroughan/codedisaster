{
  bison,
  bzip2,
  cmake,
  fetchFromGitLab,
  flex,
  gfortran,
  lib,
  mpi,
  stdenv,
  zlib,
  xz,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "scotch";
  version = "7.0.4";

  outputs = [
    "bin"
    "dev"
    "out"
  ];

  cmakeFlags = [
    "-DBUILD_SHARED_LIBS=ON"
    "-DINTSIZE=64"
    "-DINSTALL_METIS_HEADERS=OFF"
  ];

  src = fetchFromGitLab {
    domain = "gitlab.inria.fr";
    owner = "scotch";
    repo = "scotch";
    rev = "v${finalAttrs.version}";
    hash = "sha256-XXkVwTr8cbYfzXWWkPERTmjfE86JHUUuU6yxjp9k6II=";
  };

  nativeBuildInputs = [
    cmake
    gfortran
  ];

  buildInputs = [
    bison
    bzip2
    mpi
    flex
    xz
    zlib
  ];

  meta = {
    description = "Graph and mesh/hypergraph partitioning, graph clustering, and sparse matrix ordering";
    longDescription = ''
      Scotch is a software package for graph and mesh/hypergraph partitioning, graph clustering,
      and sparse matrix ordering.
    '';
    homepage = "http://www.labri.fr/perso/pelegrin/scotch";
    license = lib.licenses.cecill-c;
    maintainers = [ lib.maintainers.bzizou ];
  };
})
