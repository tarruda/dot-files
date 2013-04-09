#include "VirtualBox.h"

int InitVirtualbox(const wchar_t *name);
void FreeVirtualbox();
void VMStart();
void VMSaveState();
void VMAcpiShutdown();
MachineState VMGetState();
int Ask(const wchar_t * format, ...);
void ShowError(const wchar_t *format, ...);
void ShowInfo(const wchar_t *format, ...);
