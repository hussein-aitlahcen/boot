#include <Uefi.h>

EFI_STATUS efi_main([[maybe_unused]] EFI_HANDLE handler,
                    EFI_SYSTEM_TABLE *system_table) {
  EFI_STATUS status;
  EFI_INPUT_KEY key;

  auto ST = system_table;

  status = ST->ConOut->OutputString(ST->ConOut, L"yo bruv\n");
  if (EFI_ERROR(status))
    return status;

  status = ST->ConIn->Reset(ST->ConIn, FALSE);
  if (EFI_ERROR(status))
    return status;

  while ((status = ST->ConIn->ReadKeyStroke(ST->ConIn, &key)) == EFI_NOT_READY)
    ;

  return status;
}
