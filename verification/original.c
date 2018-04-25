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
0x00,
0x01,
0x02,
0x03,
0x04,
0x05,
0x06,
0x07,
0x08,
0x09,
0x0A,
0x0B,
0x0C,
0x0D,
0x0E,
0x0F,
0x10,
0x11,
0x12,
0x13,
0x14,
0x15,
0x16,
0x17,
0x18,
0x19,
0x1A,
0x1B,
0x1C,
0x1D,
0x1E,
0x1F,
0x20,
0x21,
0x22,
0x23,
0x24,
0x25,
0x26,
0x27,
0x28,
0x29,
0x2A,
0x2B,
0x2C,
0x2D,
0x2E,
0x2F,
0x30,
0x31,
0x32,
0x33,
0x34,
0x35,
0x36,
0x37,
0x38,
0x39,
0x3A,
0x3B,
0x3C,
0x3D,
0x3E,
0x3F,
0x40,
0x41,
0x42,
0x43,
0x44,
0x45,
0x46,
0x47,
0x48,
0x49,
0x4A,
0x4B,
0x4C,
0x4D,
0x4E,
0x4F,
0x50,
0x51,
0x52,
0x53,
0x54,
0x55,
0x56,
0x57,
0x58,
0x59,
0x5A,
0x5B,
0x5C,
0x5D,
0x5E,
0x5F,
0x60,
0x61,
0x62,
0x63,
0x64,
0x65,
0x66,
0x67,
0x68,
0x69,
0x6A,
0x6B,
0x6C,
0x6D,
0x6E,
0x6F,
0x70,
0x71,
0x72,
0x73,
0x74,
0x75,
0x76,
0x77,
0x78,
0x79,
0x7A,
0x7B,
0x7C,
0x7D,
0x7E,
0x7F,
};

#define KEY_SIZE sizeof(key)
#define RANDOM_SIZE sizeof(random_table)
#define RANDOM_TABLE_MASK 0x7F



char encrypt(char in, char * key, int key_size, char * random, char random_mask, int verbose){

    char left = in;
    char xored = 0;
    char rnout = 0;
   
    for(int i = 0 ; i < key_size ; i++){
        xored = left ^ key[i];
        rnout = random[ xored & random_mask ];
        if(verbose)
            printf("left: 0x%x key[%d]: 0x%x xored 0x%x rnout: 0x%x\n",
                    left&0xff, i, key[i]&0xff, xored&0xff, rnout&0xff);
        left = rnout;
    }

   return left;

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

    printf("Input: \"%s\"\n",mystr);
    for(int i = 0 ; mystr[i] ; i ++){
        char shifted = doshift(mystr[i], &val);
        mytag = mytag ^ shifted;
    	printf("mystr[%d]: 0x%x shifted: 0x%x currtag: 0x%x\n", 
                i, mystr[i], shifted&0xff, mytag);
    }

    printf("Final Tag: 0x%x %s\n", mytag, mytag==0x1d?"Correct":"Incorrect" );

}

void encrypttest(){

    /* Taken from assignment sheet */
    char rand[16] = {
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

    char test_key[]={
        0x12,
        0x34,
        0x56,
        0x78,
        0x9a,
        0xBC,
        0xDE,
        0xf0
    };


    char input = 'C';
    printf("In: '%c'\n", input);
    char out = encrypt(input, test_key, sizeof(test_key), rand, 0x0f, 1);
    printf ("Out: 0x%x %s\n", out&0xff, out==0x52?"Correct":"Incorrect");

}

int main(){

    printf("----------Test Cases----------\n\n");
    printf("Tagtest:\n");
    tagtest();
    printf("\n");
    printf("EncryptTest:\n");
    encrypttest();
    printf("\n");
    printf("--------------------------\n\n\n");

    char in;
    char tag=0;
    char next;
    unsigned long long key_copy;
    memcpy(&key_copy, key, 8);
    printf("Output: \n");
    int i = 0;
    while((in=getchar())!=EOF){
        next = encrypt(in, key, KEY_SIZE, random_table, RANDOM_TABLE_MASK, 1) & 0x7f;
        char shifted = doshift(next, &key_copy);
        tag = tag ^ shifted;
	    printf("out[%d] 0x%02x %c\n", i++, next , next );
    }
    printf("\n");
    printf("Tag: %x\n", tag&&0xff);
    printf("\n");



    return 0;

}
