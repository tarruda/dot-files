// based on the sdk example
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

void startvm(const wchar_t *name)
{
  HRESULT rc;
  IMachine *machine = NULL;
  BSTR machineName = SysAllocString(name);

  rc = virtualbox->FindMachine(machineName, &machine);

  if (FAILED(rc)) {
    sHowError(L"Cannot find machine named '%S'", name);
  } else {
    ShowError(L"Found '%s'", name);
    return;
    ISession *session = NULL;
    IConsole *console = NULL;
    IProgress *progress = NULL;
    BSTR sessiontype = SysAllocString(L"gui");
    BSTR guid;

    do
    {
      rc = machine->get_Id(&guid); /* Get the GUID of the machine. */
      if (!SUCCEEDED(rc))
      {
      //printf("Error retrieving machine ID! rc = 0x%x\n", rc);
        break;
      }

      /* Create the session object. */
      rc = CoCreateInstance(CLSID_Session,        /* the VirtualBox base object */
          NULL,                 /* no aggregation */
          CLSCTX_INPROC_SERVER, /* the object lives in a server process on this machine */
          IID_ISession,         /* IID of the interface */
          (void**)&session);
      if (!SUCCEEDED(rc))
      {
        //printf("Error creating Session instance! rc = 0x%x\n", rc);
        break;
      }

      /* Start a VM session using the delivered VBox GUI. */
      rc = machine->LaunchVMProcess(session, sessiontype,
          NULL, &progress);
      if (!SUCCEEDED(rc))
      {
        //printf("Could not open remote session! rc = 0x%x\n", rc);
        break;
      }

      /* Wait until VM is running. */
      //printf ("Starting VM, please wait ...\n");
      rc = progress->WaitForCompletion (-1);

      /* Get console object. */
      session->get_Console(&console);

      /* Bring console window to front. */
      machine->ShowConsoleWindow(0);

      //printf ("Press enter to power off VM and close the session...\n");
      getchar();

      /* Power down the machine. */
      rc = console->PowerDown(&progress);

      /* Wait until VM is powered down. */
      //printf ("Powering off VM, please wait ...\n");
      rc = progress->WaitForCompletion (-1);

      /* Close the session. */
      rc = session->UnlockMachine();

    } while (0);

    SAFE_RELEASE(console);
    SAFE_RELEASE(progress);
    SAFE_RELEASE(session);
    SysFreeString(guid);
    SysFreeString(sessiontype);
    SAFE_RELEASE(machine);
  }
  ShowError(L"found!!");

  SysFreeString(machineName);
}

void init_virtualbox()
{
  /* Initialize the COM subsystem. */
  CoInitialize(NULL);

  /* Instantiate the VirtualBox root object. */
  CoCreateInstance(CLSID_VirtualBox, NULL, CLSCTX_LOCAL_SERVER,
      IID_IVirtualBox, (void**)&virtualbox);

}

void destroy_virtualbox()
{
  virtualbox->Release();
  CoUninitialize();
}
