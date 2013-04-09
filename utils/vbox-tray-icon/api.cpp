// This was written using the sdk example as base and the virtualbox api
// reference. I did not look at real examples(eg: VBoxHeadless.Less) so it may
// not be following the best practices.
#include <stdio.h>
#include <stdarg.h>
#include <wchar.h>
#include <windows.h>

#include "api.h"

#define SAFE_RELEASE(x) \
    if (x) { \
        x->Release(); \
        x = NULL; \
    }

// main interface to virtualbox api
static IVirtualBox *virtualbox = NULL;
// running vm session
static ISession *session = NULL;
// running vm console
static IConsole *console = NULL;
// running vm
IMachine *machine = NULL;
// vm name
const wchar_t *name;
static char *vmname_ascii;
char tooltip[64];
// default session type
wchar_t *sessiontype = L"headless";

static NOTIFYICONDATA *ndata;

void VMStart()
{
  HRESULT rc;
  IProgress *progress;
  BSTR stype = SysAllocString(sessiontype);

  rc = machine->LaunchVMProcess(session, stype, NULL, &progress);
  if (!SUCCEEDED(rc))
    ShowError(L"Failed to start '%s'. rc = 0x%x", name, rc);

  progress->WaitForCompletion(-1);
  UpdateTray(MachineState_Running);

  // this object is used to control the vm
  session->get_Console(&console);

  SysFreeString(stype);
  SAFE_RELEASE(progress);
}

void VMSaveState(int showError)
{
  HRESULT rc;
  IProgress *progress;

  rc = console->SaveState(&progress);

  if (FAILED(rc) && showError)
    ShowError(L"Failed to save '%s' state. rc = 0x%x", name, rc);
  progress->WaitForCompletion(-1);
  UpdateTray(MachineState_Saved);

  SAFE_RELEASE(progress);
}

void VMAcpiShutdown(int showError)
{
  HRESULT rc;

  rc = console->PowerButton();
  if (FAILED(rc)) {
    if(showError)
      ShowError(L"Failed to press '%s' power button. rc = 0x%x", name, rc);
    return;
  }
  UpdateTray(MachineState_PoweredOff);
}

MachineState VMGetState()
{
  MachineState state;
  machine->get_State(&state);
  return state;
}

int InitVirtualbox(const wchar_t *n, NOTIFYICONDATA *notifyData)
{
  HRESULT rc;
  BSTR guid;
  name = n;
  BSTR machineName = SysAllocString(name);
  ndata = notifyData;

  // initialize the COM subsystem.
  CoInitialize(NULL);

  // instantiate the VirtualBox root object.
  CoCreateInstance(CLSID_VirtualBox, NULL, CLSCTX_LOCAL_SERVER,
      IID_IVirtualBox, (void**)&virtualbox);

  // try to find the machine
  rc = virtualbox->FindMachine(machineName, &machine);

  if (FAILED(rc)) {
    ShowError(L"Could not find virtual machine named '%s'", name);
    return 0;
  } else {
    // get the machine uuid
    rc = machine->get_Id(&guid);
    if (!SUCCEEDED(rc)) {
      ShowError(L"Failed to get uuid for '%s'. rc = 0x%x", name, rc);
      return 0;
    }

    // create the session object.
    rc = CoCreateInstance(CLSID_Session, NULL, CLSCTX_INPROC_SERVER,
        IID_ISession, (void**)&session);

    if (!SUCCEEDED(rc)) {
      ShowError(L"Failed to create session instance for '%s'. rc = 0x%x", name, rc);
      return 0;
    }

    // if the vm is saved, start it now
    if (VMGetState() == MachineState_Saved)
      VMStart();

    vmname_ascii = *(__argv + 1);
    UpdateTray(VMGetState());
    // release uneeded resources
    return 1;
  }
}

void FreeVirtualbox()
{
  if (VMGetState() == MachineState_Running)
    VMSaveState(0);
  session->UnlockMachine();
  virtualbox->Release();
  CoUninitialize();
}

/* Utility functions */

void UpdateTray(MachineState state)
{
  switch (state) {
    case MachineState_PoweredOff:
      sprintf(tooltip, "%s: powered off", vmname_ascii); break;
    case MachineState_Running:
      sprintf(tooltip, "%s: running", vmname_ascii); break;
    case MachineState_Saved:
      sprintf(tooltip, "%s: saved", vmname_ascii); break;
    default:
      sprintf(tooltip, "%s", vmname_ascii); break;
  };
  strcpy(ndata->szTip, TEXT(tooltip));
}

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
}

void ShowInfo(const wchar_t *format, ...)
{
  char result[2048];
  wchar_t msg[1024];
  va_list args;
  va_start(args, format);
  vswprintf(msg, format, args);
  va_end(args);
  // convert to char*(couldn't get mingw compile with unicode)
  wsprintf(result, "%S", msg);

  MessageBox(NULL, result, "Info", MB_OK | MB_ICONINFORMATION);
}

