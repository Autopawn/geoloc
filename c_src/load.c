#include "geoloc.h"

problem *new_problem_load(const char *file){
    FILE *fp;
    printf("Reading file \"%s\"...\n",file);
    fp = fopen(file,"r");
    if(fp==NULL){
        printf("ERROR: couldn't open file \"%s\"!\n",file);
        exit(1);
    }
    // Alloc memory for problem.
    problem *prob = malloc(sizeof(problem));

    // Read the facility cost:
    if(fscanf(fp,"%lld",&prob->facility_fixed_cost)!=1){
        printf("ERROR: facility cost expected!\n");
        exit(1);
    }
    printf("Facility cost: %lld\n",prob->facility_fixed_cost);

    // Read the variant gain:
    if(fscanf(fp,"%lld",&prob->variant_gain)!=1){
        printf("ERROR: variant gain expected!\n");
        exit(1);
    }
    printf("Variant gain: %lld\n",prob->variant_gain);

    // Read the transport cost:
    if(fscanf(fp,"%lld",&prob->transport_cost)!=1){
        printf("ERROR: transport cost expected!\n");
        exit(1);
    }
    printf("Transport cost: %lld\n",prob->transport_cost);

    // Read the number of facilities:
    if(fscanf(fp,"%d",&prob->n_facilities)!=1){
        printf("ERROR: number of facilities expected!\n");
        exit(1);
    }
    printf("N Facilities: %d\n",prob->n_facilities);
    assert(prob->n_facilities<=MAX_FACILITIES);

    // Read the number of clients:
    if(fscanf(fp,"%d",&prob->n_clients)!=1){
        printf("ERROR: number of clients expected!\n");
        exit(1);
    }
    printf("N Clients: %d\n",prob->n_clients);
    assert(prob->n_clients<=MAX_CLIENTS);

    // Read the facility distance matrix:
    printf("Reading facility distance matrix...\n");
    for(int i=0;i<prob->n_facilities;i++){
        for(int j=0;j<prob->n_facilities;j++){
            int result = fscanf(fp,"%lld",&prob->fdistances[i][j]);
            if(result==EOF){
                printf("ERROR: EOF while reading facility distance matrix!\n");
                exit(1);
            }else if(result!=1){
                printf("ERROR: Distance expected!\n");
                exit(1);
            }
        }
    }

    // Read clients weights:
    printf("Reading client weights...\n");
    for(int i=0;i<prob->n_clients;i++){
        int result = fscanf(fp,"%d",&prob->weights[i]);
        if(result==EOF){
            printf("ERROR: EOF while reading client weight!\n");
            exit(1);
        }else if(result!=1){
            printf("ERROR: Weight expected!\n");
            exit(1);
        }
    }

    // Read the facility-client distance matrix:
    printf("Reading facility-client distance matrix...\n");
    for(int i=0;i<prob->n_facilities;i++){
        for(int j=0;j<prob->n_clients;j++){
            int result = fscanf(fp,"%lld",&prob->distances[i][j]);
            if(result==EOF){
                printf("ERROR: EOF while reading facility-client distance matrix!\n");
                exit(1);
            }else if(result!=1){
                printf("ERROR: Distance expected!\n");
                exit(1);
            }
        }
    }
    //
    fclose(fp);
    printf("Done reading.\n");
    return prob;
}

void save_solutions(const char *file, solution **sols, int n_sols,
        const char *input_file, int pool_size, int vision_range){
    FILE *fp;
    printf("Opening file \"%s\"...\n",file);
    fp = fopen(file,"w");
    if(fp==NULL){
        printf("ERROR: couldn't open file \"%s\"!\n",file);
        exit(1);
    }
    // Print some aditional info:
    fprintf(fp,"# Input file: %s\n",input_file);
    fprintf(fp,"# Pool size: %d\n",pool_size);
    fprintf(fp,"# Vision range: %d\n",vision_range);
    // Print the solutions:
    for(int i=0;i<n_sols;i++){
        print_solution(fp,sols[i]);
    }
    fclose(fp);
}
