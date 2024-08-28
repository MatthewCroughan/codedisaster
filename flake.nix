{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    #nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs";
    #nixpkgs2405.url = "github:NixOS/nixpkgs/nixos-24.05";
    codeaster-src = {
      url = "gitlab:codeaster/src";
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
              omniorb = super.omniorb.override { python3 = self.python311; };
              omniorbpy = super.omniorbpy.override { python3 = self.python311; };
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
        packages.default = pkgs.callPackage ./default.nix { codeaster-src = inputs.codeaster-src; };
        packages.scotch = pkgs.scotch;
        packages.metis = pkgs.metis;
        packages.med = pkgs.med;
        packages.hpddm = pkgs.hpddm;
        packages.mumps = pkgs.mumps;
        packages.medcoupling = pkgs.medcoupling;
        packages.parmetis = pkgs.parmetis;
      };
      flake = {
      };
    };
}
