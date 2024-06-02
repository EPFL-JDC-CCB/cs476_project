//#define COMPRESSED
//#define ORIG

#ifdef COMPRESSED
#include "biosOld_compressed.h"
#elif ORIG
#include "biosOld_orig.h"
#else
#include "biosOld_default.h"
#endif