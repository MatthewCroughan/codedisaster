{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs2405.url = "github:NixOS/nixpkgs/nixos-24.05";
    codeaster-src = {
      url = "gitlab:codeaster/src/17.1.12";
      flake = false;
    };
  };
  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux" # Aarch64 is blocked on VPU support
      ];
      perSystem = { config, self', inputs', pkgs, system, ... }: {
        _module.args.pkgs = import inputs.nixpkgs {
          config.allowUnfree = true;
          overlays = [
            (self: super: {
              codeaster = self.callPackage ./default.nix { codeaster-src = inputs.codeaster-src; };
              vtk = super.vtk.overrideAttrs (old: {
                cmakeFlags = old.cmakeFlags ++ [
                  "VTK_MODULE_ENABLE_VTK_RenderingLOD=YES"
                ];
              });
              salome-bootstrap = self.callPackage ./salome-bootstrap.nix {};
              salome-configuration = import ./salome-configuration.nix;
              salome-paravis = self.callPackage ./salome-paravis.nix {};
              salome-gui = self.callPackage ./salome-gui.nix { paraview = inputs.nixpkgs2405.legacyPackages.${super.hostPlatform.system}.paraview; };
              salome-kernel = self.callPackage ./salome-kernel.nix {};
              scalapack = (super.scalapack.override {
                lapack = self.lapack-ilp64;
                blas = self.blas-ilp64;
              }).overrideAttrs {
                postFixup = ''
                  ln -s $out/lib/libscalapack.so $out/lib/libscalapack-openmpi.so
                '';
              };
#              hdf5 = super.hdf5.override {
#                usev110Api = true;
#                mpiSupport = true;
#                cppSupport = false;
#              };
              scotch = super.scotch.overrideAttrs (old: {
                cmakeFlags = (old.cmakeFlags or []) ++ [
                  "-DINTSIZE=64"
                  "-DINSTALL_METIS_HEADERS=OFF"
                ];
              });
              medfile = super.medfile.overrideAttrs (old: {
                cmakeFlags = (old.cmakeFlags or []) ++ [
                  "-DCMAKE_Fortran_COMPILER=mpif90"
                  "-DMEDFILE_USE_MPI=ON"
                  "-DMED_MEDINT_TYPE=long"
                  "-DMEDFILE_BUILD_STATIC_LIBS=OFF"
                  ''-DCMAKE_Fortran_FLAGS="-fdefault-integer-8"''
                ];
              });
              petsc = self.callPackage ./petsc.nix {};
              mumps = super.mumps_par.overrideAttrs (old: {
                NIX_CFLAGS_COMPILE = "-g";
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
              medcoupling = self.callPackage ./medcoupling.nix {};
              med = self.callPackage ./med.nix {};
              metis = super.metis.overrideAttrs {
                NIX_CFLAGS_COMPILE = "-DINTSIZE64";
                prePatch = ''
                  substituteInPlace include/metis.h --replace-fail '#define IDXTYPEWIDTH 32' '#define IDXTYPEWIDTH 64'
                '';
              };
              mgis = self.callPackage ./mgis.nix {};
              tfel = self.callPackage ./tfel.nix {};
            })
          ];
          inherit system;
        };
        legacyPackages = pkgs;
        packages = rec {
          default = pkgs.codeaster;
          paraview-test = pkgs.runCommand "codeaster-paraview-test" {
            nativeBuildInputs = with pkgs; [
              paraview
            ];
          };
          test = pkgs.runCommand "codeaster-test" { buildInputs = [ default pkgs.gdb pkgs.bashInteractive pkgs.strace pkgs.vim ]; } ''
            export HOME=$TMP
            export LANG=C.UTF-8
            export LC_ALL=C.UTF-8
            cp -r --no-preserve=mode ${./test} ./test
            cd test
            run_aster --no-mpi test.export || true
            cp -r ../test $out
          '';
        };
      };
    };
}
