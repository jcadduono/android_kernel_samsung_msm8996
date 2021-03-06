/*
 * EFI entry point.
 *
 * Copyright (C) 2013, 2014 Red Hat, Inc.
 * Author: Mark Salter <msalter@redhat.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 *
 */
#include <linux/linkage.h>
#include <linux/init.h>

#include <asm/assembler.h>

#define EFI_LOAD_ERROR 0x8000000000000001

	__INIT

	/*
	 * We arrive here from the EFI boot manager with:
	 *
	 *    * CPU in little-endian mode
	 *    * MMU on with identity-mapped RAM
	 *    * Icache and Dcache on
	 *
	 * We will most likely be running from some place other than where
	 * we want to be. The kernel image wants to be placed at TEXT_OFFSET
	 * from start of RAM.
	 */
ENTRY(efi_stub_entry)
	/*
	 * Create a stack frame to save FP/LR with extra space
	 * for image_addr variable passed to efi_entry().
	 */
	stp	x29, x30, [sp, #-32]!

	/*
	 * Call efi_entry to do the real work.
	 * x0 and x1 are already set up by firmware. Current runtime
	 * address of image is calculated and passed via *image_addr.
	 *
	 * unsigned long efi_entry(void *handle,
	 *                         efi_system_table_t *sys_table,
	 *                         unsigned long *image_addr) ;
	 */
	adrp	x8, _text
	add	x8, x8, #:lo12:_text
	add	x2, sp, 16
	str	x8, [x2]
	bl	efi_entry
	cmn	x0, #1
	b.eq	efi_load_fail

	/*
	 * efi_entry() will have copied the kernel image if necessary and we
	 * return here with device tree address in x0 and the kernel entry
	 * point stored at *image_addr. Save those values in registers which
	 * are callee preserved.
	 */
	mov	x20, x0		// DTB address
	ldr	x0, [sp, #16]	// relocated _text address
	mov	x21, x0

	/*
	 * Calculate size of the kernel Image (same for original and copy).
	 */
	adrp	x1, _text
	add	x1, x1, #:lo12:_text
	adrp	x2, _edata
	add	x2, x2, #:lo12:_edata
	sub	x1, x2, x1

	/*
	 * Flush the copied Image to the PoC, and ensure it is not shadowed by
	 * stale icache entries from before relocation.
	 */
	bl	__flush_dcache_area
	ic	ialluis

	/*
	 * Ensure that the rest of this function (in the original Image) is
	 * visible when the caches are disabled. The I-cache can't have stale
	 * entries for the VA range of the current image, so no maintenance is
	 * necessary.
	 */
	adr	x0, efi_stub_entry
	adr	x1, efi_stub_entry_end
	sub	x1, x1, x0
	bl	__flush_dcache_area

	/* Turn off Dcache and MMU */
	mrs	x0, CurrentEL
	cmp	x0, #CurrentEL_EL2
	b.ne	1f
	mrs	x0, sctlr_el2
	bic	x0, x0, #1 << 0	// clear SCTLR.M
	bic	x0, x0, #1 << 2	// clear SCTLR.C
	msr	sctlr_el2, x0
	isb
	b	2f
1:
	mrs	x0, sctlr_el1
	bic	x0, x0, #1 << 0	// clear SCTLR.M
	bic	x0, x0, #1 << 2	// clear SCTLR.C
#ifndef CONFIG_TIMA_RKP
	msr	sctlr_el1, x0
#else
	mov     x1, x0
	mov     x0, #0xc015                     /* smc id */
	movk    x0, #0xc300, lsl #16
back_efi_stub:
	smc     #0x0
	cmp     x0, #0x1
	b.eq    back_efi_stub
#endif
	isb
2:
	/* Jump to kernel entry point */
	mov	x0, x20
	mov	x1, xzr
	mov	x2, xzr
	mov	x3, xzr
	br	x21

efi_load_fail:
	mov	x0, #EFI_LOAD_ERROR
	ldp	x29, x30, [sp], #32
	ret

efi_stub_entry_end:
ENDPROC(efi_stub_entry)
