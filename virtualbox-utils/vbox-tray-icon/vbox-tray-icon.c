#include <windows.h>
#include <stdlib.h>
#include <string.h>
#include <tchar.h>
#include <shellapi.h>

#include "vbox-tray-icon.h"

#define WM_TRAYEVENT (WM_USER + 1)
#define WB_TRAY_EXIT 1

UINT WM_EXPLORERCRASH = 0 ;

static TCHAR wclass[] = _T("vboxtrayicon");
static TCHAR title[] = _T("VirtualBox Tray Icon");

NOTIFYICONDATA ndata;

// Tray icon context menu
HMENU menu;

void run_command() {
  STARTUPINFO si = { 0 };
  si.cb = sizeof(si);
  si.dwFlags = STARTF_USESTDHANDLES | STARTF_USESHOWWINDOW;
  si.hStdInput = GetStdHandle(STD_INPUT_HANDLE);
  si.hStdOutput =  GetStdHandle(STD_OUTPUT_HANDLE);
  si.hStdError = GetStdHandle(STD_ERROR_HANDLE);
  si.wShowWindow = SW_HIDE;
}

void init_menu() {
  menu = CreatePopupMenu();
  AppendMenu(menu, MF_STRING, WB_TRAY_EXIT, "Exit");
}

LRESULT CALLBACK handle_tray_message(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
  UINT clicked;
  POINT point;
  int result;
  // these flags will disable messages about the context menu and focus on
  // returning the clicked item id
  UINT flags = TPM_RETURNCMD | TPM_NONOTIFY;

  switch(lParam)
  {
    case WM_RBUTTONDOWN:
      GetCursorPos(&point);
      SetForegroundWindow(hWnd); 
      clicked = TrackPopupMenu(menu, flags, point.x, point.y, 0, hWnd, NULL);
      switch (clicked)
      {
        case WB_TRAY_EXIT:
          result = MessageBox(NULL, "Save the VM state?", "Exit VM instance",
              MB_YESNO);
          if (result == IDYES) PostQuitMessage(0);
          break;
      };
      break;
    default:
      return DefWindowProc(hWnd, msg, wParam, lParam);
  };
}

LRESULT CALLBACK handle_message(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
  if (msg == WM_EXPLORERCRASH) {
      Shell_NotifyIcon(NIM_ADD, &ndata);
      return 0;
  }

  switch (msg)
  {
    case WM_TRAYEVENT:
      return handle_tray_message(hWnd, msg, wParam, lParam);
    case WM_CREATE:
      init_menu();
      return 0;
    default:
      return DefWindowProc(hWnd, msg, wParam, lParam);
  };
}

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance,
    LPSTR lpCmdLine, int nCmdShow)
{
  WNDCLASSEX wcex;
  MSG msg;
  HWND hWnd;

  // every application that wants to use a message loop needs to
  // initialize/register this structure, as it points to the message handler
  // function.
  wcex.cbSize = sizeof(WNDCLASSEX);
  wcex.style = CS_HREDRAW | CS_VREDRAW;
  wcex.lpfnWndProc = handle_message;
  wcex.cbClsExtra = 0;
  wcex.cbWndExtra = 0;
  wcex.hInstance = hInstance;
  wcex.hIcon = LoadIcon(hInstance, MAKEINTRESOURCE(IDI_APPLICATION));
  wcex.hCursor = LoadCursor(NULL, IDC_ARROW);
  wcex.hbrBackground = (HBRUSH)COLOR_APPWORKSPACE;
  wcex.lpszMenuName = NULL;
  wcex.lpszClassName = wclass;
  wcex.hIconSm = LoadIcon(wcex.hInstance, MAKEINTRESOURCE(IDI_APPLICATION));
  RegisterClassEx(&wcex);

  // without creating a window no message queue will exist, so this is needed
  // even if the window will be hidden most of the time
  hWnd = CreateWindow(wclass, title, WS_OVERLAPPEDWINDOW, CW_USEDEFAULT,
      CW_USEDEFAULT, 500, 100, NULL, NULL, hInstance, NULL);

  // fill structure that holds data about the tray icon
  ndata.cbSize = sizeof(NOTIFYICONDATA);
  ndata.hWnd = hWnd;
  ndata.uCallbackMessage = WM_TRAYEVENT; // custom message to identify tray events 
  ndata.hIcon = LoadIcon(hInstance, MAKEINTRESOURCE(IDI_VBOXICON));
  wcscpy(ndata.szTip, "Virtualbox Tray Icon");
  ndata.uFlags = NIF_MESSAGE | NIF_ICON | NIF_TIP;

  Shell_NotifyIcon(NIM_ADD, &ndata);

  // listen for the "explorer crash event" so we can add the icon again
  WM_EXPLORERCRASH = RegisterWindowMessageA("TaskbarCreated");

  while (GetMessage(&msg, NULL, 0, 0))
  {
    TranslateMessage(&msg);
    DispatchMessage(&msg);
  }

  // remote tray icon
  Shell_NotifyIcon(NIM_DELETE, &ndata);

  return (int) msg.wParam;
}

