#include <windows.h>
#include <stdlib.h>
#include <string.h>
#include <tchar.h>
#include <shellapi.h>

#include "vbox-tray-icon.h"

#define VBOXDIR "C:\\Program Files\\Oracle\\VirtualBox\\"
#define STARTVM VBOXDIR "VBoxHeadless.exe --startvm %s --vrdp off"
#define ACPISHUTDOWN VBOXDIR "VBoxManage.exe controlvm %s acpipowerbutton"
#define SAVESTATE VBOXDIR "VBoxManage.exe controlvm %s savestate"

#define WM_TRAYEVENT (WM_USER + 1)
#define WM_TRAY_STARTVM 1
#define WM_TRAY_ACPISHUTDOWN 2
#define WM_TRAY_SAVESTATE 3
#define WM_TRAY_EXIT 10

static UINT WM_EXPLORERCRASH = 0;

static TCHAR wclass[] = _T("vboxtrayicon");
static TCHAR title[] = _T("VirtualBox Tray Icon");

static char format_buffer[200];

static char *vmname;

static NOTIFYICONDATA ndata;

// Tray icon context menu
static HMENU menu;

int run_command(char *cmdline) 
{
  PROCESS_INFORMATION pi; 
  STARTUPINFO si;
  memset(&si, 0, sizeof(si));
  memset(&pi, 0, sizeof(pi));
  si.cb = sizeof(si);
  si.dwFlags = STARTF_USESTDHANDLES | STARTF_USESHOWWINDOW;
  si.hStdInput = GetStdHandle(STD_INPUT_HANDLE);
  si.hStdOutput = GetStdHandle(STD_OUTPUT_HANDLE);
  si.hStdError = GetStdHandle(STD_ERROR_HANDLE);
  si.wShowWindow = SW_HIDE;
  return CreateProcess(NULL, cmdline, NULL, NULL, FALSE, CREATE_NO_WINDOW,
      NULL, NULL, &si, &pi);
  /* if (vm_pid == 0) { */
  /*   char buffer[100]; */
  /*   sprintf(buffer, "error code: %d", GetLastError()); */
  /*   MessageBox(NULL, buffer, "Debug", MB_OK); */
  /* } */
}

void init_menu() {
  menu = CreatePopupMenu();
  AppendMenu(menu, MF_STRING, WM_TRAY_STARTVM, "Start VM");
  AppendMenu(menu, MF_STRING, WM_TRAY_ACPISHUTDOWN, "ACPI shutdown");
  AppendMenu(menu, MF_STRING, WM_TRAY_SAVESTATE, "Save VM state");
  AppendMenu(menu, MF_SEPARATOR, NULL, NULL);
  AppendMenu(menu, MF_STRING, WM_TRAY_EXIT, "Exit");
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
        case WM_TRAY_STARTVM:
          sprintf(format_buffer, STARTVM, vmname);
          run_command(format_buffer);
          break;
        case WM_TRAY_ACPISHUTDOWN:
          sprintf(format_buffer, ACPISHUTDOWN, vmname);
          run_command(format_buffer);
          break;
        case WM_TRAY_SAVESTATE:
          sprintf(format_buffer, SAVESTATE, vmname);
          run_command(format_buffer);
          break;
        case WM_TRAY_EXIT:
          result = MessageBox(NULL, "Are you sure?", "Exit VM instance",
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

int parse_options()
{
  int argCount;

  if (__argc == 1)
    return 0;

  vmname = *(__argv + 1);
  return 1;
}

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance,
    LPSTR lpCmdLine, int nCmdShow)
{
  WNDCLASSEX wcex;
  MSG msg;
  HWND hWnd;

  if (parse_options() == 0) {
    MessageBox(NULL, "Need to provide the VM name as first argument", "Invalid command line arguments", MB_OK);
    return 1;
  }

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

