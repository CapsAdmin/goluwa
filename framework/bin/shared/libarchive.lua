local ffi = require("ffi");local CLIB = assert(ffi.load("libarchive"));ffi.cdef([[struct archive {};
struct archive_entry {};
struct archive_acl {};
struct archive_entry_linkresolver {};
struct archive_entry*(archive_entry_clone)(struct archive_entry*);
int(archive_read_support_filter_none)(struct archive*);
int(archive_read_open1)(struct archive*);
int(archive_read_disk_current_filesystem_is_remote)(struct archive*);
int(archive_match_owner_excluded)(struct archive*,struct archive_entry*);
int(archive_write_set_format_cpio_pwb)(struct archive*);
int(archive_write_close)(struct archive*);
const char*(archive_liblz4_version)();
int(archive_write_set_format_filter_by_ext_def)(struct archive*,const char*,const char*);
int(archive_read_support_filter_by_code)(struct archive*,int);
int(archive_write_set_format_cpio_bin)(struct archive*);
int(archive_read_support_filter_xz)(struct archive*);
int(archive_write_add_filter_lzma)(struct archive*);
int(archive_read_data_block)(struct archive*,const void**,unsigned long*,signed long*);
const char*(archive_version_details)();
int(archive_read_support_filter_program)(struct archive*,const char*);
void(archive_read_extract_set_progress_callback)(struct archive*,void(*_progress_func)(void*),void*);
int(archive_read_set_options)(struct archive*,const char*);
int(archive_write_get_bytes_per_block)(struct archive*);
int(archive_write_set_format_zip)(struct archive*);
int(archive_read_set_skip_callback)(struct archive*,signed long(unknown_2)(struct archive*,void*,signed long));
int(archive_read_support_compression_none)(struct archive*);
int(archive_match_exclude_pattern_w)(struct archive*,const int*);
void(archive_entry_set_nlink)(struct archive_entry*,unsigned int);
int(archive_read_support_format_ar)(struct archive*);
int(archive_read_support_filter_lrzip)(struct archive*);
void(archive_entry_unset_mtime)(struct archive_entry*);
int(archive_compression)(struct archive*);
int(archive_match_include_gname)(struct archive*,const char*);
int(archive_write_add_filter_lzop)(struct archive*);
int(archive_match_include_pattern_w)(struct archive*,const int*);
int(archive_write_disk_set_options)(struct archive*,int);
int(archive_read_data_skip)(struct archive*);
int(archive_read_support_format_cab)(struct archive*);
void(archive_entry_unset_atime)(struct archive_entry*);
int(archive_read_support_filter_lzop)(struct archive*);
int(archive_read_support_compression_lzma)(struct archive*);
int(archive_read_support_format_mtree)(struct archive*);
int(archive_read_support_format_cpio)(struct archive*);
int(archive_match_include_pattern_from_file_w)(struct archive*,const int*,int);
int(archive_match_include_uname_w)(struct archive*,const int*);
int(archive_read_support_filter_gzip)(struct archive*);
int(archive_match_path_unmatched_inclusions_next)(struct archive*,const char**);
int(archive_read_open_filename_w)(struct archive*,const int*,unsigned long);
struct archive*(archive_match_new)();
void(archive_read_extract_set_skip_file)(struct archive*,signed long,signed long);
int(archive_read_open_fd)(struct archive*,int,unsigned long);
int(archive_match_excluded)(struct archive*,struct archive_entry*);
int(archive_match_exclude_pattern_from_file)(struct archive*,const char*,int);
int(archive_read_append_filter)(struct archive*,int);
int(archive_read_add_callback_data)(struct archive*,void*,unsigned int);
int(archive_write_set_format_gnutar)(struct archive*);
int(archive_read_disk_set_metadata_filter_callback)(struct archive*,int(*_metadata_filter_func)(struct archive*,void*,struct archive_entry*),void*);
int(archive_write_add_filter_gzip)(struct archive*);
int(archive_read_disk_set_symlink_hybrid)(struct archive*);
int(archive_read_support_compression_rpm)(struct archive*);
int(archive_write_set_compression_xz)(struct archive*);
void(archive_entry_set_uname_utf8)(struct archive_entry*,const char*);
void(archive_entry_set_birthtime)(struct archive_entry*,long,long);
int(archive_read_disk_set_symlink_physical)(struct archive*);
int(archive_write_set_format)(struct archive*,int);
const char*(archive_zlib_version)();
int(archive_read_support_format_zip_streamable)(struct archive*);
const char*(archive_entry_pathname)(struct archive_entry*);
void(archive_entry_linkify)(struct archive_entry_linkresolver*,struct archive_entry**,struct archive_entry**);
int(archive_write_set_filter_option)(struct archive*,const char*,const char*,const char*);
void(archive_entry_linkresolver_free)(struct archive_entry_linkresolver*);
int(archive_read_append_filter_program)(struct archive*,const char*);
int(archive_entry_sparse_next)(struct archive_entry*,signed long*,signed long*);
int(archive_entry_update_symlink_utf8)(struct archive_entry*,const char*);
int(archive_entry_sparse_count)(struct archive_entry*);
int(archive_write_add_filter_grzip)(struct archive*);
void(archive_entry_sparse_clear)(struct archive_entry*);
int(archive_entry_xattr_next)(struct archive_entry*,const char**,const void**,unsigned long*);
int(archive_entry_xattr_count)(struct archive_entry*);
int(archive_write_header)(struct archive*,struct archive_entry*);
int(archive_write_add_filter)(struct archive*,int);
int(archive_entry_ino_is_set)(struct archive_entry*);
int(archive_match_include_pattern)(struct archive*,const char*);
int(archive_write_set_format_xar)(struct archive*);
int(archive_write_set_options)(struct archive*,const char*);
int(archive_write_add_filter_lz4)(struct archive*);
int(archive_write_set_compression_gzip)(struct archive*);
int(archive_read_disk_can_descend)(struct archive*);
int(archive_read_support_filter_uu)(struct archive*);
const char*(archive_entry_gname_utf8)(struct archive_entry*);
int(archive_match_include_pattern_from_file)(struct archive*,const char*,int);
int(archive_write_open_memory)(struct archive*,void*,unsigned long,unsigned long*);
int(archive_write_add_filter_program)(struct archive*,const char*);
const char*(archive_entry_gname)(struct archive_entry*);
int(archive_read_open_FILE)(struct archive*,struct _IO_FILE*);
void(archive_copy_error)(struct archive*,struct archive*);
signed long(archive_entry_gid)(struct archive_entry*);
void(archive_entry_fflags)(struct archive_entry*,unsigned long*,unsigned long*);
void(archive_entry_unset_size)(struct archive_entry*);
void(archive_entry_copy_pathname_w)(struct archive_entry*,const int*);
void(archive_entry_copy_pathname)(struct archive_entry*,const char*);
void(archive_entry_set_pathname_utf8)(struct archive_entry*,const char*);
void(archive_entry_set_pathname)(struct archive_entry*,const char*);
void(archive_entry_set_mtime)(struct archive_entry*,long,long);
void(archive_entry_set_mode)(struct archive_entry*,unsigned int);
int(archive_entry_update_link_utf8)(struct archive_entry*,const char*);
void(archive_entry_copy_link_w)(struct archive_entry*,const int*);
void(archive_entry_copy_link)(struct archive_entry*,const char*);
void(archive_entry_set_link)(struct archive_entry*,const char*);
void(archive_entry_copy_hardlink_w)(struct archive_entry*,const int*);
void(archive_entry_set_hardlink)(struct archive_entry*,const char*);
int(archive_entry_update_gname_utf8)(struct archive_entry*,const char*);
void(archive_entry_copy_gname_w)(struct archive_entry*,const int*);
void(archive_entry_set_gname_utf8)(struct archive_entry*,const char*);
void(archive_entry_set_gname)(struct archive_entry*,const char*);
const int*(archive_entry_copy_fflags_text_w)(struct archive_entry*,const int*);
const char*(archive_entry_copy_fflags_text)(struct archive_entry*,const char*);
void(archive_entry_set_filetype)(struct archive_entry*,unsigned int);
void(archive_entry_set_dev)(struct archive_entry*,unsigned long);
void(archive_entry_unset_ctime)(struct archive_entry*);
void(archive_entry_set_ctime)(struct archive_entry*,long,long);
void(archive_entry_unset_birthtime)(struct archive_entry*);
void(archive_entry_set_atime)(struct archive_entry*,long,long);
int(archive_entry_is_encrypted)(struct archive_entry*);
const int*(archive_entry_uname_w)(struct archive_entry*);
const char*(archive_entry_uname_utf8)(struct archive_entry*);
const char*(archive_entry_uname)(struct archive_entry*);
const int*(archive_entry_symlink_w)(struct archive_entry*);
const char*(archive_entry_symlink_utf8)(struct archive_entry*);
const char*(archive_entry_symlink)(struct archive_entry*);
const char*(archive_entry_strmode)(struct archive_entry*);
const int*(archive_entry_sourcepath_w)(struct archive_entry*);
unsigned long(archive_entry_rdevmajor)(struct archive_entry*);
int(archive_write_add_filter_xz)(struct archive*);
unsigned long(archive_entry_rdev)(struct archive_entry*);
int(archive_read_set_format)(struct archive*,int);
void(archive_clear_error)(struct archive*);
unsigned int(archive_entry_perm)(struct archive_entry*);
const char*(archive_entry_pathname_utf8)(struct archive_entry*);
long(archive_entry_mtime)(struct archive_entry*);
int(archive_read_open_memory)(struct archive*,const void*,unsigned long);
long(archive_write_data_block)(struct archive*,const void*,unsigned long,signed long);
int(archive_match_exclude_entry)(struct archive*,int,struct archive_entry*);
int(archive_read_open2)(struct archive*,void*,int(unknown_3)(struct archive*,void*),long(unknown_4)(struct archive*,void*,const void**),signed long(unknown_5)(struct archive*,void*,signed long),int(unknown_6)(struct archive*,void*));
int(archive_read_prepend_callback_data)(struct archive*,void*);
int(archive_entry_sparse_reset)(struct archive_entry*);
int(archive_write_set_format_filter_by_ext)(struct archive*,const char*);
int(archive_read_support_format_lha)(struct archive*);
int(archive_read_free)(struct archive*);
int(archive_match_include_time)(struct archive*,int,long,long);
int(archive_free)(struct archive*);
int(archive_read_disk_set_behavior)(struct archive*,int);
int(archive_write_open)(struct archive*,void*,int(unknown_3)(struct archive*,void*),long(unknown_4)(struct archive*,void*,const void*,unsigned long),int(unknown_5)(struct archive*,void*));
struct archive_entry*(archive_entry_partial_links)(struct archive_entry_linkresolver*,unsigned int*);
void(archive_entry_linkresolver_set_strategy)(struct archive_entry_linkresolver*,int);
int(archive_write_add_filter_uuencode)(struct archive*);
struct archive_entry_linkresolver*(archive_entry_linkresolver_new)();
void(archive_entry_set_link_utf8)(struct archive_entry*,const char*);
long(archive_write_data)(struct archive*,const void*,unsigned long);
int(archive_match_include_uid)(struct archive*,signed long);
int(archive_match_include_file_time_w)(struct archive*,int,const int*);
int(archive_entry_xattr_reset)(struct archive_entry*);
void(archive_entry_copy_mac_metadata)(struct archive_entry*,const void*,unsigned long);
int(archive_filter_count)(struct archive*);
int(archive_match_path_unmatched_inclusions)(struct archive*);
void(archive_entry_xattr_clear)(struct archive_entry*);
struct archive_acl*(archive_entry_acl)(struct archive_entry*);
int(archive_entry_acl_count)(struct archive_entry*,int);
int(archive_entry_acl_types)(struct archive_entry*);
const char*(archive_entry_acl_text)(struct archive_entry*,int);
const int*(archive_entry_acl_text_w)(struct archive_entry*,int);
int(archive_read_set_callback_data)(struct archive*,void*);
int(archive_read_support_format_rar5)(struct archive*);
int(archive_entry_acl_from_text)(struct archive_entry*,const char*,int);
int(archive_write_set_format_mtree)(struct archive*);
int(archive_entry_acl_from_text_w)(struct archive_entry*,const int*,int);
int(archive_match_include_gid)(struct archive*,signed long);
char*(archive_entry_acl_to_text)(struct archive_entry*,long*,int);
int(archive_match_include_uname)(struct archive*,const char*);
int*(archive_entry_acl_to_text_w)(struct archive_entry*,long*,int);
int(archive_read_disk_set_standard_lookup)(struct archive*);
int(archive_entry_acl_next)(struct archive_entry*,int,int*,int*,int*,int*,const char**);
int(archive_read_extract)(struct archive*,struct archive_entry*,int);
int(archive_read_close)(struct archive*);
int(archive_entry_acl_reset)(struct archive_entry*,int);
int(archive_match_include_date_w)(struct archive*,int,const int*);
int(archive_entry_acl_add_entry_w)(struct archive_entry*,int,int,int,int,const int*);
int(archive_write_set_skip_file)(struct archive*,signed long,signed long);
int(archive_entry_acl_add_entry)(struct archive_entry*,int,int,int,int,const char*);
int(archive_read_support_format_tar)(struct archive*);
int(archive_write_add_filter_lrzip)(struct archive*);
const unsigned char*(archive_entry_digest)(struct archive_entry*,int);
void(archive_entry_xattr_add_entry)(struct archive_entry*,const char*,const void*,unsigned long);
const void*(archive_entry_mac_metadata)(struct archive_entry*,unsigned long*);
int(archive_write_add_filter_bzip2)(struct archive*);
void(archive_entry_copy_stat)(struct archive_entry*,const struct stat*);
int(archive_read_support_format_by_code)(struct archive*,int);
const struct stat*(archive_entry_stat)(struct archive_entry*);
int(archive_write_finish_entry)(struct archive*);
void(archive_entry_set_is_metadata_encrypted)(struct archive_entry*,char);
void(archive_entry_set_is_data_encrypted)(struct archive_entry*,char);
int(archive_entry_update_uname_utf8)(struct archive_entry*,const char*);
void(archive_entry_copy_uname_w)(struct archive_entry*,const int*);
void(archive_entry_copy_uname)(struct archive_entry*,const char*);
void(archive_entry_set_uname)(struct archive_entry*,const char*);
void(archive_entry_set_uid)(struct archive_entry*,signed long);
void(archive_entry_copy_symlink_w)(struct archive_entry*,const int*);
void(archive_entry_copy_symlink)(struct archive_entry*,const char*);
void(archive_entry_set_symlink_utf8)(struct archive_entry*,const char*);
void(archive_entry_set_symlink_type)(struct archive_entry*,int);
void(archive_entry_set_symlink)(struct archive_entry*,const char*);
void(archive_entry_copy_sourcepath_w)(struct archive_entry*,const int*);
void(archive_entry_copy_sourcepath)(struct archive_entry*,const char*);
void(archive_entry_set_rdevminor)(struct archive_entry*,unsigned long);
void(archive_entry_set_rdevmajor)(struct archive_entry*,unsigned long);
void(archive_entry_set_perm)(struct archive_entry*,unsigned int);
int(archive_entry_update_pathname_utf8)(struct archive_entry*,const char*);
void(archive_entry_set_ino64)(struct archive_entry*,signed long);
int(archive_read_support_compression_gzip)(struct archive*);
int(archive_entry_update_hardlink_utf8)(struct archive_entry*,const char*);
int(archive_read_support_format_gnutar)(struct archive*);
void(archive_entry_set_hardlink_utf8)(struct archive_entry*,const char*);
void(archive_entry_copy_gname)(struct archive_entry*,const char*);
void(archive_entry_set_gid)(struct archive_entry*,signed long);
int(archive_read_extract2)(struct archive*,struct archive_entry*,struct archive*);
int(archive_entry_is_metadata_encrypted)(struct archive_entry*);
int(archive_entry_is_data_encrypted)(struct archive_entry*);
int(archive_read_support_filter_zstd)(struct archive*);
int(archive_entry_symlink_type)(struct archive_entry*);
int(archive_entry_size_is_set)(struct archive_entry*);
signed long(archive_entry_size)(struct archive_entry*);
const char*(archive_entry_sourcepath)(struct archive_entry*);
const int*(archive_entry_pathname_w)(struct archive_entry*);
unsigned int(archive_entry_nlink)(struct archive_entry*);
int(archive_entry_mtime_is_set)(struct archive_entry*);
long(archive_entry_mtime_nsec)(struct archive_entry*);
int(archive_file_count)(struct archive*);
const char*(archive_filter_name)(struct archive*,int);
int(archive_read_disk_current_filesystem_is_synthetic)(struct archive*);
struct archive*(archive_read_disk_new)();
const char*(archive_entry_hardlink_utf8)(struct archive_entry*);
int(archive_read_support_format_zip_seekable)(struct archive*);
int(archive_read_disk_open_w)(struct archive*,const int*);
int(archive_write_set_passphrase_callback)(struct archive*,void*,const char*(unknown_3)(struct archive*,void*));
int(archive_read_set_callback_data2)(struct archive*,void*,unsigned int);
int(archive_read_support_compression_compress)(struct archive*);
int(archive_read_support_filter_all)(struct archive*);
int(archive_read_support_compression_bzip2)(struct archive*);
int(archive_entry_birthtime_is_set)(struct archive_entry*);
int(archive_write_open_fd)(struct archive*,int);
int(archive_entry_atime_is_set)(struct archive_entry*);
long(archive_entry_atime_nsec)(struct archive_entry*);
long(archive_entry_atime)(struct archive_entry*);
struct archive_entry*(archive_entry_new)();
void(archive_entry_free)(struct archive_entry*);
struct archive_entry*(archive_entry_clear)(struct archive_entry*);
int(archive_utility_string_sort)(char**);
int(archive_match_set_inclusion_recursion)(struct archive*,int);
unsigned int(archive_entry_mode)(struct archive_entry*);
signed long(archive_entry_ino64)(struct archive_entry*);
int(archive_match_free)(struct archive*);
signed long(archive_entry_ino)(struct archive_entry*);
const char*(archive_read_disk_uname)(struct archive*,signed long);
const int*(archive_entry_hardlink_w)(struct archive_entry*);
const char*(archive_entry_hardlink)(struct archive_entry*);
const int*(archive_entry_gname_w)(struct archive_entry*);
long(archive_entry_birthtime_nsec)(struct archive_entry*);
int(archive_read_support_format_7zip)(struct archive*);
long(archive_entry_birthtime)(struct archive_entry*);
int(archive_read_support_filter_lzma)(struct archive*);
int(archive_read_set_seek_callback)(struct archive*,signed long(unknown_2)(struct archive*,void*,signed long,int));
int(archive_write_set_format_pax)(struct archive*);
int(archive_read_support_compression_program_signature)(struct archive*,const char*,const void*,unsigned long);
const char*(archive_bzlib_version)();
signed long(archive_seek_data)(struct archive*,signed long,int);
int(archive_read_support_filter_rpm)(struct archive*);
int(archive_read_support_compression_program)(struct archive*,const char*);
int(archive_write_add_filter_by_name)(struct archive*,const char*);
int(archive_write_set_format_ar_svr4)(struct archive*);
int(archive_write_set_format_option)(struct archive*,const char*,const char*,const char*);
int(archive_read_support_compression_all)(struct archive*);
int(archive_read_support_compression_uu)(struct archive*);
int(archive_write_add_filter_zstd)(struct archive*);
const char*(archive_liblzma_version)();
int(archive_read_support_format_zip)(struct archive*);
int(archive_write_add_filter_b64encode)(struct archive*);
int(archive_read_append_filter_program_signature)(struct archive*,const char*,const void*,unsigned long);
int(archive_read_set_filter_option)(struct archive*,const char*,const char*,const char*);
int(archive_read_append_callback_data)(struct archive*,void*);
int(archive_read_support_format_empty)(struct archive*);
int(archive_read_has_encrypted_entries)(struct archive*);
int(archive_read_support_format_iso9660)(struct archive*);
int(archive_write_set_bytes_per_block)(struct archive*,int);
struct archive*(archive_write_new)();
int(archive_write_set_compression_compress)(struct archive*);
int(archive_read_finish)(struct archive*);
int(archive_write_set_compression_lzma)(struct archive*);
int(archive_write_set_format_raw)(struct archive*);
int(archive_write_set_compression_none)(struct archive*);
int(archive_write_add_filter_none)(struct archive*);
int(archive_read_open_filenames)(struct archive*,const char**,unsigned long);
int(archive_write_set_format_by_name)(struct archive*,const char*);
int(archive_write_set_format_ar_bsd)(struct archive*);
int(archive_read_set_open_callback)(struct archive*,int(unknown_2)(struct archive*,void*));
int(archive_write_set_format_mtree_classic)(struct archive*);
int(archive_write_open2)(struct archive*,void*,int(unknown_3)(struct archive*,void*),long(unknown_4)(struct archive*,void*,const void*,unsigned long),int(unknown_5)(struct archive*,void*),int(unknown_6)(struct archive*,void*));
int(archive_read_set_read_callback)(struct archive*,long(unknown_2)(struct archive*,void*,const void**));
int(archive_write_open_filename_w)(struct archive*,const int*);
int(archive_read_support_format_xar)(struct archive*);
int(archive_write_open_FILE)(struct archive*,struct _IO_FILE*);
int(archive_write_set_compression_bzip2)(struct archive*);
int(archive_write_zip_set_compression_deflate)(struct archive*);
int(archive_read_set_switch_callback)(struct archive*,int(unknown_2)(struct archive*,void*,void*));
int(archive_write_free)(struct archive*);
int(archive_read_add_passphrase)(struct archive*,const char*);
int(archive_read_next_header)(struct archive*,struct archive_entry**);
int(archive_write_open_file)(struct archive*,const char*);
int(archive_write_disk_set_standard_lookup)(struct archive*);
unsigned int(archive_entry_filetype)(struct archive_entry*);
struct archive*(archive_write_disk_new)();
unsigned long(archive_entry_devmajor)(struct archive_entry*);
int(archive_read_format_capabilities)(struct archive*);
int(archive_entry_dev_is_set)(struct archive_entry*);
int(archive_read_disk_set_atime_restored)(struct archive*);
unsigned long(archive_entry_dev)(struct archive_entry*);
int(archive_write_get_bytes_in_last_block)(struct archive*);
int(archive_entry_ctime_is_set)(struct archive_entry*);
int(archive_write_set_format_cpio)(struct archive*);
long(archive_entry_ctime_nsec)(struct archive_entry*);
int(archive_format)(struct archive*);
long(archive_read_data)(struct archive*,void*,unsigned long);
int(archive_write_set_format_shar)(struct archive*);
int(archive_match_exclude_pattern)(struct archive*,const char*);
int(archive_read_support_filter_program_signature)(struct archive*,const char*,const void*,unsigned long);
int(archive_match_exclude_pattern_from_file_w)(struct archive*,const int*,int);
int(archive_read_disk_open)(struct archive*,const char*);
int(archive_write_zip_set_compression_store)(struct archive*);
struct archive_entry*(archive_entry_new2)(struct archive*);
int(archive_match_time_excluded)(struct archive*,struct archive_entry*);
int(archive_read_support_filter_grzip)(struct archive*);
int(archive_write_open_filename)(struct archive*,const char*);
int(archive_match_include_file_time)(struct archive*,int,const char*);
int(archive_read_support_filter_lz4)(struct archive*);
signed long(archive_write_disk_gid)(struct archive*,const char*,signed long);
signed long(archive_position_compressed)(struct archive*);
unsigned long(archive_entry_devminor)(struct archive_entry*);
const char*(archive_compression_name)(struct archive*);
int(archive_write_set_format_v7tar)(struct archive*);
int(archive_write_set_compression_lzip)(struct archive*);
int(archive_read_disk_set_matching)(struct archive*,struct archive*,void(*_excluded_func)(struct archive*,void*,struct archive_entry*),void*);
int(archive_read_set_option)(struct archive*,const char*,const char*,const char*);
void(archive_entry_set_fflags)(struct archive_entry*,unsigned long,unsigned long);
int(archive_write_add_filter_lzip)(struct archive*);
void(archive_set_error)(struct archive*,int,const char*,...);
int(archive_read_disk_set_symlink_logical)(struct archive*);
int(archive_write_set_passphrase)(struct archive*,const char*);
void(archive_entry_sparse_add_entry)(struct archive_entry*,signed long,signed long);
int(archive_version_number)();
int(archive_match_path_unmatched_inclusions_next_w)(struct archive*,const int**);
unsigned long(archive_entry_rdevminor)(struct archive_entry*);
int(archive_write_finish)(struct archive*);
void(archive_entry_set_size)(struct archive_entry*,signed long);
int(archive_read_support_compression_xz)(struct archive*);
int(archive_read_support_filter_lzip)(struct archive*);
void(archive_entry_set_rdev)(struct archive_entry*,unsigned long);
int(archive_filter_code)(struct archive*,int);
int(archive_errno)(struct archive*);
const char*(archive_error_string)(struct archive*);
signed long(archive_position_uncompressed)(struct archive*);
void(archive_entry_acl_clear)(struct archive_entry*);
int(archive_read_open_file)(struct archive*,const char*,unsigned long);
struct archive*(archive_read_new)();
int(archive_read_support_format_raw)(struct archive*);
const char*(archive_read_disk_gname)(struct archive*,signed long);
int(archive_read_support_filter_compress)(struct archive*);
signed long(archive_read_header_position)(struct archive*);
int(archive_read_disk_current_filesystem)(struct archive*);
const char*(archive_version_string)();
int(archive_read_support_filter_bzip2)(struct archive*);
void(archive_entry_set_ino)(struct archive_entry*,signed long);
const char*(archive_libzstd_version)();
int(archive_read_disk_entry_from_file)(struct archive*,struct archive_entry*,int,const struct stat*);
int(archive_read_set_format_option)(struct archive*,const char*,const char*,const char*);
int(archive_write_set_format_pax_restricted)(struct archive*);
int(archive_read_support_format_warc)(struct archive*);
void(archive_entry_copy_hardlink)(struct archive_entry*,const char*);
int(archive_match_include_date)(struct archive*,int,const char*);
int(archive_read_disk_descend)(struct archive*);
void(archive_entry_set_devminor)(struct archive_entry*,unsigned long);
signed long(archive_entry_uid)(struct archive_entry*);
void(archive_entry_set_devmajor)(struct archive_entry*,unsigned long);
int(archive_match_include_gname_w)(struct archive*,const int*);
int(archive_write_set_format_warc)(struct archive*);
int(archive_read_support_format_all)(struct archive*);
int(archive_read_set_passphrase_callback)(struct archive*,void*,const char*(unknown_3)(struct archive*,void*));
int(archive_write_set_format_iso9660)(struct archive*);
int(archive_read_open_memory2)(struct archive*,const void*,unsigned long,unsigned long);
const char*(archive_format_name)(struct archive*);
int(archive_write_set_format_7zip)(struct archive*);
signed long(archive_write_disk_uid)(struct archive*,const char*,signed long);
int(archive_write_disk_set_skip_file)(struct archive*,signed long,signed long);
int(archive_write_set_format_cpio_newc)(struct archive*);
int(archive_read_support_compression_lzip)(struct archive*);
int(archive_write_set_format_cpio_odc)(struct archive*);
int(archive_read_set_close_callback)(struct archive*,int(unknown_2)(struct archive*,void*));
int(archive_read_data_into_fd)(struct archive*,int);
int(archive_write_set_format_ustar)(struct archive*);
int(archive_write_set_compression_program)(struct archive*,const char*);
int(archive_read_support_format_rar)(struct archive*);
int(archive_write_set_option)(struct archive*,const char*,const char*,const char*);
int(archive_write_fail)(struct archive*);
int(archive_read_open_filename)(struct archive*,const char*,unsigned long);
int(archive_write_set_bytes_in_last_block)(struct archive*,int);
int(archive_write_add_filter_compress)(struct archive*);
int(archive_read_next_header2)(struct archive*,struct archive_entry*);
const char*(archive_entry_fflags_text)(struct archive_entry*);
int(archive_read_open)(struct archive*,void*,int(unknown_3)(struct archive*,void*),long(unknown_4)(struct archive*,void*,const void**),int(unknown_5)(struct archive*,void*));
long(archive_entry_ctime)(struct archive_entry*);
signed long(archive_filter_bytes)(struct archive*,int);
int(archive_match_path_excluded)(struct archive*,struct archive_entry*);
int(archive_write_set_format_shar_dump)(struct archive*);
]])
local library = {}


--====helper safe_clib_index====
		function SAFE_INDEX(clib)
			return setmetatable({}, {__index = function(_, k)
				local ok, val = pcall(function() return clib[k] end)
				if ok then
					return val
				elseif clib_index then
					return clib_index(k)
				end
			end})
		end
	
--====helper safe_clib_index====

CLIB = SAFE_INDEX(CLIB)library = {
	EntryClone = CLIB.archive_entry_clone,
	ReadSupportFilterNone = CLIB.archive_read_support_filter_none,
	ReadOpen1 = CLIB.archive_read_open1,
	ReadDiskCurrentFilesystemIsRemote = CLIB.archive_read_disk_current_filesystem_is_remote,
	MatchOwnerExcluded = CLIB.archive_match_owner_excluded,
	WriteSetFormatCpioPwb = CLIB.archive_write_set_format_cpio_pwb,
	WriteClose = CLIB.archive_write_close,
	Liblz4Version = CLIB.archive_liblz4_version,
	WriteSetFormatFilterByExtDef = CLIB.archive_write_set_format_filter_by_ext_def,
	ReadSupportFilterByCode = CLIB.archive_read_support_filter_by_code,
	WriteSetFormatCpioBin = CLIB.archive_write_set_format_cpio_bin,
	ReadSupportFilterXz = CLIB.archive_read_support_filter_xz,
	WriteAddFilterLzma = CLIB.archive_write_add_filter_lzma,
	ReadDataBlock = CLIB.archive_read_data_block,
	VersionDetails = CLIB.archive_version_details,
	ReadSupportFilterProgram = CLIB.archive_read_support_filter_program,
	ReadExtractSetProgressCallback = CLIB.archive_read_extract_set_progress_callback,
	ReadSetOptions = CLIB.archive_read_set_options,
	WriteGetBytesPerBlock = CLIB.archive_write_get_bytes_per_block,
	WriteSetFormatZip = CLIB.archive_write_set_format_zip,
	ReadSetSkipCallback = CLIB.archive_read_set_skip_callback,
	ReadSupportCompressionNone = CLIB.archive_read_support_compression_none,
	MatchExcludePatternW = CLIB.archive_match_exclude_pattern_w,
	EntrySetNlink = CLIB.archive_entry_set_nlink,
	ReadSupportFormatAr = CLIB.archive_read_support_format_ar,
	ReadSupportFilterLrzip = CLIB.archive_read_support_filter_lrzip,
	EntryUnsetMtime = CLIB.archive_entry_unset_mtime,
	Compression = CLIB.archive_compression,
	MatchIncludeGname = CLIB.archive_match_include_gname,
	WriteAddFilterLzop = CLIB.archive_write_add_filter_lzop,
	MatchIncludePatternW = CLIB.archive_match_include_pattern_w,
	WriteDiskSetOptions = CLIB.archive_write_disk_set_options,
	ReadDataSkip = CLIB.archive_read_data_skip,
	ReadSupportFormatCab = CLIB.archive_read_support_format_cab,
	EntryUnsetAtime = CLIB.archive_entry_unset_atime,
	ReadSupportFilterLzop = CLIB.archive_read_support_filter_lzop,
	ReadSupportCompressionLzma = CLIB.archive_read_support_compression_lzma,
	ReadSupportFormatMtree = CLIB.archive_read_support_format_mtree,
	ReadSupportFormatCpio = CLIB.archive_read_support_format_cpio,
	MatchIncludePatternFromFileW = CLIB.archive_match_include_pattern_from_file_w,
	MatchIncludeUnameW = CLIB.archive_match_include_uname_w,
	ReadSupportFilterGzip = CLIB.archive_read_support_filter_gzip,
	MatchPathUnmatchedInclusionsNext = CLIB.archive_match_path_unmatched_inclusions_next,
	ReadOpenFilenameW = CLIB.archive_read_open_filename_w,
	MatchNew = CLIB.archive_match_new,
	ReadExtractSetSkipFile = CLIB.archive_read_extract_set_skip_file,
	ReadOpenFd = CLIB.archive_read_open_fd,
	MatchExcluded = CLIB.archive_match_excluded,
	MatchExcludePatternFromFile = CLIB.archive_match_exclude_pattern_from_file,
	ReadAppendFilter = CLIB.archive_read_append_filter,
	ReadAddCallbackData = CLIB.archive_read_add_callback_data,
	WriteSetFormatGnutar = CLIB.archive_write_set_format_gnutar,
	ReadDiskSetMetadataFilterCallback = CLIB.archive_read_disk_set_metadata_filter_callback,
	WriteAddFilterGzip = CLIB.archive_write_add_filter_gzip,
	ReadDiskSetSymlinkHybrid = CLIB.archive_read_disk_set_symlink_hybrid,
	ReadSupportCompressionRpm = CLIB.archive_read_support_compression_rpm,
	WriteSetCompressionXz = CLIB.archive_write_set_compression_xz,
	EntrySetUnameUtf8 = CLIB.archive_entry_set_uname_utf8,
	EntrySetBirthtime = CLIB.archive_entry_set_birthtime,
	ReadDiskSetSymlinkPhysical = CLIB.archive_read_disk_set_symlink_physical,
	WriteSetFormat = CLIB.archive_write_set_format,
	ZlibVersion = CLIB.archive_zlib_version,
	ReadSupportFormatZipStreamable = CLIB.archive_read_support_format_zip_streamable,
	EntryPathname = CLIB.archive_entry_pathname,
	EntryLinkify = CLIB.archive_entry_linkify,
	WriteSetFilterOption = CLIB.archive_write_set_filter_option,
	EntryLinkresolverFree = CLIB.archive_entry_linkresolver_free,
	ReadAppendFilterProgram = CLIB.archive_read_append_filter_program,
	EntrySparseNext = CLIB.archive_entry_sparse_next,
	EntryUpdateSymlinkUtf8 = CLIB.archive_entry_update_symlink_utf8,
	EntrySparseCount = CLIB.archive_entry_sparse_count,
	WriteAddFilterGrzip = CLIB.archive_write_add_filter_grzip,
	EntrySparseClear = CLIB.archive_entry_sparse_clear,
	EntryXattrNext = CLIB.archive_entry_xattr_next,
	EntryXattrCount = CLIB.archive_entry_xattr_count,
	WriteHeader = CLIB.archive_write_header,
	WriteAddFilter = CLIB.archive_write_add_filter,
	EntryInoIsSet = CLIB.archive_entry_ino_is_set,
	MatchIncludePattern = CLIB.archive_match_include_pattern,
	WriteSetFormatXar = CLIB.archive_write_set_format_xar,
	WriteSetOptions = CLIB.archive_write_set_options,
	WriteAddFilterLz4 = CLIB.archive_write_add_filter_lz4,
	WriteSetCompressionGzip = CLIB.archive_write_set_compression_gzip,
	ReadDiskCanDescend = CLIB.archive_read_disk_can_descend,
	ReadSupportFilterUu = CLIB.archive_read_support_filter_uu,
	EntryGnameUtf8 = CLIB.archive_entry_gname_utf8,
	MatchIncludePatternFromFile = CLIB.archive_match_include_pattern_from_file,
	WriteOpenMemory = CLIB.archive_write_open_memory,
	WriteAddFilterProgram = CLIB.archive_write_add_filter_program,
	EntryGname = CLIB.archive_entry_gname,
	ReadOpen_FILE = CLIB.archive_read_open_FILE,
	CopyError = CLIB.archive_copy_error,
	EntryGid = CLIB.archive_entry_gid,
	EntryFflags = CLIB.archive_entry_fflags,
	EntryUnsetSize = CLIB.archive_entry_unset_size,
	EntryCopyPathnameW = CLIB.archive_entry_copy_pathname_w,
	EntryCopyPathname = CLIB.archive_entry_copy_pathname,
	EntrySetPathnameUtf8 = CLIB.archive_entry_set_pathname_utf8,
	EntrySetPathname = CLIB.archive_entry_set_pathname,
	EntrySetMtime = CLIB.archive_entry_set_mtime,
	EntrySetMode = CLIB.archive_entry_set_mode,
	EntryUpdateLinkUtf8 = CLIB.archive_entry_update_link_utf8,
	EntryCopyLinkW = CLIB.archive_entry_copy_link_w,
	EntryCopyLink = CLIB.archive_entry_copy_link,
	EntrySetLink = CLIB.archive_entry_set_link,
	EntryCopyHardlinkW = CLIB.archive_entry_copy_hardlink_w,
	EntrySetHardlink = CLIB.archive_entry_set_hardlink,
	EntryUpdateGnameUtf8 = CLIB.archive_entry_update_gname_utf8,
	EntryCopyGnameW = CLIB.archive_entry_copy_gname_w,
	EntrySetGnameUtf8 = CLIB.archive_entry_set_gname_utf8,
	EntrySetGname = CLIB.archive_entry_set_gname,
	EntryCopyFflagsTextW = CLIB.archive_entry_copy_fflags_text_w,
	EntryCopyFflagsText = CLIB.archive_entry_copy_fflags_text,
	EntrySetFiletype = CLIB.archive_entry_set_filetype,
	EntrySetDev = CLIB.archive_entry_set_dev,
	EntryUnsetCtime = CLIB.archive_entry_unset_ctime,
	EntrySetCtime = CLIB.archive_entry_set_ctime,
	EntryUnsetBirthtime = CLIB.archive_entry_unset_birthtime,
	EntrySetAtime = CLIB.archive_entry_set_atime,
	EntryIsEncrypted = CLIB.archive_entry_is_encrypted,
	EntryUnameW = CLIB.archive_entry_uname_w,
	EntryUnameUtf8 = CLIB.archive_entry_uname_utf8,
	EntryUname = CLIB.archive_entry_uname,
	EntrySymlinkW = CLIB.archive_entry_symlink_w,
	EntrySymlinkUtf8 = CLIB.archive_entry_symlink_utf8,
	EntrySymlink = CLIB.archive_entry_symlink,
	EntryStrmode = CLIB.archive_entry_strmode,
	EntrySourcepathW = CLIB.archive_entry_sourcepath_w,
	EntryRdevmajor = CLIB.archive_entry_rdevmajor,
	WriteAddFilterXz = CLIB.archive_write_add_filter_xz,
	EntryRdev = CLIB.archive_entry_rdev,
	ReadSetFormat = CLIB.archive_read_set_format,
	ClearError = CLIB.archive_clear_error,
	EntryPerm = CLIB.archive_entry_perm,
	EntryPathnameUtf8 = CLIB.archive_entry_pathname_utf8,
	EntryMtime = CLIB.archive_entry_mtime,
	ReadOpenMemory = CLIB.archive_read_open_memory,
	WriteDataBlock = CLIB.archive_write_data_block,
	MatchExcludeEntry = CLIB.archive_match_exclude_entry,
	ReadOpen2 = CLIB.archive_read_open2,
	ReadPrependCallbackData = CLIB.archive_read_prepend_callback_data,
	EntrySparseReset = CLIB.archive_entry_sparse_reset,
	WriteSetFormatFilterByExt = CLIB.archive_write_set_format_filter_by_ext,
	ReadSupportFormatLha = CLIB.archive_read_support_format_lha,
	ReadFree = CLIB.archive_read_free,
	MatchIncludeTime = CLIB.archive_match_include_time,
	Free = CLIB.archive_free,
	ReadDiskSetBehavior = CLIB.archive_read_disk_set_behavior,
	WriteOpen = CLIB.archive_write_open,
	EntryPartialLinks = CLIB.archive_entry_partial_links,
	EntryLinkresolverSetStrategy = CLIB.archive_entry_linkresolver_set_strategy,
	WriteAddFilterUuencode = CLIB.archive_write_add_filter_uuencode,
	EntryLinkresolverNew = CLIB.archive_entry_linkresolver_new,
	EntrySetLinkUtf8 = CLIB.archive_entry_set_link_utf8,
	WriteData = CLIB.archive_write_data,
	MatchIncludeUid = CLIB.archive_match_include_uid,
	MatchIncludeFileTimeW = CLIB.archive_match_include_file_time_w,
	EntryXattrReset = CLIB.archive_entry_xattr_reset,
	EntryCopyMacMetadata = CLIB.archive_entry_copy_mac_metadata,
	FilterCount = CLIB.archive_filter_count,
	MatchPathUnmatchedInclusions = CLIB.archive_match_path_unmatched_inclusions,
	EntryXattrClear = CLIB.archive_entry_xattr_clear,
	EntryAcl = CLIB.archive_entry_acl,
	EntryAclCount = CLIB.archive_entry_acl_count,
	EntryAclTypes = CLIB.archive_entry_acl_types,
	EntryAclText = CLIB.archive_entry_acl_text,
	EntryAclTextW = CLIB.archive_entry_acl_text_w,
	ReadSetCallbackData = CLIB.archive_read_set_callback_data,
	ReadSupportFormatRar5 = CLIB.archive_read_support_format_rar5,
	EntryAclFromText = CLIB.archive_entry_acl_from_text,
	WriteSetFormatMtree = CLIB.archive_write_set_format_mtree,
	EntryAclFromTextW = CLIB.archive_entry_acl_from_text_w,
	MatchIncludeGid = CLIB.archive_match_include_gid,
	EntryAclToText = CLIB.archive_entry_acl_to_text,
	MatchIncludeUname = CLIB.archive_match_include_uname,
	EntryAclToTextW = CLIB.archive_entry_acl_to_text_w,
	ReadDiskSetStandardLookup = CLIB.archive_read_disk_set_standard_lookup,
	EntryAclNext = CLIB.archive_entry_acl_next,
	ReadExtract = CLIB.archive_read_extract,
	ReadClose = CLIB.archive_read_close,
	EntryAclReset = CLIB.archive_entry_acl_reset,
	MatchIncludeDateW = CLIB.archive_match_include_date_w,
	EntryAclAddEntryW = CLIB.archive_entry_acl_add_entry_w,
	WriteSetSkipFile = CLIB.archive_write_set_skip_file,
	EntryAclAddEntry = CLIB.archive_entry_acl_add_entry,
	ReadSupportFormatTar = CLIB.archive_read_support_format_tar,
	WriteAddFilterLrzip = CLIB.archive_write_add_filter_lrzip,
	EntryDigest = CLIB.archive_entry_digest,
	EntryXattrAddEntry = CLIB.archive_entry_xattr_add_entry,
	EntryMacMetadata = CLIB.archive_entry_mac_metadata,
	WriteAddFilterBzip2 = CLIB.archive_write_add_filter_bzip2,
	EntryCopyStat = CLIB.archive_entry_copy_stat,
	ReadSupportFormatByCode = CLIB.archive_read_support_format_by_code,
	EntryStat = CLIB.archive_entry_stat,
	WriteFinishEntry = CLIB.archive_write_finish_entry,
	EntrySetIsMetadataEncrypted = CLIB.archive_entry_set_is_metadata_encrypted,
	EntrySetIsDataEncrypted = CLIB.archive_entry_set_is_data_encrypted,
	EntryUpdateUnameUtf8 = CLIB.archive_entry_update_uname_utf8,
	EntryCopyUnameW = CLIB.archive_entry_copy_uname_w,
	EntryCopyUname = CLIB.archive_entry_copy_uname,
	EntrySetUname = CLIB.archive_entry_set_uname,
	EntrySetUid = CLIB.archive_entry_set_uid,
	EntryCopySymlinkW = CLIB.archive_entry_copy_symlink_w,
	EntryCopySymlink = CLIB.archive_entry_copy_symlink,
	EntrySetSymlinkUtf8 = CLIB.archive_entry_set_symlink_utf8,
	EntrySetSymlinkType = CLIB.archive_entry_set_symlink_type,
	EntrySetSymlink = CLIB.archive_entry_set_symlink,
	EntryCopySourcepathW = CLIB.archive_entry_copy_sourcepath_w,
	EntryCopySourcepath = CLIB.archive_entry_copy_sourcepath,
	EntrySetRdevminor = CLIB.archive_entry_set_rdevminor,
	EntrySetRdevmajor = CLIB.archive_entry_set_rdevmajor,
	EntrySetPerm = CLIB.archive_entry_set_perm,
	EntryUpdatePathnameUtf8 = CLIB.archive_entry_update_pathname_utf8,
	EntrySetIno64 = CLIB.archive_entry_set_ino64,
	ReadSupportCompressionGzip = CLIB.archive_read_support_compression_gzip,
	EntryUpdateHardlinkUtf8 = CLIB.archive_entry_update_hardlink_utf8,
	ReadSupportFormatGnutar = CLIB.archive_read_support_format_gnutar,
	EntrySetHardlinkUtf8 = CLIB.archive_entry_set_hardlink_utf8,
	EntryCopyGname = CLIB.archive_entry_copy_gname,
	EntrySetGid = CLIB.archive_entry_set_gid,
	ReadExtract2 = CLIB.archive_read_extract2,
	EntryIsMetadataEncrypted = CLIB.archive_entry_is_metadata_encrypted,
	EntryIsDataEncrypted = CLIB.archive_entry_is_data_encrypted,
	ReadSupportFilterZstd = CLIB.archive_read_support_filter_zstd,
	EntrySymlinkType = CLIB.archive_entry_symlink_type,
	EntrySizeIsSet = CLIB.archive_entry_size_is_set,
	EntrySize = CLIB.archive_entry_size,
	EntrySourcepath = CLIB.archive_entry_sourcepath,
	EntryPathnameW = CLIB.archive_entry_pathname_w,
	EntryNlink = CLIB.archive_entry_nlink,
	EntryMtimeIsSet = CLIB.archive_entry_mtime_is_set,
	EntryMtimeNsec = CLIB.archive_entry_mtime_nsec,
	FileCount = CLIB.archive_file_count,
	FilterName = CLIB.archive_filter_name,
	ReadDiskCurrentFilesystemIsSynthetic = CLIB.archive_read_disk_current_filesystem_is_synthetic,
	ReadDiskNew = CLIB.archive_read_disk_new,
	EntryHardlinkUtf8 = CLIB.archive_entry_hardlink_utf8,
	ReadSupportFormatZipSeekable = CLIB.archive_read_support_format_zip_seekable,
	ReadDiskOpenW = CLIB.archive_read_disk_open_w,
	WriteSetPassphraseCallback = CLIB.archive_write_set_passphrase_callback,
	ReadSetCallbackData2 = CLIB.archive_read_set_callback_data2,
	ReadSupportCompressionCompress = CLIB.archive_read_support_compression_compress,
	ReadSupportFilterAll = CLIB.archive_read_support_filter_all,
	ReadSupportCompressionBzip2 = CLIB.archive_read_support_compression_bzip2,
	EntryBirthtimeIsSet = CLIB.archive_entry_birthtime_is_set,
	WriteOpenFd = CLIB.archive_write_open_fd,
	EntryAtimeIsSet = CLIB.archive_entry_atime_is_set,
	EntryAtimeNsec = CLIB.archive_entry_atime_nsec,
	EntryAtime = CLIB.archive_entry_atime,
	EntryNew = CLIB.archive_entry_new,
	EntryFree = CLIB.archive_entry_free,
	EntryClear = CLIB.archive_entry_clear,
	UtilityStringSort = CLIB.archive_utility_string_sort,
	MatchSetInclusionRecursion = CLIB.archive_match_set_inclusion_recursion,
	EntryMode = CLIB.archive_entry_mode,
	EntryIno64 = CLIB.archive_entry_ino64,
	MatchFree = CLIB.archive_match_free,
	EntryIno = CLIB.archive_entry_ino,
	ReadDiskUname = CLIB.archive_read_disk_uname,
	EntryHardlinkW = CLIB.archive_entry_hardlink_w,
	EntryHardlink = CLIB.archive_entry_hardlink,
	EntryGnameW = CLIB.archive_entry_gname_w,
	EntryBirthtimeNsec = CLIB.archive_entry_birthtime_nsec,
	ReadSupportFormat_7zip = CLIB.archive_read_support_format_7zip,
	EntryBirthtime = CLIB.archive_entry_birthtime,
	ReadSupportFilterLzma = CLIB.archive_read_support_filter_lzma,
	ReadSetSeekCallback = CLIB.archive_read_set_seek_callback,
	WriteSetFormatPax = CLIB.archive_write_set_format_pax,
	ReadSupportCompressionProgramSignature = CLIB.archive_read_support_compression_program_signature,
	BzlibVersion = CLIB.archive_bzlib_version,
	SeekData = CLIB.archive_seek_data,
	ReadSupportFilterRpm = CLIB.archive_read_support_filter_rpm,
	ReadSupportCompressionProgram = CLIB.archive_read_support_compression_program,
	WriteAddFilterByName = CLIB.archive_write_add_filter_by_name,
	WriteSetFormatArSvr4 = CLIB.archive_write_set_format_ar_svr4,
	WriteSetFormatOption = CLIB.archive_write_set_format_option,
	ReadSupportCompressionAll = CLIB.archive_read_support_compression_all,
	ReadSupportCompressionUu = CLIB.archive_read_support_compression_uu,
	WriteAddFilterZstd = CLIB.archive_write_add_filter_zstd,
	LiblzmaVersion = CLIB.archive_liblzma_version,
	ReadSupportFormatZip = CLIB.archive_read_support_format_zip,
	WriteAddFilterB64encode = CLIB.archive_write_add_filter_b64encode,
	ReadAppendFilterProgramSignature = CLIB.archive_read_append_filter_program_signature,
	ReadSetFilterOption = CLIB.archive_read_set_filter_option,
	ReadAppendCallbackData = CLIB.archive_read_append_callback_data,
	ReadSupportFormatEmpty = CLIB.archive_read_support_format_empty,
	ReadHasEncryptedEntries = CLIB.archive_read_has_encrypted_entries,
	ReadSupportFormatIso9660 = CLIB.archive_read_support_format_iso9660,
	WriteSetBytesPerBlock = CLIB.archive_write_set_bytes_per_block,
	WriteNew = CLIB.archive_write_new,
	WriteSetCompressionCompress = CLIB.archive_write_set_compression_compress,
	ReadFinish = CLIB.archive_read_finish,
	WriteSetCompressionLzma = CLIB.archive_write_set_compression_lzma,
	WriteSetFormatRaw = CLIB.archive_write_set_format_raw,
	WriteSetCompressionNone = CLIB.archive_write_set_compression_none,
	WriteAddFilterNone = CLIB.archive_write_add_filter_none,
	ReadOpenFilenames = CLIB.archive_read_open_filenames,
	WriteSetFormatByName = CLIB.archive_write_set_format_by_name,
	WriteSetFormatArBsd = CLIB.archive_write_set_format_ar_bsd,
	ReadSetOpenCallback = CLIB.archive_read_set_open_callback,
	WriteSetFormatMtreeClassic = CLIB.archive_write_set_format_mtree_classic,
	WriteOpen2 = CLIB.archive_write_open2,
	ReadSetReadCallback = CLIB.archive_read_set_read_callback,
	WriteOpenFilenameW = CLIB.archive_write_open_filename_w,
	ReadSupportFormatXar = CLIB.archive_read_support_format_xar,
	WriteOpen_FILE = CLIB.archive_write_open_FILE,
	WriteSetCompressionBzip2 = CLIB.archive_write_set_compression_bzip2,
	WriteZipSetCompressionDeflate = CLIB.archive_write_zip_set_compression_deflate,
	ReadSetSwitchCallback = CLIB.archive_read_set_switch_callback,
	WriteFree = CLIB.archive_write_free,
	ReadAddPassphrase = CLIB.archive_read_add_passphrase,
	ReadNextHeader = CLIB.archive_read_next_header,
	WriteOpenFile = CLIB.archive_write_open_file,
	WriteDiskSetStandardLookup = CLIB.archive_write_disk_set_standard_lookup,
	EntryFiletype = CLIB.archive_entry_filetype,
	WriteDiskNew = CLIB.archive_write_disk_new,
	EntryDevmajor = CLIB.archive_entry_devmajor,
	ReadFormatCapabilities = CLIB.archive_read_format_capabilities,
	EntryDevIsSet = CLIB.archive_entry_dev_is_set,
	ReadDiskSetAtimeRestored = CLIB.archive_read_disk_set_atime_restored,
	EntryDev = CLIB.archive_entry_dev,
	WriteGetBytesInLastBlock = CLIB.archive_write_get_bytes_in_last_block,
	EntryCtimeIsSet = CLIB.archive_entry_ctime_is_set,
	WriteSetFormatCpio = CLIB.archive_write_set_format_cpio,
	EntryCtimeNsec = CLIB.archive_entry_ctime_nsec,
	Format = CLIB.archive_format,
	ReadData = CLIB.archive_read_data,
	WriteSetFormatShar = CLIB.archive_write_set_format_shar,
	MatchExcludePattern = CLIB.archive_match_exclude_pattern,
	ReadSupportFilterProgramSignature = CLIB.archive_read_support_filter_program_signature,
	MatchExcludePatternFromFileW = CLIB.archive_match_exclude_pattern_from_file_w,
	ReadDiskOpen = CLIB.archive_read_disk_open,
	WriteZipSetCompressionStore = CLIB.archive_write_zip_set_compression_store,
	EntryNew2 = CLIB.archive_entry_new2,
	MatchTimeExcluded = CLIB.archive_match_time_excluded,
	ReadSupportFilterGrzip = CLIB.archive_read_support_filter_grzip,
	WriteOpenFilename = CLIB.archive_write_open_filename,
	MatchIncludeFileTime = CLIB.archive_match_include_file_time,
	ReadSupportFilterLz4 = CLIB.archive_read_support_filter_lz4,
	WriteDiskGid = CLIB.archive_write_disk_gid,
	PositionCompressed = CLIB.archive_position_compressed,
	EntryDevminor = CLIB.archive_entry_devminor,
	CompressionName = CLIB.archive_compression_name,
	WriteSetFormatV7tar = CLIB.archive_write_set_format_v7tar,
	WriteSetCompressionLzip = CLIB.archive_write_set_compression_lzip,
	ReadDiskSetMatching = CLIB.archive_read_disk_set_matching,
	ReadSetOption = CLIB.archive_read_set_option,
	EntrySetFflags = CLIB.archive_entry_set_fflags,
	WriteAddFilterLzip = CLIB.archive_write_add_filter_lzip,
	SetError = CLIB.archive_set_error,
	ReadDiskSetSymlinkLogical = CLIB.archive_read_disk_set_symlink_logical,
	WriteSetPassphrase = CLIB.archive_write_set_passphrase,
	EntrySparseAddEntry = CLIB.archive_entry_sparse_add_entry,
	VersionNumber = CLIB.archive_version_number,
	MatchPathUnmatchedInclusionsNextW = CLIB.archive_match_path_unmatched_inclusions_next_w,
	EntryRdevminor = CLIB.archive_entry_rdevminor,
	WriteFinish = CLIB.archive_write_finish,
	EntrySetSize = CLIB.archive_entry_set_size,
	ReadSupportCompressionXz = CLIB.archive_read_support_compression_xz,
	ReadSupportFilterLzip = CLIB.archive_read_support_filter_lzip,
	EntrySetRdev = CLIB.archive_entry_set_rdev,
	FilterCode = CLIB.archive_filter_code,
	Errno = CLIB.archive_errno,
	ErrorString = CLIB.archive_error_string,
	PositionUncompressed = CLIB.archive_position_uncompressed,
	EntryAclClear = CLIB.archive_entry_acl_clear,
	ReadOpenFile = CLIB.archive_read_open_file,
	ReadNew = CLIB.archive_read_new,
	ReadSupportFormatRaw = CLIB.archive_read_support_format_raw,
	ReadDiskGname = CLIB.archive_read_disk_gname,
	ReadSupportFilterCompress = CLIB.archive_read_support_filter_compress,
	ReadHeaderPosition = CLIB.archive_read_header_position,
	ReadDiskCurrentFilesystem = CLIB.archive_read_disk_current_filesystem,
	VersionString = CLIB.archive_version_string,
	ReadSupportFilterBzip2 = CLIB.archive_read_support_filter_bzip2,
	EntrySetIno = CLIB.archive_entry_set_ino,
	LibzstdVersion = CLIB.archive_libzstd_version,
	ReadDiskEntryFromFile = CLIB.archive_read_disk_entry_from_file,
	ReadSetFormatOption = CLIB.archive_read_set_format_option,
	WriteSetFormatPaxRestricted = CLIB.archive_write_set_format_pax_restricted,
	ReadSupportFormatWarc = CLIB.archive_read_support_format_warc,
	EntryCopyHardlink = CLIB.archive_entry_copy_hardlink,
	MatchIncludeDate = CLIB.archive_match_include_date,
	ReadDiskDescend = CLIB.archive_read_disk_descend,
	EntrySetDevminor = CLIB.archive_entry_set_devminor,
	EntryUid = CLIB.archive_entry_uid,
	EntrySetDevmajor = CLIB.archive_entry_set_devmajor,
	MatchIncludeGnameW = CLIB.archive_match_include_gname_w,
	WriteSetFormatWarc = CLIB.archive_write_set_format_warc,
	ReadSupportFormatAll = CLIB.archive_read_support_format_all,
	ReadSetPassphraseCallback = CLIB.archive_read_set_passphrase_callback,
	WriteSetFormatIso9660 = CLIB.archive_write_set_format_iso9660,
	ReadOpenMemory2 = CLIB.archive_read_open_memory2,
	FormatName = CLIB.archive_format_name,
	WriteSetFormat_7zip = CLIB.archive_write_set_format_7zip,
	WriteDiskUid = CLIB.archive_write_disk_uid,
	WriteDiskSetSkipFile = CLIB.archive_write_disk_set_skip_file,
	WriteSetFormatCpioNewc = CLIB.archive_write_set_format_cpio_newc,
	ReadSupportCompressionLzip = CLIB.archive_read_support_compression_lzip,
	WriteSetFormatCpioOdc = CLIB.archive_write_set_format_cpio_odc,
	ReadSetCloseCallback = CLIB.archive_read_set_close_callback,
	ReadDataIntoFd = CLIB.archive_read_data_into_fd,
	WriteSetFormatUstar = CLIB.archive_write_set_format_ustar,
	WriteSetCompressionProgram = CLIB.archive_write_set_compression_program,
	ReadSupportFormatRar = CLIB.archive_read_support_format_rar,
	WriteSetOption = CLIB.archive_write_set_option,
	WriteFail = CLIB.archive_write_fail,
	ReadOpenFilename = CLIB.archive_read_open_filename,
	WriteSetBytesInLastBlock = CLIB.archive_write_set_bytes_in_last_block,
	WriteAddFilterCompress = CLIB.archive_write_add_filter_compress,
	ReadNextHeader2 = CLIB.archive_read_next_header2,
	EntryFflagsText = CLIB.archive_entry_fflags_text,
	ReadOpen = CLIB.archive_read_open,
	EntryCtime = CLIB.archive_entry_ctime,
	FilterBytes = CLIB.archive_filter_bytes,
	MatchPathExcluded = CLIB.archive_match_path_excluded,
	WriteSetFormatSharDump = CLIB.archive_write_set_format_shar_dump,
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
