#include "VirtualBox.h"

int InitVirtualbox(const wchar_t *name, NOTIFYICONDATA *ndata);
void FreeVirtualbox();
void VMStart();
void VMSaveState(int showError);
void VMAcpiShutdown(int showError);
MachineState VMGetState();
int Ask(const wchar_t * format, ...);
void ShowError(const wchar_t *format, ...);
void ShowInfo(const wchar_t *format, ...);
void UpdateTray(MachineState state);
