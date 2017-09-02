#include <stdio.h>
#include <stdlib.h>

#include "geoloc.h"

#include <math.h>
#include <time.h>

/*
Problem with:
clients on the Same locations than facilities
on the Euclidian plane.
places are Equiprobably distributed
on a Square
with constant Unitary weights for each client

Random positions are written in the arrays because it may be used somewhere else.
*/
void SEESU_problem(problem *prob, int seed, lint board_size, int n_places,
        int facility_fixed_cost, int variant_gain, int transport_cost,
        lint *out_pos_x, lint *out_pos_y){
    //
    assert(n_places<MAX_FACILITIES && n_places<MAX_CLIENTS);
    prob->n_facilities = n_places;
    prob->n_clients = n_places;
    prob->facility_fixed_cost = facility_fixed_cost;
    prob->variant_gain = variant_gain;
    prob->transport_cost = transport_cost;
    // Set the positions and weights
    srand(seed);
    lint pos_x[n_places];
    lint pos_y[n_places];
    for(int i=0;i<n_places;i++){
        prob->weights[i] = 1;
        pos_x[i] = rand()%board_size;
        if(out_pos_x!=NULL) out_pos_x[i] = pos_x[i];
        pos_y[i] = rand()%board_size;
        if(out_pos_y!=NULL) out_pos_y[i] = pos_y[i];
    }
    // calculate the distances:
    for(int i=0;i<n_places;i++){
        for(int j=0;j<n_places;j++){
            lint delta_x = pos_x[j]-pos_x[i];
            lint delta_y = pos_y[j]-pos_y[i];
            lint dist = (lint) sqrt(delta_x*delta_x+delta_y*delta_y);
            prob->distances[i][j] = dist;
            prob->fdistances[i][j] = dist;
        }
    }
}

int main(int argc, char **argv){
    // Problem is static so that it doesn't overflow the stack.
    static problem prob;
    //
    time_t second;
    time(&second);
    int seed = (int) second;
    if(seed<0) seed*=-1;
    printf("seed: %d\n", seed);
    // Algorithm parameters:
    int pool_size = 400;
    int vision_range = 200;
    // Problem parameters:
    int n_places = 100;
    int board_size = 1000;
    // Problem constants:
    int facility_cost = 600;
    int variant_gain = 300;
    int transport_cost = 1;
    // Output:
    int max_to_show = 10;
    // Print parameters
    printf("Pool size: %d\n",pool_size);
    printf("Vision range: %d\n",vision_range);
    printf("N places: %d\n",n_places);
    printf("facility cost:  %d\n",facility_cost);
    printf("variant_gain:   %d\n",variant_gain);
    printf("transport cost: %d\n",transport_cost);
    //
    lint pos_x[n_places];
    lint pos_y[n_places];
    printf("Creating SEESU problem...\n");
    SEESU_problem(&prob, seed,board_size,n_places,
        facility_cost,variant_gain,transport_cost,pos_x,pos_y);
    // Get the solutions:
    int n_sols;
    printf("Starting search...\n");
    solution **sols = new_find_best_solutions(&prob,
        pool_size, vision_range, &n_sols);
    printf("Search done!\n");
    // Print 10 best solutions
    for(int i=0;i<max_to_show;i++){
        if(i>=n_sols) break;
        print_solution(sols[i]);
    }
    // Save best solution on svg file:
    save_solution_svg("best_sol.svg",
        pos_x,pos_y,n_places,pos_x,pos_y,n_places,
        sols[0],500.0/board_size);
    // Free memory
    for(int i=0;i<n_sols;i++){
        free(sols[i]);
    }
    free(sols);
    return 0;
}
