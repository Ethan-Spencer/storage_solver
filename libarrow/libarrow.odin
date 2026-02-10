package libarrow

ArrowArray :: struct {
    length: i64,
    null_count: i64,
    offset: i64,
    n_buffers: i64,
    n_children: i64,
    buffers: [^]rawptr,
    children: [^]^ArrowArray,
    dictionary: ^ArrowArray,
    release: proc "c" (array: ^ArrowArray),
    private_data: rawptr
}

