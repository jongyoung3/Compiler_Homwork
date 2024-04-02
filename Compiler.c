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
    char a=input;

    s=action_tbl[stack[sp]]; // 상태값 갱신
    int tmp;
    
    // 입력받은 게 토큰인지 검사
    for(int i=0; i<6; i++){
        if(a==token[i]){
            break;
        }
        else if((a!=token[i]) && (i<6)){
            continue;
        }
        else{
            printf("invaild token (%c) error", a);
            return 0; //이렇게 해도 되나?
        }
    }

    //문법 오류 검사
    if(stack[sp-1]==a){
        printf("error");
    }else if((stack[sp-1]!=token[0]) && (a==token[1])){
        printf("error");
    }else if((stack[sp-1]!=token[0]) && (a==token[2])){
        printf("error");
    }else if((stack[sp-1]!=token[0]) && (a==token[4])){
        printf("error");
    }else if((stack[sp-1]!=token[0]) && (a==token[3])){
        printf("error");
    }

    

    if(s>0){
        push(a);

    }else{

    }

    // switch (a)
    // {
    // case 'd':
    //     push(token[0]); // token push
    //     if(s>0){ // shift
    //         push(s); // 해당 토큰 앞의 상태 값에 알맞는 상태값 push
    //     }
    //     else{ //reduce
    //         tmp=action_tbl[-s];
    //         pop(rhs_len[tmp]); // stack에서 rhs의 길이의 2배만큼 pop
    //         switch (-s)
    //         {
    //         case 1:
    //             push()
    //             break;
    //         case 2:
                
    //             break;
    //         case 3:
            
    //             break;
    //         case 4:
            
    //             break;
    //         case 5:
            
    //             break;
    //         case 6:
            
    //             break;
            
    //         default:
    //             break;
    //         }

    //     }


    //     break;
    // case '+':
        
    //     break;
    // case '*':
        
    //     break;
    // case '(':
        
    //     break;
    // case ')':
        
    //     break;
    // case '$':
        
    //     break;
    
    // default:
    //     break;
    // }


}

// 상태 확인

main()
{
    char input[MAX];
    s=0;
    push(0); // 스택의 맨위에 0 push

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

