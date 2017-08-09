#ifndef GEOLOC_H
#define GEOLOC_H

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

#include "../lib/avltree/avltree.h"

#define MAX_FACILITIES 512
#define MAX_CLIENTS 512
#define HASH_SLOTS 999983
// ^ 2^19-7

typedef long long int lint;
typedef unsigned int uint;

typedef struct {
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
    // ^ Facilities
    int assignments[MAX_CLIENTS];
    // ^ Which facility is working each client.
    lint value;
    // ^ Value of this solution on the objective function.

    uint hash;
    // ^ Current hash for the solution, and if it is valid or it should be recomputed.
    struct _solution* next;
    // ^ Pointer to be used on a linked list, a solution can only stay in one linked list at the same time.
};
typedef struct _solution solution;

solution **new_find_best_solutions(problem* prob,
        int pool_size, int vision_range, int *final_n);

static inline void print_solution(const solution *sol){
    printf("SOLUTION:\n");
    printf("  Value: %lld\n",sol->value);
    printf("  Facilities:\n");
    for(int i=0;i<sol->n_facilities;i++){
        printf("  %4d :",sol->facilities[i]);
        for(int j=0;j<MAX_CLIENTS;j++){
            if(sol->assignments[j]==sol->facilities[i]){
                printf("%4d",j);
            }
        }
        printf("\n");
    }
}

#endif
