#include <stdio.h>
#include <string.h>
#include <windows.h>
#include "sdk/bindings/mscom/include/VirtualBox.h"


void debugbox(char *msg);

static IVirtualBox *virtualbox;

void startvm(char *name)
{
  const size_t size = strlen(name) + 1;
  wchar_t* wname = new wchar_t[size];
  mbstowcs(wname, name, size);

  HRESULT rc;
  IMachine *machine = NULL;
  BSTR machineName = SysAllocString(wname);

  rc = virtualbox->FindMachine(machineName, &machine);

  if (FAILED(rc))
    debugbox("not found");
  else 
    debugbox("found!!");

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
