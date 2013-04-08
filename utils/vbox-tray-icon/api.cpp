// a lot here was copied from the sdk example, so it may not
// follow the best practices for virtualbox programming
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
// running vm session
static ISession *session;
// running vm console
static IConsole *console;

void VMStart()
{
  HRESULT rc;
  IMachine *machine = NULL;
  IProgress *progress = NULL;
  BSTR sessiontype;
  BSTR guid;
  BSTR machineName = SysAllocString(name);

  // try to find the machine //
  rc = virtualbox->FindMachine(machineName, &machine);

  if (FAILED(rc)) {
    ShowError(L"Could not find virtual machine named '%s'", name);
    return;
  } else {
    sessiontype = SysAllocString(L"headless");

    // get the machine uuid
    rc = machine->get_Id(&guid);
    if (!SUCCEEDED(rc)) {
      ShowError(L"Failed to get uuid for '%s'. rc = 0x%x", name, rc);
      return;
    }

    // create the session object.
    rc = CoCreateInstance(CLSID_Session, NULL, CLSCTX_INPROC_SERVER,
        IID_ISession, (void**)&session);
    if (!SUCCEEDED(rc)) {
      ShowError(L"Failed to create session instance for '%s'. rc = 0x%x", name, rc);
      return;
    }

    // start a headless VM session //
    rc = machine->LaunchVMProcess(session, sessiontype, NULL, &progress);
    if (!SUCCEEDED(rc)) {
      ShowError(L"Failed to start a new remote session for '%s'. rc = 0x%x", name, rc);
      return;
    }

    // wait until VM is running.
    progress->WaitForCompletion(-1);

    // store console object.
    session->get_Console(&console);

    // release uneeded resources
    SAFE_RELEASE(progress);
    SysFreeString(guid);
    SysFreeString(sessiontype);
    SAFE_RELEASE(machine);
  }

  SysFreeString(machineName);
}

void VMSaveState()
{

}

int InitVirtualbox(const wchar_t *name)
{
  HRESULT rc;
  IMachine *machine = NULL;
  BSTR sessiontype;
  BSTR guid;
  BSTR machineName = SysAllocString(name);

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
    sessiontype = SysAllocString(L"headless");

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

    // lock the machine
    rc = machine->lockMachine(&session, LockType_Write);
    if (!SUCCEEDED(rc)) {
      ShowError(L"Failed to acquire lock for '%s'. rc = 0x%x", name, rc);
      return 0;
    }

    // get the vm console
    session->get_Console(&console);

    // release uneeded resources
    SAFE_RELEASE(progress);
    SysFreeString(guid);
    SysFreeString(sessiontype);
    SysFreeString(machineName);
    SAFE_RELEASE(machine);
    return 1;
  }
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

