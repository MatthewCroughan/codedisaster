{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs2405.url = "github:NixOS/nixpkgs/nixos-24.05";
    codeaster-src = {
      url = "gitlab:codeaster/src/17.1.9";
      flake = false;
    };
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
      ];
      systems = [ "x86_64-linux" "aarch64-linux" ];
      perSystem = { config, self', inputs', pkgs, system, ... }: {
        _module.args.pkgs = import inputs.nixpkgs {
          config.allowUnfree = true;
          overlays = [
            (self: super: {
              codeaster = self.callPackage ./default.nix { codeaster-src = inputs.codeaster-src; };
              salome-configuration = import ./salome-configuration.nix;
              salome-kernel = self.callPackage ./salome-kernel.nix {};
              scalapack = (super.scalapack.override {
                lapack = self.lapack-ilp64;
                blas = self.blas-ilp64;
              }).overrideAttrs {
                postFixup = ''
                  ln -s $out/lib/libscalapack.so $out/lib/libscalapack-openmpi.so
                '';
              };
              hdf5 = super.hdf5.override {
                usev110Api = true;
                mpiSupport = true;
                cppSupport = false;
              };
              scotch = super.scotch.overrideAttrs (old: {
                cmakeFlags = (old.cmakeFlags or []) ++ [
                  "-DINTSIZE=64"
                  "-DINSTALL_METIS_HEADERS=OFF"
                ];
              });
#              medfile = super.medfile.overrideAttrs (old: {
#                cmakeFlags = (old.cmakeFlags or []) ++ [
#                  "-DCMAKE_Fortran_COMPILER=mpif90"
#                  "-DMEDFILE_USE_MPI=ON"
#                  "-DMED_MEDINT_TYPE=long"
#                  "-DMEDFILE_BUILD_STATIC_LIBS=OFF"
#                  ''-DCMAKE_Fortran_FLAGS="-fdefault-integer-8"''
#                ];
#              });
              medfile = self.callPackage ./medfile-5.nix {};
              petsc = self.callPackage ./petsc-minimal.nix {};
              mumps = super.mumps.overrideAttrs (old: {
                NIX_CFLAGS_COMPILE = "-g";
                nativeBuildInputs = [ super.mpi ];
                buildInputs = with self; [
                  blas
                  scalapack
                  metis
                  scotch
                  lapack
                ];
                configurePhase = ''
                  cp Make.inc/Makefile.debian.PAR ./Makefile.inc
                '';
                prePatch = ''
                  sed --debug -i 's/INTEGER *,/INTEGER(4),/g' include/*_{struc,root}.h
                  sed --debug -i 's/INTEGER *::/INTEGER(4) ::/g' include/*_{struc,root}.h
                  sed --debug -i 's/INTEGER MPI/INTEGER(4) MPI/g' libseq/mpif.h
                  sed --debug -i 's/REAL *,/REAL(4),/g' include/*_{struc,root}.h libseq/mpif.h
                  sed --debug -i 's/REAL *::/REAL(4) ::/g' include/*_{struc,root}.h libseq/mpif.h
                  sed --debug -i 's/COMPLEX *,/COMPLEX(4),/g' include/*_{struc,root}.h libseq/mpif.h
                  sed --debug -i 's/COMPLEX *::/COMPLEX(4) ::/g' include/*_{struc,root}.h libseq/mpif.h
                  sed --debug -i 's/LOGICAL *,/LOGICAL(4),/g' include/*_{struc,root}.h libseq/mpif.h
                  sed --debug -i 's/LOGICAL *::/LOGICAL(4) ::/g' include/*_{struc,root}.h libseq/mpif.h

                '';
              });
#              medfile = self.callPackage ./medfile-pmed.nix {};
#              medfile = self.callPackage ./medfile-pmed.nix {};
              medcoupling = self.callPackage ./medcoupling.nix {};
              med = self.callPackage ./med.nix {};
              metis = super.metis.overrideAttrs {
                NIX_CFLAGS_COMPILE = "-DINTSIZE64";
                prePatch = ''
                  substituteInPlace include/metis.h --replace-fail '#define IDXTYPEWIDTH 32' '#define IDXTYPEWIDTH 64'
                '';
              };
              parmetis = self.callPackage ./parmetis.nix {};
              mgis = self.callPackage ./mgis.nix {};
              tfel = self.callPackage ./tfel.nix {};
            })
          ];
          inherit system;
        };
        packages = rec {
          default = pkgs.codeaster;
          scalapack = pkgs.scalapack;
          hdf5 = pkgs.hdf5;
          medfile = pkgs.medfile;
          scotch = pkgs.scotch;
          metis = pkgs.metis;
          gklib = pkgs.gklib;
          parmetis = pkgs.parmetis;
          mpi = pkgs.mpi;
          med = pkgs.med;
          petsc = pkgs.petsc;
          hpddm = pkgs.hpddm;
          mumps = pkgs.mumps;
          medcoupling = pkgs.medcoupling;
          addTmateBreakpoint = (builtins.getFlake "github:matthewcroughan/nixpkgs/mc/addTmateBreakpoint").legacyPackages.x86_64-linux.addTmateBreakpoint;

          test-debug = addTmateBreakpoint test;
          test = pkgs.runCommand "codeaster-test" { buildInputs = [ default pkgs.gdb pkgs.bashInteractive pkgs.strace pkgs.vim ]; } ''
            export HOME=$TMP
            export LANG=C.UTF-8
            export LC_ALL=C.UTF-8
            export PYTHONPATH=${medcoupling}/lib/python3.11/site-packages:${med}/lib/python3.11/site-packages
            cp -r --no-preserve=mode ${./test} ./test
            cd test
           run_aster --no-mpi test.export || true
           exit 1
           ls -lah
          '';
        };
      };
      flake = {
      };
    };
}
