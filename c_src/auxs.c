#include "geoloc.h"

//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
// MISCELANEOUS AND COMPARISON FUNCTIONS
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

void *safe_malloc(size_t size){
    void *ptr = malloc(size);
    if(size>0 && ptr==NULL){
        fprintf(stderr,"ERROR: Not enough memory!\n");
        exit(1);
    }
    return ptr;
}

uint hash_int(uint x){
    // Thanks to https://stackoverflow.com/a/12996028
    x = ((x >> 16)^x)*0x45d9f3b;
    x = ((x >> 16)^x)*0x45d9f3b;
    x = (x >> 16)^x;
    return x;
}

void add_to_sorted(short *array, int *len, short val){
    int place = *len;
    while(place>0){
        if(array[place-1]<=val) break;
        array[place] = array[place-1];
        place--;
    }
    array[place] = val;
    *len += 1;
}

void rem_of_sorted(short *array, int *len, short val){
    int place=-1;
    for(int i=0;i<*len;i++){
        if(array[i]==val){
            place = i;
            break;
        }
    }
    assert(place!=-1); // Not in array.
    for(int i=place;i<*len-1;i++){
        array[i] = array[i+1];
    }
    *len -= 1;
}
