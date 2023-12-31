#include "gillespie.h"
#include "../../lib/mt19937ar.h"
#include <math.h>
#include <stdlib.h>

void init_state_list(struct state *head, int *pops, size_t p_size)
{
    // fill `head` values
    head->p_size = p_size;
    head->pops = malloc(p_size * sizeof(int));
    for (size_t i = 0; i < p_size; ++i)
        head->pops[i] = pops[i];
    head->time = 0.0;

    // set pointer to non-existent (yet) next item to NULL
    head->next = NULL;
}

void update_state_list(struct state **head, int *pops, double time)
{
    struct state *tmp = malloc(sizeof(struct state));

    // fill the new state values
    tmp->p_size = (*head)->p_size;
    tmp->pops = malloc(tmp->p_size * sizeof(int));
    for (size_t i = 0; i < tmp->p_size; ++i)
        tmp->pops[i] = pops[i];
    tmp->time = time;

    // make `tmp` the new head pointer
    tmp->next = *head;
    *head = tmp;
}

void write_state_list(struct state *head, FILE *file)
{
    struct state *tmp = head;

    size_t i, ps = head->p_size;
    while (tmp != NULL) {
        fprintf(file, "%.10f,", tmp->time);
        for (i = 0; i < ps; ++i)
            fprintf(file, "%d%c", tmp->pops[i], i == ps - 1 ? '\n' : ',');
        tmp = tmp->next;
    }
}

void free_state_list(struct state *head)
{
    struct state *tmp = head;

    // if head == NULL the list is already empty
    while (head != NULL) {
        tmp = head;
        head = head->next; // move to next with `head`
        free(tmp->pops);   // `tmp` points to prev, so we can free
        free(tmp);
    }
}

void gillespie(struct state **head, rate_ptr *rate_fns, double *rate_con,
               reac_ptr *reac_fns, int n_react, double max_time)
{
    // rate array to be updated at every iteration
    double rates[n_react];
    // int array to momentarily hold the updated state
    int new_pops[(*head)->p_size];
    int *cur_pops; // just for clarity

    double esc_rate, tau, thr, sum, tot_time = 0.0;
    int i, pick;

    while (tot_time < max_time) {
        // update current populations
        cur_pops = (*head)->pops;

        // calculate the escape rate by looping over rate functions
        esc_rate = 0.0;
        for (i = 0; i < n_react; ++i) {
            rates[i] = rate_fns[i](rate_con, cur_pops);
            esc_rate += rates[i];
        }

        // calculate the residence time and check if we are past the maximum
        tau = -log(genrand_real3()) / esc_rate;
        if (tot_time + tau > max_time)
            break;

        // pick a reaction with probability ~ rate_i / esc_rate
        thr = genrand_real1() * esc_rate;
        sum = 0.0;
        pick = n_react - 1; // if you never reach thr, pick the last
        for (i = 0; i < n_react; ++i) {
            sum += rates[i];
            if (sum > thr) {
                pick = i;
                break;
            }
        }

        // update the elapsed time
        tot_time += tau;

        // update the state according to the chosen reaction
        reac_fns[pick](cur_pops, new_pops);
        update_state_list(head, new_pops, tot_time);
    }
}
