#ifndef GEOLOC_H
#define GEOLOC_H

#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#define MAX_FACILITIES 1024
#define MAX_CLIENTS 1024

typedef long long int lint;
typedef unsigned int uint;
typedef unsigned short ushort;

#define MAX_LINT LLONG_MAX

typedef struct{
    int n_facilities, n_clients;
    // ^ Number of facilities and clients.
    int weights[MAX_CLIENTS];
    // ^ Weight of each client.
    lint distances[MAX_FACILITIES][MAX_CLIENTS];
    // ^ Distance matrix between facilities and clients.
    lint fdistances[MAX_FACILITIES][MAX_FACILITIES];
    // ^ Distance matrix between facilities and facilities, used for solution comparison.
    lint facility_fixed_cost;
    // ^ Cost of each facility.
    lint variant_gain;
    // ^ Gains for connecting one weight of unit.
    lint transport_cost;
    // ^ Cost of connecting one weight of unit one unit of distance.
    int nearest[MAX_FACILITIES][MAX_CLIENTS];
    // ^ Optimization automatically computed.
} problem;

struct _solution {
    int n_facilities;
    // ^ Number of facilities in this solution.
    int facilities[MAX_FACILITIES];
    // ^ Facilities from the smaller index to the larger one.
    int assignments[MAX_CLIENTS];
    // ^ Which facility is working each client.
    lint value;
    // ^ Value of this solution on the objective function.
};

typedef struct _solution solution;

solution empty_solution();

solution **new_find_best_solutions(problem* prob,
        int pool_size, int vision_range, int *final_n, int *max_sol_size);

problem *new_problem_load(const char *file);

void save_solutions(const char *file, solution **sols, int n_sols,
        const char *input_file, int pool_size, int vision_range,
        float seconds, int max_sol_size);

static inline void print_solution(FILE *f, const solution *sol){
    fprintf(f,"SOLUTION:\n");
    fprintf(f,"  Value: %lld\n",sol->value);
    fprintf(f,"  Facilities: %d\n",sol->n_facilities);
    for(int i=0;i<sol->n_facilities;i++){
        fprintf(f,"  %4d :",sol->facilities[i]);
        for(int j=0;j<MAX_CLIENTS;j++){
            if(sol->assignments[j]==sol->facilities[i]){
                fprintf(f,"%4d",j);
            }
        }
        fprintf(f,"\n");
    }
}

static inline void print_solsets(solution **sols, int n_sols){
    printf("{");
    for(int i=0;i<n_sols;i++){
        printf("{");
        for(int k=0;k<sols[i]->n_facilities;k++){
            printf("%d",sols[i]->facilities[k]);
            if(k<sols[i]->n_facilities-1)printf(",");
        }
        printf("}");
        if(i<n_sols-1)printf(",");
    }
    printf("}\n");
}

#endif
