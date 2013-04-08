void InitVirtualbox(const wchar_t *name);
void FreeVirtualbox();
void VMStart();
void VMSaveState();
void VMAcpiShutdown();
int Ask(const wchar_t * format, ...);
void ShowError(const wchar_t *format, ...);
