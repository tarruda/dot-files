// this is largely based on the sdk example
#include <stdio.h>
#include <stdarg.h>
#include <wchar.h>
#include <windows.h>
#include "VirtualBox.h"

#include "api.h"

#define SAFE_RELEASE(x) \
    if (x) { \
        x->Release(); \
        x = NULL; \
    }

// main interface to virtualbox api
static IVirtualBox *virtualbox;

void StartVM(const wchar_t *name)
{
  HRESULT rc;
  IMachine *machine = NULL;
  ISession *session = NULL;
  IConsole *console = NULL;
  IProgress *progress = NULL;
  BSTR sessiontype;
  BSTR guid;
  BSTR machineName = SysAllocString(name);

  /* Try to find the machine */
  rc = virtualbox->FindMachine(machineName, &machine);

  if (FAILED(rc)) {
    ShowError(L"Could not find virtual machine named '%s'", name);
    return;
  } else {
    sessiontype = SysAllocString(L"gui");

     /* Get machine uuid */
    rc = machine->get_Id(&guid);
    if (!SUCCEEDED(rc)) {
      ShowError(L"Failed to get uuid for '%s'", name);
      return;
    }

    /* Create the session object. */
    rc = CoCreateInstance(CLSID_Session, NULL, CLSCTX_INPROC_SERVER,
        IID_ISession, (void**)&session);
    if (!SUCCEEDED(rc)) {
      ShowError(L"Error creating session instance! rc = 0x%x", rc);
      return;
    }

    /* Start a VM session using the delivered VBox GUI. */
    rc = machine->LaunchVMProcess(session, sessiontype, NULL, &progress);
    if (!SUCCEEDED(rc)) {
      ShowError(L"Could not open remote session for '%s'", name);
      return;
    }

    /* Wait until VM is running. */
    rc = progress->WaitForCompletion(-1);

    /* Get console object. */
    session->get_Console(&console);

    /* Bring console window to front. */
    machine->ShowConsoleWindow(0);

    SAFE_RELEASE(console);
    SAFE_RELEASE(progress);
    SAFE_RELEASE(session);
    SysFreeString(guid);
    SysFreeString(sessiontype);
    SAFE_RELEASE(machine);
  }

  SysFreeString(machineName);
}

void InitVirtualbox()
{
  /* Initialize the COM subsystem. */
  CoInitialize(NULL);

  /* Instantiate the VirtualBox root object. */
  CoCreateInstance(CLSID_VirtualBox, NULL, CLSCTX_LOCAL_SERVER,
      IID_IVirtualBox, (void**)&virtualbox);

}

void FreeVirtualbox()
{
  virtualbox->Release();
  CoUninitialize();
}

/* Utility functions */

int Ask(const wchar_t * format, ...)
{
  int res;
  char result[2048];
  wchar_t msg[1024];
  va_list args;
  va_start(args, format);
  vswprintf(msg, format, args);
  va_end(args);
  wsprintf(result, "%S", msg);
  res = MessageBox(NULL, result, "Confirm", MB_YESNO | MB_ICONQUESTION);
  free(result);
  free(msg);
  if (res == IDYES)
    return 1;
  return 0;
}

void ShowError(const wchar_t * format, ...)
{
  char result[2048];
  wchar_t msg[1024];
  va_list args;
  va_start(args, format);
  vswprintf(msg, format, args);
  va_end(args);
  // convert to char*(couldn't get mingw compile with unicode)
  wsprintf(result, "%S", msg);

  MessageBox(NULL, result, "Error", MB_OK | MB_ICONERROR);
  free(result);
  free(msg);
}

