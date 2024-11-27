{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-matt.url = "github:matthewcroughan/nixpkgs/mc/update-vtk";
#    vtk-nixpkgs.url = "github:bcdarwin/nixpkgs/update-vtk";
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
        _module.args.pkgs = import inputs.nixpkgs-matt {
          config.allowUnfree = true;
          overlays = [
            (self: super: {
              codeaster = self.callPackage ./default.nix { codeaster-src = inputs.codeaster-src; };
              vtk = (super.vtk.override {
                enableQt = true;
                enablePython = true;
                enableEgl = true;
                python = self.python311;
              }).overrideAttrs (old: {
#                src = pkgs.fetchFromGitHub {
#                  owner = "Kitware";
#                  repo = "VTK";
##                  rev = "v9.4.0";
##                  hash = "sha256-OUB3Po7rv7B2eOm6ZL+KiSdLuOqDTT1cqGgV3BUVlnI=";
#rev = "v9.3.1";
#hash = "sha256-HM19Itmce/qFORa4PNZWJ/R//hBrNxq/adhPtM+3LqE=";
#                  fetchSubmodules = true;
#                };
                prePatch = ''
                  sed '1i#include <cstdint>' \
                  -i IO/PIO/PIOData.h \
                  -i Rendering/Matplotlib/vtkMatplotlibMathTextUtilities.h
                  sed '1i#include <cstdint>' \
                    -i ThirdParty/libproj/vtklibproj/src/proj_json_streaming_writer.hpp \
                    -i IO/Image/vtkSEPReader.h
                '';
#                nativeBuildInputs = old.nativeBuildInputs ++ [ pkgs.ninja ];
                cmakeFlags = old.cmakeFlags ++ [
                  "-DVTK_USE_64BIT_IDS=ON"
                  "-DVTK_MODULE_ENABLE_VTK_cli11=YES"
                  "-DVTK_MODULE_ENABLE_VTK_vtkm_cont=YES"
                  "-DVTK_MODULE_ENABLE_VTK_vtkm_filter=YES"
"-DVTK_HAVE_GETSOCKNAME_WITH_SOCKLEN_T=1"
"-DBUILD_SHARED_LIBS=ON"
"-DVTK_USE_HYBRID=ON"
"-DVTK_USE_PARALLEL=ON"
"-DVTK_USE_PATENTED=OFF"
"-DVTK_USE_RENDERING=ON"
"-DVTK_USE_GL2PS=ON"
"-DVTK_WRAP_PYTHON=ON"
"-DVTK_WRAP_TCL=OFF"
"-DVTK_USE_TK=OFF"
"-DVTK_USE_MPI=ON"
"-DVTK_MODULE_ENABLE_VTK_RenderingParallel=YES"
  "-DVTK_MODULE_ENABLE_VTK_WebCore=YES"
  "-DVTK_MODULE_ENABLE_VTK_WebGLExporter=YES"
  "-DVTK_MODULE_ENABLE_VTK_ParallelMPI=YES"
  "-DVTK_MODULE_ENABLE_VTK_FiltersParallelDIY2=YES"
"-DVTK_MODULE_ENABLE_VTK_FiltersParallelStatistics=YES"
"-DVTK_MODULE_ENABLE_VTK_FiltersParallelFlowPaths=YES"
"-DVTK_MODULE_ENABLE_VTK_RenderingVolumeAMR=YES"
"-DVTK_MODULE_ENABLE_VTK_RenderingMatplotlib=YES"
"-DVTK_MODULE_ENABLE_VTK_ParallelMPI4Py=YES"
"-DVTK_MODULE_ENABLE_VTK_IOXdmf2=YES"
"-DVTK_MODULE_ENABLE_VTK_IOVPIC=YES"
"-DVTK_MODULE_ENABLE_VTK_IOTRUCHAS=YES"
"-DVTK_MODULE_ENABLE_VTK_IOXdmf3=YES"
"-DVTK_MODULE_ENABLE_VTK_IOParallelNetCDF=YES"
"-DVTK_MODULE_ENABLE_VTK_IOParallelLSDyna=YES"
"-DVTK_MODULE_ENABLE_VTK_IOParallelExodus=YES"
"-DVTK_MODULE_ENABLE_VTK_IOPIO=YES"
"-DVTK_MODULE_ENABLE_VTK_IOOMF=YES"
"-DVTK_MODULE_ENABLE_VTK_IOMPIImage=YES"
"-DVTK_MODULE_ENABLE_VTK_IOH5part=YES"
"-DVTK_MODULE_ENABLE_VTK_IOH5Rage=YES"
"-DVTK_MODULE_ENABLE_VTK_IOFFMPEG=YES"
"-DVTK_MODULE_ENABLE_VTK_IOGDAL=YES"
"-DVTK_MODULE_ENABLE_VTK_FiltersParallelVerdict=YES"
"-DVTK_MODULE_ENABLE_VTK_FiltersParallelGeometry=YES"
"-DVTK_MODULE_ENABLE_VTK_FiltersParallelMPI=YES"
"-DVTK_MODULE_ENABLE_VTK_AcceleratorsVTKmFilters=YES"
"-DVTK_MODULE_ENABLE_VTK_AcceleratorsVTKmCore=YES"
"-DVTK_MODULE_ENABLE_VTK_AcceleratorsVTKmDataModel=YES"

                ];
#                cmakeFlags = old.cmakeFlags ++ [
#                  "-DVTK_MODULE_ENABLE_VTK_cli11=YES"
#                  "-DVTK_MODULE_ENABLE_VTK_vtkm_cont=YES"
#                  "-DVTK_MODULE_ENABLE_VTK_vtkm_filter=YES"
#
#  "-DVTK_MODULE_ENABLE_VTK_ParallelMPI=YES"
#  "-DVTK_MODULE_ENABLE_VTK_WebCore=YES"
#  "-DVTK_MODULE_ENABLE_VTK_FiltersParallelDIY2=YES"
#  "-DVTK_MODULE_ENABLE_VTK_WebGLExporter=YES"
#  "-DVTK_USE_MPI=YES"
#
#  "-DVTK_MODULE_ENABLE_VTK_FiltersParallelStatistics=YES"
#  "-DVTK_MODULE_ENABLE_VTK_FiltersParallelFlowPaths=YES"
#  "-DVTK_MODULE_ENABLE_VTK_RenderingVolumeAMR=YES"
#  "-DVTK_MODULE_ENABLE_VTK_RenderingMatplotlib=YES"
#  "-DVTK_MODULE_ENABLE_VTK_ParallelMPI4Py=YES"
#  "-DVTK_MODULE_ENABLE_VTK_IOXdmf2=YES"
#  "-DVTK_MODULE_ENABLE_VTK_IOXdmf3=YES"
#  "-DVTK_MODULE_ENABLE_VTK_IOVPIC=YES"
#  "-DVTK_MODULE_ENABLE_VTK_IOTRUCHAS=YES"
#  "-DVTK_MODULE_ENABLE_VTK_IOParallelNetCDF=YES"
#  "-DVTK_MODULE_ENABLE_VTK_IOParallelLSDyna=YES"
#  "-DVTK_MODULE_ENABLE_VTK_IOParallelExodus=YES"
#  "-DVTK_MODULE_ENABLE_VTK_IOPIO=YES"
#  "-DVTK_MODULE_ENABLE_VTK_IOOMF=YES"
#  "-DVTK_MODULE_ENABLE_VTK_IOMPIImage=YES"
#  "-DVTK_MODULE_ENABLE_VTK_IOH5part=YES"
#  "-DVTK_MODULE_ENABLE_VTK_IOH5Rage=YES"
#  "-DVTK_MODULE_ENABLE_VTK_IOFFMPEG=YES"
#  "-DVTK_MODULE_ENABLE_VTK_IOGDAL=YES"
#  "-DVTK_MODULE_ENABLE_VTK_FiltersParallelVerdict=YES"
#  "-DVTK_MODULE_ENABLE_VTK_FiltersParallelGeometry=YES"
#  "-DVTK_MODULE_ENABLE_VTK_FiltersParallelMPI=YES"
#  "-DVTK_MODULE_ENABLE_VTK_AcceleratorsVTKmFilters=YES"
#  "-DVTK_MODULE_ENABLE_VTK_AcceleratorsVTKmCore=YES"
#  "-DVTK_MODULE_ENABLE_VTK_AcceleratorsVTKmDataModel=YES"
#
#
#                  "-DVTK_MODULE_ENABLE_VTK_RenderingParallel=YES"
#                ];
                buildInputs = old.buildInputs ++ [
                  self.cli11
                  self.mpi
                  self.boost
                  self.ffmpeg
                  self.gdal
                ];
              });
#              vtk = super.vtk.overrideAttrs (old: {
#                cmakeFlags = old.cmakeFlags ++ [
#                  "VTK_MODULE_ENABLE_VTK_RenderingLOD=YES"
#                ];
#              });
              salome-bootstrap = self.callPackage ./salome-bootstrap.nix {};
              salome-configuration = import ./salome-configuration.nix;
              salome-paravis = self.callPackage ./salome-paravis.nix {};
              paraview = inputs.nixpkgs2405.legacyPackages.${super.hostPlatform.system}.paraview;
              #paraview = super.paraview.overrideAttrs {
              #  src = pkgs.fetchFromGitHub {
              #    owner = "Kitware";
              #    repo = "ParaView";
              #    rev = "v5.12.1";
              #    hash = "sha256-jbqMqj3D7LTwQ+hHIPscCHw4TfY/BR2HuVmMYom2+dA=";
              #    fetchSubmodules = true;
              #  };
              #};
              gdal = inputs.nixpkgs.legacyPackages.${super.hostPlatform.system}.gdal;
#              paraview = self.libsForQt5.callPackage "${inputs.nixpkgs2405}/pkgs/applications/graphics/paraview/default.nix" { python3 = self.python311; };
              #inputs.nixpkgs2405.legacyPackages.${super.hostPlatform.system}.paraview;
              salome-gui = self.callPackage ./salome-gui.nix {};
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
#                mpiSupport = true;
                cppSupport = false;
              };

              scotch = super.scotch.overrideAttrs (old: {
                cmakeFlags = (old.cmakeFlags or []) ++ [
                  "-DINTSIZE=64"
                  "-DINSTALL_METIS_HEADERS=OFF"
                ];
              });
              medfile = (super.medfile.overrideAttrs (old: {
                buildInputs = old.buildInputs ++ [ self.mpi ];
                cmakeFlags = (old.cmakeFlags or []) ++ [
                  "-DCMAKE_Fortran_COMPILER=mpif90"
                  "-DMEDFILE_USE_MPI=ON"
                  "-DMED_MEDINT_TYPE=long"
                  "-DMEDFILE_BUILD_STATIC_LIBS=OFF"
                  ''-DCMAKE_Fortran_FLAGS="-fdefault-integer-8"''
                ];
              })).override { hdf5 = self.hdf5-mpi; };
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
