{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation rec {
  pname = "tfel";
  version = "4.2.1";

  src = fetchFromGitHub {
    owner = "thelfer";
    repo = "tfel";
    rev = "TFEL-${version}";
    hash = "sha256-8jWyPX7jsz/PJYfCPrvH6Ze0AaMD/qvFm77a63isk2s=";
  };

  nativeBuildInputs = [
    cmake
  ];

  meta = {
    description = "Main repository of TFEL/MFront project";
    homepage = "https://github.com/thelfer/tfel";
    changelog = "https://github.com/thelfer/tfel/blob/${src.rev}/ChangeLog";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ matthewcroughan ];
    mainProgram = "tfel";
    platforms = lib.platforms.all;
  };
}
