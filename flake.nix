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
              scalapack = super.scalapack.override {
                lapack = self.lapack-ilp64;
                blas = self.blas-ilp64;
              };
              hdf5 = super.hdf5.override {
                usev110Api = true;
                mpiSupport = true;
                cppSupport = false;
              };
              medfile = self.callPackage ./medfile.nix {};
              medcoupling = self.callPackage ./medcoupling.nix {};
              med = self.callPackage ./med.nix {};
              metis = super.metis.overrideAttrs {
                NIX_CFLAGS_COMPILE = "-DINTSIZE64";
                prePatch = ''
                  substituteInPlace include/metis.h --replace-fail '#define IDXTYPEWIDTH 32' '#define IDXTYPEWIDTH 64'
                '';
              };
              parmetis = self.callPackage ./parmetis.nix {};
            })
          ];
          inherit system;
        };
        packages = rec {
          default = pkgs.codeaster;
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
          test = pkgs.runCommand "codeaster-test" { buildInputs = [ default ]; } ''
            export HOME=$TMP
            export LANG=C.UTF-8
            export LC_ALL=C.UTF-8
            export PYTHONPATH=${medcoupling}/lib/python3.11/site-packages:${med}/lib/python3.11/site-packages
            cp -r --no-preserve=mode ${./test} ./test
            cd test
           run_aster test.export || true
           ls -lah
          '';
        };
      };
      flake = {
      };
    };
}
