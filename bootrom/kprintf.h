#ifndef _SDBOOT_KPRINTF_H
#define _SDBOOT_KPRINTF_H

extern void kputc(char ch);
extern void kputs(const char *);
extern void kprintf(const char *, ...);

#endif /* _SDBOOT_KPRINTF_H */
