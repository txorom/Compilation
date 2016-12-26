define i32 @pile(i32 %x) {
%x.addr = alloca i32
store i32 %x , i32* %x.addr
%sum = alloca i32
%i = alloca i32
%x3 = add i32 0, 0 
store i32 %x3, i32* %sum 
%x5 = add i32 0, 0 
store i32 %x5, i32* %i 

br label %label1

label1:
br i1 %x0, label %label2, label %label4

label2:
%x11 = add i32 0, 1 
%x12 = load i32, i32* %sum
%x13 = add i32 %x12, %x11
store i32 %x13, i32* %sum
br label %label3

label3:
%x8 = load i32, i32* %i
%x9 = add i32 %x8, 1
store i32 %x9, i32* %i
br label %label1

label4:
%x14 = load i32, i32* %sum
ret i32 %x14
}
