#include "geoloc.h"

//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
// MISCELANEOUS AND COMPARISON FUNCTIONS
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

inline void *safe_malloc(size_t size){
    void *ptr = malloc(size);
    if(size>0 && ptr==NULL){
        printf("ERROR: Not enough memory!\n");
        exit(1);
    }
    return ptr;
}

int compare_ints(const void * a, const void * b){
    return ( *(int*)a - *(int*)b );
}

uint hash_int(uint x){
    // Thanks to https://stackoverflow.com/a/12996028
    x = ((x >> 16)^x)*0x45d9f3b;
    x = ((x >> 16)^x)*0x45d9f3b;
    x = (x >> 16)^x;
    return x;
}

static const problem *prob_value_for_compare_dist_to_f;
static int f_value_for_compare_dist_to_f;
int compare_dist_to_f(const void * a, const void * b){
    int ia = *(int*)a;
    int ib = *(int*)b;
    const problem *prob = prob_value_for_compare_dist_to_f;
    const int f = f_value_for_compare_dist_to_f;
    return prob->distances[f][ia]-prob->distances[f][ib];
}

int solution_value_cmp_inv(const void *a, const void *b){
    solution **aa = (solution **) a;
    solution **bb = (solution **) b;
    return (*bb)->value - (*aa)->value;
}

//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
// SOLUTION FUNCTIONS
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

// | Returns an empty solution, with no facilities.
solution empty_solution(){
    solution sol;
    sol.n_facilities = 0;
    for(int c=0;c<MAX_CLIENTS;c++) sol.assignments[c] = -1;
    sol.value = 0;
    sol.hash = 0;
    sol.next = NULL;
    return sol;
}

// | Checks if two solutions are the same:
int solution_equals(solution* sol_a, solution* sol_b){
    // Check basic values:
    if(sol_a->hash!=sol_b->hash) return 0;
    if(sol_a->n_facilities!=sol_b->n_facilities) return 0;
    // Sort the facilities indexes for both solutions.
    qsort(sol_a->facilities,sol_a->n_facilities,sizeof(int),compare_ints);
    qsort(sol_b->facilities,sol_b->n_facilities,sizeof(int),compare_ints);
    // Compare each facility index:
    for(int i=0;i<sol_a->n_facilities;i++){
        if(sol_a->facilities[i]!=sol_b->facilities[i]) return 0;
    }
    return 1;
}

// | Adds a facility to the solution, returns the delta of the value on the objective function.
lint solution_add(const problem *prob, solution *sol, int newf){
    // Check if f is already on the solution:
    for(int f=0;f<sol->n_facilities;f++){
        if(sol->facilities[f]==newf) return 0;
    }
    // Add the facility to the solution.
    sol->facilities[sol->n_facilities] = newf;
    sol->n_facilities += 1;
    sol->hash = sol->hash ^ hash_int(newf);
    // | Critical radious.
    lint crit_rad = prob->variant_gain/prob->transport_cost;
    // | Difference on the value after adding the new facility.
    lint delta = 0;
    // Reassign clients to the new facility, from nearest to further.
    for(int c=0;c<prob->n_clients;c++){
        int cli = prob->nearest[newf][c];
        // Distance of that client to the new facility:
        lint distance = prob->distances[newf][cli];
        if(distance>crit_rad) break;
        // Distance to the previously assignated facility:
        lint old_distance = -1;
        if(sol->assignments[cli]!=-1){
            old_distance = prob->distances[sol->assignments[cli]][cli];
        }
        if(old_distance==-1 || distance<old_distance){
            // ^ If client not assigned, or is nearest to the new facility assign it.
            // Gain of the new assignation:
            delta += prob->weights[cli]*
                (prob->variant_gain-prob->transport_cost*distance);
            // Lost the previous assignation:
            if(old_distance!=-1){
                delta -= prob->weights[cli]*
                    (prob->variant_gain-prob->transport_cost*old_distance);
            }
            // Reassign client to new facility
            sol->assignments[cli] = newf;
        }
    }
    // The constant cost of a facility:
    delta -= prob->facility_fixed_cost;
    // Update solution value:
    sol->value += delta;
    return delta;
}

// Returns the dissimilitude (using modified Hausdorff distance without coeficients).
lint solution_dissimilitude(const problem *prob,
        const solution *sol_a, const solution *sol_b){
    lint disim = 0;
    for(int t=0;t<2;t++){
        // Add distance from each facility in a to the set of facilities of b.
        for(int ai=0;ai<sol_a->n_facilities;ai++){
            lint min_dist = -1;
            for(int bi=0;bi<sol_b->n_facilities;bi++){
                int f_a = sol_a->facilities[ai];
                int f_b = sol_b->facilities[bi];
                lint dist = prob->fdistances[f_a][f_b];
                if(min_dist==-1 || dist<min_dist) min_dist = dist;
            }
            disim += min_dist;
        }
        // Swap solutions for 2nd iteration:
        const solution *aux = sol_a;
        sol_a = sol_b;
        sol_b = aux;
    }
    return disim;
}

//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
// SOLUTIONSET
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

typedef struct {
    solution* slots[HASH_SLOTS];
    // ^ Hash table for solutions.
    int n_solutions;
} solutionset;

void init_solutionset(solutionset* sset){
    for(int i=0;i<HASH_SLOTS;i++) sset->slots[i] = NULL;
    sset->n_solutions = 0;
}

// | Adds a solution to a solutionset, returning 1 if it didn't exist already.
int solutionset_add(solutionset* sset, solution *sol){
    assert(sol->next==NULL);
    int hash_slot = sol->hash%HASH_SLOTS;
    solution **sol_pp = &sset->slots[hash_slot];
    while(*sol_pp!=NULL){
        if(solution_equals(*sol_pp,sol)) return 0;
        sol_pp = &(*sol_pp)->next;
    }
    *sol_pp = sol;
    sset->n_solutions += 1;
    return 1;
}

// | Sets an array (out_sols) with the pointers of all the solutions, out_sols must have length of at least sset->n_solutions solution pointers.
void solutionset_as_array(solutionset* sset, solution** out_sols){
    int n_sols = 0;
    //
    for(int i=0;i<HASH_SLOTS;i++){
        solution *sol_p = sset->slots[i];
        while(sol_p!=NULL){
            out_sols[n_sols] = sol_p;
            n_sols += 1;
            sol_p = sol_p->next;
        }
    }
    assert(n_sols==sset->n_solutions);
}

//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
// DISSIMILITUDE PAIRS HEAP
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

typedef struct{
    lint dissim;
    unsigned short indx_a, indx_b;
} dissimpair;

dissimpair heap_poll(dissimpair *heap, int *size){
    dissimpair retp = heap[0];
    heap[0] = heap[*size-1];
    *size -= 1;
    // Heapify down:
    int i = 0;
    int c = 2*i+1;
    while(c<*size){
        if(c+1<*size && heap[c+1].dissim<heap[c].dissim) c = c+1;
        if(heap[i].dissim<heap[c].dissim) break;
        dissimpair aux = heap[i];
        heap[i] = heap[c];
        heap[c] = aux;
        i = c;
        c = 2*i+1;
    }
    //
    return retp;
}

void heap_add(dissimpair *heap, int *size, dissimpair val){
    heap[*size] = val;
    *size += 1;
    // Heapify up:
    int i = *size-1;
    int p = (i-1)/2;
    while(p>=0 && heap[i].dissim<heap[p].dissim){
        dissimpair aux = heap[i];
        heap[i] = heap[p];
        heap[p] = aux;
        i = p;
        p = (i-1)/2;
    }
}

//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
// MAIN ALGORITHM
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

// | Compute the clients indexes sorted by distance for each facility.
// nearest should be a [MAX_FACILITIES]x[MAX_CLIENTS] matrix.
void problem_compute_nearest(problem* prob){
    // For each facility
    for(int f=0;f<prob->n_facilities;f++){
        // Sort each client index according to their distance to the facility
        for(int c=0;c<prob->n_clients;c++) prob->nearest[f][c] = c;
        f_value_for_compare_dist_to_f = f;
        prob_value_for_compare_dist_to_f = prob;
        qsort(prob->nearest[f],prob->n_clients,sizeof(int),compare_dist_to_f);
    }
}

// | From n_sols solutions and an array to pointers to them (sols), create new solutions and return an array of pointers to them, also sets the out_n_sols value to the length of the created array.
solution **new_expand_solutions(const problem *prob,
        solution** sols, int n_sols, int *out_n_sols){
    solutionset *sset = safe_malloc(sizeof(solutionset));
    init_solutionset(sset);
    // Create solutions for the next iteration.
    for(int i=0;i<n_sols;i++){
        for(int f=0;f<prob->n_facilities;f++){
            // Create a new solution, with the old one and adding a facility.
            solution *new_sol = safe_malloc(sizeof(solution));
            *new_sol = *sols[i];
            new_sol->next = NULL; // !
            lint delta = solution_add(prob,new_sol,f);
            // If delta is not larger than 0, or it already exists, free it, in other case, save it on the solutionset.
            if(delta<=0 || !solutionset_add(sset,new_sol)){
                free(new_sol);
            }
        }
    }
    solution **out_sols = safe_malloc(sizeof(solution*)*sset->n_solutions);
    *out_n_sols = sset->n_solutions;
    solutionset_as_array(sset,out_sols);
    free(sset);
    return out_sols;
}

// Reduces an array (sols) with pointers to a set of solutions to target_n size, freeing memory of the discarted ones. *n_sols is modified.
void reduce_solutions(const problem *prob,
        solution **sols, int *n_sols, int target_n, int vision_range){
    // Sort solution pointers from larger to smaller value of the solution.
    qsort(sols,*n_sols,sizeof(solution*),solution_value_cmp_inv);
    // Double linked structure to know solutions that haven't yet been discarted:
    int *discarted = safe_malloc((*n_sols)*sizeof(int));
    int *nexts = safe_malloc((*n_sols)*sizeof(int));
    int *prevs = safe_malloc((*n_sols)*sizeof(int));
    for(int i=0;i<*n_sols;i++){
        discarted[i] = 0;
        prevs[i] = i-1;
        nexts[i] = i+1;
    }
    prevs[0] = -1;
    nexts[*n_sols-1] = -1;
    // Heap of dissimilitude pairs
    int n_pairs = 0;
    dissimpair *heap = safe_malloc(sizeof(dissimpair)*2*(*n_sols)*vision_range);
    // Initial set of dissimilitude pairs
    for(int i=0;i<*n_sols;i++){
        for(int j=1;j<=vision_range;j++){
            if(i+j>=*n_sols) break;
            dissimpair dp;
            dp.indx_a = i;
            dp.indx_b = i+j;
            dp.dissim = solution_dissimilitude(prob,
                sols[dp.indx_a],sols[dp.indx_b]);
            heap_add(heap,&n_pairs,dp);
        }
    }
    // Eliminate as much solutions as required:
    int n_eliminate = *n_sols-target_n;
    int elims = 0;
    while(elims<n_eliminate){
        // Eliminate worst solution of most similar pair
        if(n_pairs==0) break;
        dissimpair pair = heap_poll(heap,&n_pairs);
        if(!discarted[pair.indx_a] && !discarted[pair.indx_b]){
            // printf("%6d%6d-%8lld\n",pair.indx_a,pair.indx_b,pair.dissim);
            // Delete the second solution on the pair.
            int to_delete = pair.indx_b;
            discarted[to_delete] = 1;
            free(sols[to_delete]);
            elims += 1;
            // Update double linked list:
            if(nexts[to_delete]!=-1) prevs[nexts[to_delete]] = prevs[to_delete];
            if(prevs[to_delete]!=-1) nexts[prevs[to_delete]] = nexts[to_delete];
            // Add new pairs to replace those that will be deleted on the destroyed solution.
            int *prev_sols = safe_malloc(sizeof(int)*vision_range);
            int *next_sols = safe_malloc(sizeof(int)*vision_range);
            int iter;
            // Get solutions after
            iter = to_delete;
            for(int i=0;i<vision_range;i++){
                if(nexts[iter]==-1){
                    next_sols[i] = -1;
                }else{
                    iter = nexts[iter];
                    next_sols[i] = iter;
                }
            }
            // Get solutions before
            iter = to_delete;
            for(int i=0;i<vision_range;i++){
                if(prevs[iter]==-1){
                    prev_sols[i] = -1;
                }else{
                    iter = prevs[iter];
                    prev_sols[i] = iter;
                }
            }
            // Create new pairs
            for(int i=0;i<vision_range;i++){
                int pair_a = prev_sols[vision_range-1-i];
                int pair_b = next_sols[i];
                if(pair_a!=-1 && pair_b!=-1){
                    // Create the replace node:
                    dissimpair pair;
                    pair.indx_a = pair_a;
                    pair.indx_b = pair_b;
                    pair.dissim = solution_dissimilitude(prob,
                        sols[pair.indx_a],sols[pair.indx_b]);
                    assert(n_pairs<2*(*n_sols)*vision_range);
                    heap_add(heap,&n_pairs,pair);
                }
            }
            //
            free(prev_sols);
            free(next_sols);
        }
    }
    // Free all the pairs:
    free(heap);
    n_pairs = 0;
    // Set output final array:
    int new_nsols=0;
    for(int i=0;i<*n_sols;i++){
        if(discarted[i]==0){
            sols[new_nsols] = sols[i];
            new_nsols += 1;
        }
    }
    *n_sols = new_nsols;
    // Free arrays
    free(discarted);
    free(nexts);
    free(prevs);
}


solution **new_find_best_solutions(problem* prob,
        int pool_size, int vision_range, int *final_n){
    //
    printf("Computing 'nearest' table optimization...\n");
    problem_compute_nearest(prob);
    // Place to store all the pools:
    int pools_size[MAX_FACILITIES+1] = {0};
    solution **pools[MAX_FACILITIES+1] = {NULL};
    // Create the first pool:
    solution empt = empty_solution();
    solution *pool0[1];
    pool0[0] = &empt;
    pools[0] = pool0;
    pools_size[0] = 1;
    // Create all the next pools:
    int total_pools_size = 0;
    for(int i=1;i<=MAX_FACILITIES;i++){
        printf("Expanding %d solutions of size %d...\n",pools_size[i-1],i-1);
        pools[i] = new_expand_solutions(prob, pools[i-1],
            pools_size[i-1], &pools_size[i]);
        if(pools_size[i]==0){
            printf("No more valuable solution of size %d!\n",i);
            break;
        }
        printf("Reducing %d solutions of size %d...\n",pools_size[i],i);
        reduce_solutions(prob, pools[i], &pools_size[i],
            pool_size, vision_range);
        // Realloc to reduce memory usage:
        pools[i] = realloc(pools[i],sizeof(solution*)*pools_size[i]);
        //
        total_pools_size += pools_size[i];
    }
    printf("Merging pools...\n");
    // Merge all solution pointers into one final array:
    solution **final = safe_malloc(sizeof(solution*)*total_pools_size);
    int current_sol_n = 0;
    for(int i=1;i<=MAX_FACILITIES;i++){
        for(int j=0;j<pools_size[i];j++){
            final[current_sol_n] = pools[i][j];
            current_sol_n += 1;
        }
        if(pools[i]!=NULL) free(pools[i]);
    }
    assert(current_sol_n==total_pools_size);
    // Sort solution pointers form best to worst value.
    qsort(final,current_sol_n,sizeof(solution*),solution_value_cmp_inv);
    *final_n = current_sol_n;
    // Return it
    return final;
}
