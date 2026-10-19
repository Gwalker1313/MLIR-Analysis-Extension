module attributes {dlti.dl_spec = #dlti.dl_spec<!llvm.ptr<270> = dense<32> : vector<4xi64>, !llvm.ptr<271> = dense<32> : vector<4xi64>, !llvm.ptr<272> = dense<64> : vector<4xi64>, i64 = dense<64> : vector<2xi64>, i128 = dense<128> : vector<2xi64>, !llvm.ptr = dense<64> : vector<4xi64>, i1 = dense<8> : vector<2xi64>, i8 = dense<8> : vector<2xi64>, i16 = dense<16> : vector<2xi64>, i32 = dense<32> : vector<2xi64>, f16 = dense<16> : vector<2xi64>, f64 = dense<64> : vector<2xi64>, f128 = dense<128> : vector<2xi64>, "dlti.endianness" = "little", "dlti.mangling_mode" = "o", "dlti.legal_int_widths" = array<i32: 32, 64>, "dlti.stack_alignment" = 128 : i64, "dlti.function_pointer_alignment" = #dlti.function_pointer_alignment<32, function_dependent = true>>, llvm.module_asm = [], llvm.target_triple = "arm64-apple-macosx15.0.0"} {
  llvm.mlir.global private constant @__sign_failure_message_2("Sign assertion failed in @f\0A  %%16 = llvm.add %%0, %%8 : i32\0A  location: loc(\22soundness/reduced.mlir\22:5:10)\0A  expected: positive\0A  actual: %lld\0A\00") {addr_space = 0 : i32}
  llvm.mlir.global private constant @__sign_failure_message_1("Sign assertion failed in @f\0A  %%8 = llvm.mlir.constant(2147483647 : i32) : i32\0A  location: loc(\22soundness/reduced.mlir\22:4:10)\0A  expected: positive\0A  actual: %lld\0A\00") {addr_space = 0 : i32}
  llvm.mlir.global private constant @__sign_failure_message_0("Sign assertion failed in @f\0A  %%0 = llvm.mlir.constant(1 : i32) : i32\0A  location: loc(\22soundness/reduced.mlir\22:3:10)\0A  expected: positive\0A  actual: %lld\0A\00") {addr_space = 0 : i32}
  llvm.func @dprintf(i32, !llvm.ptr, ...) -> i32
  llvm.func @f() -> i32 {
    %0 = llvm.mlir.constant(1 : i32) : i32
    %1 = llvm.mlir.constant(0 : i32) : i32
    %2 = llvm.icmp "sgt" %0, %1 : i32
    llvm.cond_br %2, ^bb2, ^bb1
  ^bb1:  // pred: ^bb0
    %3 = llvm.sext %0 : i32 to i64
    %4 = llvm.mlir.addressof @__sign_failure_message_0 : !llvm.ptr
    %5 = llvm.getelementptr %4[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<154 x i8>
    %6 = llvm.mlir.constant(2 : i32) : i32
    %7 = llvm.call @dprintf(%6, %5, %3) vararg(!llvm.func<i32 (i32, ptr, ...)>) : (i32, !llvm.ptr, i64) -> i32
    llvm.intr.trap
    llvm.unreachable
  ^bb2:  // pred: ^bb0
    %8 = llvm.mlir.constant(2147483647 : i32) : i32
    %9 = llvm.mlir.constant(0 : i32) : i32
    %10 = llvm.icmp "sgt" %8, %9 : i32
    llvm.cond_br %10, ^bb4, ^bb3
  ^bb3:  // pred: ^bb2
    %11 = llvm.sext %8 : i32 to i64
    %12 = llvm.mlir.addressof @__sign_failure_message_1 : !llvm.ptr
    %13 = llvm.getelementptr %12[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<163 x i8>
    %14 = llvm.mlir.constant(2 : i32) : i32
    %15 = llvm.call @dprintf(%14, %13, %11) vararg(!llvm.func<i32 (i32, ptr, ...)>) : (i32, !llvm.ptr, i64) -> i32
    llvm.intr.trap
    llvm.unreachable
  ^bb4:  // pred: ^bb2
    %16 = llvm.add %0, %8 : i32
    %17 = llvm.mlir.constant(0 : i32) : i32
    %18 = llvm.icmp "sgt" %16, %17 : i32
    llvm.cond_br %18, ^bb6, ^bb5
  ^bb5:  // pred: ^bb4
    %19 = llvm.sext %16 : i32 to i64
    %20 = llvm.mlir.addressof @__sign_failure_message_2 : !llvm.ptr
    %21 = llvm.getelementptr %20[0, 0] : (!llvm.ptr) -> !llvm.ptr, !llvm.array<145 x i8>
    %22 = llvm.mlir.constant(2 : i32) : i32
    %23 = llvm.call @dprintf(%22, %21, %19) vararg(!llvm.func<i32 (i32, ptr, ...)>) : (i32, !llvm.ptr, i64) -> i32
    llvm.intr.trap
    llvm.unreachable
  ^bb6:  // pred: ^bb4
    llvm.return %16 : i32
  }
  llvm.func @main() -> i32 {
    %0 = llvm.call @f() : () -> i32
    llvm.return %0 : i32
  }
}

