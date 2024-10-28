/// The time an admin has to cancel a cross-sector message
#define CROSS_SECTOR_CANCEL_TIME (10 SECONDS)

/// The extended time an admin has to cancel a cross-sector message if they pass the filter, for instance
#define EXTENDED_CROSS_SECTOR_CANCEL_TIME (30 SECONDS)

//Security levels affect the escape shuttle timer
/// Security level is green. (no threats)
#define SEC_LEVEL_GREEN 0
/// Security level is blue. (caution advised)
#define SEC_LEVEL_BLUE 1
/// Security level is yellow. (Engineering issue) MONKESTATION EDIT
#define SEC_LEVEL_YELLOW 1
/// Security level is amber. (biological issue, so blob or bloodlings) MONKESTATION EDIT
#define SEC_LEVEL_AMBER 1
/// Security level is red. (hostile threats)
#define SEC_LEVEL_RED 4
/// Security level is gamma. (Its like red alert, but CC flavored) MONKESTATION EDIT
#define SEC_LEVEL_GAMMA 4
/// Security level is delta. (station destruction immiment)
#define SEC_LEVEL_DELTA 5
/// Security level is lambda. (oh god eldtrich beings won the video game) MONKESTATION EDIT
#define SEC_LEVEL_LAMBDA 5
// Security level is epsilon. (yall fucked up) MONKESTATION EDIT
#define SEC_LEVEL_EPSILON 6
