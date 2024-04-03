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
    {0, -5, -5, 0, -5, -5}};
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
    {0, 0, 0, 0}};

char lhs[] = {' ', 'E', 'E', 'T', 'T', 'F', 'F'}; // dummy in 0 index
int rhs_len[] = {0, 3, 1, 3, 1, 3, 1};            // rhs length: 0 for dummy rule
char token[] = {'d', '+', '*', '(', ')', '$'};
char NT[] = {' ', 'E', 'T', 'F'}; // non-terminals: dummy in 0 index
int stack[MAX], sp;

// 함수 프로토타입 선언
void LR_Parser(char *input);
int get_row(char c);

// 스택 관련 함수 프로토타입 선언
int IsEmpty();
int IsFull();
void push(int value);
int pop();

int main()
{
    char input[MAX];

    while (1)
    {
        printf("\nInput: ");
        scanf("%s", input);

        if (input[0] == '$')  // 입력이 '$'인 경우 종료
        {
            break;
        }

        LR_Parser(input); // 입력에 대해 LR 파싱 실행
    }

    return 0;
}

// LR 파서 구현
void LR_Parser(char *input)
{
    // 스택을 초기화하고, 입력을 순차적으로 읽으면서 action_tbl과 goto_tbl을 참조하여 파싱을 진행
    // 이 과정에서 shift, reduce, accept, error 동작을 수행

    int ip = 0;        // Input pointer
    int order_num = 1; // 파싱 단계
    sp = -1;           // stack pointer(=top) 초기화
    push(0);           // stack의 초기상태 push

    // 초기 상태 출력
    printf("(%d) initial : %d", order_num, stack[sp]);
    order_num++;
    printf("  %s\n", input);

    while (1)
    {
        int state = stack[sp]; // 현재 상태
        int symbolIndex = -1; 

        // token 오류 검사
        for (int i = 0; i < 6; i++)
        {
            if (token[i] == input[ip])
            {
                symbolIndex = i;
                break;
            }
        }

        if (symbolIndex == -1)
        {
            printf("(%d) invalid token (%c) error\n", order_num, input[ip]);
            order_num++;
            return;
        }

        // Shift, Reduce, Accept, Error
        int action = action_tbl[state][symbolIndex];

        if ((action > 0) && action < 999)
        {
            // Shift
            push(input[ip]);
            push(action);

            printf("(%d) shift %d:  ", order_num, action); // (파싱 단계) (파서 동작) 출력
            order_num++;

            for (int i = 0; i <= sp; i++)
            {
                switch (stack[i])
                {
                case 100: // 'd'
                case 43:  // '+'
                case 42:  // '*'
                case 36:  // '$'
                case 40:  // '('
                case 41:  // ')'
                case 69:  // 'E'
                case 84:  // 'T'
                case 70:  // 'F'
                    printf("%c", stack[i]); // (스택 내용) 출력(char 형의 경우)
                    break;

                default:
                    printf("%d", stack[i]); // (스택 내용) 출력(int형의 경우)
                    break;
                }
            }

            ip++; //입력된 문자열 배열의 다음 칸
            printf("  %s\n", input + ip); // (입력열 내용) 출력
        }
        else if (action < 0)
        {
            // Reduce
            int rule = -action;
            int r_col;

            // rhs의 길이의 2배만큼 pop
            int tmp = rhs_len[rule];
            tmp = tmp * 2;
            for (int i = 0; i < tmp; i++)
            {
                r_col = pop();
            }
            // push(r_col);

            int NT_Index = get_row(lhs[rule]);
            int goTo = goto_tbl[stack[sp]][NT_Index];
            push(lhs[rule]);
            push(goTo);

            printf("(%d) reduce %d: ", order_num, rule); // (파싱 단계) (파서 동작) 출력
            order_num++;

            for (int i = 0; i <= sp; i++)
            {
                switch (stack[i])
                {
                case 100: // 'd'
                case 43:  // '+'
                case 42:  // '*'
                case 36:  // '$'
                case 40:  // '('
                case 41:  // ')'
                case 69:  // 'E'
                case 84:  // 'T'
                case 70:  // 'F'
                    printf("%c", stack[i]); // (스택 내용) 출력(char 형의 경우)
                    break;

                default:
                    printf("%d", stack[i]); // (스택 내용) 출력(int형의 경우)
                    break;
                }
            }

            printf("  %s\n", input + ip); // (입력열 내용) 출력
        }
        else if (action == 999)
        { 
            // accept
            printf("(%d) accept\n", order_num);
            order_num++;
            return;
        }
        else
        {
            // error
            printf("(%d) error\n", order_num);
            return;
        }
    }
}

// 주어진 문자(=c)에 해당하는 행 번호를 반환하는 함수
// 비터미널에 해당하는 인덱스를 찾음
int get_row(char c)
{
    // 문자 c에 대한 행 번호를 반환, 찾지 못한 경우 -1을 반환
    for (int i = 1; i < 4; i++) // goto_tbl에서 0번 인덱스 제외
    {
        if (NT[i] == c)
        {
            return i; 
        }
    }

    return -1;
}

// 스택이 비어있는지 확인하는 함수
int IsEmpty()
{
    if (sp < 0)
    {
        return true;
    }
    else
    {
        return false;
    }
}

// 스택이 가득 찼는지 확인하는 함수
int IsFull()
{
    if (sp >= MAX - 1)
    {
        return true;
    }
    else
    {
        return false;
    }
}

// 스택에 값을 추가하는 함수
void push(int value)
{
    if (IsFull() == true)
    {
        printf("Stack is full.");
    }
    else
    {
        stack[++sp] = value;
    }
}

// 스택에서 값을 제거하고 반환하는 함수
int pop()
{
    if (IsEmpty() == true)
    {
        printf("Stack is empty.");
    }
    else
    {
        return stack[sp--];
    }
}
