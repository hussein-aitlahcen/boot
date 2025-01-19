{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, ... }@inputs: inputs.utils.lib.eachSystem [
    "x86_64-linux" "i686-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"
  ] (system: let
    pkgs = import nixpkgs {
      inherit system;
      overlays = [];
      config.allowUnfree = true;
    };
  in {
    devShells.default = pkgs.mkShell rec {
      name = "dev";
      packages = with pkgs; [
        llvmPackages_latest.clang-unwrapped
        llvmPackages_latest.lld
        cmake
        cmakeCurses
        mtools
        xorriso
      ];
    };
    packages.default = pkgs.callPackage ./default.nix { };
    packages.iso = pkgs.runCommand "package-iso" { buildInputs = with pkgs; [ xorriso mtools ]; } ''
      set -xe
      mkdir -p iso
      if [ ! -f iso/fat.img ]; then
          echo "Creating fat.img..."
          dd if=/dev/zero of=./iso/fat.img bs=1k count=1440
          mformat -i iso/fat.img -f 1440 ::
          mmd -i iso/fat.img ::/EFI
          mmd -i iso/fat.img ::/EFI/BOOT
      fi
      echo "Copying efi app"
      mcopy -o -i iso/fat.img ${self.packages.${system}.default}/bootx64.efi ::/EFI/BOOT
      xorriso -as mkisofs -R -f -e fat.img -no-emul-boot -o cdimage.iso iso
      mkdir $out
      mv cdimage.iso $out/bootloader.iso
    '';
    packages.qemu-debug = pkgs.writeShellApplication {
      name = "qemu-debug";
      text = ''
        TMP=$(mktemp -d)
        cp ${pkgs.OVMFFull.fd}/FV/OVMF_VARS.fd "$TMP"
        chmod a+rw "$TMP"/OVMF_VARS.fd
        qemu-kvm \
            -machine q35 \
            -cpu host \
            -drive if=pflash,format=raw,unit=0,readonly=on,file=${pkgs.OVMFFull.fd}/FV/OVMF_CODE.fd \
            -drive if=pflash,format=raw,unit=1,readonly=off,file="$TMP"/OVMF_VARS.fd \
            -cdrom ${self.packages.${system}.iso}/bootloader.iso \
            -nodefaults \
            -vga std \
            -display gtk,zoom-to-fit=on \
            -m 1024M
      '';
    };
  });
}
