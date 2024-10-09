{
  stdenv,
  codeaster-src,
  waf,
  openssh,
  python311,
  mpi,
  zlib,
  openblas,

  addTmateBreakpoint ? (builtins.getFlake "github:matthewcroughan/nixpkgs/mc/addTmateBreakpoint").legacyPackages.x86_64-linux.addTmateBreakpoint,

  hdf5-mpi,
  scotch,

  lapack,
  scalapack,
  mumps,
  med,
  medcoupling,
  medfile,
  metis,
  parmetis
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
addTmateBreakpoint (stdenv.mkDerivation {
  name = "code-aster";
  NIX_CFLAGS_COMPILE = "-I${mumps}/include";
  preInstall = ''
    # Only needed with mpi4
    export LD_PRELOAD=${mpi}/lib/libmpi_cxx.so
    unset PYTHONPATH
#    export LD_LIBRARY_PATH=$out/lib/aster
  '';
  preConfigure = ''
    failHook() {
      cat /build/source/build/config.log
    }
    failureHooks+=(failHook)
    export PYTHONPATH=${medcoupling}/lib/python3.11/site-packages:${med}/lib/python3.11/site-packages
    export CC=mpicc
  '';
  wafConfigureFlags = [
#    "--no-enable-all"
#    "--enable-mumps"
#    "--enable-med"
#    "--enable-scotch"
    "--disable-petsc"
    "--without-repo"
  ];
  src = codeaster-src;
  wafPath = "waf.engine";
  buildInputs = [
    buildPython

    hdf5-mpi
    scotch

    mumps
    scalapack
    med
    medcoupling
    medfile
    metis
    parmetis

    zlib
    openblas
    lapack
  ];
  nativeBuildInputs = [
    mpi
    openssh
    wafHook
  ];
})
#{ lib
#, waf
#, lapack
#, mgis
#, parmetis
#, metis
#, tfel
#, pkg-config
#, zlib
#, blas
#, medfile
#, hdf5-mpi
#, python311
#, bash
#, getopt
#, mpi
#, nix
#, writeShellScriptBin
#, stdenv
#, scotch
#, mumps
#, medcoupling
#, med
#, codeaster-src
#}:
#let
#  realGxx = writeShellScriptBin "g++"
#    ''${mpi.dev}/bin/mpicxx -I${buildPython}/lib/python3.11/site-packages/numpy/core/include -I${scotch}/include "$@"'';
#  realGcc = writeShellScriptBin "gcc"
#    ''${mpi.dev}/bin/mpicc -I${buildPython}/lib/python3.11/site-packages/numpy/core/include "$@"'';
#  realGfortran = writeShellScriptBin "gfortran"
#    ''${mpi.dev}/bin/mpif90 -I${mumps}/include "$@"'';
#  buildPython = (python311.withPackages (p: with p; [
#    setuptools
#    numpy
#    pyaml
#    mpi4py
#    ipython
#  ]));
#  wafHook = (waf.override { python3 = buildPython; }).hook;
#in
#(stdenv.mkDerivation {
#  name = "code-aster";
#  wafConfigureFlags = [ "--without-repo" "--disable-med" "--enable-parmetis" "--enable-mpi" "--disable-petsc" ];
#  src = codeaster-src;
#  wafPath = "waf.engine";
#  prePatch = ''
##    export ENABLE_MPI=1
##    export ASTER_HAVE_64_BITS=1
##    export ASTER_INT_SIZE=8
#    #export ASTER_MPI_INT_SIZE=8
##    export ASTER_BLAS_INT_SIZE=8
##    substituteInPlace waftools/parallel.py --replace-fail 'into=(4, 8)' 'into=(8)'
#    export PYTHONPATH=${medcoupling}/lib/python3.11/site-packages:${med}/lib/python3.11/site-packages
#  '';
#  buildInputs = [
#    lapack
#    mgis
#    scotch
#    mumps
##    (scotch.overrideAttrs (oldAttrs: {
##      nativeBuildInputs = [ gfortran ];
##      buildFlags = [ "scotch ptscotch esmumps" ];
###      prePatch = ''
###        cat src/CMakeLists.txt
###        substituteInPlace src/CMakeLists.txt \
###      '';
###        for i in $out/lib/*.a; do
###          base=$(basename "$i" .a)
###          ln -s "$i" "$out/lib/$base.so"
###        done
###      '';
##    }))
#    zlib
#    blas
#    parmetis
#    metis
##    medcouplingPython
#    medfile
#    hdf5-mpi
#  ];
#  nativeBuildInputs = [
#    wafHook
#    tfel
#    pkg-config
#    buildPython
##    gcc
##    gfortran
##    realGcc
##    realGfortran
##    (symlinkJoin {
##      name = "mpifuck";
##      paths = [
##        mpi
##        mumps
##      ];
##    })
#    getopt
##    which
#    nix
#  ];
#  preInstall = ''
#    unset PYTHONPATH
#  '';
#  postPatch = ''
#    export TFELHOME="${tfel}"
#    export FC=${realGfortran}/bin/gfortran
#    export CC=${realGcc}/bin/gcc
#    export CXX=${realGxx}/bin/g++
#
#    patchShebangs waf.engine
#    patchShebangs waf_mpi
#    for i in $(grep -rl '/bin/bash' .)
#    do
#      substituteInPlace $i \
#        --replace-fail '/bin/bash' '${bash}/bin/bash'
#    done
#    for i in $(grep -rl '/bin' .)
#    do
#      patchShebangs $i
#    done
#  '';
#
#  meta = with lib; {
#    description = "Source files of code_aster, its build scripts and verification testcases";
#    homepage = "https://gitlab.com/codeaster/src";
#    changelog = "https://gitlab.com/codeaster/src/-/blob/${src.rev}/CHANGELOG";
#    license = licenses.gpl3Only;
#    maintainers = with maintainers; [ matthewcroughan ];
#    mainProgram = "src";
#  };
#})
#
##python3.pkgs.buildPythonApplication rec {
##  pname = "src";
##  version = "unstable-2024-08-07";
##  pyproject = true;
##
##  src = fetchFromGitLab {
##    owner = "codeaster";
##    repo = "src";
##    rev = "13c0ab3c7b734a479735766abc0604b01b76de24";
##    hash = "sha256-l3af3+EeQvW+1mpvQOAQiOxSLNRz+DTsbamAik3IT3I=";
##  };
##
##  nativeBuildInputs = [
##    python3.pkgs.setuptools
##    python3.pkgs.distlib
##    python3.pkgs.distutils-extra
##    python3.pkgs.wheel
##    getopt
##  ];
##
##  pythonImportsCheck = [ "src" ];
##
##  patchPhase = ''
##    for i in $(grep -rl '/bin/bash' .)
##    do
##      substituteInPlace $i \
##        --replace-fail '/bin/bash' '${bash}/bin/bash'
##    done
##    for i in $(find)
##    do
##      patchShebangs $i
##    done
##    cat configure
##  '';
##}
