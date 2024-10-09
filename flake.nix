{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    mumps = {
     # inputs.nixpkgs.follows = "nixpkgs";
     # inputs.mumps-src = {
     #   url = "tarball+https://mumps-solver.org/MUMPS_5.6.2.tar.gz";
     #   flake = false;
     # };
      url = "github:mk3z/mumps";
    };
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
              salome-configuration = import ./salome-configuration.nix;
              salome-kernel = self.callPackage ./salome-kernel.nix {};
              medfile = self.callPackage ./medfile.nix {};
              medcoupling = self.callPackage ./medcoupling.nix {};
              med = self.callPackage ./med.nix {};
              scotch = self.callPackage ./scotch.nix {};
              mumps = self.callPackage "${inputs.nixpkgs-unstable.outPath}/pkgs/by-name/mu/mumps/package.nix" {};
#              mumps = inputs.mumps.packages.${system}.default.overrideAttrs
#              (old: {
#                cmakeFlags = old.cmakeFlags ++ [
#                  "-DBUILD_DOUBLE=ON"
#                  "-DINTSIZE64=ON"
#                  "-DMETIS=ON"
#                  "-DMETIS=ON"
#                ];
#              });
              #mumps = self.callPackage ./mumps.nix {};
#              mumps = let
#                makeinc = pkgs.writeText "Makefile.inc" ''
#OPTF = -O3 -fPIC -DPORD_INTSIZE64 ''${FCFLAGS}
#OPTC = -O3 -fPIC -DPORD_INTSIZE64 ''${CFLAGS}
#OPTL = -O3 -fPIC -DPORD_INTSIZE64
#                '';
#              in super.mumps.overrideAttrs (old: {
#                src = self.fetchzip {
#                  url = "https://mumps-solver.org/MUMPS_5.6.2.tar.gz";
#                  hash = "sha256-9RgPjZ+4YI/ZMP2UcKofDak+GEJ7eFvmHUWRmeMmnbc=";
#                };
#                prePatch = ''
#                  sed -i 's/INTEGER *,/INTEGER(4),/g' include/*_{struc,root}.h
#                  sed -i 's/INTEGER *::/INTEGER(4) ::/g' include/*_{struc,root}.h
#                  sed -i 's/INTEGER MPI/INTEGER(4) MPI/g' libseq/mpif.h
#                  sed -i 's/REAL *,/REAL(4),/g' include/*_{struc,root}.h libseq/mpif.h
#                  sed -i 's/REAL *::/REAL(4) ::/g' include/*_{struc,root}.h libseq/mpif.h
#                  sed -i 's/COMPLEX *,/COMPLEX(4),/g' include/*_{struc,root}.h libseq/mpif.h
#                  sed -i 's/COMPLEX *::/COMPLEX(4) ::/g' include/*_{struc,root}.h libseq/mpif.h
#                  sed -i 's/LOGICAL *,/LOGICAL(4),/g' include/*_{struc,root}.h libseq/mpif.h
#                  sed -i 's/LOGICAL *::/LOGICAL(4) ::/g' include/*_{struc,root}.h libseq/mpif.h
##                  substituteInPlace src/Makefile --replace-fail '$(OPTF)' '$(OPTF) -O3 -fPIC -DINTSIZE64 -DPORD_INTSIZE64 -DUSE_MPI3 -DUSE_SCHEDAFFINITY -Dtry_null_space -ffixed-line-length-none -fallow-argument-mismatch'
##                  substituteInPlace src/Makefile --replace-fail '$(OPTC)' '$(OPTC) -O3 -fPIC -DINTSIZE64 -DPORD_INTSIZE64'
#                '';
#              });
              metis = super.metis.overrideAttrs {
                NIX_CFLAGS_COMPILE = "-DINTSIZE64";
                prePatch = ''
                  substituteInPlace include/metis.h --replace-fail '#define IDXTYPEWIDTH 32' '#define IDXTYPEWIDTH 64'
                '';
              };
              parmetis = self.callPackage ./parmetis.nix {};
#              metis = self.callPackage ./metis.nix {};
#              gklib = self.callPackage ./gklib.nix {};
#              mumps = self.callPackage ./mumps.nix {};
              #mpi = super.mpi.overrideAttrs (old: {
              #  configureFlags = old.configureFlags ++ [ "--enable-mpi-fortran=usempi" ];
              #  preConfigure = ''
              #    export F77=gfortran
              #    export FC=gfortran
              #    export CC=gcc
              #    export CXX=g++
              #    export FFLAGS="-m64 -fdefault-integer-8"
              #    export FCFLAGS="-m64 -fdefault-integer-8"
              #    export CFLAGS=-m64
              #    export CXXFLAGS=-m64
              #  '';
              #});
              #blas = super.blas.override {
              #  #blasProvider = self.openblas;
              #  blasProvider = self.mkl;
              #};
#              metis = super.metis.overrideAttrs (old: {
#                prePatch = ''
#                  substituteInPlace include/metis.h --replace-fail 'IDXTYPEWIDTH 32' 'IDXTYPEWIDTH 64'
#                  substituteInPlace include/metis.h --replace-fail 'REALTYPEWIDTH 32' 'REALTYPEWIDTH 64'
#                '';
##                cmakeFlags = (old.cmakeFlags or []) ++ [
##                  "-DIDXTYPEWIDTH=64"
##                  "-DREALTYPEWIDTH=64"
##                ];
#              });
#              medfile = super.medfile.overrideAttrs {
#                postFixup = "ln -s $out/lib/libmedC.so $out/lib/libmed.so";
#                cmakeFlags = [ "-DMEDFILE_USE_MPI=1" ];
#                configureFlags = [
#                  "--with-hdf5-lib=${super.hdf5}/lib"
#                  "--with-hdf5-include=${super.hdf5.dev}/include"
#                ];
#                nativeBuildInputs = [
#                  super.mpi
#                ];
#              };
              #medfile = self.callPackage "${inputs.nixpkgs2405}/pkgs/development/libraries/medfile" {};
#              medfile = inputs.nixpkgs2405.legacyPackages.${system}.medfile.overrideAttrs { postFixup = "ln -s $out/lib/libmedC.so $out/lib/libmed.so"; };
#              scotch = super.scotch.overrideAttrs (old: {
#                cmakeFlags = (old.cmakeFlags or []) ++ [
#                  "-DIDXSIZE=64"
#                  "-DINTSIZE=64"
#                  "-DINSTALL_METIS_HEADERS=ON"
#                ];
#              });
              #scotch = self.callPackage ./scotch.nix {};
#              petsc = self.callPackage ./petsc-minimal.nix {};
#              mumps = (super.mumps.overrideAttrs (old: {
#                buildInputs = old.buildInputs ++ [ super.mpi ];
#                prePatch = ''
#                  substituteInPlace Makefile --replace-fail '$(OPTC)' "-DINTSIZE=64"
#                '';
#                NIX_CFLAGS_COMPILE = "-DINTSIZE64";
#              })).override {
#                lapack = super.lapack-ilp64;
#                blas = super.blas-ilp64;
#              };
#              mumps = self.callPackage ./mumps.nix {};
              #mgis = self.callPackage ./mgis.nix {};
              #hpddm = self.callPackage ./hpddm.nix {};
              tfel = self.callPackage ./tfel.nix {};
              #trilinos-mpi = super.trilinos-mpi.overrideAttrs (old: {
              #  cmakeFlags = (old.cmakeFlags or []) ++ [
              #    "-DTrilinos_ENABLE_ML=1"
              #  ];
              #});
            })
          ];
          inherit system;
        };
        packages = rec {
          default = pkgs.callPackage ./default.nix { codeaster-src = inputs.codeaster-src; };
          tfel = pkgs.tfel;
          scotch = pkgs.scotch;
          metis = pkgs.metis;
          gklib = pkgs.gklib;
          parmetis = pkgs.parmetis;
          mpi = pkgs.mpi;
          med = pkgs.med;
          petsc = pkgs.petsc;
#          petsc = pkgs.petsc;
          hpddm = pkgs.hpddm;
          mumps = pkgs.mumps;
          medcoupling = pkgs.medcoupling;
          test = pkgs.runCommand "" { buildInputs = [ default pkgs.openssh ]; } ''
            export HOME=$TMP
            export PYTHONPATH=${medcoupling}/lib/python3.11/site-packages:${med}/lib/python3.11/site-packages
            export LD_PRELOAD=${mpi}/lib/libmpi_cxx.so
            cp -r --no-preserve=mode ${./test} ./test
            cd test
           # substituteInPlace test.export --replace-fail '/home/tim/aster/bin/case' "$(pwd)"
           # substituteInPlace test.export --replace-fail '/home/tim/aster' "$(pwd)"
           run_aster test.export || true
           ls -lah
          '';
        };
      };
      flake = {
      };
    };
}
