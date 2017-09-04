#ifndef GEOLOC_H
#define GEOLOC_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#define MAX_FACILITIES 512
#define MAX_CLIENTS 512

typedef long long int lint;
typedef unsigned int uint;
typedef unsigned short ushort;

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

solution **new_find_best_solutions(problem* prob,
        int pool_size, int vision_range, int *final_n);

problem *new_problem_load(const char *file);

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

static inline void print_solutions(solution **sols, int n_sols){
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

static inline void save_solution_svg(const char *fname,
        const lint *cli_xs, const lint *cli_ys, int n_clis,
        const lint *fac_xs, const lint *fac_ys, int n_facs,
        const solution *sol, float scale){
    printf("Exporting solution to svg file: %s\n",fname);
    // Open file
    FILE *f = fopen(fname, "w");
    if(f==NULL){
        printf("Error opening file to save svg!\n");
        exit(1);
    }
    // Start SVG file
    fprintf(f,"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
    fprintf(f,"<svg xmlns=\"http://www.w3.org/2000/svg\" version=\"1.1\">\n");
    // Print clients
    for(int i=0;i<n_clis;i++){
        fprintf(f,"<circle cx=\"%6f\" cy=\"%6f\" r=\"4\" fill=\"red\"/>\n",
        cli_xs[i]*scale,cli_ys[i]*scale);
    }
    // Print facilities:
    for(int i=0;i<n_facs;i++){
        int present = 0;
        for(int k=0;k<sol->n_facilities;k++){
            if(sol->facilities[k]==i){
                present = 1;
                break;
            }
        }
        if(present){
            // Print facility:
            fprintf(f,"<rect x=\"%6f\" y=\"%6f\" width=\"9\" height=\"9\" fill=\"blue\" stroke-width=\"2\" stroke=\"black\" fill-opacity=\"0.75\" />\n",
            fac_xs[i]*scale-4.5,fac_ys[i]*scale-4.5);
        }else{
            // Print facility:
            fprintf(f,"<rect x=\"%6f\" y=\"%6f\" width=\"9\" height=\"9\" stroke-width=\"2\" stroke=\"black\" fill-opacity=\"0\" />\n",fac_xs[i]*scale-4.5,fac_ys[i]*scale-4.5);
        }
    }
    // Print arrows:
    for(int k=0;k<n_clis;k++){
        int i = sol->assignments[k];
        if(fac_xs[i]!=cli_xs[k] || fac_ys[i]!=cli_ys[k]){
            fprintf(f,"<line x1=\"%6f\" y1=\"%6f\" x2=\"%6f\" y2=\"%6f\" stroke=\"blue\" stroke-width=\"2\"/>\n",
            fac_xs[i]*scale,fac_ys[i]*scale,
            cli_xs[k]*scale,cli_ys[k]*scale);
        }
    }
    // End SVG file
    fprintf(f,"</svg>\n");
    fclose(f);
}
#endif
