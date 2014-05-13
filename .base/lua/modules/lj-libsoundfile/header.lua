return [[
typedef	struct SNDFILE_tag	SNDFILE ;
typedef __int64		sf_count_t ;
struct SF_INFO
{	sf_count_t	frames ;
	int			samplerate ;
	int			channels ;
	int			format ;
	int			sections ;
	int			seekable ;
} ;
typedef	struct SF_INFO SF_INFO ;
typedef struct
{	int			format ;
	const char	*name ;
	const char	*extension ;
} SF_FORMAT_INFO ;

typedef struct
{	int			type ;
	double		level ;
	const char	*name ;
} SF_DITHER_INFO ;
typedef struct
{	sf_count_t	offset ;
	sf_count_t	length ;
} SF_EMBED_FILE_INFO ;

typedef struct
{	int gain ;
	char basenote, detune ;
	char velocity_lo, velocity_hi ;
	char key_lo, key_hi ;
	int loop_count ;
	struct
	{	int mode ;
		unsigned int start ;
		unsigned int end ;
		unsigned int count ;
	} loops [16] ;
} SF_INSTRUMENT ;
typedef struct
{
	short	time_sig_num ;
	short	time_sig_den ;
	int		loop_mode ;
	int		num_beats ;
	float	bpm ;
	int	root_key ;
	int future [6] ;
} SF_LOOP_INFO ;
typedef struct { char description [256] ; char originator [32] ; char originator_reference [32] ; char origination_date [10] ; char origination_time [8] ; unsigned int time_reference_low ; unsigned int time_reference_high ; short version ; char umid [64] ; char reserved [190] ; unsigned int coding_history_size ; char coding_history [256] ; } SF_BROADCAST_INFO ;
typedef sf_count_t		(*sf_vio_get_filelen)	(void *user_data) ;
typedef sf_count_t		(*sf_vio_seek)		(sf_count_t offset, int whence, void *user_data) ;
typedef sf_count_t		(*sf_vio_read)		(void *ptr, sf_count_t count, void *user_data) ;
typedef sf_count_t		(*sf_vio_write)		(const void *ptr, sf_count_t count, void *user_data) ;
typedef sf_count_t		(*sf_vio_tell)		(void *user_data) ;
struct SF_VIRTUAL_IO
{	sf_vio_get_filelen	get_filelen ;
	sf_vio_seek			seek ;
	sf_vio_read			read ;
	sf_vio_write		write ;
	sf_vio_tell			tell ;
} ;
typedef	struct SF_VIRTUAL_IO SF_VIRTUAL_IO ;
SNDFILE* 	sf_open		(const char *path, int mode, SF_INFO *sfinfo) ;
SNDFILE* 	sf_open_fd	(int fd, int mode, SF_INFO *sfinfo, int close_desc) ;
SNDFILE* 	sf_open_virtual	(SF_VIRTUAL_IO *sfvirtual, int mode, SF_INFO *sfinfo, void *user_data) ;
int		sf_error		(SNDFILE *sndfile) ;
const char* sf_strerror (SNDFILE *sndfile) ;
const char*	sf_error_number	(int errnum) ;
int		sf_perror		(SNDFILE *sndfile) ;
int		sf_error_str	(SNDFILE *sndfile, char* str, size_t len) ;
int		sf_command	(SNDFILE *sndfile, int command, void *data, int datasize) ;
int		sf_format_check	(const SF_INFO *info) ;
sf_count_t	sf_seek 		(SNDFILE *sndfile, sf_count_t frames, int whence) ;
int sf_set_string (SNDFILE *sndfile, int str_type, const char* str) ;
const char* sf_get_string (SNDFILE *sndfile, int str_type) ;
const char * sf_version_string (void) ;
sf_count_t	sf_read_raw		(SNDFILE *sndfile, void *ptr, sf_count_t bytes) ;
sf_count_t	sf_write_raw 	(SNDFILE *sndfile, const void *ptr, sf_count_t bytes) ;
sf_count_t	sf_readf_short	(SNDFILE *sndfile, short *ptr, sf_count_t frames) ;
sf_count_t	sf_writef_short	(SNDFILE *sndfile, const short *ptr, sf_count_t frames) ;
sf_count_t	sf_readf_int	(SNDFILE *sndfile, int *ptr, sf_count_t frames) ;
sf_count_t	sf_writef_int 	(SNDFILE *sndfile, const int *ptr, sf_count_t frames) ;
sf_count_t	sf_readf_float	(SNDFILE *sndfile, float *ptr, sf_count_t frames) ;
sf_count_t	sf_writef_float	(SNDFILE *sndfile, const float *ptr, sf_count_t frames) ;
sf_count_t	sf_readf_double		(SNDFILE *sndfile, double *ptr, sf_count_t frames) ;
sf_count_t	sf_writef_double	(SNDFILE *sndfile, const double *ptr, sf_count_t frames) ;
sf_count_t	sf_read_short	(SNDFILE *sndfile, short *ptr, sf_count_t items) ;
sf_count_t	sf_write_short	(SNDFILE *sndfile, const short *ptr, sf_count_t items) ;
sf_count_t	sf_read_int		(SNDFILE *sndfile, int *ptr, sf_count_t items) ;
sf_count_t	sf_write_int 	(SNDFILE *sndfile, const int *ptr, sf_count_t items) ;
sf_count_t	sf_read_float	(SNDFILE *sndfile, float *ptr, sf_count_t items) ;
sf_count_t	sf_write_float	(SNDFILE *sndfile, const float *ptr, sf_count_t items) ;
sf_count_t	sf_read_double	(SNDFILE *sndfile, double *ptr, sf_count_t items) ;
sf_count_t	sf_write_double	(SNDFILE *sndfile, const double *ptr, sf_count_t items) ;
int		sf_close		(SNDFILE *sndfile) ;
void	sf_write_sync	(SNDFILE *sndfile) ;
]]