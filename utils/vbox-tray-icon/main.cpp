#include <windows.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <tchar.h>
#include <shellapi.h>

#include "resources/resources.h"

#include "api.h"


#define WM_TRAYEVENT (WM_USER + 1)
#define WM_TRAY_STARTVM 1
#define WM_TRAY_ACPISHUTDOWN 2
#define WM_TRAY_SAVESTATE 3
#define WM_TRAY_EXIT 10

static UINT WM_EXPLORERCRASH = 0;

static TCHAR wclass[] = _T("vboxtrayicon");
static TCHAR title[] = _T("VirtualBox Tray Icon");

static NOTIFYICONDATA ndata;

// Tray icon context menu
static HMENU running_menu;
static HMENU stopped_menu;

static wchar_t *vmname;

void InitMenus()
{
  running_menu = CreatePopupMenu();
  stopped_menu = CreatePopupMenu();
  AppendMenu(running_menu, MF_STRING, WM_TRAY_SAVESTATE, "Save VM state");
  AppendMenu(running_menu, MF_STRING, WM_TRAY_ACPISHUTDOWN, "ACPI shutdown");
  AppendMenu(running_menu, MF_SEPARATOR, NULL, NULL);
  AppendMenu(running_menu, MF_STRING, WM_TRAY_EXIT, "Exit");
  AppendMenu(stopped_menu, MF_STRING, WM_TRAY_STARTVM, "Start VM");
  AppendMenu(stopped_menu, MF_SEPARATOR, NULL, NULL);
  AppendMenu(stopped_menu, MF_STRING, WM_TRAY_EXIT, "Exit");
}


LRESULT CALLBACK HandleTrayMessage(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
  HMENU menu;
  UINT clicked;
  POINT point;
  MachineState state;
  // these flags will disable messages about the context menu
  // and focus on returning the clicked item id
  UINT flags = TPM_RETURNCMD | TPM_NONOTIFY;

  switch(lParam)
  {
    case WM_RBUTTONDOWN:
      state = VMGetState();
      GetCursorPos(&point);
      SetForegroundWindow(hWnd); 
      if (state == MachineState_Running)
        menu = running_menu;
      else
        menu = stopped_menu;
      clicked = TrackPopupMenu(menu, flags, point.x, point.y, 0, hWnd, NULL);
      switch (clicked)
      {
        case WM_TRAY_STARTVM:
          VMStart();
          break;
        case WM_TRAY_SAVESTATE:
          VMSaveState(1);
          break;
        case WM_TRAY_ACPISHUTDOWN:
          VMAcpiShutdown(1);
          break;
        case WM_TRAY_EXIT:
          if (Ask(L"Are you sure?")) {
            PostQuitMessage(0);
          }
          break;
      };
      break;
  };
  return DefWindowProc(hWnd, msg, wParam, lParam);
}

LRESULT CALLBACK HandleMessage(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
  if (msg == WM_EXPLORERCRASH) {
    Shell_NotifyIcon(NIM_ADD, &ndata);
    return 0;
  }

  switch (msg)
  {
    case WM_TRAYEVENT:
      return HandleTrayMessage(hWnd, msg, wParam, lParam);
    case WM_CREATE:
      InitMenus();
      return 0;
    case WM_QUERYENDSESSION:
      return TRUE;       
    case WM_ENDSESSION:
      PostQuitMessage(0);
      return 0;
    default:
      return DefWindowProc(hWnd, msg, wParam, lParam);
  };
}

int ParseOptions()
{
  if (__argc == 1)
    return 0;

  // convert the vm name to wchar_t
  const size_t size = strlen(*(__argv + 1)) + 1;
  vmname = new wchar_t[size];
  mbstowcs(vmname, *(__argv + 1), size);
  return 1;
}

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance,
    LPSTR lpCmdLine, int nCmdShow)
{
  WNDCLASSEX wcex;
  MSG msg;
  HWND hWnd;

  if (ParseOptions() == 0) {
    ShowError(L"Need to provide the VM name as first argument");
    return 1;
  }

  // initialize the virtualbox api
  if (!InitVirtualbox(vmname, &ndata)) {
    return 1;
  }
  // every application that wants to use a message loop needs to
  // initialize/register this structure
  wcex.cbSize = sizeof(WNDCLASSEX);
  wcex.style = CS_HREDRAW | CS_VREDRAW;
  wcex.lpfnWndProc = HandleMessage;
  wcex.cbClsExtra = 0;
  wcex.cbWndExtra = 0;
  wcex.hInstance = hInstance;
  wcex.hIcon = LoadIcon(hInstance, IDI_APPLICATION);
  wcex.hCursor = LoadCursor(NULL, IDC_ARROW);
  wcex.hbrBackground = (HBRUSH)COLOR_APPWORKSPACE;
  wcex.lpszMenuName = NULL;
  wcex.lpszClassName = wclass;
  wcex.hIconSm = LoadIcon(wcex.hInstance, IDI_APPLICATION);
  RegisterClassEx(&wcex);

  // without creating a window no message queue will exist, so this is
  // needed even if the window will be hidden most(or all) of the time
  hWnd = CreateWindow(wclass, title, WS_OVERLAPPEDWINDOW, CW_USEDEFAULT,
      CW_USEDEFAULT, 500, 100, NULL, NULL, hInstance, NULL);

  // fill structure that holds data about the tray icon
  ndata.cbSize = sizeof(NOTIFYICONDATA);
  ndata.hWnd = hWnd;
  ndata.uCallbackMessage = WM_TRAYEVENT; // custom message to identify tray events 
  ndata.hIcon = LoadIcon(hInstance, MAKEINTRESOURCE(IDI_VBOXICON));
  ndata.uFlags = NIF_MESSAGE | NIF_ICON | NIF_TIP;

  Shell_NotifyIcon(NIM_ADD, &ndata);

  // listen for the "explorer crash event" so we can add the icon
  // again
  WM_EXPLORERCRASH = RegisterWindowMessageA("TaskbarCreated");

  while (GetMessage(&msg, NULL, 0, 0))
  {
    TranslateMessage(&msg);
    DispatchMessage(&msg);
  }

  // remove tray icon
  Shell_NotifyIcon(NIM_DELETE, &ndata);
  // cleanup virtualbox api resources
  FreeVirtualbox();
  return (int) msg.wParam;
}

