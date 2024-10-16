{
  codeaster-src,
  stdenv,
  makeWrapper,
  waf,
  python311,
  mpi,
  zlib,
  tfel,
  mgis,
  lapack-ilp64,
  petsc,
  blas,
  scotch,
  scalapack,
  hdf5-mpi,
  mumps,
  med,
  medcoupling,
  metis,
  parmetis,
  medfile,
}:
let
  pythonPath = "${medcoupling}/lib/python3.11/site-packages:${med}/lib/python3.11/site-packages:${petsc}/lib";
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
stdenv.mkDerivation rec {
  name = "code-aster";
  version = src.rev;
  prePatch = ''
    # Can't replace the 0.0.1 version number because Aster relies upon it in
    # strange ways at runtime
    # substituteInPlace code_aster/wscript \
    #  --replace-fail 'VERSION_INFO=pformat(env["ASTER_VERSION"])' 'VERSION_INFO=pformat(env["${src.rev}-nix"])'

    # Can replace the "aesthetic" version with one that reports the git revision
    # of the aster sources
    substituteInPlace code_aster/Utilities/version.py \
      --replace-fail 'get_version() if version_info else ""' '"${src.rev}-nix"' \
      --replace-fail 'name = get_version_name()' 'name = "${src.rev}-nix"'
  '';
  NIX_CFLAGS_COMPILE = "-I${mumps}/include -I${petsc}/include -I${petsc}/lib/petsc4py -I${petsc}/lib/petsc4py/include";
  preInstall = ''
    unset PYTHONPATH
  '';
  preConfigure = ''
    failHook() {
      cat /build/source/build/config.log
    }
    failureHooks+=(failHook)
    export PYTHONPATH="${pythonPath}"
    export CC=mpicc
    export CXX=mpic++
    export FC=mpif90
    export LDFLAGS="-lmedC"
    export TFELHOME="${tfel}"
  '';
  wafConfigureFlags = [
    "--without-repo"
  ];
  src = codeaster-src;
  wafPath = "waf.engine";
  buildInputs = [
    buildPython
    mumps
    petsc
    blas
    mgis
    lapack-ilp64
    scalapack
    scotch
    zlib
    mpi
    metis
    parmetis
    medfile
    hdf5-mpi
  ];

  postFixup = ''
    wrapProgram $out/bin/run_aster --set PYTHONPATH ${pythonPath}
    wrapProgram $out/bin/run_ctest --set PYTHONPATH ${pythonPath}
  '';

  nativeBuildInputs = [
    makeWrapper
    wafHook
  ];
}
