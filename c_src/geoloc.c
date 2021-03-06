#include "geoloc.h"

//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
// FUTURESOL
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

// Possible future solution that results from another one.

typedef struct {
    solution *origin;
    int newf;
    uint hash;
    int n_facilities;
    short facilities[0]; // Flexible array member.
} futuresol;

int futuresol_cmp(const void *a, const void *b){
    const futuresol *aa = (const futuresol *) a;
    const futuresol *bb = (const futuresol *) b;
    if(aa->hash>bb->hash) return +1;
    if(aa->hash<bb->hash) return -1;
    int nf_delta = aa->n_facilities - bb->n_facilities;
    if(nf_delta!=0) return nf_delta;
    for(int i=0;i<aa->n_facilities;i++){
        int idx_delta = aa->facilities[i]-bb->facilities[i];
        if(idx_delta!=0) return idx_delta;
    }
    return 0;
}

//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
// DISSIMILITUDE PAIRS HEAP
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

// NOTE: Is possible to replace lint=>float and int=>ushort to use half of the memory saving pair data.
typedef struct{
    lint dissim;
    int indx_a, indx_b;
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
    while(i>0 && heap[i].dissim<heap[p].dissim){
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

// Compare the distance of two clients to one specific facility
static const problem *prob_value_for_compare_dist_to_f;
static int f_value_for_compare_dist_to_f;
int compare_dist_to_f(const void * a, const void * b){
    short ia = *(short*)a;
    short ib = *(short*)b;
    const problem *prob = prob_value_for_compare_dist_to_f;
    const int f = f_value_for_compare_dist_to_f;
    return prob->distances[f][ia]-prob->distances[f][ib];
}

// | Compute the clients indexes sorted by distance for each facility.
void problem_compute_nearest(problem* prob){
    // For each facility
    for(int f=0;f<prob->n_facilities;f++){
        // Sort each client index according to their distance to the facility
        for(int c=0;c<prob->n_clients;c++) prob->nearest[f][c] = c;
        f_value_for_compare_dist_to_f = f;
        prob_value_for_compare_dist_to_f = prob;
        qsort(prob->nearest[f],prob->n_clients,sizeof(short),compare_dist_to_f);
    }
}

// | From n_sols solutions and an array to pointers to them (sols), create new solutions and return an array of pointers to them, also sets the out_n_sols value to the length of the created array.
solution **new_expand_solutions(const problem *prob,
        solution** sols, int n_sols, int *out_n_sols){
    int csize = sols[0]->n_facilities;
    size_t fsol_size = sizeof(futuresol)+sizeof(short)*(csize+1);
    void *futuresols = safe_malloc(fsol_size*n_sols*prob->n_facilities);
    int n_futuresols = 0;
    // Create solutions for the next iteration.
    for(int i=0;i<n_sols;i++){
        assert(sols[i]->n_facilities==csize);
        for(short f=0;f<prob->n_facilities;f++){
            futuresol *fsol = (futuresol *)(futuresols+fsol_size*n_futuresols);
            // Create a potential future solution, with the old one and adding a facility.
            fsol->origin = sols[i];
            fsol->newf = f;
            fsol->hash = hash_int(fsol->newf);
            fsol->n_facilities = csize;
            // Copy its facilities, and check if f already exists.
            int f_is_new=1;
            for(int k=0;k<csize;k++){
                if(sols[i]->facilities[k]==f){
                    f_is_new = 0;
                    break;
                }
                fsol->facilities[k] = sols[i]->facilities[k];
                fsol->hash = fsol->hash ^ hash_int(sols[i]->facilities[k]);
            }
            if(!f_is_new) continue;
            add_to_sorted(fsol->facilities,&fsol->n_facilities,f);
            n_futuresols += 1;
        }
    }
    // Sort futuresols to detect the ones that are the same faster.
    qsort(futuresols,n_futuresols,fsol_size,futuresol_cmp);
    int new_n_futuresols = 0;
    futuresol *last_fsol = NULL;
    for(int r=0;r<n_futuresols;r++){
        futuresol *fsol = (futuresol *)(futuresols+fsol_size*r);
        // Compare fsol with the last_fsol:
        int ftsol_cmp = 0;
        if(last_fsol!=NULL) ftsol_cmp = futuresol_cmp(last_fsol,fsol);
        // Check if fsol creates a brave new solution.
        if(last_fsol==NULL || ftsol_cmp!=0){
            futuresol *next_pos = (futuresol *)
                (futuresols+fsol_size*new_n_futuresols);
            memcpy(next_pos,fsol,fsol_size);
            last_fsol = next_pos;
            new_n_futuresols += 1;
        }
        /* Check if fsol doesn't create a new solution but creates it from a better one, in that case fsol replaces last_fsol. Because the new
        solution should be better that the better one that generates it */
        if(last_fsol!=NULL && ftsol_cmp==0){
            int is_better = fsol->origin->value>last_fsol->origin->value;
            if(is_better) memcpy(last_fsol,fsol,fsol_size);
        }
    }
    n_futuresols = new_n_futuresols;
    // Create the new solutions:
    solution **out_sols = safe_malloc(sizeof(solution*)*n_futuresols);
    *out_n_sols = 0;
    for(int r=0;r<n_futuresols;r++){
        futuresol *fsol = (futuresol *)(futuresols+fsol_size*r);
        solution *new_sol = safe_malloc(sizeof(solution));
        *new_sol = *fsol->origin;
        lint delta = solution_add(prob,new_sol,fsol->newf);
        #ifdef PRINT_EXPANSIONS
        printf("#EXPAND {");
            for(int k=0;k<new_sol->n_facilities;k++){
                printf("%d",new_sol->facilities[k]);
                if(k<new_sol->n_facilities-1) printf(",");
            }
            printf("} :%lld %lld\n",new_sol->value,delta);
        #endif
        if(delta<=0){
            free(new_sol);
            continue;
        }
        out_sols[*out_n_sols] = new_sol;
        *out_n_sols += 1;
    }
    free(futuresols);
    return out_sols;
}

// Reduces an array (sols) with pointers to a set of solutions to target_n size, freeing memory of the discarted ones. *n_sols is modified.
void reduce_solutions(const problem *prob,
        solution **sols, int *n_sols, int target_n, int vision_range){
    // If the vision range is -1, use random selection.
    if(vision_range==-1 && *n_sols>target_n){
        // Put target_n randomly selected solutions first on the array:
        for(int i=0;i<target_n;i++){
            int choice = i+rand()%(*n_sols-i);
            solution *aux = sols[i];
            sols[i] = sols[choice];
            sols[choice] = aux;
        }
        // Free other solutions:
        for(int i=target_n;i<*n_sols;i++){
            free(sols[i]);
        }
        // Set the amount of solutions right.
        *n_sols = target_n;
        return;
    }
    // Ensure that the vision_range isn't larger than the number of solutions.
    if(vision_range>*n_sols) vision_range = *n_sols;
    // Sort solution pointers from larger to smaller value of the solution.
    qsort(sols,*n_sols,sizeof(solution*),solution_value_cmp_inv);
    #ifdef VERBOSE
        printf("#BASESORTED\n");
        print_solsets(sols,*n_sols);
    #endif
    // Return if there is no need of reduction.
    if(*n_sols<=target_n) return;
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
            dissimpair pair;
            pair.indx_a = i;
            pair.indx_b = i+j;
            pair.dissim = solution_dissimilitude(prob,
                sols[pair.indx_a],sols[pair.indx_b]);
            #ifdef PAIR_DISTANCE
            printf("#INITIAL DISSIM %d(%lld) %d(%lld) %llu\n",
                pair.indx_a,sols[pair.indx_a]->value,
                pair.indx_b,sols[pair.indx_b]->value,
                pair.dissim);
            #endif
            heap_add(heap,&n_pairs,pair);
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
            #ifdef PAIR_DISTANCE
            // Get the distance on the linked list of the solutions of the pair:
            // NOTE: this may be expensive to do.
            int idx = pair.indx_a;
            int llist_dist = 0;
            while(idx != pair.indx_b){
                idx = nexts[idx];
                assert(idx!=-1);
                llist_dist++;
            }
            // Print the indexes, dissimilitude and distance in the linked list:
            int n_base = sols[pair.indx_a]->n_facilities;
            printf("#DIST %d %d %d %llu %d\n",
                n_base,pair.indx_a,pair.indx_b,pair.dissim,llist_dist);
            #endif
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
                    #ifdef PAIR_DISTANCE
                    printf("#REPLACEMENT DISSIM %d(%lld) %d(%lld) %llu\n",
                        pair.indx_a,sols[pair.indx_a]->value,
                        pair.indx_b,sols[pair.indx_b]->value,
                        pair.dissim);
                    #endif
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
        int pool_size, int vision_range, int *final_n, int *n_iterations){
    //
    printf("Computing 'nearest' table optimization...\n");
    problem_compute_nearest(prob);
    // Place to store all the pools:
    int pools_size[MAX_FACILITIES+1];
    for(int i=0;i<MAX_FACILITIES+1;i++) pools_size[i] = 0;
    solution **pools[MAX_FACILITIES+1];
    for(int i=0;i<MAX_FACILITIES+1;i++) pools[i] = NULL;
    // Create the first pool:
    solution empt = empty_solution();
    solution *pool0[1];
    pool0[0] = &empt;
    pools[0] = pool0;
    pools_size[0] = 1;
    // Create all the next pools:
    *n_iterations = -1;
    int total_pools_size = 0;
    int STEPS = MAX_SOL_SIZE<MAX_FACILITIES? MAX_SOL_SIZE:MAX_FACILITIES;
    for(int i=1;i<=STEPS;i++){
        printf("Expanding %d solutions of size %d...\n",pools_size[i-1],i-1);
        pools[i] = new_expand_solutions(prob, pools[i-1],
            pools_size[i-1], &pools_size[i]);
        #ifdef VERBOSE
            printf("#BASE %d %d\n",i,pools_size[i]);
            print_solsets(pools[i],pools_size[i]);
        #endif
        if(pools_size[i]==0){
            *n_iterations = i;
            printf("No more valuable solutions of size %d!\n",i);
            break;
        }
        printf("Reducing %d solutions of size %d...\n",pools_size[i],i);
        #ifndef EXTENSIVE_VR_TEST_STEP
            // Apply reduction on the pool:
            reduce_solutions(prob, pools[i], &pools_size[i],
                pool_size, vision_range);
        #else
            // Create a copy of the whole pool.
            int sols_size_c = pools_size[i];
            solution **sols_c = safe_malloc(sizeof(solution*)*sols_size_c);
            for(int k=0;k<sols_size_c;k++){
                sols_c[k] = safe_malloc(sizeof(solution));
                memcpy(sols_c[k],pools[i][k],sizeof(solution));
            }
            // Apply reduction on the pool:
            reduce_solutions(prob, pools[i], &pools_size[i],
                pool_size, vision_range);
            //Perform tests for several vision ranges:
            int vrmax = vision_range;
            #ifdef EXTENSIVE_VR_TEST_MAX
                if(vrmax>EXTENSIVE_VR_TEST_MAX) vrmax = EXTENSIVE_VR_TEST_MAX;
            #endif
            for(int p=0; p<vrmax; p+=EXTENSIVE_VR_TEST_STEP){
                // ^ Repeat for several vision ranges.
                if(p==1) continue;
                int vision_range_x = (p==0)? 1:p;
                int sols_size_x = sols_size_c;
                // Create a copy (x) of the whole pool.
                solution **sols_x = safe_malloc(sizeof(solution*)*sols_size_c);
                for(int k=0;k<sols_size_x;k++){
                    sols_x[k] = safe_malloc(sizeof(solution));
                    memcpy(sols_x[k],sols_c[k],sizeof(solution));
                }
                // Reduce the copy (x) with the vrange:
                reduce_solutions(prob,sols_x, &sols_size_x,
                    pool_size, vision_range_x);
                // Compute how many of the solutions with the vision_range
                // remained on the reduction with vision_range_x:
                int remained = 0;
                assert(pools_size[i]==sols_size_x);
                int p_start_x = 0;
                for(int k=0;k<pools_size[i];k++){
                    int r = p_start_x;
                    while(r<sols_size_x){
                        if(sols_x[r]->value>pools[i][k]->value){
                            p_start_x += 1;
                            assert(p_start_x==r+1);
                        }else if(sols_x[r]->value<pools[i][k]->value){
                            break;
                        }
                        if(solution_dissimilitude(prob,
                                pools[i][k],sols_x[r])==0){
                            remained += 1;
                        }
                        r+=1;
                    }
                }
                // Free solutions of copy(x):
                for(int k=0;k<sols_size_x;k++){
                    free(sols_x[k]);
                }
                free(sols_x);
                float remradio = (float)remained/(float)sols_size_x;
                printf("#REMAINED %d %d from %d to %d with vr %d radio %.5f\n",
                    i,remained,sols_size_c,sols_size_x,vision_range_x,remradio);
            }
            // Free copy of the whole pool.
            for(int k=0;k<sols_size_c;k++){
                free(sols_c[k]);
            }
            free(sols_c);
        #endif
        // Realloc to reduce memory usage:
        pools[i] = realloc(pools[i],sizeof(solution*)*pools_size[i]);
        //
        #ifdef VERBOSE
            printf("#POOL %d %d\n",i,pools_size[i]);
            print_solsets(pools[i],pools_size[i]);
        #endif
        total_pools_size += pools_size[i];
        //
        if(i==STEPS){
            printf("MAX_SOL_SIZE reached.\n");
        }
    }
    if(*n_iterations==-1) *n_iterations = MAX_SOL_SIZE;
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

void local_search_solutions(problem* prob, solution **sols, int *n_sols){
    printf("Performing local search for %d solutions...\n",*n_sols);
    // Perform HC for each solution:
    for(int i=0;i<*n_sols;i++){
        solution enhanced = solution_hill_climbing(prob,*sols[i]);
        if(sols[i]->value!=enhanced.value){
            printf("sol %d: %lld -> %lld\n",i,sols[i]->value,enhanced.value);
        }
        *sols[i] = enhanced;
    }
    printf("Deleting repeated solutions...\n");
    // Sort solution pointers to indenfify repeated solutions (also in decreasing value).
    qsort(sols,*n_sols,sizeof(solution*),solution_cmp);
    // Detect and delete repeated solutions:
    int n_final = 0;
    for(int i=1;i<*n_sols;i++){
        if(solution_cmp(&sols[n_final],&sols[i])!=0){
            n_final++;
            *sols[n_final] = *sols[i];
        }
    }
    for(int k=n_final;k<*n_sols;k++){
        free(sols[k]);
    }
    printf("Local search reduced %d solutions to %d local optima.\n",*n_sols,n_final);
    *n_sols = n_final;
}
