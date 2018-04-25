#include <stdio.h>
#include <string.h>

char key[]={
    0x12,
    0x34,
    0x56,
    0x78,
    0x9a,
    0xBC,
    0xDE,
    0xf0
};

char random_table[]={
    0x11,
    0x90,
    0x52,
    0xc8,
    0xb7,
    0xce,
    0xd4,
    0x31,
    0xd3,
    0xcb,
    0xf1,
    0xb5,
    0x73,
    0xab,
    0xbf,
    0x62,
};

#define KEY_SIZE sizeof(key)
#define RANDOM_SIZE sizeof(random_table)
#define RANDOM_TABLE_MASK 0x0F



char encrypt(char in){

    char tmp = in;
   
    for(int i = 0 ; i < KEY_SIZE ; i++){
        tmp = tmp ^ key[i];
        //printf("XOR output: %x\n", tmp & 0xff);
        tmp = random_table[ tmp & RANDOM_TABLE_MASK ];
        //printf("RN output: %x\n", tmp & 0xff);
    }

   return tmp;

}

char doshift(char next, unsigned long long * key){
    
    unsigned long long x = (*key >= 0x8000000000000000);
    //printf("key val is %x\n", *key);
    //printf("X val is %x\n", x);
    *key = (*key << 1)+x; 
    //printf("key val is now %x\n", *key);
    return next << x;
}



void tagtest(){
    char mystr[] = "CompArch";
    unsigned long long val = 0xAAAAAAAAAAAAAAAA;
    unsigned char mytag = 0;

    for(int i = 0 ; i < sizeof(mystr) ; i ++){
        mytag = mytag ^ doshift(mystr[i], &val);
    	printf("%x\n", mytag);
    }

}

int main(){
    char in;
    char tag=0;
    char next;
    unsigned long long key_copy;
    memcpy(&key_copy, key, 8);
    while((in=getchar())!=EOF){
        next = encrypt(in);
        tag = tag ^ doshift(next, &key_copy);
	printf("%c\n", next);
    }
    printf("\n");
    printf("%x\n", tag);
    printf("\n");

    return 0;

}
