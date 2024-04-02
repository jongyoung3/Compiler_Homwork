#include <stdio.h>
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
    {0, -5, -5, 0, -5, -5}
    };

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
    {0, 0, 0, 0}
    };

char lhs[] = {' ', 'E', 'E', 'T', 'T', 'F', 'F'}; // dummy in 0 index
int rhs_len[] = {0, 3, 1, 3, 1, 3, 1};            // rhs length: 0 for dummy rule
char token[] = {'d', '+', '*', '(', ')', '$'};
char NT[] = {' ', 'E', 'T', 'F'}; // non-terminals: dummy in 0 index

int s; // 상태

// 스택 구현
int stack[MAX], sp;

// 함수
int IsEmpty();
int IsFull();
void push(int value);
int pop();
int NTindex(char lhs);
void LR_Parser(char* input);




main()
{
    char input[MAX];
    // s=0;
    // push(0); // 스택의 맨위에 0 push

    while (1)
    {
        printf("\nInput: ");
        scanf("%s", input);

        if (input[0] == '$'){
            break;
        }
            
        LR_Parser(input);
    }

    /*
    결과 화면 출력
    (파싱 단계) (파서 동작) (스택 내용) (입력열 내용)
    */

}

// 스택 구현
int stack[MAX], sp;
 
int IsEmpty(){
    if(sp<0)
        return true;
    else
        return false;
    }
int IsFull(){
    if(sp>=MAX-1)
        return true;
    else
        return false;
}
 
void push(int value){
    if(IsFull()==true)
        printf("Stack is full.");
    else
        stack[++sp]=value; 
}
 
int pop(){
    if(IsEmpty()==true)
        printf("Stack is empty.");
    else 
        return stack[sp--];
}

int NTindex(char lhs){
    int i;

    for(i=0; i<4; i++){
        if(lhs == NT[i]){
            return i;
        }
    } 
    
}

// LR_파서 구현
/*
1. token 오류 검사
1-1. 문법 오류 검사
2. action_tbl[]의 값이 음수 인지 검사
2-1. 음수라면 rhs_len만큼 pop, 양수이면 push
3. push한 token과 그 앞의 상태값을 심볼테이블을 참조하여 다음 상태값 push
4.
*/
void LR_Parser(char* input){
    int ip = 0; // Input Pointer를 input의 처음 위치 기호로 설정
    sp = 0; // Reset Stack Pointer
    stack[sp++] = 0; // s0 push
    char tmp_lhs;
    int temp;

    while (1) {
        int currentState = stack[sp - 1]; // 현재 상태
        int symbol;
        
        for (int i = 0; i < 6; i++)
        {
            if(input[ip] == token[i]){
                symbol=i;
            }else if((input[ip] != token[i]) && (i == 5)){
                printf("invaild token (%c) error\n", input[ip]);
                return;
            }
        }
        
        int action = action_tbl[currentState][symbol];
        int getNTindex;


        if (action > 0) { // Shift
            push(input[ip]);
            push(action);
            ip++;
        }
        else if (action < 0) { // Reduce
            tmp_lhs=lhs[-action];
            temp = NTindex(tmp_lhs);

            pop(rhs_len[-action]);
            push(tmp_lhs);
            push(goto_tbl[currentState][temp]);
        }
        else if (action == 999) {
                printf("accept\n");
                return;
        }
        else {
            printf("error\n");
            return;
        }
    }


}





