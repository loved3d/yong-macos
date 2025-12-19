//
//  yong_engine.h
//  yong-macos
//
//  C interface to yong input method engine
//

#ifndef yong_engine_h
#define yong_engine_h

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef __cplusplus
extern "C" {
#endif

// Maximum number of candidates to return
#define MAX_CANDIDATES 9

// Initialize the yong engine
int yong_engine_init(void);

// Clean up the yong engine
void yong_engine_cleanup(void);

// Get candidates for the given input
// Returns the number of candidates found
// candidates: array of strings to be filled with results
// max_count: maximum number of candidates to return
int yong_engine_get_candidates(const char *input, char **candidates, int max_count);

// Free candidates memory
void yong_engine_free_candidates(char **candidates, int count);

#ifdef __cplusplus
}
#endif

#endif /* yong_engine_h */
