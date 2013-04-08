void InitVirtualbox();
void FreeVirtualbox();
void StartVM(const wchar_t *name);
int Ask(const wchar_t * format, ...);
void ShowError(const wchar_t *format, ...);
