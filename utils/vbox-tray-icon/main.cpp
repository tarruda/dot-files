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
static HMENU menu;


void InitMenu() {
  menu = CreatePopupMenu();
  AppendMenu(menu, MF_STRING, WM_TRAY_STARTVM, "Start VM");
  AppendMenu(menu, MF_STRING, WM_TRAY_ACPISHUTDOWN, "ACPI shutdown");
  AppendMenu(menu, MF_STRING, WM_TRAY_SAVESTATE, "Save VM state");
  AppendMenu(menu, MF_SEPARATOR, NULL, NULL);
  AppendMenu(menu, MF_STRING, WM_TRAY_EXIT, "Exit");
}

LRESULT CALLBACK HandleTrayMessage(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
  UINT clicked;
  POINT point;
  // these flags will disable messages about the context menu
  // and focus on returning the clicked item id
  UINT flags = TPM_RETURNCMD | TPM_NONOTIFY;

  switch(lParam)
  {
    case WM_RBUTTONDOWN:
      GetCursorPos(&point);
      SetForegroundWindow(hWnd); 
      clicked = TrackPopupMenu(menu, flags, point.x, point.y, 0, hWnd, NULL);
      switch (clicked)
      {
        case WM_TRAY_STARTVM:
          VMStart();
          break;
        case WM_TRAY_SAVESTATE:
          VMSaveState();
          break;
        case WM_TRAY_ACPISHUTDOWN:
          VMAcpiShutdown();
          break;
        case WM_TRAY_EXIT:
          if (Ask(L"The VM will be suspended. Are you sure?")) {
            VMSaveState();
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
  /* PROCESS_INFORMATION pi; */

  if (msg == WM_EXPLORERCRASH) {
    Shell_NotifyIcon(NIM_ADD, &ndata);
    return 0;
  }

  switch (msg)
  {
    case WM_TRAYEVENT:
      return HandleTrayMessage(hWnd, msg, wParam, lParam);
    case WM_CREATE:
      InitMenu();
      return 0;
    case WM_QUERYENDSESSION:
      return TRUE;       
    case WM_ENDSESSION: 
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
  wcscpy((wchar_t *)ndata.szTip, L"Virtualbox Tray Icon");
  ndata.uFlags = NIF_MESSAGE | NIF_ICON | NIF_TIP;


  Shell_NotifyIcon(NIM_ADD, &ndata);

  // listen for the "explorer crash event" so we can add the icon
  // again
  WM_EXPLORERCRASH = RegisterWindowMessageA("TaskbarCreated");

  // initialize the virtualbox api
  InitVirtualbox(vmname);

  while (GetMessage(&msg, NULL, 0, 0))
  {
    TranslateMessage(&msg);
    DispatchMessage(&msg);
  }

  // remote tray icon
  Shell_NotifyIcon(NIM_DELETE, &ndata);
  // cleanup virtualbox api resources
  FreeVirtualbox();
  return (int) msg.wParam;
}

