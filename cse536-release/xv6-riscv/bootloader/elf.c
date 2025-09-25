#include "types.h"
#include "param.h"
#include "layout.h"
#include "riscv.h"
#include "defs.h"
#include "buf.h"
#include "elf.h"

#include <stdbool.h>
#include <stdint.h>

struct elfhdr* kernel_elfhdr;
struct proghdr* kernel_phdr;

bool is_elf(uint64 address){
        struct elfhdr* elook = (struct elfhdr*) address;
        return elook->magic == ELF_MAGIC;
}

void find_exec_segment(uint64 start){
    for(uint64 i = 0; i< kernel_elfhdr->phnum; i++){
        kernel_phdr = (struct proghdr*) (start + kernel_elfhdr->phoff + kernel_elfhdr->phentsize*i);
        if(kernel_phdr->type ==1)
            break;
    }
}

uint64 find_kernel_read_addr(enum kernel ktype){
    uint64 check2 = 0xA0000000;
    uint64 check1 = RAMDISK;
    uint64 addr_offset = 0;
    if(ktype == RECOVERY)
        addr_offset=RECOVERYDISK - RAMDISK;
    uint64 start = check1 + addr_offset;
    if(is_elf(start)){
        kernel_elfhdr = (struct elfhdr*) (check1 + addr_offset);
        find_exec_segment(check1 + addr_offset);
        return check1 + addr_offset;
    }
    kernel_elfhdr = (struct elfhdr*) (check2 + addr_offset);
    find_exec_segment(check2 + addr_offset);
    return check2 + addr_offset;
}
uint64 find_kernel_scopy_off(){
    return kernel_phdr->off;
}
uint64 find_kernel_load_addr(enum kernel ktype) {
    struct proghdr* sec_addr=kernel_phdr;
    return sec_addr->vaddr;
}


uint64 find_kernel_size(enum kernel ktype) {
    return kernel_elfhdr->shoff - kernel_phdr->off;
}
uint64 find_kernel_full_size(enum kernel ktype) {
    return kernel_elfhdr->shoff + kernel_elfhdr->shnum*kernel_elfhdr->shentsize;
}
uint64 find_kernel_entry_addr(enum kernel ktype) {
    /* CSE 536: Get kernel entry point from headers */
    struct elfhdr* rd=kernel_elfhdr;
    return rd->entry;
}