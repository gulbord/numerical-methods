#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define PRE_ARGS 2
#define BUF_SIZE 0x10000

int count_lines(FILE *file)
{
    char buffer[BUF_SIZE];
    int counter = 0;
    while (1) {
        size_t num_read = fread(buffer, 1, BUF_SIZE, file);
        if (ferror(file))
            return -1;

        for (size_t i = 0; i < num_read; ++i)
            if (buffer[i] == '\n')
                ++counter;

        if (feof(file))
            break;
    }

    return counter;
}

double extract_beta(const char *fname)
{
    // Look for 'T' in the file name
    const char *t_pos = strchr(fname, 'T');
    if (t_pos == NULL) {
        fprintf(stderr, "No temperature info in file name %s\n", fname);
        return -1;
    }

    // Extract the number following 'T'
    char *end;
    double beta = 1.0 / strtod(t_pos + 1, &end);
    if (end == t_pos + 1) {
        fprintf(stderr, "Invalid temperature format in file name %s\n", fname);
        return -1;
    }

    return beta;
}

void rescale(double *z, int n)
{
    double min = z[0];
    double max = min;
    for (int i = 1; i < n; ++i) {
        if (z[i] > max)
            max = z[i];
        else if (z[i] < min)
            min = z[i];
    }

    double scale = sqrt(min * max);
    for (int i = 0; i < n; ++i)
        z[i] /= scale;
}

int main(int argc, const char **argv)
{
    if (argc < PRE_ARGS + 1) {
        fprintf(stderr, "Usage: %s <tolerance> <file1> <file2> ...\n", argv[0]);
        return 1;
    }

    double tol = atof(argv[1]);
    int num_betas = argc - PRE_ARGS;
    const char **fnames = argv + PRE_ARGS;
    FILE **files = malloc(num_betas * sizeof(*files));
    double *betas = malloc(num_betas * sizeof(*betas));

    // Open every file for reading and parse temperatures
    for (int i = 0; i < num_betas; ++i) {
        files[i] = fopen(fnames[i], "r");
        if (files[i] == NULL) {
            fprintf(stderr, "Error opening file: %s\n", fnames[i]);
            for (int j = 0; j < i; ++j)
                fclose(files[j]);
            free(files);
            free(betas);
            return 1;
        }

        betas[i] = extract_beta(fnames[i]);
        if (betas[i] < 0.0) {
            for (int j = 0; j < i; ++j)
                fclose(files[j]);
            free(files);
            free(betas);
            return 1;
        }
    }

    int num_samples = count_lines(files[0]) - 1;
    if (num_samples < 1) {
        fprintf(stderr, "Error: file %s is empty\n", fnames[0]);
        for (int i = 0; i < num_betas; ++i)
            fclose(files[i]);
        free(files);
        free(betas);
        return 1;
    }

    rewind(files[0]); // Go back to file start after counting lines
    int(*energies)[num_samples] = malloc(num_betas * sizeof(*energies));

    // Read and store energy values from each file
    for (int i = 0; i < num_betas; ++i) {
        // Skip header file
        char header[0x100];
        if (fgets(header, sizeof(header), files[i]) == NULL) {
            fprintf(stderr, "Error: file %s is empty\n", fnames[i]);
            for (int k = 0; k < num_betas; ++k)
                fclose(files[k]);
            free(files);
            free(betas);
            free(energies);
            return 1;
        }

        int magnet;
        for (int j = 0; j < num_samples; ++j) {
            if (fscanf(files[i], "%d,%d", &energies[i][j], &magnet) != 2) {
                fprintf(stderr, "Error reading row %d from file: %s\n", j + 1,
                        fnames[i]);
                for (int k = 0; k < num_betas; ++k)
                    fclose(files[k]);
                free(files);
                free(betas);
                free(energies);
                return 1;
            }
        }
    }

    double *z_old = malloc(num_betas * sizeof(*z_old));
    double *z_new = malloc(num_betas * sizeof(*z_new));
    // Initialize with ones
    for (int i = 0; i < num_betas; ++i)
        z_old[i] = 1.0;

    while (1) {
        rescale(z_old, num_betas);

        // Self-consistent equations to fill z_new
        for (int k = 0; k < num_betas; ++k) {
            z_new[k] = 0.0;
            for (int i = 0; i < num_betas; ++i) {
                for (int n = 0; n < num_samples; ++n) {
                    double denom = 0.0;
                    for (int j = 0; j < num_betas; ++j)
                        denom += exp((betas[0] - betas[j]) * energies[i][n] -
                                     log(z_old[j]) + log(z_old[0]));
                    denom *= exp((betas[k] - betas[0]) * energies[i][n] -
                                 log(z_old[0]));
                    z_new[k] += 1.0 / denom;
                }
            }
            z_new[k] /= num_samples;
        }

        // Check for convergence
        double delta = 0.0;
        for (int i = 0; i < num_betas; ++i)
            delta += (1.0 - z_old[i] / z_new[i]) * (1.0 - z_old[i] / z_new[i]);
        if (delta < tol)
            break;

        // Set z_old = z_new
        for (int i = 0; i < num_betas; ++i)
            z_old[i] = z_new[i];
    };

    // Print results
    for (int i = 0; i < num_betas; ++i)
        printf("%f\n", z_new[i]);

    for (int i = 0; i < num_betas; ++i)
        fclose(files[i]);
    free(files);
    free(betas);
    free(energies);
    free(z_old);
    free(z_new);

    return 0;
}
