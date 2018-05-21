#include <stdio.h>
#include <string.h>
#include <pthread.h>

int encryption_repetitions = 1;
int shift_amount = 1;
int number_of_cores = 4;

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
0x80,
0x81,
0x82,
0x83,
0x84,
0x85,
0x86,
0x87,
0x88,
0x89,
0x8A,
0x8B,
0x8C,
0x8D,
0x8E,
0x8F,
0x90,
0x91,
0x92,
0x93,
0x94,
0x95,
0x96,
0x97,
0x98,
0x99,
0x9A,
0x9B,
0x9C,
0x9D,
0x9E,
0x9F,
0xA0,
0xA1,
0xA2,
0xA3,
0xA4,
0xA5,
0xA6,
0xA7,
0xA8,
0xA9,
0xAA,
0xAB,
0xAC,
0xAD,
0xAE,
0xAF,
0xB0,
0xB1,
0xB2,
0xB3,
0xB4,
0xB5,
0xB6,
0xB7,
0xB8,
0xB9,
0xBA,
0xBB,
0xBC,
0xBD,
0xBE,
0xBF,
0xC0,
0xC1,
0xC2,
0xC3,
0xC4,
0xC5,
0xC6,
0xC7,
0xC8,
0xC9,
0xCA,
0xCB,
0xCC,
0xCD,
0xCE,
0xCF,
0xD0,
0xD1,
0xD2,
0xD3,
0xD4,
0xD5,
0xD6,
0xD7,
0xD8,
0xD9,
0xDA,
0xDB,
0xDC,
0xDD,
0xDE,
0xDF,
0xE0,
0xE1,
0xE2,
0xE3,
0xE4,
0xE5,
0xE6,
0xE7,
0xE8,
0xE9,
0xEA,
0xEB,
0xEC,
0xED,
0xEE,
0xEF,
0xF0,
0xF1,
0xF2,
0xF3,
0xF4,
0xF5,
0xF6,
0xF7,
0xF8,
0xF9,
0xFA,
0xFB,
0xFC,
0xFD,
0xFE,
0xFF,

};

#define KEY_SIZE sizeof(key)
#define RANDOM_SIZE sizeof(random_table)
#define RANDOM_TABLE_MASK 0x7F



char encrypt(char in, char * key, int key_size, char * random, char random_mask, int verbose, 
    int repetitions){

    unsigned char left = in;
    unsigned char xored = 0;
    unsigned char rnout = 0;
   
    for(int j = 0 ; j < repetitions ; j++){
        if(verbose)
            printf("Repetition %d\n", j);
        for(int i = 0 ; i < key_size ; i++){
            xored = left ^ key[i];
            rnout = random[ xored & random_mask];
            if(verbose)
                printf("left: 0x%x key[%d]: 0x%x xored 0x%x masked 0x%x rnout: 0x%x\n",
                        left&0xff, i, key[i]&0xff, xored&0xff, xored&random_mask&0xff, rnout&0xff);
            left = rnout;
        }
    }

   return left;

}

char doshift(char next, unsigned long long * key, int shifts){
    
    unsigned long long x = (*key >= 0x8000000000000000);
    //printf("key val is %x\n", *key);
    //printf("X val is %x\n", x);
    *key = (*key << 1)+x; 
    //printf("key val is now %x\n", *key);
    for(int j = 0 ; j < shifts ; j++)
        next = next << x;
    return next;
}



void tagtest(){
    char mystr[] = "CompArch";
    unsigned long long val = 0xAAAAAAAAAAAAAAAA;
    unsigned char mytag = 0;

    printf("Input: \"%s\"\n",mystr);
    for(int i = 0 ; mystr[i] ; i ++){
        char shifted = doshift(mystr[i], &val, 1);
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
    char out = encrypt(input, test_key, sizeof(test_key), rand, 0x0f, 1, 1);
    printf ("Out: 0x%x %s\n", out&0xff, out==0x52?"Correct":"Incorrect");

}

// Returns the tag
unsigned char do_encrypt(char * input, char * output, int len, int offset, int stride){

    unsigned char next;
    unsigned char tag=0;
    unsigned long long key_copy = 0x123456789abcdef0;

    for(int i = offset ; i < len ; i += stride){

        next = encrypt(input[i], key, KEY_SIZE, random_table, RANDOM_TABLE_MASK, 0, encryption_repetitions) & 0x7f;
        unsigned char shifted = doshift(next, &key_copy, shift_amount);
        unsigned char newtag = tag ^ shifted;
        printf("in[%02d]: %c -> out[%02d] 0x%02x %c tag: 0x%x\n", i,next, i, input[i],  next , next, newtag );
        output[i] = next;
        output[i+1] = 0;
        tag = newtag;
    }

    return tag;

}

struct data {
    char * input;
    char * output;
    int len;
    int numthreads;
    int * finished;
    unsigned char * tags;
    unsigned char finalTag;
} DATA;

void* perform_work(void* argument) {
    int threadId;

    threadId = *((int*) argument);
    unsigned char tag = do_encrypt(DATA.input, DATA.output, DATA.len, threadId, DATA.numthreads);
    printf("Thread %d of %d, Tag = 0x%x\n", threadId, DATA.numthreads, tag);
 
    DATA.tags[threadId] = tag;
    DATA.finished[threadId] = 1;

    for(int i = 0 ; i < DATA.numthreads ; i++){
        if(!DATA.finished[i])
            return NULL;
    }

    /* If we get here we are the last thread */
    tag = 0;
    for (int index = 0; index < number_of_cores; ++index) {
        printf("Tag 0x%x ^ 0x%x -> 0x%x\n", tag, DATA.tags[index], tag ^ DATA.tags[index]);
        tag = tag ^ DATA.tags[index];
    }
    DATA.finalTag = tag;

    return NULL;
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

    printf("Output: \n");
    char input[1000];
    char output[1000];
    while(fgets(input, sizeof(input), stdin)){
        int len = strlen(input);

        unsigned char tags[number_of_cores];
        int finished[number_of_cores];
        memset(finished, 0, sizeof(int) * number_of_cores);
        DATA.input = input,
        DATA.output = output,
        DATA.len = len;
        DATA.numthreads = number_of_cores;
        DATA.tags = tags;
        DATA.finished = finished;

        pthread_t threads[number_of_cores];
        int thread_args[number_of_cores];
        int result_code[number_of_cores];

        // Create N threads
        for (int index = 0; index < number_of_cores; ++index) {
            thread_args[ index ] = index;
            printf("In main: creating thread %d\n", index);
            pthread_create(&threads[index], NULL, perform_work, &thread_args[index]); 
        }
        for (int index = 0; index < number_of_cores; ++index) {
            pthread_join(threads[index], NULL);
            printf("In main: thread %d has completed and returned 0x%x\n", index, DATA.tags[index]&0xff);
        }
        /* This section is for serialising reads of the tags */
        //unsigned char tag = 0;
        //for (int index = 0; index < number_of_cores; ++index) {
        //    printf("Tag 0x%x ^ 0x%x -> 0x%x\n", tag, DATA.tags[index], tag ^ DATA.tags[index]);
        //    tag = tag ^ DATA.tags[index];
        //}

        //printf("In: %s\n", DATA.input);
        //printf("Out: ");
        //for(int i = 0 ; i < DATA.len ; i ++)
        //    printf("0x%x ", DATA.output[i]&0xff);
        //printf("(%s)", DATA.output);
        //printf("\n");

        //printf("Final Tag: 0x%x vs 0x%x\n", tag & 0xff, DATA.finalTag);
        printf("Final Tag: 0x%x \n", DATA.finalTag);


    }
    printf("\n");



    return 0;

}
