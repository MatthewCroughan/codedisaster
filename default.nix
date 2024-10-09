{
  codeaster-src,
  stdenv,
  waf,
  python311,
  mpi,
  zlib,
  openblas,
  lapack-ilp64,
  hdf5-mpi,
  mumps,
  med,
  medcoupling,
  metis,
  parmetis,
  medfile
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
#    "--no-enable-all"
    "--disable-petsc"
    "--without-repo"
  ];
  src = codeaster-src;
  wafPath = "waf.engine";
  buildInputs = [
    buildPython
    mumps

    openblas
    lapack-ilp64

    # Only needed when petsc is enabled
#    scalapack

    zlib
    mpi

    # Additional stuff that is only needed when compiling everything
    metis
    parmetis
    medfile
    hdf5-mpi
  ];

  nativeBuildInputs = [
    wafHook
  ];

}
