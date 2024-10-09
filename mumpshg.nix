{
  stdenv,
  fetchhg,
  waf,
  python311,
  blas,
  lapack,
  metis,
  scotch,
  gfortran,
  mpi
}:
let
  python3 = python311;
  buildPython = (python3.withPackages (p: with p; [
    setuptools
    distutils
    numpy
#    pyaml
#    mpi4py
#    ipython
  ]));
  wafHook = (waf.override { python3 = buildPython; }).hook;
in
stdenv.mkDerivation {
  name = "";
  src = fetchhg {
    url = "http://hg.code.sf.net/p/prereq/mumps";
    rev = "768dcb88317b";
    sha256 = "sha256-gzO1LNG0lxbcEY5M8h2Pc+TcrrS3Hh20Tjc1ANwBGlM=";
  };
  buildInputs = [
    blas
    lapack
    metis
    scotch
    mpi
  ];
  nativeBuildInputs = [
    wafHook
    buildPython
    gfortran
  ];
}
