{ lib
, waf
, trilinos-mpi
, mgis
, tfel
, superlu
, hypre
, petsc
, pkg-config
, metis
, zlib
, openblas
, medfile
, scalapack
, hdf5-mpi
, python311
, bash
, getopt
, mpi
, which
, gcc
, gfortran
, nix
, writeShellScriptBin
, stdenv
, scotch
, parmetis
#, addTmateBreakpoint ? (builtins.getFlake "github:matthewcroughan/nixpkgs/mc/addTmateBreakpoint").legacyPackages.x86_64-linux.addTmateBreakpoint
, mumps
, medcoupling
, med
, codeaster-src
}:
let
  realGxx = writeShellScriptBin "g++"
    ''${mpi.dev}/bin/mpicxx -I${petsc}/lib/petsc4py -I${petsc}/lib/petsc4py/include -I${buildPython}/lib/python3.11/site-packages/numpy/core/include -I${scotch}/include "$@"'';
  realGcc = writeShellScriptBin "gcc"
    ''${mpi.dev}/bin/mpicc -I${petsc}/lib/petsc4py -I${petsc}/lib/petsc4py/include -I${buildPython}/lib/python3.11/site-packages/numpy/core/include "$@"'';
  realGfortran = writeShellScriptBin "gfortran"
    ''${mpi.dev}/bin/mpif90 -I${mumps}/include -I${petsc}/include -I${petsc}/lib/petsc4py -I${petsc}/lib/petsc4py/include "$@"'';
  buildPython = (python311.withPackages (p: with p; [
    setuptools
# distutils is included by default in python 3.11
#    distutils
    numpy
    pyaml
    mpi4py
    ipython
#    (p.callPackage ./petsc4py.nix {})
  ]));
  wafHook = (waf.override { python3 = buildPython; }).hook;
in
(stdenv.mkDerivation {
  name = "code-aster";
  wafConfigureFlags = [ "--without-repo" "--disable-med" "--enable-mpi" "--disable-petsc" ];
  src = codeaster-src;
  wafPath = "waf.engine";
  prePatch = ''
    export ENABLE_MPI=1
    export PYTHONPATH=${medcoupling}/lib/python3.11/site-packages:${med}/lib/python3.11/site-packages:${petsc}/lib
  '';
  buildInputs = [
    trilinos-mpi
    superlu
    hypre
    mgis
    petsc
    scotch
    mumps
#    (scotch.overrideAttrs (oldAttrs: {
#      nativeBuildInputs = [ gfortran ];
#      buildFlags = [ "scotch ptscotch esmumps" ];
##      prePatch = ''
##        cat src/CMakeLists.txt
##        substituteInPlace src/CMakeLists.txt \
##      '';
##        for i in $out/lib/*.a; do
##          base=$(basename "$i" .a)
##          ln -s "$i" "$out/lib/$base.so"
##        done
##      '';
#    }))
    zlib
    openblas
    scalapack
    metis
    parmetis
#    medcouplingPython
    medfile
    hdf5-mpi
  ];
  nativeBuildInputs = [
    wafHook
    tfel
    pkg-config
    buildPython
#    gcc
#    gfortran
#    realGcc
#    realGfortran
#    (symlinkJoin {
#      name = "mpifuck";
#      paths = [
#        mpi
#        mumps
#      ];
#    })
    getopt
#    which
    nix
  ];
  preInstall = ''
    unset PYTHONPATH
  '';
  postPatch = ''
    export TFELHOME="${tfel}"
    export FC=${realGfortran}/bin/gfortran
    export CC=${realGcc}/bin/gcc
    export CXX=${realGxx}/bin/g++

    patchShebangs waf.engine
    patchShebangs waf_mpi
    for i in $(grep -rl '/bin/bash' .)
    do
      substituteInPlace $i \
        --replace-fail '/bin/bash' '${bash}/bin/bash'
    done
    for i in $(grep -rl '/bin' .)
    do
      patchShebangs $i
    done
  '';

  meta = with lib; {
    description = "Source files of code_aster, its build scripts and verification testcases";
    homepage = "https://gitlab.com/codeaster/src";
    changelog = "https://gitlab.com/codeaster/src/-/blob/${src.rev}/CHANGELOG";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ matthewcroughan ];
    mainProgram = "src";
  };
})

#python3.pkgs.buildPythonApplication rec {
#  pname = "src";
#  version = "unstable-2024-08-07";
#  pyproject = true;
#
#  src = fetchFromGitLab {
#    owner = "codeaster";
#    repo = "src";
#    rev = "13c0ab3c7b734a479735766abc0604b01b76de24";
#    hash = "sha256-l3af3+EeQvW+1mpvQOAQiOxSLNRz+DTsbamAik3IT3I=";
#  };
#
#  nativeBuildInputs = [
#    python3.pkgs.setuptools
#    python3.pkgs.distlib
#    python3.pkgs.distutils-extra
#    python3.pkgs.wheel
#    getopt
#  ];
#
#  pythonImportsCheck = [ "src" ];
#
#  patchPhase = ''
#    for i in $(grep -rl '/bin/bash' .)
#    do
#      substituteInPlace $i \
#        --replace-fail '/bin/bash' '${bash}/bin/bash'
#    done
#    for i in $(find)
#    do
#      patchShebangs $i
#    done
#    cat configure
#  '';
#}
