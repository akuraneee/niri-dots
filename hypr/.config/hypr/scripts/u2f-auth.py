#!/usr/bin/env python3
# Check the current user's YubiKey through PAM (service "hyprlock-u2f", see README).
# Blocks until the key is touched or removed; exits 0 only on success.
import ctypes
import ctypes.util
import os
import pwd

libpam = ctypes.CDLL(ctypes.util.find_library("pam"))


class PamMessage(ctypes.Structure):
    _fields_ = [("msg_style", ctypes.c_int), ("msg", ctypes.c_char_p)]


class PamResponse(ctypes.Structure):
    _fields_ = [("resp", ctypes.c_char_p), ("resp_retcode", ctypes.c_int)]


ConvFunc = ctypes.CFUNCTYPE(
    ctypes.c_int,
    ctypes.c_int,
    ctypes.POINTER(ctypes.POINTER(PamMessage)),
    ctypes.POINTER(ctypes.POINTER(PamResponse)),
    ctypes.c_void_p,
)


class PamConv(ctypes.Structure):
    _fields_ = [("conv", ConvFunc), ("appdata_ptr", ctypes.c_void_p)]


PAM_CONV_ERR = 19


# The U2F module needs no answers; refuse any prompt so nothing falls back to a password
@ConvFunc
def conv(n, msgs, resp, data):
    return PAM_CONV_ERR


user = pwd.getpwuid(os.getuid()).pw_name.encode()
handle = ctypes.c_void_p()
conversation = PamConv(conv, None)
if libpam.pam_start(b"hyprlock-u2f", user, ctypes.byref(conversation), ctypes.byref(handle)):
    raise SystemExit(1)
ret = libpam.pam_authenticate(handle, 0)
libpam.pam_end(handle, ret)
raise SystemExit(0 if ret == 0 else 1)
