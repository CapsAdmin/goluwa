				local ffi = require("ffi")
				local lib = assert(ffi.load("libarchive"))
				ffi.cdef([[struct archive {};
struct archive_entry {};
struct archive_acl {};
struct archive_entry_linkresolver {};
char*(archive_entry_acl_to_text)(struct archive_entry*,long*,int);
const char*(archive_bzlib_version)();
const char*(archive_compression_name)(struct archive*);
const char*(archive_entry_acl_text)(struct archive_entry*,int);
const char*(archive_entry_copy_fflags_text)(struct archive_entry*,const char*);
const char*(archive_entry_fflags_text)(struct archive_entry*);
const char*(archive_entry_gname)(struct archive_entry*);
const char*(archive_entry_gname_utf8)(struct archive_entry*);
const char*(archive_entry_hardlink)(struct archive_entry*);
const char*(archive_entry_hardlink_utf8)(struct archive_entry*);
const char*(archive_entry_pathname)(struct archive_entry*);
const char*(archive_entry_pathname_utf8)(struct archive_entry*);
const char*(archive_entry_sourcepath)(struct archive_entry*);
const char*(archive_entry_strmode)(struct archive_entry*);
const char*(archive_entry_symlink)(struct archive_entry*);
const char*(archive_entry_symlink_utf8)(struct archive_entry*);
const char*(archive_entry_uname)(struct archive_entry*);
const char*(archive_entry_uname_utf8)(struct archive_entry*);
const char*(archive_error_string)(struct archive*);
const char*(archive_filter_name)(struct archive*,int);
const char*(archive_format_name)(struct archive*);
const char*(archive_liblz4_version)();
const char*(archive_liblzma_version)();
const char*(archive_libzstd_version)();
const char*(archive_read_disk_gname)(struct archive*,signed long);
const char*(archive_read_disk_uname)(struct archive*,signed long);
const char*(archive_version_details)();
const char*(archive_version_string)();
const char*(archive_zlib_version)();
const int*(archive_entry_acl_text_w)(struct archive_entry*,int);
const int*(archive_entry_copy_fflags_text_w)(struct archive_entry*,const int*);
const int*(archive_entry_gname_w)(struct archive_entry*);
const int*(archive_entry_hardlink_w)(struct archive_entry*);
const int*(archive_entry_pathname_w)(struct archive_entry*);
const int*(archive_entry_sourcepath_w)(struct archive_entry*);
const int*(archive_entry_symlink_w)(struct archive_entry*);
const int*(archive_entry_uname_w)(struct archive_entry*);
const struct stat*(archive_entry_stat)(struct archive_entry*);
const unsigned char*(archive_entry_digest)(struct archive_entry*,int);
const void*(archive_entry_mac_metadata)(struct archive_entry*,unsigned long*);
int*(archive_entry_acl_to_text_w)(struct archive_entry*,long*,int);
int(archive_compression)(struct archive*);
int(archive_entry_acl_add_entry)(struct archive_entry*,int,int,int,int,const char*);
int(archive_entry_acl_add_entry_w)(struct archive_entry*,int,int,int,int,const int*);
int(archive_entry_acl_count)(struct archive_entry*,int);
int(archive_entry_acl_from_text)(struct archive_entry*,const char*,int);
int(archive_entry_acl_from_text_w)(struct archive_entry*,const int*,int);
int(archive_entry_acl_next)(struct archive_entry*,int,int*,int*,int*,int*,const char**);
int(archive_entry_acl_reset)(struct archive_entry*,int);
int(archive_entry_acl_types)(struct archive_entry*);
int(archive_entry_atime_is_set)(struct archive_entry*);
int(archive_entry_birthtime_is_set)(struct archive_entry*);
int(archive_entry_ctime_is_set)(struct archive_entry*);
int(archive_entry_dev_is_set)(struct archive_entry*);
int(archive_entry_ino_is_set)(struct archive_entry*);
int(archive_entry_is_data_encrypted)(struct archive_entry*);
int(archive_entry_is_encrypted)(struct archive_entry*);
int(archive_entry_is_metadata_encrypted)(struct archive_entry*);
int(archive_entry_mtime_is_set)(struct archive_entry*);
int(archive_entry_size_is_set)(struct archive_entry*);
int(archive_entry_sparse_count)(struct archive_entry*);
int(archive_entry_sparse_next)(struct archive_entry*,signed long*,signed long*);
int(archive_entry_sparse_reset)(struct archive_entry*);
int(archive_entry_symlink_type)(struct archive_entry*);
int(archive_entry_update_gname_utf8)(struct archive_entry*,const char*);
int(archive_entry_update_hardlink_utf8)(struct archive_entry*,const char*);
int(archive_entry_update_link_utf8)(struct archive_entry*,const char*);
int(archive_entry_update_pathname_utf8)(struct archive_entry*,const char*);
int(archive_entry_update_symlink_utf8)(struct archive_entry*,const char*);
int(archive_entry_update_uname_utf8)(struct archive_entry*,const char*);
int(archive_entry_xattr_count)(struct archive_entry*);
int(archive_entry_xattr_next)(struct archive_entry*,const char**,const void**,unsigned long*);
int(archive_entry_xattr_reset)(struct archive_entry*);
int(archive_errno)(struct archive*);
int(archive_file_count)(struct archive*);
int(archive_filter_code)(struct archive*,int);
int(archive_filter_count)(struct archive*);
int(archive_format)(struct archive*);
int(archive_free)(struct archive*);
int(archive_match_exclude_entry)(struct archive*,int,struct archive_entry*);
int(archive_match_exclude_pattern)(struct archive*,const char*);
int(archive_match_exclude_pattern_from_file)(struct archive*,const char*,int);
int(archive_match_exclude_pattern_from_file_w)(struct archive*,const int*,int);
int(archive_match_exclude_pattern_w)(struct archive*,const int*);
int(archive_match_excluded)(struct archive*,struct archive_entry*);
int(archive_match_free)(struct archive*);
int(archive_match_include_date)(struct archive*,int,const char*);
int(archive_match_include_date_w)(struct archive*,int,const int*);
int(archive_match_include_file_time)(struct archive*,int,const char*);
int(archive_match_include_file_time_w)(struct archive*,int,const int*);
int(archive_match_include_gid)(struct archive*,signed long);
int(archive_match_include_gname)(struct archive*,const char*);
int(archive_match_include_gname_w)(struct archive*,const int*);
int(archive_match_include_pattern)(struct archive*,const char*);
int(archive_match_include_pattern_from_file)(struct archive*,const char*,int);
int(archive_match_include_pattern_from_file_w)(struct archive*,const int*,int);
int(archive_match_include_pattern_w)(struct archive*,const int*);
int(archive_match_include_time)(struct archive*,int,long,long);
int(archive_match_include_uid)(struct archive*,signed long);
int(archive_match_include_uname)(struct archive*,const char*);
int(archive_match_include_uname_w)(struct archive*,const int*);
int(archive_match_owner_excluded)(struct archive*,struct archive_entry*);
int(archive_match_path_excluded)(struct archive*,struct archive_entry*);
int(archive_match_path_unmatched_inclusions)(struct archive*);
int(archive_match_path_unmatched_inclusions_next)(struct archive*,const char**);
int(archive_match_path_unmatched_inclusions_next_w)(struct archive*,const int**);
int(archive_match_set_inclusion_recursion)(struct archive*,int);
int(archive_match_time_excluded)(struct archive*,struct archive_entry*);
int(archive_read_add_callback_data)(struct archive*,void*,unsigned int);
int(archive_read_add_passphrase)(struct archive*,const char*);
int(archive_read_append_callback_data)(struct archive*,void*);
int(archive_read_append_filter)(struct archive*,int);
int(archive_read_append_filter_program)(struct archive*,const char*);
int(archive_read_append_filter_program_signature)(struct archive*,const char*,const void*,unsigned long);
int(archive_read_close)(struct archive*);
int(archive_read_data_block)(struct archive*,const void**,unsigned long*,signed long*);
int(archive_read_data_into_fd)(struct archive*,int);
int(archive_read_data_skip)(struct archive*);
int(archive_read_disk_can_descend)(struct archive*);
int(archive_read_disk_current_filesystem)(struct archive*);
int(archive_read_disk_current_filesystem_is_remote)(struct archive*);
int(archive_read_disk_current_filesystem_is_synthetic)(struct archive*);
int(archive_read_disk_descend)(struct archive*);
int(archive_read_disk_entry_from_file)(struct archive*,struct archive_entry*,int,const struct stat*);
int(archive_read_disk_open)(struct archive*,const char*);
int(archive_read_disk_open_w)(struct archive*,const int*);
int(archive_read_disk_set_atime_restored)(struct archive*);
int(archive_read_disk_set_behavior)(struct archive*,int);
int(archive_read_disk_set_matching)(struct archive*,struct archive*,void(*_excluded_func)(struct archive*,void*,struct archive_entry*),void*);
int(archive_read_disk_set_metadata_filter_callback)(struct archive*,int(*_metadata_filter_func)(struct archive*,void*,struct archive_entry*),void*);
int(archive_read_disk_set_standard_lookup)(struct archive*);
int(archive_read_disk_set_symlink_hybrid)(struct archive*);
int(archive_read_disk_set_symlink_logical)(struct archive*);
int(archive_read_disk_set_symlink_physical)(struct archive*);
int(archive_read_extract)(struct archive*,struct archive_entry*,int);
int(archive_read_extract2)(struct archive*,struct archive_entry*,struct archive*);
int(archive_read_finish)(struct archive*);
int(archive_read_format_capabilities)(struct archive*);
int(archive_read_free)(struct archive*);
int(archive_read_has_encrypted_entries)(struct archive*);
int(archive_read_next_header)(struct archive*,struct archive_entry**);
int(archive_read_next_header2)(struct archive*,struct archive_entry*);
int(archive_read_open)(struct archive*,void*,int(unknown_3)(struct archive*,void*),long(unknown_4)(struct archive*,void*,const void**),int(unknown_5)(struct archive*,void*));
int(archive_read_open1)(struct archive*);
int(archive_read_open2)(struct archive*,void*,int(unknown_3)(struct archive*,void*),long(unknown_4)(struct archive*,void*,const void**),signed long(unknown_5)(struct archive*,void*,signed long),int(unknown_6)(struct archive*,void*));
int(archive_read_open_FILE)(struct archive*,struct _IO_FILE*);
int(archive_read_open_fd)(struct archive*,int,unsigned long);
int(archive_read_open_file)(struct archive*,const char*,unsigned long);
int(archive_read_open_filename)(struct archive*,const char*,unsigned long);
int(archive_read_open_filename_w)(struct archive*,const int*,unsigned long);
int(archive_read_open_filenames)(struct archive*,const char**,unsigned long);
int(archive_read_open_memory)(struct archive*,const void*,unsigned long);
int(archive_read_open_memory2)(struct archive*,const void*,unsigned long,unsigned long);
int(archive_read_prepend_callback_data)(struct archive*,void*);
int(archive_read_set_callback_data)(struct archive*,void*);
int(archive_read_set_callback_data2)(struct archive*,void*,unsigned int);
int(archive_read_set_close_callback)(struct archive*,int(unknown_2)(struct archive*,void*));
int(archive_read_set_filter_option)(struct archive*,const char*,const char*,const char*);
int(archive_read_set_format)(struct archive*,int);
int(archive_read_set_format_option)(struct archive*,const char*,const char*,const char*);
int(archive_read_set_open_callback)(struct archive*,int(unknown_2)(struct archive*,void*));
int(archive_read_set_option)(struct archive*,const char*,const char*,const char*);
int(archive_read_set_options)(struct archive*,const char*);
int(archive_read_set_passphrase_callback)(struct archive*,void*,const char*(unknown_3)(struct archive*,void*));
int(archive_read_set_read_callback)(struct archive*,long(unknown_2)(struct archive*,void*,const void**));
int(archive_read_set_seek_callback)(struct archive*,signed long(unknown_2)(struct archive*,void*,signed long,int));
int(archive_read_set_skip_callback)(struct archive*,signed long(unknown_2)(struct archive*,void*,signed long));
int(archive_read_set_switch_callback)(struct archive*,int(unknown_2)(struct archive*,void*,void*));
int(archive_read_support_compression_all)(struct archive*);
int(archive_read_support_compression_bzip2)(struct archive*);
int(archive_read_support_compression_compress)(struct archive*);
int(archive_read_support_compression_gzip)(struct archive*);
int(archive_read_support_compression_lzip)(struct archive*);
int(archive_read_support_compression_lzma)(struct archive*);
int(archive_read_support_compression_none)(struct archive*);
int(archive_read_support_compression_program)(struct archive*,const char*);
int(archive_read_support_compression_program_signature)(struct archive*,const char*,const void*,unsigned long);
int(archive_read_support_compression_rpm)(struct archive*);
int(archive_read_support_compression_uu)(struct archive*);
int(archive_read_support_compression_xz)(struct archive*);
int(archive_read_support_filter_all)(struct archive*);
int(archive_read_support_filter_by_code)(struct archive*,int);
int(archive_read_support_filter_bzip2)(struct archive*);
int(archive_read_support_filter_compress)(struct archive*);
int(archive_read_support_filter_grzip)(struct archive*);
int(archive_read_support_filter_gzip)(struct archive*);
int(archive_read_support_filter_lrzip)(struct archive*);
int(archive_read_support_filter_lz4)(struct archive*);
int(archive_read_support_filter_lzip)(struct archive*);
int(archive_read_support_filter_lzma)(struct archive*);
int(archive_read_support_filter_lzop)(struct archive*);
int(archive_read_support_filter_none)(struct archive*);
int(archive_read_support_filter_program)(struct archive*,const char*);
int(archive_read_support_filter_program_signature)(struct archive*,const char*,const void*,unsigned long);
int(archive_read_support_filter_rpm)(struct archive*);
int(archive_read_support_filter_uu)(struct archive*);
int(archive_read_support_filter_xz)(struct archive*);
int(archive_read_support_filter_zstd)(struct archive*);
int(archive_read_support_format_7zip)(struct archive*);
int(archive_read_support_format_all)(struct archive*);
int(archive_read_support_format_ar)(struct archive*);
int(archive_read_support_format_by_code)(struct archive*,int);
int(archive_read_support_format_cab)(struct archive*);
int(archive_read_support_format_cpio)(struct archive*);
int(archive_read_support_format_empty)(struct archive*);
int(archive_read_support_format_gnutar)(struct archive*);
int(archive_read_support_format_iso9660)(struct archive*);
int(archive_read_support_format_lha)(struct archive*);
int(archive_read_support_format_mtree)(struct archive*);
int(archive_read_support_format_rar)(struct archive*);
int(archive_read_support_format_rar5)(struct archive*);
int(archive_read_support_format_raw)(struct archive*);
int(archive_read_support_format_tar)(struct archive*);
int(archive_read_support_format_warc)(struct archive*);
int(archive_read_support_format_xar)(struct archive*);
int(archive_read_support_format_zip)(struct archive*);
int(archive_read_support_format_zip_seekable)(struct archive*);
int(archive_read_support_format_zip_streamable)(struct archive*);
int(archive_utility_string_sort)(char**);
int(archive_version_number)();
int(archive_write_add_filter)(struct archive*,int);
int(archive_write_add_filter_b64encode)(struct archive*);
int(archive_write_add_filter_by_name)(struct archive*,const char*);
int(archive_write_add_filter_bzip2)(struct archive*);
int(archive_write_add_filter_compress)(struct archive*);
int(archive_write_add_filter_grzip)(struct archive*);
int(archive_write_add_filter_gzip)(struct archive*);
int(archive_write_add_filter_lrzip)(struct archive*);
int(archive_write_add_filter_lz4)(struct archive*);
int(archive_write_add_filter_lzip)(struct archive*);
int(archive_write_add_filter_lzma)(struct archive*);
int(archive_write_add_filter_lzop)(struct archive*);
int(archive_write_add_filter_none)(struct archive*);
int(archive_write_add_filter_program)(struct archive*,const char*);
int(archive_write_add_filter_uuencode)(struct archive*);
int(archive_write_add_filter_xz)(struct archive*);
int(archive_write_add_filter_zstd)(struct archive*);
int(archive_write_close)(struct archive*);
int(archive_write_disk_set_options)(struct archive*,int);
int(archive_write_disk_set_skip_file)(struct archive*,signed long,signed long);
int(archive_write_disk_set_standard_lookup)(struct archive*);
int(archive_write_fail)(struct archive*);
int(archive_write_finish)(struct archive*);
int(archive_write_finish_entry)(struct archive*);
int(archive_write_free)(struct archive*);
int(archive_write_get_bytes_in_last_block)(struct archive*);
int(archive_write_get_bytes_per_block)(struct archive*);
int(archive_write_header)(struct archive*,struct archive_entry*);
int(archive_write_open)(struct archive*,void*,int(unknown_3)(struct archive*,void*),long(unknown_4)(struct archive*,void*,const void*,unsigned long),int(unknown_5)(struct archive*,void*));
int(archive_write_open2)(struct archive*,void*,int(unknown_3)(struct archive*,void*),long(unknown_4)(struct archive*,void*,const void*,unsigned long),int(unknown_5)(struct archive*,void*),int(unknown_6)(struct archive*,void*));
int(archive_write_open_FILE)(struct archive*,struct _IO_FILE*);
int(archive_write_open_fd)(struct archive*,int);
int(archive_write_open_file)(struct archive*,const char*);
int(archive_write_open_filename)(struct archive*,const char*);
int(archive_write_open_filename_w)(struct archive*,const int*);
int(archive_write_open_memory)(struct archive*,void*,unsigned long,unsigned long*);
int(archive_write_set_bytes_in_last_block)(struct archive*,int);
int(archive_write_set_bytes_per_block)(struct archive*,int);
int(archive_write_set_compression_bzip2)(struct archive*);
int(archive_write_set_compression_compress)(struct archive*);
int(archive_write_set_compression_gzip)(struct archive*);
int(archive_write_set_compression_lzip)(struct archive*);
int(archive_write_set_compression_lzma)(struct archive*);
int(archive_write_set_compression_none)(struct archive*);
int(archive_write_set_compression_program)(struct archive*,const char*);
int(archive_write_set_compression_xz)(struct archive*);
int(archive_write_set_filter_option)(struct archive*,const char*,const char*,const char*);
int(archive_write_set_format)(struct archive*,int);
int(archive_write_set_format_7zip)(struct archive*);
int(archive_write_set_format_ar_bsd)(struct archive*);
int(archive_write_set_format_ar_svr4)(struct archive*);
int(archive_write_set_format_by_name)(struct archive*,const char*);
int(archive_write_set_format_cpio)(struct archive*);
int(archive_write_set_format_cpio_bin)(struct archive*);
int(archive_write_set_format_cpio_newc)(struct archive*);
int(archive_write_set_format_cpio_odc)(struct archive*);
int(archive_write_set_format_cpio_pwb)(struct archive*);
int(archive_write_set_format_filter_by_ext)(struct archive*,const char*);
int(archive_write_set_format_filter_by_ext_def)(struct archive*,const char*,const char*);
int(archive_write_set_format_gnutar)(struct archive*);
int(archive_write_set_format_iso9660)(struct archive*);
int(archive_write_set_format_mtree)(struct archive*);
int(archive_write_set_format_mtree_classic)(struct archive*);
int(archive_write_set_format_option)(struct archive*,const char*,const char*,const char*);
int(archive_write_set_format_pax)(struct archive*);
int(archive_write_set_format_pax_restricted)(struct archive*);
int(archive_write_set_format_raw)(struct archive*);
int(archive_write_set_format_shar)(struct archive*);
int(archive_write_set_format_shar_dump)(struct archive*);
int(archive_write_set_format_ustar)(struct archive*);
int(archive_write_set_format_v7tar)(struct archive*);
int(archive_write_set_format_warc)(struct archive*);
int(archive_write_set_format_xar)(struct archive*);
int(archive_write_set_format_zip)(struct archive*);
int(archive_write_set_option)(struct archive*,const char*,const char*,const char*);
int(archive_write_set_options)(struct archive*,const char*);
int(archive_write_set_passphrase)(struct archive*,const char*);
int(archive_write_set_passphrase_callback)(struct archive*,void*,const char*(unknown_3)(struct archive*,void*));
int(archive_write_set_skip_file)(struct archive*,signed long,signed long);
int(archive_write_zip_set_compression_deflate)(struct archive*);
int(archive_write_zip_set_compression_store)(struct archive*);
long(archive_entry_atime)(struct archive_entry*);
long(archive_entry_atime_nsec)(struct archive_entry*);
long(archive_entry_birthtime)(struct archive_entry*);
long(archive_entry_birthtime_nsec)(struct archive_entry*);
long(archive_entry_ctime)(struct archive_entry*);
long(archive_entry_ctime_nsec)(struct archive_entry*);
long(archive_entry_mtime)(struct archive_entry*);
long(archive_entry_mtime_nsec)(struct archive_entry*);
long(archive_read_data)(struct archive*,void*,unsigned long);
long(archive_write_data)(struct archive*,const void*,unsigned long);
long(archive_write_data_block)(struct archive*,const void*,unsigned long,signed long);
signed long(archive_entry_gid)(struct archive_entry*);
signed long(archive_entry_ino)(struct archive_entry*);
signed long(archive_entry_ino64)(struct archive_entry*);
signed long(archive_entry_size)(struct archive_entry*);
signed long(archive_entry_uid)(struct archive_entry*);
signed long(archive_filter_bytes)(struct archive*,int);
signed long(archive_position_compressed)(struct archive*);
signed long(archive_position_uncompressed)(struct archive*);
signed long(archive_read_header_position)(struct archive*);
signed long(archive_seek_data)(struct archive*,signed long,int);
signed long(archive_write_disk_gid)(struct archive*,const char*,signed long);
signed long(archive_write_disk_uid)(struct archive*,const char*,signed long);
struct archive*(archive_match_new)();
struct archive*(archive_read_disk_new)();
struct archive*(archive_read_new)();
struct archive*(archive_write_disk_new)();
struct archive*(archive_write_new)();
struct archive_acl*(archive_entry_acl)(struct archive_entry*);
struct archive_entry*(archive_entry_clear)(struct archive_entry*);
struct archive_entry*(archive_entry_clone)(struct archive_entry*);
struct archive_entry*(archive_entry_new)();
struct archive_entry*(archive_entry_new2)(struct archive*);
struct archive_entry*(archive_entry_partial_links)(struct archive_entry_linkresolver*,unsigned int*);
struct archive_entry_linkresolver*(archive_entry_linkresolver_new)();
unsigned int(archive_entry_filetype)(struct archive_entry*);
unsigned int(archive_entry_mode)(struct archive_entry*);
unsigned int(archive_entry_nlink)(struct archive_entry*);
unsigned int(archive_entry_perm)(struct archive_entry*);
unsigned long(archive_entry_dev)(struct archive_entry*);
unsigned long(archive_entry_devmajor)(struct archive_entry*);
unsigned long(archive_entry_devminor)(struct archive_entry*);
unsigned long(archive_entry_rdev)(struct archive_entry*);
unsigned long(archive_entry_rdevmajor)(struct archive_entry*);
unsigned long(archive_entry_rdevminor)(struct archive_entry*);
void(archive_clear_error)(struct archive*);
void(archive_copy_error)(struct archive*,struct archive*);
void(archive_entry_acl_clear)(struct archive_entry*);
void(archive_entry_copy_gname)(struct archive_entry*,const char*);
void(archive_entry_copy_gname_w)(struct archive_entry*,const int*);
void(archive_entry_copy_hardlink)(struct archive_entry*,const char*);
void(archive_entry_copy_hardlink_w)(struct archive_entry*,const int*);
void(archive_entry_copy_link)(struct archive_entry*,const char*);
void(archive_entry_copy_link_w)(struct archive_entry*,const int*);
void(archive_entry_copy_mac_metadata)(struct archive_entry*,const void*,unsigned long);
void(archive_entry_copy_pathname)(struct archive_entry*,const char*);
void(archive_entry_copy_pathname_w)(struct archive_entry*,const int*);
void(archive_entry_copy_sourcepath)(struct archive_entry*,const char*);
void(archive_entry_copy_sourcepath_w)(struct archive_entry*,const int*);
void(archive_entry_copy_stat)(struct archive_entry*,const struct stat*);
void(archive_entry_copy_symlink)(struct archive_entry*,const char*);
void(archive_entry_copy_symlink_w)(struct archive_entry*,const int*);
void(archive_entry_copy_uname)(struct archive_entry*,const char*);
void(archive_entry_copy_uname_w)(struct archive_entry*,const int*);
void(archive_entry_fflags)(struct archive_entry*,unsigned long*,unsigned long*);
void(archive_entry_free)(struct archive_entry*);
void(archive_entry_linkify)(struct archive_entry_linkresolver*,struct archive_entry**,struct archive_entry**);
void(archive_entry_linkresolver_free)(struct archive_entry_linkresolver*);
void(archive_entry_linkresolver_set_strategy)(struct archive_entry_linkresolver*,int);
void(archive_entry_set_atime)(struct archive_entry*,long,long);
void(archive_entry_set_birthtime)(struct archive_entry*,long,long);
void(archive_entry_set_ctime)(struct archive_entry*,long,long);
void(archive_entry_set_dev)(struct archive_entry*,unsigned long);
void(archive_entry_set_devmajor)(struct archive_entry*,unsigned long);
void(archive_entry_set_devminor)(struct archive_entry*,unsigned long);
void(archive_entry_set_fflags)(struct archive_entry*,unsigned long,unsigned long);
void(archive_entry_set_filetype)(struct archive_entry*,unsigned int);
void(archive_entry_set_gid)(struct archive_entry*,signed long);
void(archive_entry_set_gname)(struct archive_entry*,const char*);
void(archive_entry_set_gname_utf8)(struct archive_entry*,const char*);
void(archive_entry_set_hardlink)(struct archive_entry*,const char*);
void(archive_entry_set_hardlink_utf8)(struct archive_entry*,const char*);
void(archive_entry_set_ino)(struct archive_entry*,signed long);
void(archive_entry_set_ino64)(struct archive_entry*,signed long);
void(archive_entry_set_is_data_encrypted)(struct archive_entry*,char);
void(archive_entry_set_is_metadata_encrypted)(struct archive_entry*,char);
void(archive_entry_set_link)(struct archive_entry*,const char*);
void(archive_entry_set_link_utf8)(struct archive_entry*,const char*);
void(archive_entry_set_mode)(struct archive_entry*,unsigned int);
void(archive_entry_set_mtime)(struct archive_entry*,long,long);
void(archive_entry_set_nlink)(struct archive_entry*,unsigned int);
void(archive_entry_set_pathname)(struct archive_entry*,const char*);
void(archive_entry_set_pathname_utf8)(struct archive_entry*,const char*);
void(archive_entry_set_perm)(struct archive_entry*,unsigned int);
void(archive_entry_set_rdev)(struct archive_entry*,unsigned long);
void(archive_entry_set_rdevmajor)(struct archive_entry*,unsigned long);
void(archive_entry_set_rdevminor)(struct archive_entry*,unsigned long);
void(archive_entry_set_size)(struct archive_entry*,signed long);
void(archive_entry_set_symlink)(struct archive_entry*,const char*);
void(archive_entry_set_symlink_type)(struct archive_entry*,int);
void(archive_entry_set_symlink_utf8)(struct archive_entry*,const char*);
void(archive_entry_set_uid)(struct archive_entry*,signed long);
void(archive_entry_set_uname)(struct archive_entry*,const char*);
void(archive_entry_set_uname_utf8)(struct archive_entry*,const char*);
void(archive_entry_sparse_add_entry)(struct archive_entry*,signed long,signed long);
void(archive_entry_sparse_clear)(struct archive_entry*);
void(archive_entry_unset_atime)(struct archive_entry*);
void(archive_entry_unset_birthtime)(struct archive_entry*);
void(archive_entry_unset_ctime)(struct archive_entry*);
void(archive_entry_unset_mtime)(struct archive_entry*);
void(archive_entry_unset_size)(struct archive_entry*);
void(archive_entry_xattr_add_entry)(struct archive_entry*,const char*,const void*,unsigned long);
void(archive_entry_xattr_clear)(struct archive_entry*);
void(archive_read_extract_set_progress_callback)(struct archive*,void(*_progress_func)(void*),void*);
void(archive_read_extract_set_skip_file)(struct archive*,signed long,signed long);
void(archive_set_error)(struct archive*,int,const char*,...);
]])
				local CLIB = setmetatable({}, {__index = function(_, k)
					local ok, val = pcall(function() return lib[k] end)
					if ok then
						return val
					end
				end})
			library = {
	BzlibVersion = CLIB.archive_bzlib_version,
	ClearError = CLIB.archive_clear_error,
	Compression = CLIB.archive_compression,
	CompressionName = CLIB.archive_compression_name,
	CopyError = CLIB.archive_copy_error,
	EntryAcl = CLIB.archive_entry_acl,
	EntryAclAddEntry = CLIB.archive_entry_acl_add_entry,
	EntryAclAddEntryW = CLIB.archive_entry_acl_add_entry_w,
	EntryAclClear = CLIB.archive_entry_acl_clear,
	EntryAclCount = CLIB.archive_entry_acl_count,
	EntryAclFromText = CLIB.archive_entry_acl_from_text,
	EntryAclFromTextW = CLIB.archive_entry_acl_from_text_w,
	EntryAclNext = CLIB.archive_entry_acl_next,
	EntryAclReset = CLIB.archive_entry_acl_reset,
	EntryAclText = CLIB.archive_entry_acl_text,
	EntryAclTextW = CLIB.archive_entry_acl_text_w,
	EntryAclToText = CLIB.archive_entry_acl_to_text,
	EntryAclToTextW = CLIB.archive_entry_acl_to_text_w,
	EntryAclTypes = CLIB.archive_entry_acl_types,
	EntryAtime = CLIB.archive_entry_atime,
	EntryAtimeIsSet = CLIB.archive_entry_atime_is_set,
	EntryAtimeNsec = CLIB.archive_entry_atime_nsec,
	EntryBirthtime = CLIB.archive_entry_birthtime,
	EntryBirthtimeIsSet = CLIB.archive_entry_birthtime_is_set,
	EntryBirthtimeNsec = CLIB.archive_entry_birthtime_nsec,
	EntryClear = CLIB.archive_entry_clear,
	EntryClone = CLIB.archive_entry_clone,
	EntryCopyFflagsText = CLIB.archive_entry_copy_fflags_text,
	EntryCopyFflagsTextW = CLIB.archive_entry_copy_fflags_text_w,
	EntryCopyGname = CLIB.archive_entry_copy_gname,
	EntryCopyGnameW = CLIB.archive_entry_copy_gname_w,
	EntryCopyHardlink = CLIB.archive_entry_copy_hardlink,
	EntryCopyHardlinkW = CLIB.archive_entry_copy_hardlink_w,
	EntryCopyLink = CLIB.archive_entry_copy_link,
	EntryCopyLinkW = CLIB.archive_entry_copy_link_w,
	EntryCopyMacMetadata = CLIB.archive_entry_copy_mac_metadata,
	EntryCopyPathname = CLIB.archive_entry_copy_pathname,
	EntryCopyPathnameW = CLIB.archive_entry_copy_pathname_w,
	EntryCopySourcepath = CLIB.archive_entry_copy_sourcepath,
	EntryCopySourcepathW = CLIB.archive_entry_copy_sourcepath_w,
	EntryCopyStat = CLIB.archive_entry_copy_stat,
	EntryCopySymlink = CLIB.archive_entry_copy_symlink,
	EntryCopySymlinkW = CLIB.archive_entry_copy_symlink_w,
	EntryCopyUname = CLIB.archive_entry_copy_uname,
	EntryCopyUnameW = CLIB.archive_entry_copy_uname_w,
	EntryCtime = CLIB.archive_entry_ctime,
	EntryCtimeIsSet = CLIB.archive_entry_ctime_is_set,
	EntryCtimeNsec = CLIB.archive_entry_ctime_nsec,
	EntryDev = CLIB.archive_entry_dev,
	EntryDevIsSet = CLIB.archive_entry_dev_is_set,
	EntryDevmajor = CLIB.archive_entry_devmajor,
	EntryDevminor = CLIB.archive_entry_devminor,
	EntryDigest = CLIB.archive_entry_digest,
	EntryFflags = CLIB.archive_entry_fflags,
	EntryFflagsText = CLIB.archive_entry_fflags_text,
	EntryFiletype = CLIB.archive_entry_filetype,
	EntryFree = CLIB.archive_entry_free,
	EntryGid = CLIB.archive_entry_gid,
	EntryGname = CLIB.archive_entry_gname,
	EntryGnameUtf8 = CLIB.archive_entry_gname_utf8,
	EntryGnameW = CLIB.archive_entry_gname_w,
	EntryHardlink = CLIB.archive_entry_hardlink,
	EntryHardlinkUtf8 = CLIB.archive_entry_hardlink_utf8,
	EntryHardlinkW = CLIB.archive_entry_hardlink_w,
	EntryIno = CLIB.archive_entry_ino,
	EntryIno64 = CLIB.archive_entry_ino64,
	EntryInoIsSet = CLIB.archive_entry_ino_is_set,
	EntryIsDataEncrypted = CLIB.archive_entry_is_data_encrypted,
	EntryIsEncrypted = CLIB.archive_entry_is_encrypted,
	EntryIsMetadataEncrypted = CLIB.archive_entry_is_metadata_encrypted,
	EntryLinkify = CLIB.archive_entry_linkify,
	EntryLinkresolverFree = CLIB.archive_entry_linkresolver_free,
	EntryLinkresolverNew = CLIB.archive_entry_linkresolver_new,
	EntryLinkresolverSetStrategy = CLIB.archive_entry_linkresolver_set_strategy,
	EntryMacMetadata = CLIB.archive_entry_mac_metadata,
	EntryMode = CLIB.archive_entry_mode,
	EntryMtime = CLIB.archive_entry_mtime,
	EntryMtimeIsSet = CLIB.archive_entry_mtime_is_set,
	EntryMtimeNsec = CLIB.archive_entry_mtime_nsec,
	EntryNew = CLIB.archive_entry_new,
	EntryNew2 = CLIB.archive_entry_new2,
	EntryNlink = CLIB.archive_entry_nlink,
	EntryPartialLinks = CLIB.archive_entry_partial_links,
	EntryPathname = CLIB.archive_entry_pathname,
	EntryPathnameUtf8 = CLIB.archive_entry_pathname_utf8,
	EntryPathnameW = CLIB.archive_entry_pathname_w,
	EntryPerm = CLIB.archive_entry_perm,
	EntryRdev = CLIB.archive_entry_rdev,
	EntryRdevmajor = CLIB.archive_entry_rdevmajor,
	EntryRdevminor = CLIB.archive_entry_rdevminor,
	EntrySetAtime = CLIB.archive_entry_set_atime,
	EntrySetBirthtime = CLIB.archive_entry_set_birthtime,
	EntrySetCtime = CLIB.archive_entry_set_ctime,
	EntrySetDev = CLIB.archive_entry_set_dev,
	EntrySetDevmajor = CLIB.archive_entry_set_devmajor,
	EntrySetDevminor = CLIB.archive_entry_set_devminor,
	EntrySetFflags = CLIB.archive_entry_set_fflags,
	EntrySetFiletype = CLIB.archive_entry_set_filetype,
	EntrySetGid = CLIB.archive_entry_set_gid,
	EntrySetGname = CLIB.archive_entry_set_gname,
	EntrySetGnameUtf8 = CLIB.archive_entry_set_gname_utf8,
	EntrySetHardlink = CLIB.archive_entry_set_hardlink,
	EntrySetHardlinkUtf8 = CLIB.archive_entry_set_hardlink_utf8,
	EntrySetIno = CLIB.archive_entry_set_ino,
	EntrySetIno64 = CLIB.archive_entry_set_ino64,
	EntrySetIsDataEncrypted = CLIB.archive_entry_set_is_data_encrypted,
	EntrySetIsMetadataEncrypted = CLIB.archive_entry_set_is_metadata_encrypted,
	EntrySetLink = CLIB.archive_entry_set_link,
	EntrySetLinkUtf8 = CLIB.archive_entry_set_link_utf8,
	EntrySetMode = CLIB.archive_entry_set_mode,
	EntrySetMtime = CLIB.archive_entry_set_mtime,
	EntrySetNlink = CLIB.archive_entry_set_nlink,
	EntrySetPathname = CLIB.archive_entry_set_pathname,
	EntrySetPathnameUtf8 = CLIB.archive_entry_set_pathname_utf8,
	EntrySetPerm = CLIB.archive_entry_set_perm,
	EntrySetRdev = CLIB.archive_entry_set_rdev,
	EntrySetRdevmajor = CLIB.archive_entry_set_rdevmajor,
	EntrySetRdevminor = CLIB.archive_entry_set_rdevminor,
	EntrySetSize = CLIB.archive_entry_set_size,
	EntrySetSymlink = CLIB.archive_entry_set_symlink,
	EntrySetSymlinkType = CLIB.archive_entry_set_symlink_type,
	EntrySetSymlinkUtf8 = CLIB.archive_entry_set_symlink_utf8,
	EntrySetUid = CLIB.archive_entry_set_uid,
	EntrySetUname = CLIB.archive_entry_set_uname,
	EntrySetUnameUtf8 = CLIB.archive_entry_set_uname_utf8,
	EntrySize = CLIB.archive_entry_size,
	EntrySizeIsSet = CLIB.archive_entry_size_is_set,
	EntrySourcepath = CLIB.archive_entry_sourcepath,
	EntrySourcepathW = CLIB.archive_entry_sourcepath_w,
	EntrySparseAddEntry = CLIB.archive_entry_sparse_add_entry,
	EntrySparseClear = CLIB.archive_entry_sparse_clear,
	EntrySparseCount = CLIB.archive_entry_sparse_count,
	EntrySparseNext = CLIB.archive_entry_sparse_next,
	EntrySparseReset = CLIB.archive_entry_sparse_reset,
	EntryStat = CLIB.archive_entry_stat,
	EntryStrmode = CLIB.archive_entry_strmode,
	EntrySymlink = CLIB.archive_entry_symlink,
	EntrySymlinkType = CLIB.archive_entry_symlink_type,
	EntrySymlinkUtf8 = CLIB.archive_entry_symlink_utf8,
	EntrySymlinkW = CLIB.archive_entry_symlink_w,
	EntryUid = CLIB.archive_entry_uid,
	EntryUname = CLIB.archive_entry_uname,
	EntryUnameUtf8 = CLIB.archive_entry_uname_utf8,
	EntryUnameW = CLIB.archive_entry_uname_w,
	EntryUnsetAtime = CLIB.archive_entry_unset_atime,
	EntryUnsetBirthtime = CLIB.archive_entry_unset_birthtime,
	EntryUnsetCtime = CLIB.archive_entry_unset_ctime,
	EntryUnsetMtime = CLIB.archive_entry_unset_mtime,
	EntryUnsetSize = CLIB.archive_entry_unset_size,
	EntryUpdateGnameUtf8 = CLIB.archive_entry_update_gname_utf8,
	EntryUpdateHardlinkUtf8 = CLIB.archive_entry_update_hardlink_utf8,
	EntryUpdateLinkUtf8 = CLIB.archive_entry_update_link_utf8,
	EntryUpdatePathnameUtf8 = CLIB.archive_entry_update_pathname_utf8,
	EntryUpdateSymlinkUtf8 = CLIB.archive_entry_update_symlink_utf8,
	EntryUpdateUnameUtf8 = CLIB.archive_entry_update_uname_utf8,
	EntryXattrAddEntry = CLIB.archive_entry_xattr_add_entry,
	EntryXattrClear = CLIB.archive_entry_xattr_clear,
	EntryXattrCount = CLIB.archive_entry_xattr_count,
	EntryXattrNext = CLIB.archive_entry_xattr_next,
	EntryXattrReset = CLIB.archive_entry_xattr_reset,
	Errno = CLIB.archive_errno,
	ErrorString = CLIB.archive_error_string,
	FileCount = CLIB.archive_file_count,
	FilterBytes = CLIB.archive_filter_bytes,
	FilterCode = CLIB.archive_filter_code,
	FilterCount = CLIB.archive_filter_count,
	FilterName = CLIB.archive_filter_name,
	Format = CLIB.archive_format,
	FormatName = CLIB.archive_format_name,
	Free = CLIB.archive_free,
	Liblz4Version = CLIB.archive_liblz4_version,
	LiblzmaVersion = CLIB.archive_liblzma_version,
	LibzstdVersion = CLIB.archive_libzstd_version,
	MatchExcludeEntry = CLIB.archive_match_exclude_entry,
	MatchExcludePattern = CLIB.archive_match_exclude_pattern,
	MatchExcludePatternFromFile = CLIB.archive_match_exclude_pattern_from_file,
	MatchExcludePatternFromFileW = CLIB.archive_match_exclude_pattern_from_file_w,
	MatchExcludePatternW = CLIB.archive_match_exclude_pattern_w,
	MatchExcluded = CLIB.archive_match_excluded,
	MatchFree = CLIB.archive_match_free,
	MatchIncludeDate = CLIB.archive_match_include_date,
	MatchIncludeDateW = CLIB.archive_match_include_date_w,
	MatchIncludeFileTime = CLIB.archive_match_include_file_time,
	MatchIncludeFileTimeW = CLIB.archive_match_include_file_time_w,
	MatchIncludeGid = CLIB.archive_match_include_gid,
	MatchIncludeGname = CLIB.archive_match_include_gname,
	MatchIncludeGnameW = CLIB.archive_match_include_gname_w,
	MatchIncludePattern = CLIB.archive_match_include_pattern,
	MatchIncludePatternFromFile = CLIB.archive_match_include_pattern_from_file,
	MatchIncludePatternFromFileW = CLIB.archive_match_include_pattern_from_file_w,
	MatchIncludePatternW = CLIB.archive_match_include_pattern_w,
	MatchIncludeTime = CLIB.archive_match_include_time,
	MatchIncludeUid = CLIB.archive_match_include_uid,
	MatchIncludeUname = CLIB.archive_match_include_uname,
	MatchIncludeUnameW = CLIB.archive_match_include_uname_w,
	MatchNew = CLIB.archive_match_new,
	MatchOwnerExcluded = CLIB.archive_match_owner_excluded,
	MatchPathExcluded = CLIB.archive_match_path_excluded,
	MatchPathUnmatchedInclusions = CLIB.archive_match_path_unmatched_inclusions,
	MatchPathUnmatchedInclusionsNext = CLIB.archive_match_path_unmatched_inclusions_next,
	MatchPathUnmatchedInclusionsNextW = CLIB.archive_match_path_unmatched_inclusions_next_w,
	MatchSetInclusionRecursion = CLIB.archive_match_set_inclusion_recursion,
	MatchTimeExcluded = CLIB.archive_match_time_excluded,
	PositionCompressed = CLIB.archive_position_compressed,
	PositionUncompressed = CLIB.archive_position_uncompressed,
	ReadAddCallbackData = CLIB.archive_read_add_callback_data,
	ReadAddPassphrase = CLIB.archive_read_add_passphrase,
	ReadAppendCallbackData = CLIB.archive_read_append_callback_data,
	ReadAppendFilter = CLIB.archive_read_append_filter,
	ReadAppendFilterProgram = CLIB.archive_read_append_filter_program,
	ReadAppendFilterProgramSignature = CLIB.archive_read_append_filter_program_signature,
	ReadClose = CLIB.archive_read_close,
	ReadData = CLIB.archive_read_data,
	ReadDataBlock = CLIB.archive_read_data_block,
	ReadDataIntoFd = CLIB.archive_read_data_into_fd,
	ReadDataSkip = CLIB.archive_read_data_skip,
	ReadDiskCanDescend = CLIB.archive_read_disk_can_descend,
	ReadDiskCurrentFilesystem = CLIB.archive_read_disk_current_filesystem,
	ReadDiskCurrentFilesystemIsRemote = CLIB.archive_read_disk_current_filesystem_is_remote,
	ReadDiskCurrentFilesystemIsSynthetic = CLIB.archive_read_disk_current_filesystem_is_synthetic,
	ReadDiskDescend = CLIB.archive_read_disk_descend,
	ReadDiskEntryFromFile = CLIB.archive_read_disk_entry_from_file,
	ReadDiskGname = CLIB.archive_read_disk_gname,
	ReadDiskNew = CLIB.archive_read_disk_new,
	ReadDiskOpen = CLIB.archive_read_disk_open,
	ReadDiskOpenW = CLIB.archive_read_disk_open_w,
	ReadDiskSetAtimeRestored = CLIB.archive_read_disk_set_atime_restored,
	ReadDiskSetBehavior = CLIB.archive_read_disk_set_behavior,
	ReadDiskSetMatching = CLIB.archive_read_disk_set_matching,
	ReadDiskSetMetadataFilterCallback = CLIB.archive_read_disk_set_metadata_filter_callback,
	ReadDiskSetStandardLookup = CLIB.archive_read_disk_set_standard_lookup,
	ReadDiskSetSymlinkHybrid = CLIB.archive_read_disk_set_symlink_hybrid,
	ReadDiskSetSymlinkLogical = CLIB.archive_read_disk_set_symlink_logical,
	ReadDiskSetSymlinkPhysical = CLIB.archive_read_disk_set_symlink_physical,
	ReadDiskUname = CLIB.archive_read_disk_uname,
	ReadExtract = CLIB.archive_read_extract,
	ReadExtract2 = CLIB.archive_read_extract2,
	ReadExtractSetProgressCallback = CLIB.archive_read_extract_set_progress_callback,
	ReadExtractSetSkipFile = CLIB.archive_read_extract_set_skip_file,
	ReadFinish = CLIB.archive_read_finish,
	ReadFormatCapabilities = CLIB.archive_read_format_capabilities,
	ReadFree = CLIB.archive_read_free,
	ReadHasEncryptedEntries = CLIB.archive_read_has_encrypted_entries,
	ReadHeaderPosition = CLIB.archive_read_header_position,
	ReadNew = CLIB.archive_read_new,
	ReadNextHeader = CLIB.archive_read_next_header,
	ReadNextHeader2 = CLIB.archive_read_next_header2,
	ReadOpen = CLIB.archive_read_open,
	ReadOpen1 = CLIB.archive_read_open1,
	ReadOpen2 = CLIB.archive_read_open2,
	ReadOpen_FILE = CLIB.archive_read_open_FILE,
	ReadOpenFd = CLIB.archive_read_open_fd,
	ReadOpenFile = CLIB.archive_read_open_file,
	ReadOpenFilename = CLIB.archive_read_open_filename,
	ReadOpenFilenameW = CLIB.archive_read_open_filename_w,
	ReadOpenFilenames = CLIB.archive_read_open_filenames,
	ReadOpenMemory = CLIB.archive_read_open_memory,
	ReadOpenMemory2 = CLIB.archive_read_open_memory2,
	ReadPrependCallbackData = CLIB.archive_read_prepend_callback_data,
	ReadSetCallbackData = CLIB.archive_read_set_callback_data,
	ReadSetCallbackData2 = CLIB.archive_read_set_callback_data2,
	ReadSetCloseCallback = CLIB.archive_read_set_close_callback,
	ReadSetFilterOption = CLIB.archive_read_set_filter_option,
	ReadSetFormat = CLIB.archive_read_set_format,
	ReadSetFormatOption = CLIB.archive_read_set_format_option,
	ReadSetOpenCallback = CLIB.archive_read_set_open_callback,
	ReadSetOption = CLIB.archive_read_set_option,
	ReadSetOptions = CLIB.archive_read_set_options,
	ReadSetPassphraseCallback = CLIB.archive_read_set_passphrase_callback,
	ReadSetReadCallback = CLIB.archive_read_set_read_callback,
	ReadSetSeekCallback = CLIB.archive_read_set_seek_callback,
	ReadSetSkipCallback = CLIB.archive_read_set_skip_callback,
	ReadSetSwitchCallback = CLIB.archive_read_set_switch_callback,
	ReadSupportCompressionAll = CLIB.archive_read_support_compression_all,
	ReadSupportCompressionBzip2 = CLIB.archive_read_support_compression_bzip2,
	ReadSupportCompressionCompress = CLIB.archive_read_support_compression_compress,
	ReadSupportCompressionGzip = CLIB.archive_read_support_compression_gzip,
	ReadSupportCompressionLzip = CLIB.archive_read_support_compression_lzip,
	ReadSupportCompressionLzma = CLIB.archive_read_support_compression_lzma,
	ReadSupportCompressionNone = CLIB.archive_read_support_compression_none,
	ReadSupportCompressionProgram = CLIB.archive_read_support_compression_program,
	ReadSupportCompressionProgramSignature = CLIB.archive_read_support_compression_program_signature,
	ReadSupportCompressionRpm = CLIB.archive_read_support_compression_rpm,
	ReadSupportCompressionUu = CLIB.archive_read_support_compression_uu,
	ReadSupportCompressionXz = CLIB.archive_read_support_compression_xz,
	ReadSupportFilterAll = CLIB.archive_read_support_filter_all,
	ReadSupportFilterByCode = CLIB.archive_read_support_filter_by_code,
	ReadSupportFilterBzip2 = CLIB.archive_read_support_filter_bzip2,
	ReadSupportFilterCompress = CLIB.archive_read_support_filter_compress,
	ReadSupportFilterGrzip = CLIB.archive_read_support_filter_grzip,
	ReadSupportFilterGzip = CLIB.archive_read_support_filter_gzip,
	ReadSupportFilterLrzip = CLIB.archive_read_support_filter_lrzip,
	ReadSupportFilterLz4 = CLIB.archive_read_support_filter_lz4,
	ReadSupportFilterLzip = CLIB.archive_read_support_filter_lzip,
	ReadSupportFilterLzma = CLIB.archive_read_support_filter_lzma,
	ReadSupportFilterLzop = CLIB.archive_read_support_filter_lzop,
	ReadSupportFilterNone = CLIB.archive_read_support_filter_none,
	ReadSupportFilterProgram = CLIB.archive_read_support_filter_program,
	ReadSupportFilterProgramSignature = CLIB.archive_read_support_filter_program_signature,
	ReadSupportFilterRpm = CLIB.archive_read_support_filter_rpm,
	ReadSupportFilterUu = CLIB.archive_read_support_filter_uu,
	ReadSupportFilterXz = CLIB.archive_read_support_filter_xz,
	ReadSupportFilterZstd = CLIB.archive_read_support_filter_zstd,
	ReadSupportFormat_7zip = CLIB.archive_read_support_format_7zip,
	ReadSupportFormatAll = CLIB.archive_read_support_format_all,
	ReadSupportFormatAr = CLIB.archive_read_support_format_ar,
	ReadSupportFormatByCode = CLIB.archive_read_support_format_by_code,
	ReadSupportFormatCab = CLIB.archive_read_support_format_cab,
	ReadSupportFormatCpio = CLIB.archive_read_support_format_cpio,
	ReadSupportFormatEmpty = CLIB.archive_read_support_format_empty,
	ReadSupportFormatGnutar = CLIB.archive_read_support_format_gnutar,
	ReadSupportFormatIso9660 = CLIB.archive_read_support_format_iso9660,
	ReadSupportFormatLha = CLIB.archive_read_support_format_lha,
	ReadSupportFormatMtree = CLIB.archive_read_support_format_mtree,
	ReadSupportFormatRar = CLIB.archive_read_support_format_rar,
	ReadSupportFormatRar5 = CLIB.archive_read_support_format_rar5,
	ReadSupportFormatRaw = CLIB.archive_read_support_format_raw,
	ReadSupportFormatTar = CLIB.archive_read_support_format_tar,
	ReadSupportFormatWarc = CLIB.archive_read_support_format_warc,
	ReadSupportFormatXar = CLIB.archive_read_support_format_xar,
	ReadSupportFormatZip = CLIB.archive_read_support_format_zip,
	ReadSupportFormatZipSeekable = CLIB.archive_read_support_format_zip_seekable,
	ReadSupportFormatZipStreamable = CLIB.archive_read_support_format_zip_streamable,
	SeekData = CLIB.archive_seek_data,
	SetError = CLIB.archive_set_error,
	UtilityStringSort = CLIB.archive_utility_string_sort,
	VersionDetails = CLIB.archive_version_details,
	VersionNumber = CLIB.archive_version_number,
	VersionString = CLIB.archive_version_string,
	WriteAddFilter = CLIB.archive_write_add_filter,
	WriteAddFilterB64encode = CLIB.archive_write_add_filter_b64encode,
	WriteAddFilterByName = CLIB.archive_write_add_filter_by_name,
	WriteAddFilterBzip2 = CLIB.archive_write_add_filter_bzip2,
	WriteAddFilterCompress = CLIB.archive_write_add_filter_compress,
	WriteAddFilterGrzip = CLIB.archive_write_add_filter_grzip,
	WriteAddFilterGzip = CLIB.archive_write_add_filter_gzip,
	WriteAddFilterLrzip = CLIB.archive_write_add_filter_lrzip,
	WriteAddFilterLz4 = CLIB.archive_write_add_filter_lz4,
	WriteAddFilterLzip = CLIB.archive_write_add_filter_lzip,
	WriteAddFilterLzma = CLIB.archive_write_add_filter_lzma,
	WriteAddFilterLzop = CLIB.archive_write_add_filter_lzop,
	WriteAddFilterNone = CLIB.archive_write_add_filter_none,
	WriteAddFilterProgram = CLIB.archive_write_add_filter_program,
	WriteAddFilterUuencode = CLIB.archive_write_add_filter_uuencode,
	WriteAddFilterXz = CLIB.archive_write_add_filter_xz,
	WriteAddFilterZstd = CLIB.archive_write_add_filter_zstd,
	WriteClose = CLIB.archive_write_close,
	WriteData = CLIB.archive_write_data,
	WriteDataBlock = CLIB.archive_write_data_block,
	WriteDiskGid = CLIB.archive_write_disk_gid,
	WriteDiskNew = CLIB.archive_write_disk_new,
	WriteDiskSetOptions = CLIB.archive_write_disk_set_options,
	WriteDiskSetSkipFile = CLIB.archive_write_disk_set_skip_file,
	WriteDiskSetStandardLookup = CLIB.archive_write_disk_set_standard_lookup,
	WriteDiskUid = CLIB.archive_write_disk_uid,
	WriteFail = CLIB.archive_write_fail,
	WriteFinish = CLIB.archive_write_finish,
	WriteFinishEntry = CLIB.archive_write_finish_entry,
	WriteFree = CLIB.archive_write_free,
	WriteGetBytesInLastBlock = CLIB.archive_write_get_bytes_in_last_block,
	WriteGetBytesPerBlock = CLIB.archive_write_get_bytes_per_block,
	WriteHeader = CLIB.archive_write_header,
	WriteNew = CLIB.archive_write_new,
	WriteOpen = CLIB.archive_write_open,
	WriteOpen2 = CLIB.archive_write_open2,
	WriteOpen_FILE = CLIB.archive_write_open_FILE,
	WriteOpenFd = CLIB.archive_write_open_fd,
	WriteOpenFile = CLIB.archive_write_open_file,
	WriteOpenFilename = CLIB.archive_write_open_filename,
	WriteOpenFilenameW = CLIB.archive_write_open_filename_w,
	WriteOpenMemory = CLIB.archive_write_open_memory,
	WriteSetBytesInLastBlock = CLIB.archive_write_set_bytes_in_last_block,
	WriteSetBytesPerBlock = CLIB.archive_write_set_bytes_per_block,
	WriteSetCompressionBzip2 = CLIB.archive_write_set_compression_bzip2,
	WriteSetCompressionCompress = CLIB.archive_write_set_compression_compress,
	WriteSetCompressionGzip = CLIB.archive_write_set_compression_gzip,
	WriteSetCompressionLzip = CLIB.archive_write_set_compression_lzip,
	WriteSetCompressionLzma = CLIB.archive_write_set_compression_lzma,
	WriteSetCompressionNone = CLIB.archive_write_set_compression_none,
	WriteSetCompressionProgram = CLIB.archive_write_set_compression_program,
	WriteSetCompressionXz = CLIB.archive_write_set_compression_xz,
	WriteSetFilterOption = CLIB.archive_write_set_filter_option,
	WriteSetFormat = CLIB.archive_write_set_format,
	WriteSetFormat_7zip = CLIB.archive_write_set_format_7zip,
	WriteSetFormatArBsd = CLIB.archive_write_set_format_ar_bsd,
	WriteSetFormatArSvr4 = CLIB.archive_write_set_format_ar_svr4,
	WriteSetFormatByName = CLIB.archive_write_set_format_by_name,
	WriteSetFormatCpio = CLIB.archive_write_set_format_cpio,
	WriteSetFormatCpioBin = CLIB.archive_write_set_format_cpio_bin,
	WriteSetFormatCpioNewc = CLIB.archive_write_set_format_cpio_newc,
	WriteSetFormatCpioOdc = CLIB.archive_write_set_format_cpio_odc,
	WriteSetFormatCpioPwb = CLIB.archive_write_set_format_cpio_pwb,
	WriteSetFormatFilterByExt = CLIB.archive_write_set_format_filter_by_ext,
	WriteSetFormatFilterByExtDef = CLIB.archive_write_set_format_filter_by_ext_def,
	WriteSetFormatGnutar = CLIB.archive_write_set_format_gnutar,
	WriteSetFormatIso9660 = CLIB.archive_write_set_format_iso9660,
	WriteSetFormatMtree = CLIB.archive_write_set_format_mtree,
	WriteSetFormatMtreeClassic = CLIB.archive_write_set_format_mtree_classic,
	WriteSetFormatOption = CLIB.archive_write_set_format_option,
	WriteSetFormatPax = CLIB.archive_write_set_format_pax,
	WriteSetFormatPaxRestricted = CLIB.archive_write_set_format_pax_restricted,
	WriteSetFormatRaw = CLIB.archive_write_set_format_raw,
	WriteSetFormatShar = CLIB.archive_write_set_format_shar,
	WriteSetFormatSharDump = CLIB.archive_write_set_format_shar_dump,
	WriteSetFormatUstar = CLIB.archive_write_set_format_ustar,
	WriteSetFormatV7tar = CLIB.archive_write_set_format_v7tar,
	WriteSetFormatWarc = CLIB.archive_write_set_format_warc,
	WriteSetFormatXar = CLIB.archive_write_set_format_xar,
	WriteSetFormatZip = CLIB.archive_write_set_format_zip,
	WriteSetOption = CLIB.archive_write_set_option,
	WriteSetOptions = CLIB.archive_write_set_options,
	WriteSetPassphrase = CLIB.archive_write_set_passphrase,
	WriteSetPassphraseCallback = CLIB.archive_write_set_passphrase_callback,
	WriteSetSkipFile = CLIB.archive_write_set_skip_file,
	WriteZipSetCompressionDeflate = CLIB.archive_write_zip_set_compression_deflate,
	WriteZipSetCompressionStore = CLIB.archive_write_zip_set_compression_store,
	ZlibVersion = CLIB.archive_zlib_version,
}
library.e = {
	H_INCLUDED = 1,
	VERSION_NUMBER = 3006002,
	VERSION_ONLY_STRING = "3.6.2dev",
	VERSION_STRING = "libarchive 3.6.2dev",
	EOF = 1,
	OK = 0,
	RETRY = -10,
	WARN = -20,
	FAILED = -25,
	FATAL = -30,
	FILTER_NONE = 0,
	FILTER_GZIP = 1,
	FILTER_BZIP2 = 2,
	FILTER_COMPRESS = 3,
	FILTER_PROGRAM = 4,
	FILTER_LZMA = 5,
	FILTER_XZ = 6,
	FILTER_UU = 7,
	FILTER_RPM = 8,
	FILTER_LZIP = 9,
	FILTER_LRZIP = 10,
	FILTER_LZOP = 11,
	FILTER_GRZIP = 12,
	FILTER_LZ4 = 13,
	FILTER_ZSTD = 14,
	COMPRESSION_NONE = 0,
	COMPRESSION_GZIP = 1,
	COMPRESSION_BZIP2 = 2,
	COMPRESSION_COMPRESS = 3,
	COMPRESSION_PROGRAM = 4,
	COMPRESSION_LZMA = 5,
	COMPRESSION_XZ = 6,
	COMPRESSION_UU = 7,
	COMPRESSION_RPM = 8,
	COMPRESSION_LZIP = 9,
	COMPRESSION_LRZIP = 10,
	FORMAT_BASE_MASK = 16711680,
	FORMAT_CPIO = 65536,
	FORMAT_CPIO_POSIX = 65537,
	FORMAT_CPIO_BIN_LE = 65538,
	FORMAT_CPIO_BIN_BE = 65539,
	FORMAT_CPIO_SVR4_NOCRC = 65540,
	FORMAT_CPIO_SVR4_CRC = 65541,
	FORMAT_CPIO_AFIO_LARGE = 65542,
	FORMAT_CPIO_PWB = 65543,
	FORMAT_SHAR = 131072,
	FORMAT_SHAR_BASE = 131073,
	FORMAT_SHAR_DUMP = 131074,
	FORMAT_TAR = 196608,
	FORMAT_TAR_USTAR = 196609,
	FORMAT_TAR_PAX_INTERCHANGE = 196610,
	FORMAT_TAR_PAX_RESTRICTED = 196611,
	FORMAT_TAR_GNUTAR = 196612,
	FORMAT_ISO9660 = 262144,
	FORMAT_ISO9660_ROCKRIDGE = 262145,
	FORMAT_ZIP = 327680,
	FORMAT_EMPTY = 393216,
	FORMAT_AR = 458752,
	FORMAT_AR_GNU = 458753,
	FORMAT_AR_BSD = 458754,
	FORMAT_MTREE = 524288,
	FORMAT_RAW = 589824,
	FORMAT_XAR = 655360,
	FORMAT_LHA = 720896,
	FORMAT_CAB = 786432,
	FORMAT_RAR = 851968,
	FORMAT_7ZIP = 917504,
	FORMAT_WARC = 983040,
	FORMAT_RAR_V5 = 1048576,
	READ_FORMAT_CAPS_NONE = 0,
	READ_FORMAT_CAPS_ENCRYPT_DATA = 1,
	READ_FORMAT_CAPS_ENCRYPT_METADATA = 2,
	READ_FORMAT_ENCRYPTION_UNSUPPORTED = -2,
	READ_FORMAT_ENCRYPTION_DONT_KNOW = -1,
	EXTRACT_OWNER = 1,
	EXTRACT_PERM = 2,
	EXTRACT_TIME = 4,
	EXTRACT_NO_OVERWRITE = 8,
	EXTRACT_UNLINK = 16,
	EXTRACT_ACL = 32,
	EXTRACT_FFLAGS = 64,
	EXTRACT_XATTR = 128,
	EXTRACT_SECURE_SYMLINKS = 256,
	EXTRACT_SECURE_NODOTDOT = 512,
	EXTRACT_NO_AUTODIR = 1024,
	EXTRACT_NO_OVERWRITE_NEWER = 2048,
	EXTRACT_SPARSE = 4096,
	EXTRACT_MAC_METADATA = 8192,
	EXTRACT_NO_HFS_COMPRESSION = 16384,
	EXTRACT_HFS_COMPRESSION_FORCED = 32768,
	EXTRACT_SECURE_NOABSOLUTEPATHS = 65536,
	EXTRACT_CLEAR_NOCHANGE_FFLAGS = 131072,
	EXTRACT_SAFE_WRITES = 262144,
	READDISK_RESTORE_ATIME = 1,
	READDISK_HONOR_NODUMP = 2,
	READDISK_MAC_COPYFILE = 4,
	READDISK_NO_TRAVERSE_MOUNTS = 8,
	READDISK_NO_XATTR = 16,
	READDISK_NO_ACL = 32,
	READDISK_NO_FFLAGS = 64,
	READDISK_NO_SPARSE = 128,
	MATCH_MTIME = 256,
	MATCH_CTIME = 512,
	MATCH_NEWER = 1,
	MATCH_OLDER = 2,
	MATCH_EQUAL = 16,
}
library.clib = CLIB
return library
