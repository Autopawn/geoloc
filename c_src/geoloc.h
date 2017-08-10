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

static inline void save_solution_asy(const char *fname,
        const lint *cli_xs, const lint *cli_ys, int n_clis,
        const lint *fac_xs, const lint *fac_ys, int n_facs,
        const solution *sol, float scale){
    printf("Exporting solution to asy file: %s\n",fname);
    // Open file
    FILE *f = fopen(fname, "w");
    if(f==NULL){
        printf("Error opening file to save asy!\n");
        exit(1);
    }
    // Print function to make arrows:
    fprintf(f,"unitsize(5);\n");
    fprintf(f,"path unibox = box((-1,-1),(1,1));\n");
    fprintf(f,"path larrow(pair ini, pair end, bool pre=false){\n");
    fprintf(f,"\treal signx = end.x-ini.x;\n");
    fprintf(f,"\tif(signx<-1) signx=-1;\n");
    fprintf(f,"\tif(signx>1) signx=1;\n");
    fprintf(f,"\treal signy = end.y-ini.y;\n");
    fprintf(f,"\tif(signy<-1) signy=-1;\n");
    fprintf(f,"\tif(signy>1) signy=1;\n");
    fprintf(f,"\treturn (ini.x+(pre?signx:0),ini.y+(pre?signy:0))\n");
    fprintf(f,"\t\t--(end.x-signx,end.y-signy);\n");
    fprintf(f,"}\n");
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
            // Print arrows:
            for(int k=0;k<n_clis;k++){
                if(sol->assignments[k]==i){
                    if(fac_xs[i]!=cli_xs[k] || fac_ys[i]!=cli_ys[k]){
                        fprintf(f,"draw(larrow((%6f,%6f),(%6f,%6f)),",
                        fac_xs[i]*scale,fac_ys[i]*scale,
                        cli_xs[k]*scale,cli_ys[k]*scale);
                        fprintf(f,"arrow=Arrow(TeXHead),black);\n");
                    }
                }
            }
            // Print facility:
            fprintf(f,"filldraw(shift(%6f,%6f)*unibox,blue);\n",
                fac_xs[i]*scale,fac_ys[i]*scale);
        }else{
            fprintf(f,"draw(shift(%6f,%6f)*unibox);\n",
                fac_xs[i]*scale,fac_ys[i]*scale);
        }
    }
    // Print clients
    for(int i=0;i<n_clis;i++){
        fprintf(f,"filldraw(shift(%6f,%6f)*unitcircle,red);\n",
            cli_xs[i]*scale,cli_ys[i]*scale);
    }
    fclose(f);
}
#endif
