package;

/*
	VS DAVE WINDOWS/LINUX/MACOS UTIL
	You can use this code while you give credit to it.
	65% of the code written by chromasen
	35% of the code written by Erizur (cross-platform and extra windows utils)

	Windows: You need the Windows SDK (any version) to compile.
	Linux: TODO
	macOS: TODO
 */
#if windows
@:cppFileCode('#include <stdlib.h>
#include <stdio.h>
#include <windows.h>
#include <winuser.h>
#include <dwmapi.h>
#include <strsafe.h>
#include <shellapi.h>
#include <direct.h>
#include <fileapi.h>
#include <winbase.h>
#include <iostream>
#include <string>

#pragma comment(lib, "Dwmapi")
#pragma comment(lib, "Shell32.lib")')
#elseif linux
@:cppFileCode('
#include <stdlib.h>
#include <stdio.h>
#include <iostream>
#include <string>
')
#end
class PlatformUtil
{
	#if windows
	@:functionCode('
        HWND hWnd = GetActiveWindow();
        res = SetWindowLong(hWnd, GWL_EXSTYLE, GetWindowLong(hWnd, GWL_EXSTYLE) | WS_EX_LAYERED);
        if (res)
        {
            SetLayeredWindowAttributes(hWnd, RGB(red, green, blue), 0, LWA_COLORKEY);
        }
    ')
	#end
	static public function getWindowsTransparent(red, green, blue, res:Int = 0) // Only works on windows, otherwise returns 0!
	{
		return res;
	}

	#if windows
	@:functionCode('
        NOTIFYICONDATA m_NID;

        memset(&m_NID, 0, sizeof(m_NID));
        m_NID.cbSize = sizeof(m_NID);
        m_NID.hWnd = GetForegroundWindow();
        m_NID.uFlags = NIF_MESSAGE | NIIF_WARNING | NIS_HIDDEN;

        m_NID.uVersion = NOTIFYICON_VERSION_4;

        if (!Shell_NotifyIcon(NIM_ADD, &m_NID))
            return FALSE;
    
        Shell_NotifyIcon(NIM_SETVERSION, &m_NID);

        m_NID.uFlags |= NIF_INFO;
        m_NID.uTimeout = 1000;
        m_NID.dwInfoFlags = NULL;

        LPCTSTR lTitle = title.c_str();
        LPCTSTR lDesc = desc.c_str();

        if (StringCchCopy(m_NID.szInfoTitle, sizeof(m_NID.szInfoTitle), lTitle) != S_OK)
            return FALSE;

        if (StringCchCopy(m_NID.szInfo, sizeof(m_NID.szInfo), lDesc) != S_OK)
            return FALSE;

        return Shell_NotifyIcon(NIM_MODIFY, &m_NID);
    ')
	#elseif linux
	@:functionCode('
        std::string cmd = "notify-send -u normal \'";
        cmd += title.c_str();
        cmd += "\' \'";
        cmd += desc.c_str();
        cmd += "\'";
        system(cmd.c_str());
    ')
	#end
	static public function sendWindowsNotification(title:String = "", desc:String = "", res:Int = 0) // TODO: Linux (found out how to do it so ill do it soon)
	{
		return res;
	}

	#if windows
	@:functionCode('
        LPCSTR lwDesc = desc.c_str();

        res = MessageBox(
            NULL,
            lwDesc,
            NULL,
            MB_OK
        );
    ')
	#end
	static public function sendFakeMsgBox(desc:String = "", res:Int = 0) // TODO: Linux and macOS (will do soon)
	{
		return res;
	}

	#if windows
	@:functionCode('
        HWND hWnd = GetActiveWindow();
        res = SetWindowLong(hWnd, GWL_EXSTYLE, GetWindowLong(hWnd, GWL_EXSTYLE) ^ WS_EX_LAYERED);
        if (res)
        {
            SetLayeredWindowAttributes(hWnd, RGB(red, green, blue), 1, LWA_COLORKEY);
        }
    ')
	#end
	static public function getWindowsbackward(red, green, blue, res:Int = 0) // Only works on windows, otherwise returns 0!
	{
		return res;
	}

	#if windows
	@:functionCode('
        WIN32_FIND_DATA FindFileData;
        HANDLE hFind;

        std::string bg(getenv("APPDATA"));
        bg.append("\\\\Microsoft\\\\Windows\\\\Themes\\\\CachedFiles\\\\*.jpg");

        hFind = (FindFirstFile(bg.c_str(), &FindFileData));
        
        std::string file(FindFileData.cFileName);

        std::string fullPath(getenv("APPDATA"));
        fullPath.append("\\\\Microsoft\\\\Windows\\\\Themes\\\\CachedFiles\\\\");
        fullPath.append(file);

        path = fullPath.c_str();

        std::string game(_getcwd(NULL, 0));
        game.append("\\\\assets\\\\images\\\\backgrounds\\\\yourBG.jpg");
        
        CopyFile(fullPath.c_str(), game.c_str(), FALSE);
    ')
	#end
	static public function getCurrentWalllpaper(?path = "")
	{
		return path;
	}

	#if windows
	@:functionCode('
        std::string p(_getcwd(NULL,0));
        p.append(path);

        output = p.c_str();

        SystemParametersInfo(SPI_SETDESKWALLPAPER, 0, (PVOID)p.c_str(), SPIF_UPDATEINIFILE);
    ')
	#end
	static public function updateWallpaper(path = "", ?output = "")
	{
		return output;
	}
}
