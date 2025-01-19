{ lib
, llvmPackages_latest
, cmake
, fetchgit
}:
llvmPackages_latest.stdenv.mkDerivation rec {
  pname = "bootloader";
  version = "0.1.0";
  src = ./.;
  nativeBuildInputs = [
    cmake
    llvmPackages_latest.clang-unwrapped
    llvmPackages_latest.lld
  ];
  cmakeFlags = [
    "-DENABLE_TESTING=OFF"
    "-DENABLE_INSTALL=ON"
  ];
  installPhase = ''
    mkdir -p $out
    mv BOOTX64.EFI $out/bootx64.efi
  '';
}
