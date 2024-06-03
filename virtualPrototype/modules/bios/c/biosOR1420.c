//#define COMPRESSED
//#define ORIG

#define biosNextChar get_rs232_blocking

#ifdef COMPRESSED
#include "biosOR1420_compressed.h"
#elif ORIG
#include "biosOR1420_orig.h"
#else
#include "biosOR1420_default.h"
#endif