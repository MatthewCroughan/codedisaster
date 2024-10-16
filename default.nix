{
  codeaster-src,
  stdenv,
  makeWrapper,
  waf,
  python311,
  mpi,
  zlib,
  tfel,
  openblas,
  mgis,
  lapack-ilp64,
  petsc,
  blas,
  scotch,
  scalapack,
  lapack,
  hdf5-mpi,
  mumps,
  med,
  medcoupling,
  metis,
  parmetis,
  medfile,
  addTmateBreakpoint ? (builtins.getFlake "github:matthewcroughan/nixpkgs/mc/addTmateBreakpoint").legacyPackages.x86_64-linux.addTmateBreakpoint
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
  #NIX_CFLAGS_COMPILE = "-I${mumps}/include -I${petsc}/include -I${petsc}/lib/petsc4py -I${petsc}/lib/petsc4py/include";
  NIX_CFLAGS_COMPILE = "-I${mumps}/include";
  preInstall = ''
    unset PYTHONPATH
  '';
  preConfigure = ''
    failHook() {
      cat /build/source/build/config.log
    }
    failureHooks+=(failHook)
    export PYTHONPATH=${medcoupling}/lib/python3.11/site-packages:${med}/lib/python3.11/site-packages

    export CC=mpicc
    export CXX=mpic++
    export FC=mpif90
    export LDFLAGS="-lmedC"
    export TFELHOME="${tfel}"

#    substituteInPlace waftools/med_cfg.py --replace-fail 'use="MED HDF5 Z"' 'use="HDF5 Z MEDC"'
     substituteInPlace bibcxx/Solvers/LinearSolver.cxx --replace-fail \
       'const std::string solverName( getName() + "           " );' \
       'const std::string solverName( getName() + "           " ); printf(" HELLOHELLOHELLO ASTERINTEGER size--- %d %d  %d\n", sizeof(ASTERINTEGER), sizeof(int), sizeof(long));'
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

#    petsc

    blas
    #openblas
    mgis
    lapack-ilp64

    # Only needed when petsc is enabled
    scalapack

    scotch

    zlib
    mpi

    # Additional stuff that is only needed when compiling everything
    metis
    parmetis
    medfile
    hdf5-mpi
  ];

  postFixup = ''
    wrapProgram $out/bin/run_aster --set PYTHONPATH "${medcoupling}/lib/python3.11/site-packages:${med}/lib/python3.11/site-packages"
    wrapProgram $out/bin/run_ctest --set PYTHONPATH "${medcoupling}/lib/python3.11/site-packages:${med}/lib/python3.11/site-packages"
  '';

  nativeBuildInputs = [
    makeWrapper
    wafHook
  ];

}
