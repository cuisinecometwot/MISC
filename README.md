# Chương trình kiểm tra cú pháp lệnh MIPS (MIPS Instruction Syntax Checker)

Trình biên dịch của bộ xử lý MIPS sẽ tiến hành kiểm tra cú pháp các lệnh hợp ngữ trong mã nguồn, xem
có phù hợp về cú pháp hay không, rồi mới tiến hành dịch các lệnh ra mã máy. Hãy viết một chương trình
kiểm tra cú pháp của 1 lệnh hợp ngữ MIPS bất kì (không làm với giả lệnh) như sau:
- Nhập vào từ bàn phím một dòng lệnh hợp ngữ. Ví dụ beq $s1,31,$t4
- Kiểm tra xem mã opcode có đúng hay không? Trong ví dụ trên, opcode là beq là hợp lệ thì hiện
thị thông báo “opcode: beq, hợp lệ”
- Kiểm tra xem tên các toán hạng phía sau có hợp lệ hay không? Trong ví dụ trên, toán hạng $s1 là
hợp lệ, 31 là không hợp lệ, $t4 thì khỏi phải kiểm tra nữa vì toán hạng trước đã sai rồi.

Gợi ý: nên xây dựng một cấu trúc chứa khuôn dạng của từng lệnh với tên lệnh, kiểu của toán hạng 1, toán
hạng 2, toán hạng 3.

This is one of the ten final projects in the "Assembly Language and Computer Architecture Lab" course.
