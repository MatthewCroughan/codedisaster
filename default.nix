{
  codeaster-src,
  stdenv,
  waf,
  python311,
  mpi,
  zlib,
  openblas,
  lapack-ilp64,
  scalapack,
  lapack-reference,
  lapack,

  hdf5-mpi,
  scotch,

  mumps,
  med,
  medcoupling,
}:
let
  python3 = python311;
  buildPython = (python3.withPackages (p: with p; [
    setuptools
    numpy
    pyaml
    mpi4py
    ipython
  ]));
  wafHook = (waf.override { python3 = buildPython; }).hook;
in
stdenv.mkDerivation {
  name = "code-aster";
  NIX_CFLAGS_COMPILE = "-I${mumps}/include";
  preInstall = ''
    unset PYTHONPATH
  '';
  preConfigure = ''
    #failHook() {
    #  cat /build/source/build/config.log
    #}
    #failureHooks+=(failHook)
    export PYTHONPATH=${medcoupling}/lib/python3.11/site-packages:${med}/lib/python3.11/site-packages
    export CC=mpicc
  '';
  wafConfigureFlags = [
    "--no-enable-all"
    "--without-repo"
    "--enable-mumps"
  ];
  src = codeaster-src;
  wafPath = "waf.engine";
  buildInputs = [
    buildPython
    mumps

    openblas
    scalapack

    zlib
    mpi
  ];
  nativeBuildInputs = [
    wafHook
  ];
}
