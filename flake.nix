{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/27e30d177e57d912d614c88c622dcfdb2e6e6515";
    #nixpkgs2405.url = "github:NixOS/nixpkgs/nixos-24.05";
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
              blas = super.blas.override {
                blasProvider = self.openblas;
              };
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
              medfile = self.callPackage ./medfile.nix {};
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
              parmetis = self.callPackage ./parmetis.nix {};
              medcoupling = self.callPackage ./medcoupling.nix {};
              med = self.callPackage ./med.nix {};
#              scotch = super.scotch.overrideAttrs (old: {
#                cmakeFlags = (old.cmakeFlags or []) ++ [
#                  "-DIDXSIZE=64"
#                  "-DINTSIZE=64"
#                  "-DINSTALL_METIS_HEADERS=ON"
#                ];
#              });
              scotch = self.callPackage ./scotch.nix {};
              metis = super.metis.overrideAttrs {
                prePatch = ''
                  substituteInPlace include/metis.h --replace-fail 'IDXTYPEWIDTH 32' 'IDXTYPEWIDTH 64'
                '';
              };
              petsc = self.callPackage ./petsc-minimal.nix {};
#              mumps = self.callPackage ./mumps.nix {};
              mgis = self.callPackage ./mgis.nix {};
              hpddm = self.callPackage ./hpddm.nix {};
              tfel = self.callPackage ./tfel.nix {};
              trilinos-mpi = super.trilinos-mpi.overrideAttrs (old: {
                cmakeFlags = (old.cmakeFlags or []) ++ [
                  "-DTrilinos_ENABLE_ML=1"
                ];
              });
            })
          ];
          inherit system;
        };
        packages = rec {
          default = pkgs.callPackage ./default.nix { codeaster-src = inputs.codeaster-src; };
          scotch = pkgs.scotch;
          metis = pkgs.metis;
          med = pkgs.med;
          petsc = pkgs.petsc;
          hpddm = pkgs.hpddm;
          mumps = pkgs.mumps;
          medcoupling = pkgs.medcoupling;
          parmetis = pkgs.parmetis;
          test = pkgs.runCommand "" { buildInputs = [ default ]; } ''
            export HOME=$TMP
            export PYTHONPATH=${medcoupling}/lib/python3.11/site-packages:${med}/lib/python3.11/site-packages:${petsc}/lib
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
