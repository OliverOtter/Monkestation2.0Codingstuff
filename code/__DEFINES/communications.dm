/// The time an admin has to cancel a cross-sector message
#define CROSS_SECTOR_CANCEL_TIME (10 SECONDS)

/// The extended time an admin has to cancel a cross-sector message if they pass the filter, for instance
#define EXTENDED_CROSS_SECTOR_CANCEL_TIME (30 SECONDS)

//Security levels affect the escape shuttle timer
/// Security level is green. (no threats)
#define SEC_LEVEL_GREEN 0
/// Security level is blue. (caution advised)
#define SEC_LEVEL_BLUE 1
/// Security level is red. (hostile threats)
#define SEC_LEVEL_RED 2
/// Security level is delta. (station destruction immiment)
#define SEC_LEVEL_DELTA 3
//MONKESTATION EDIT START
// Security level is epsilon. (yall fucked up)
#define SEC_LEVEL_EPSILON 4
/// Security level is yellow. (Engineering issue)
#define SEC_LEVEL_YELLOW 1
/// Security level is amber. (biological issue, so virus, blob, or bloodlings)
#define SEC_LEVEL_VIOLET 1
/// Security level is gamma. (Its like red alert, but CC flavored)
#define SEC_LEVEL_GAMMA 2
/// Security level is lambda. (oh god eldtrich beings won the video game)
#define SEC_LEVEL_LAMBDA 3
//MONKESTATION EDIT STOP
