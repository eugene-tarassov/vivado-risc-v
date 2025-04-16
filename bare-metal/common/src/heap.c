#include <stddef.h>

// These are declared weakly in newlib, but we'll override them entirely
extern void* _sbrk(ptrdiff_t increment);

void* malloc(size_t size) {
    void *ptr = _sbrk(size);
    return (ptr == (void*)-1) ? NULL : ptr;
}

void free(void *ptr) {
    // No-op: simple bump allocator can't free
}

extern char _end; // defined by linker
static char *heap_end;

void* _sbrk(ptrdiff_t incr) {
    if (!heap_end)
        heap_end = &_end;

    char *prev_heap_end = heap_end;
    heap_end += incr;
    return (void *)prev_heap_end;
}
