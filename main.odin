package main

import "core:fmt"

matrix_csc :: struct {
    values: [dynamic]f32,
    row_indices: [dynamic]i32,
    col_pointers: [dynamic]i32
}

init_constraints :: proc(intervals: i32, efficiency: f32) -> ^matrix_csc {
    constraints := new(matrix_csc)

    columns: i32 = 0
    row_start: i32
    nnz: i32 = 0 // non-negative values
    for i in 0..<intervals {
        row_start = i*3

        // Period column 0 (discharge)
        columns += 1
        append(&constraints.col_pointers, nnz)

        append(&constraints.values, -1, -1, 1)
        append(&constraints.row_indices, row_start, row_start+1, row_start+2)
        nnz += 3

        for j in 0..<intervals - 1 - i {
            append(&constraints.values, -1, -1)
            append(
                &constraints.row_indices,
                row_start + (j+1)*3,
                row_start + (j+1)*3 + 1
            )
            nnz += 2
        }
        append(&constraints.values, 1)
        append(&constraints.row_indices, 3*intervals)
        nnz += 1
        
        // Period column 1 (charge)
        columns += 1
        append(&constraints.col_pointers, nnz)

        append(
            &constraints.values,
            efficiency,
            efficiency,
            1
        )
        append(&constraints.row_indices, row_start, row_start+1, row_start+2)
        nnz += 3

        for j in 0..<intervals - 1 - i {
            append(&constraints.values, efficiency, efficiency)
            append(
                &constraints.row_indices,
                row_start + (j+1)*3,
                row_start + (j+1)*3 + 1
            )
            nnz += 2
        }


        // Period columns 2, 3, 4 (slack variable columns)
        columns += 3
        append(&constraints.col_pointers, nnz, nnz+1, nnz+2)
        append(&constraints.values, 1, -1, 1)
        append(
            &constraints.row_indices,
            row_start, row_start+1, row_start+2
        )
        nnz += 3
    }
    
    // Final column (cycle constraint slack)
    columns += 1
    append(&constraints.col_pointers, nnz)
    append(&constraints.values, 1)
    append(&constraints.row_indices, intervals*3)
    
    append(&constraints.col_pointers, columns)

    return constraints
}

main :: proc() {
    price := [24]f32{
        95, 90, 88,
        80, 85, 120,
        134, 20, 5,
        -5, -5, -10,
        -5, 0, 0,
        30, 60, 90,
        150, 300, 275,
        125, 105, 100
    }

    p_hat: [24*5]f32
    for i in 0..<24 {
        p_hat[i*5] = price[i]
        p_hat[i*5 + 1] = -price[i]

        for j in 0..<3 {
            p_hat[i*5 + 2 + j] = 0
        }
    }

    duration_h: f32 = 2
    cycle_limit: f32 = 1
    efficiency: f32 = 0.8

    b: [24*3 + 1]f32
    for i in 0..<24 {
        b[i*3] = duration_h
        b[i*3+1] = 0
        b[i*3+2] = 1
    } 
    b[24*3] = cycle_limit
    
    test_csc_mat := init_constraints(2, 0.5)

    fmt.println("Values: ", test_csc_mat.values)
    fmt.println("Row indices: ", test_csc_mat.row_indices)
    fmt.println("Col pointers: ", test_csc_mat.col_pointers)
}
