#include <stdio.h>
#include <string.h>
#include <stdbool.h>

#define MAX 100

int action_tbl[12][6] = {
    {5, 0, 0, 4, 0, 0},
    {0, 6, 0, 0, 0, 999},
    {0, -2, 7, 0, -2, -2},
    {0, -4, -4, 0, -4, -4},
    {5, 0, 0, 4, 0, 0},
    {0, -6, -6, 0, -6, -6},
    {5, 0, 0, 4, 0, 0},
    {5, 0, 0, 4, 0, 0},
    {0, 6, 0, 0, 11, 0},
    {0, -1, 7, 0, -1, -1},
    {0, -3, -3, 0, -3, -3},
    {0, -5, -5, 0, -5, -5} };

int goto_tbl[12][4] = {
    {0, 1, 2, 3},
    {0, 0, 0, 0},
    {0, 0, 0, 0},
    {0, 0, 0, 0},
    {0, 8, 2, 3},
    {0, 0, 0, 0},
    {0, 0, 9, 3},
    {0, 0, 0, 10},
    {0, 0, 0, 0},
    {0, 0, 0, 0},
    {0, 0, 0, 0},
    {0, 0, 0, 0} };

char lhs[] = { ' ', 'E', 'E', 'T', 'T', 'F', 'F' }; // dummy in 0 index
int rhs_len[] = { 0, 3, 1, 3, 1, 3, 1 }; // rhs length: 0 for dummy rule
char token[] = { 'd', '+', '*', '(', ')', '$' };
char NT[] = { ' ', 'E', 'T', 'F' }; // non-terminals: dummy in 0 index
int stack[MAX], sp = 0;

// 함수 프로토타입
void LR_Parser(char* input);
int get_row(char c);
int IsEmpty();
int IsFull();
void push(int value);
int pop();

int main() {
    char input[MAX];

    while (1) {
        printf("\nInput: ");
        scanf_s("%s", input);

        if (input[0] == '$') {
            break;
        }

        LR_Parser(input);
    }

    return 0;
}

void LR_Parser(char* input) {
    char buffer[MAX];
    int ip = 0;    // Input pointer
    int order_num = 1; // 파싱 순서
    sp = 0;        // stack pointer 초기화
    stack[sp] = 0; // stack의 초기상태 push

    //push(0); 
    printf("(%d) initial : 0", order_num);
    order_num++;
    printf("  %s\n", input);

    while (1) {
        int state = pop(sp); // 현재 상태
        //push(state);
        int symbolIndex = -1;

        // token 오류 검사
        for (int i = 0; i < sizeof(token) / sizeof(token[0]); i++) {
            if (token[i] == input[ip]) {
                symbolIndex = i;
                break;
            }
        }

        if (symbolIndex == -1) {
            printf("(%d) invalid token (%c) error\n", order_num, input[ip]);
            order_num++;
            return;
        }

        // Shift and Reduce
        int action = action_tbl[state][symbolIndex];

        if (action > 0) {
            // Shift
            push(input[ip]);
            push(action);

            printf("(%d) shift %d:  ", order_num, action);
            order_num++;

            for (int i = 0; i <= sp; i++) {
                switch (stack[i])
                {
                case 100: // 'd'
                case 43: // '+'
                case 42: // '*'
                case 36: // '$'
                case 40: // '('
                case 41: // ')'
                case 69: // 'E'
                case 84: // 'T'
                case 70: // 'F'
                    printf("%c", stack[i]);
                    break;

                default:
                    printf("%d", stack[i]);
                    break;
                }
            }

            ip++;
            printf("  %s\n", input + ip);



        }
        else if (action < 0) {
            // Reduce
            int rule = -action;
            int r_col=0;

            // rhs의 길이의 2배만큼 pop
            int tmp = 2 * rhs_len[rule];
            for (int i = 0; i < tmp; i++) {
                r_col = pop();
            }
            push(r_col);

            int NT_Index = get_row(lhs[rule]);
            int goTo = goto_tbl[r_col][NT_Index];
            push(lhs[rule]);
            push(goTo);

            printf("(%d) reduce %d: ", order_num, rule);
            order_num++;

            for (int i = 0; i <= sp; i++) {
                switch (stack[i])
                {
                case 100: // 'd'
                case 43: // '+'
                case 42: // '*'
                case 36: // '$'
                case 40: // '('
                case 41: // ')'
                case 69: // 'E'
                case 84: // 'T'
                case 70: // 'F'
                    printf("%c", stack[i]);
                    break;

                default:
                    printf("%d", stack[i]);
                    break;
                }
            }

            printf("  %s\n", input + ip);

        }
        else if (action == 999) { // Accept
            printf("(%d) accept\n", order_num);
            order_num++;
            return;
        }
        else {
            // Error
            printf("(%d) error\n", input[ip]);
            return;
        }
    }
}

int get_row(char c) {
    for (int i = 1; i < sizeof(NT) / sizeof(NT[0]); i++) {
        if (NT[i] == c) {
            return (i - 1); // goto_tbl에서 0번 인덱스 제외
        }
    }

    return -1; // 못찾음
}

int IsEmpty() {
    if (sp < 0) {
        return true;
    }
    else {
        return false;
    }
}
int IsFull() {
    if (sp >= MAX - 1) {
        return true;
    }
    else {
        return false;
    }
}

void push(int value) {
    if (IsFull() == true) {
        printf("Stack is full.");
    }
    else {
        stack[++sp] = value;
    }
}

int pop() {
    if (IsEmpty() == true) {
        printf("Stack is empty.");
    }
    else {
        return stack[sp--];
    }
}
