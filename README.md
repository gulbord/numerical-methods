All the source codes are located in the `src` directory, the output files in
`out` and the executables in `exe`. Each `makefile` ending in `.6`, `.7`, etc.
is configured to compile the codes corresponding to the respective exercise set,
the 6th, the 7th and so on. PRNGs and other utilities are inside the `lib`
directory.

To compile with `makefile.<number>`, you can run `make <number>`. To clean only
the executables pertaining to that set of exercises, you can run `make
<number>c`. For example, `make 6` compiles the Metropolis algorithm codes and
`make 6c` cleans the corresponding executables.

The `src` directory also contains some R scripts to generate the figures that
are included in the LaTeX documents. They are saved in `tex/img`.
