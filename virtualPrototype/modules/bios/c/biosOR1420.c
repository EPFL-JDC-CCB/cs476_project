//#define COMPRESSED
//#define ORIG

#ifdef COMPRESSED
#include "biosOR1420_compressed.h"
#elif ORIG
#include "biosOR1420_orig.h"
#else
#include "biosOR1420_default.h"
#endif