#include <stdio.h>
#include <stdlib.h>

#include "geoloc.h"

#include <math.h>
#include <time.h>


int main(int argc, char **argv){
    int pool_size,vision_range,max_to_show;
    const char *input_file = NULL;
    int good = 1;
    if(argc!=6) good = 0;
    if(good){
        if(sscanf(argv[1],"%d",&pool_size)!=1) good = 0;
        if(sscanf(argv[2],"%d",&vision_range)!=1) good = 0;
        if(sscanf(argv[3],"%d",&max_to_show)!=1) good = 0;
        input_file = argv[4];
    }
    if(!good){
        printf("Usage: %s <pool_size> <vision_range> <max_sols_to_show> <problem_file> <output_file>\n",argv[0]);
        exit(1);
    }
    printf("Pool size: %d\n",pool_size);
    printf("Vision range: %d\n",vision_range);
    printf("Max solutions to show: %d\n",max_to_show);
    // Load problem file:
    problem *prob = new_problem_load(input_file);
    // Get the solutions:
    int n_sols, max_size_found;
    printf("Starting search...\n");
    clock_t start = clock();
    solution **sols = new_find_best_solutions(prob,
        pool_size, vision_range, &n_sols, &max_size_found);
    clock_t end = clock();
    float seconds = (float)(end - start) / (float)CLOCKS_PER_SEC;
    printf("Max size solution found: %d\n",max_size_found);
    printf("Search done in %f [s]!\n",seconds);
    // Print best solutions
    printf("Best solutions:\n");
    int sols_show = n_sols;
    if(sols_show>max_to_show) sols_show = max_to_show;
    for(int i=0;i<sols_show;i++){
        print_solution(stdout,sols[i]);
    }
    printf("Saving solutions...\n");
    if(sols_show==0){
        solution empty_sol = empty_solution();
        solution *empty_sol_p = &empty_sol;
        save_solutions(argv[5],&empty_sol_p,1,input_file,pool_size,vision_range,
            seconds,max_size_found);
    }else{
        save_solutions(argv[5],sols,sols_show,input_file,pool_size,vision_range,
            seconds,max_size_found);
    }
    // Free memory
    for(int i=0;i<n_sols;i++){
        free(sols[i]);
    }
    free(sols);
    free(prob);

    return 0;
}
