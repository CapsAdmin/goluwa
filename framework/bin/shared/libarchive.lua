local ffi = require("ffi");local CLIB = assert(ffi.load("libarchive"));ffi.cdef([[struct archive {};
struct archive_entry {};
struct archive_acl {};
struct archive_entry_linkresolver {};
void(archive_entry_copy_stat)(struct archive_entry*,const struct stat*);
const void*(archive_entry_mac_metadata)(struct archive_entry*,unsigned long*);
void(archive_entry_copy_mac_metadata)(struct archive_entry*,const void*,unsigned long);
const unsigned char*(archive_entry_digest)(struct archive_entry*,int);
void(archive_entry_acl_clear)(struct archive_entry*);
int(archive_entry_acl_add_entry)(struct archive_entry*,int,int,int,int,const char*);
int(archive_entry_acl_add_entry_w)(struct archive_entry*,int,int,int,int,const int*);
int(archive_entry_acl_reset)(struct archive_entry*,int);
int(archive_entry_acl_next)(struct archive_entry*,int,int*,int*,int*,int*,const char**);
int*(archive_entry_acl_to_text_w)(struct archive_entry*,long*,int);
char*(archive_entry_acl_to_text)(struct archive_entry*,long*,int);
int(archive_entry_acl_from_text_w)(struct archive_entry*,const int*,int);
int(archive_entry_acl_from_text)(struct archive_entry*,const char*,int);
const int*(archive_entry_acl_text_w)(struct archive_entry*,int);
const char*(archive_entry_acl_text)(struct archive_entry*,int);
int(archive_entry_acl_types)(struct archive_entry*);
int(archive_entry_acl_count)(struct archive_entry*,int);
struct archive_acl*(archive_entry_acl)(struct archive_entry*);
void(archive_entry_xattr_clear)(struct archive_entry*);
void(archive_entry_xattr_add_entry)(struct archive_entry*,const char*,const void*,unsigned long);
int(archive_entry_xattr_count)(struct archive_entry*);
int(archive_entry_xattr_reset)(struct archive_entry*);
int(archive_entry_xattr_next)(struct archive_entry*,const char**,const void**,unsigned long*);
void(archive_entry_sparse_clear)(struct archive_entry*);
void(archive_entry_sparse_add_entry)(struct archive_entry*,signed long,signed long);
int(archive_entry_sparse_count)(struct archive_entry*);
int(archive_entry_sparse_reset)(struct archive_entry*);
int(archive_entry_sparse_next)(struct archive_entry*,signed long*,signed long*);
struct archive_entry_linkresolver*(archive_entry_linkresolver_new)();
void(archive_entry_linkresolver_free)(struct archive_entry_linkresolver*);
int(archive_entry_update_gname_utf8)(struct archive_entry*,const char*);
void(archive_entry_set_hardlink)(struct archive_entry*,const char*);
void(archive_entry_set_hardlink_utf8)(struct archive_entry*,const char*);
void(archive_entry_copy_hardlink)(struct archive_entry*,const char*);
int(archive_entry_update_hardlink_utf8)(struct archive_entry*,const char*);
void(archive_entry_set_ino)(struct archive_entry*,signed long);
void(archive_entry_set_ino64)(struct archive_entry*,signed long);
void(archive_entry_set_link)(struct archive_entry*,const char*);
void(archive_entry_copy_link)(struct archive_entry*,const char*);
int(archive_entry_update_link_utf8)(struct archive_entry*,const char*);
void(archive_entry_set_mode)(struct archive_entry*,unsigned int);
void(archive_entry_set_mtime)(struct archive_entry*,long,long);
void(archive_entry_unset_mtime)(struct archive_entry*);
void(archive_entry_set_pathname)(struct archive_entry*,const char*);
void(archive_entry_set_pathname_utf8)(struct archive_entry*,const char*);
void(archive_entry_copy_pathname_w)(struct archive_entry*,const int*);
int(archive_entry_update_pathname_utf8)(struct archive_entry*,const char*);
void(archive_entry_set_perm)(struct archive_entry*,unsigned int);
void(archive_entry_set_rdevmajor)(struct archive_entry*,unsigned long);
void(archive_entry_set_rdevminor)(struct archive_entry*,unsigned long);
void(archive_entry_unset_size)(struct archive_entry*);
void(archive_entry_copy_sourcepath_w)(struct archive_entry*,const int*);
void(archive_entry_set_symlink)(struct archive_entry*,const char*);
void(archive_entry_copy_symlink)(struct archive_entry*,const char*);
void(archive_entry_copy_uname_w)(struct archive_entry*,const int*);
int(archive_read_open_filenames)(struct archive*,const char**,unsigned long);
int(archive_read_open_filename_w)(struct archive*,const int*,unsigned long);
int(archive_read_open_memory)(struct archive*,const void*,unsigned long);
int(archive_read_open_memory2)(struct archive*,const void*,unsigned long,unsigned long);
int(archive_read_open_fd)(struct archive*,int,unsigned long);
int(archive_read_open_FILE)(struct archive*,struct _IO_FILE*);
int(archive_read_next_header2)(struct archive*,struct archive_entry*);
int(archive_read_has_encrypted_entries)(struct archive*);
int(archive_read_format_capabilities)(struct archive*);
long(archive_read_data)(struct archive*,void*,unsigned long);
unsigned int(archive_entry_mode)(struct archive_entry*);
int(archive_read_disk_set_symlink_logical)(struct archive*);
long(archive_entry_mtime)(struct archive_entry*);
int(archive_read_disk_set_symlink_physical)(struct archive*);
int(archive_read_data_block)(struct archive*,const void**,unsigned long*,signed long*);
int(archive_read_disk_set_symlink_hybrid)(struct archive*);
long(archive_entry_mtime_nsec)(struct archive_entry*);
int(archive_read_disk_entry_from_file)(struct archive*,struct archive_entry*,int,const struct stat*);
int(archive_entry_mtime_is_set)(struct archive_entry*);
int(archive_read_data_into_fd)(struct archive*,int);
const char*(archive_read_disk_gname)(struct archive*,signed long);
int(archive_read_set_format_option)(struct archive*,const char*,const char*,const char*);
const char*(archive_read_disk_uname)(struct archive*,signed long);
int(archive_read_disk_set_standard_lookup)(struct archive*);
int(archive_read_set_option)(struct archive*,const char*,const char*,const char*);
int(archive_read_set_options)(struct archive*,const char*);
unsigned long(archive_entry_rdev)(struct archive_entry*);
int(archive_read_add_passphrase)(struct archive*,const char*);
unsigned long(archive_entry_rdevmajor)(struct archive_entry*);
int(archive_read_disk_open)(struct archive*,const char*);
int(archive_read_disk_open_w)(struct archive*,const int*);
int(archive_read_extract)(struct archive*,struct archive_entry*,int);
int(archive_read_disk_descend)(struct archive*);
int(archive_read_extract2)(struct archive*,struct archive_entry*,struct archive*);
int(archive_read_disk_can_descend)(struct archive*);
int(archive_read_disk_current_filesystem)(struct archive*);
void(archive_read_extract_set_progress_callback)(struct archive*,void(*_progress_func)(void*),void*);
int(archive_read_disk_current_filesystem_is_synthetic)(struct archive*);
int(archive_read_disk_current_filesystem_is_remote)(struct archive*);
int(archive_read_disk_set_atime_restored)(struct archive*);
int(archive_read_close)(struct archive*);
int(archive_read_disk_set_behavior)(struct archive*,int);
int(archive_read_free)(struct archive*);
int(archive_read_disk_set_matching)(struct archive*,struct archive*,void(*_excluded_func)(struct archive*,void*,struct archive_entry*),void*);
int(archive_read_finish)(struct archive*);
signed long(archive_entry_uid)(struct archive_entry*);
int(archive_read_disk_set_metadata_filter_callback)(struct archive*,int(*_metadata_filter_func)(struct archive*,void*,struct archive_entry*),void*);
int(archive_write_set_bytes_per_block)(struct archive*,int);
int(archive_free)(struct archive*);
int(archive_filter_count)(struct archive*);
signed long(archive_filter_bytes)(struct archive*,int);
int(archive_filter_code)(struct archive*,int);
int(archive_write_get_bytes_in_last_block)(struct archive*);
const char*(archive_filter_name)(struct archive*,int);
int(archive_write_set_skip_file)(struct archive*,signed long,signed long);
signed long(archive_position_compressed)(struct archive*);
int(archive_write_set_compression_bzip2)(struct archive*);
signed long(archive_position_uncompressed)(struct archive*);
int(archive_write_set_compression_compress)(struct archive*);
const char*(archive_compression_name)(struct archive*);
int(archive_write_set_compression_gzip)(struct archive*);
int(archive_compression)(struct archive*);
int(archive_write_set_compression_lzip)(struct archive*);
int(archive_errno)(struct archive*);
int(archive_write_set_compression_lzma)(struct archive*);
const char*(archive_error_string)(struct archive*);
int(archive_write_set_compression_none)(struct archive*);
const char*(archive_format_name)(struct archive*);
int(archive_write_set_compression_program)(struct archive*,const char*);
int(archive_format)(struct archive*);
void(archive_clear_error)(struct archive*);
void(archive_set_error)(struct archive*,int,const char*,...);
void(archive_copy_error)(struct archive*,struct archive*);
int(archive_file_count)(struct archive*);
struct archive*(archive_match_new)();
int(archive_match_free)(struct archive*);
int(archive_match_excluded)(struct archive*,struct archive_entry*);
int(archive_match_path_excluded)(struct archive*,struct archive_entry*);
int(archive_write_add_filter_lrzip)(struct archive*);
int(archive_match_set_inclusion_recursion)(struct archive*,int);
int(archive_match_exclude_pattern)(struct archive*,const char*);
int(archive_match_exclude_pattern_w)(struct archive*,const int*);
int(archive_match_exclude_pattern_from_file)(struct archive*,const char*,int);
int(archive_read_support_compression_bzip2)(struct archive*);
int(archive_match_exclude_pattern_from_file_w)(struct archive*,const int*,int);
int(archive_read_support_compression_gzip)(struct archive*);
int(archive_match_include_pattern)(struct archive*,const char*);
int(archive_read_support_compression_lzip)(struct archive*);
int(archive_match_include_pattern_w)(struct archive*,const int*);
int(archive_read_support_compression_lzma)(struct archive*);
int(archive_match_include_pattern_from_file)(struct archive*,const char*,int);
int(archive_read_support_compression_none)(struct archive*);
int(archive_match_include_pattern_from_file_w)(struct archive*,const int*,int);
int(archive_read_support_compression_program)(struct archive*,const char*);
int(archive_match_path_unmatched_inclusions)(struct archive*);
int(archive_read_support_compression_program_signature)(struct archive*,const char*,const void*,unsigned long);
int(archive_read_support_compression_rpm)(struct archive*);
int(archive_read_support_compression_uu)(struct archive*);
int(archive_match_time_excluded)(struct archive*,struct archive_entry*);
int(archive_read_support_filter_all)(struct archive*);
int(archive_match_include_file_time)(struct archive*,int,const char*);
int(archive_read_support_filter_lrzip)(struct archive*);
int(archive_match_exclude_entry)(struct archive*,int,struct archive_entry*);
int(archive_match_owner_excluded)(struct archive*,struct archive_entry*);
int(archive_read_support_filter_lzip)(struct archive*);
int(archive_match_include_uid)(struct archive*,signed long);
int(archive_read_support_filter_lzma)(struct archive*);
int(archive_match_include_gid)(struct archive*,signed long);
int(archive_read_support_filter_lzop)(struct archive*);
int(archive_match_include_uname)(struct archive*,const char*);
int(archive_read_support_filter_none)(struct archive*);
int(archive_match_include_uname_w)(struct archive*,const int*);
int(archive_read_support_filter_program)(struct archive*,const char*);
int(archive_match_include_gname)(struct archive*,const char*);
int(archive_read_support_filter_program_signature)(struct archive*,const char*,const void*,unsigned long);
int(archive_match_include_gname_w)(struct archive*,const int*);
int(archive_read_support_filter_rpm)(struct archive*);
int(archive_utility_string_sort)(char**);
int(archive_read_support_filter_uu)(struct archive*);
int(archive_read_support_filter_xz)(struct archive*);
int(archive_read_support_filter_zstd)(struct archive*);
int(archive_read_support_format_7zip)(struct archive*);
int(archive_read_support_format_all)(struct archive*);
int(archive_read_support_format_ar)(struct archive*);
struct archive_entry*(archive_entry_clone)(struct archive_entry*);
int(archive_read_support_format_by_code)(struct archive*,int);
void(archive_entry_free)(struct archive_entry*);
int(archive_read_support_format_cab)(struct archive*);
struct archive_entry*(archive_entry_new)();
int(archive_read_support_format_cpio)(struct archive*);
struct archive_entry*(archive_entry_new2)(struct archive*);
int(archive_read_support_format_empty)(struct archive*);
int(archive_read_support_format_gnutar)(struct archive*);
int(archive_read_support_format_iso9660)(struct archive*);
long(archive_entry_atime_nsec)(struct archive_entry*);
int(archive_read_support_format_lha)(struct archive*);
int(archive_entry_atime_is_set)(struct archive_entry*);
int(archive_read_support_format_mtree)(struct archive*);
long(archive_entry_birthtime)(struct archive_entry*);
int(archive_read_support_format_rar)(struct archive*);
long(archive_entry_birthtime_nsec)(struct archive_entry*);
int(archive_read_support_format_rar5)(struct archive*);
int(archive_entry_birthtime_is_set)(struct archive_entry*);
int(archive_read_support_format_raw)(struct archive*);
long(archive_entry_ctime)(struct archive_entry*);
int(archive_read_support_format_tar)(struct archive*);
long(archive_entry_ctime_nsec)(struct archive_entry*);
int(archive_read_support_format_warc)(struct archive*);
int(archive_entry_ctime_is_set)(struct archive_entry*);
int(archive_read_support_format_xar)(struct archive*);
int(archive_read_support_format_zip)(struct archive*);
int(archive_read_support_format_zip_streamable)(struct archive*);
int(archive_read_support_format_zip_seekable)(struct archive*);
int(archive_read_set_format)(struct archive*,int);
int(archive_read_append_filter)(struct archive*,int);
unsigned int(archive_entry_filetype)(struct archive_entry*);
int(archive_read_append_filter_program)(struct archive*,const char*);
void(archive_entry_fflags)(struct archive_entry*,unsigned long*,unsigned long*);
int(archive_read_append_filter_program_signature)(struct archive*,const char*,const void*,unsigned long);
const char*(archive_entry_fflags_text)(struct archive_entry*);
int(archive_read_set_open_callback)(struct archive*,int(unknown_2)(struct archive*,void*));
signed long(archive_entry_gid)(struct archive_entry*);
int(archive_read_set_read_callback)(struct archive*,long(unknown_2)(struct archive*,void*,const void**));
const char*(archive_entry_gname_utf8)(struct archive_entry*);
int(archive_read_set_seek_callback)(struct archive*,signed long(unknown_2)(struct archive*,void*,signed long,int));
const int*(archive_entry_gname_w)(struct archive_entry*);
int(archive_read_set_skip_callback)(struct archive*,signed long(unknown_2)(struct archive*,void*,signed long));
const char*(archive_entry_hardlink)(struct archive_entry*);
int(archive_read_set_close_callback)(struct archive*,int(unknown_2)(struct archive*,void*));
const int*(archive_entry_hardlink_w)(struct archive_entry*);
int(archive_read_set_switch_callback)(struct archive*,int(unknown_2)(struct archive*,void*,void*));
signed long(archive_entry_ino)(struct archive_entry*);
int(archive_read_set_callback_data)(struct archive*,void*);
int(archive_entry_ino_is_set)(struct archive_entry*);
int(archive_read_set_callback_data2)(struct archive*,void*,unsigned int);
int(archive_read_add_callback_data)(struct archive*,void*,unsigned int);
int(archive_read_append_callback_data)(struct archive*,void*);
int(archive_read_prepend_callback_data)(struct archive*,void*);
int(archive_read_open1)(struct archive*);
int(archive_read_open)(struct archive*,void*,int(unknown_3)(struct archive*,void*),long(unknown_4)(struct archive*,void*,const void**),int(unknown_5)(struct archive*,void*));
int(archive_read_open2)(struct archive*,void*,int(unknown_3)(struct archive*,void*),long(unknown_4)(struct archive*,void*,const void**),signed long(unknown_5)(struct archive*,void*,signed long),int(unknown_6)(struct archive*,void*));
struct archive*(archive_read_disk_new)();
int(archive_write_add_filter_lz4)(struct archive*);
int(archive_write_add_filter_lzip)(struct archive*);
int(archive_write_add_filter_lzma)(struct archive*);
int(archive_write_add_filter_lzop)(struct archive*);
int(archive_write_add_filter_none)(struct archive*);
int(archive_write_add_filter_program)(struct archive*,const char*);
int(archive_write_add_filter_uuencode)(struct archive*);
int(archive_write_add_filter_xz)(struct archive*);
int(archive_write_add_filter_zstd)(struct archive*);
int(archive_write_set_format)(struct archive*,int);
int(archive_write_set_format_by_name)(struct archive*,const char*);
int(archive_write_set_format_7zip)(struct archive*);
int(archive_write_set_format_ar_bsd)(struct archive*);
int(archive_write_set_format_ar_svr4)(struct archive*);
int(archive_write_set_format_cpio)(struct archive*);
int(archive_write_set_format_cpio_bin)(struct archive*);
int(archive_write_set_format_cpio_newc)(struct archive*);
int(archive_write_set_format_cpio_pwb)(struct archive*);
int(archive_write_set_format_gnutar)(struct archive*);
int(archive_write_set_format_iso9660)(struct archive*);
int(archive_write_set_format_mtree)(struct archive*);
int(archive_write_set_format_mtree_classic)(struct archive*);
int(archive_write_set_format_pax)(struct archive*);
int(archive_write_set_format_pax_restricted)(struct archive*);
int(archive_write_set_format_raw)(struct archive*);
int(archive_write_set_format_shar)(struct archive*);
struct archive_entry*(archive_entry_partial_links)(struct archive_entry_linkresolver*,unsigned int*);
int(archive_write_set_format_shar_dump)(struct archive*);
void(archive_entry_linkify)(struct archive_entry_linkresolver*,struct archive_entry**,struct archive_entry**);
int(archive_write_set_format_ustar)(struct archive*);
void(archive_entry_linkresolver_set_strategy)(struct archive_entry_linkresolver*,int);
int(archive_write_set_format_v7tar)(struct archive*);
const struct stat*(archive_entry_stat)(struct archive_entry*);
int(archive_write_set_format_warc)(struct archive*);
void(archive_entry_set_is_metadata_encrypted)(struct archive_entry*,char);
int(archive_write_set_format_xar)(struct archive*);
void(archive_entry_set_is_data_encrypted)(struct archive_entry*,char);
int(archive_write_set_format_zip)(struct archive*);
int(archive_entry_update_uname_utf8)(struct archive_entry*,const char*);
int(archive_write_set_format_filter_by_ext)(struct archive*,const char*);
void(archive_entry_copy_uname)(struct archive_entry*,const char*);
void(archive_entry_set_uname_utf8)(struct archive_entry*,const char*);
int(archive_write_set_format_filter_by_ext_def)(struct archive*,const char*,const char*);
void(archive_entry_set_uname)(struct archive_entry*,const char*);
void(archive_entry_set_uid)(struct archive_entry*,signed long);
int(archive_write_zip_set_compression_deflate)(struct archive*);
int(archive_entry_update_symlink_utf8)(struct archive_entry*,const char*);
int(archive_write_zip_set_compression_store)(struct archive*);
void(archive_entry_copy_symlink_w)(struct archive_entry*,const int*);
int(archive_write_open)(struct archive*,void*,int(unknown_3)(struct archive*,void*),long(unknown_4)(struct archive*,void*,const void*,unsigned long),int(unknown_5)(struct archive*,void*));
void(archive_entry_set_symlink_utf8)(struct archive_entry*,const char*);
void(archive_entry_set_symlink_type)(struct archive_entry*,int);
int(archive_write_open2)(struct archive*,void*,int(unknown_3)(struct archive*,void*),long(unknown_4)(struct archive*,void*,const void*,unsigned long),int(unknown_5)(struct archive*,void*),int(unknown_6)(struct archive*,void*));
void(archive_entry_copy_sourcepath)(struct archive_entry*,const char*);
void(archive_entry_set_size)(struct archive_entry*,signed long);
int(archive_write_open_fd)(struct archive*,int);
void(archive_entry_set_rdev)(struct archive_entry*,unsigned long);
void(archive_entry_copy_pathname)(struct archive_entry*,const char*);
int(archive_write_open_filename)(struct archive*,const char*);
void(archive_entry_set_nlink)(struct archive_entry*,unsigned int);
void(archive_entry_copy_link_w)(struct archive_entry*,const int*);
int(archive_write_open_filename_w)(struct archive*,const int*);
void(archive_entry_set_link_utf8)(struct archive_entry*,const char*);
int(archive_write_open_file)(struct archive*,const char*);
void(archive_entry_copy_hardlink_w)(struct archive_entry*,const int*);
int(archive_write_open_FILE)(struct archive*,struct _IO_FILE*);
void(archive_entry_copy_gname_w)(struct archive_entry*,const int*);
int(archive_write_header)(struct archive*,struct archive_entry*);
void(archive_entry_copy_gname)(struct archive_entry*,const char*);
long(archive_write_data)(struct archive*,const void*,unsigned long);
void(archive_entry_set_gname_utf8)(struct archive_entry*,const char*);
long(archive_write_data_block)(struct archive*,const void*,unsigned long,signed long);
void(archive_entry_set_gname)(struct archive_entry*,const char*);
int(archive_write_finish_entry)(struct archive*);
void(archive_entry_set_gid)(struct archive_entry*,signed long);
int(archive_write_close)(struct archive*);
int(archive_write_free)(struct archive*);
const int*(archive_entry_copy_fflags_text_w)(struct archive_entry*,const int*);
int(archive_write_finish)(struct archive*);
const char*(archive_entry_copy_fflags_text)(struct archive_entry*,const char*);
int(archive_write_set_format_option)(struct archive*,const char*,const char*,const char*);
void(archive_entry_set_fflags)(struct archive_entry*,unsigned long,unsigned long);
int(archive_write_set_filter_option)(struct archive*,const char*,const char*,const char*);
void(archive_entry_set_filetype)(struct archive_entry*,unsigned int);
int(archive_write_set_option)(struct archive*,const char*,const char*,const char*);
void(archive_entry_set_devminor)(struct archive_entry*,unsigned long);
int(archive_write_set_options)(struct archive*,const char*);
void(archive_entry_set_devmajor)(struct archive_entry*,unsigned long);
int(archive_write_set_passphrase)(struct archive*,const char*);
void(archive_entry_set_dev)(struct archive_entry*,unsigned long);
void(archive_entry_unset_ctime)(struct archive_entry*);
int(archive_write_set_passphrase_callback)(struct archive*,void*,const char*(unknown_3)(struct archive*,void*));
void(archive_entry_set_ctime)(struct archive_entry*,long,long);
struct archive*(archive_write_disk_new)();
void(archive_entry_unset_birthtime)(struct archive_entry*);
int(archive_write_disk_set_skip_file)(struct archive*,signed long,signed long);
void(archive_entry_set_birthtime)(struct archive_entry*,long,long);
int(archive_write_disk_set_options)(struct archive*,int);
void(archive_entry_unset_atime)(struct archive_entry*);
void(archive_entry_set_atime)(struct archive_entry*,long,long);
int(archive_write_disk_set_standard_lookup)(struct archive*);
int(archive_entry_is_encrypted)(struct archive_entry*);
int(archive_entry_is_metadata_encrypted)(struct archive_entry*);
int(archive_entry_is_data_encrypted)(struct archive_entry*);
const int*(archive_entry_uname_w)(struct archive_entry*);
const char*(archive_entry_uname_utf8)(struct archive_entry*);
const char*(archive_entry_uname)(struct archive_entry*);
const int*(archive_entry_symlink_w)(struct archive_entry*);
int(archive_entry_symlink_type)(struct archive_entry*);
signed long(archive_write_disk_gid)(struct archive*,const char*,signed long);
const char*(archive_entry_symlink_utf8)(struct archive_entry*);
const char*(archive_entry_symlink)(struct archive_entry*);
signed long(archive_write_disk_uid)(struct archive*,const char*,signed long);
const char*(archive_entry_strmode)(struct archive_entry*);
int(archive_entry_size_is_set)(struct archive_entry*);
signed long(archive_entry_size)(struct archive_entry*);
const int*(archive_entry_sourcepath_w)(struct archive_entry*);
const char*(archive_entry_sourcepath)(struct archive_entry*);
unsigned long(archive_entry_rdevminor)(struct archive_entry*);
unsigned int(archive_entry_perm)(struct archive_entry*);
const int*(archive_entry_pathname_w)(struct archive_entry*);
const char*(archive_entry_pathname_utf8)(struct archive_entry*);
const char*(archive_entry_pathname)(struct archive_entry*);
unsigned int(archive_entry_nlink)(struct archive_entry*);
signed long(archive_entry_ino64)(struct archive_entry*);
const char*(archive_entry_hardlink_utf8)(struct archive_entry*);
const char*(archive_entry_gname)(struct archive_entry*);
unsigned long(archive_entry_devminor)(struct archive_entry*);
unsigned long(archive_entry_devmajor)(struct archive_entry*);
int(archive_entry_dev_is_set)(struct archive_entry*);
unsigned long(archive_entry_dev)(struct archive_entry*);
long(archive_entry_atime)(struct archive_entry*);
struct archive_entry*(archive_entry_clear)(struct archive_entry*);
int(archive_read_support_compression_compress)(struct archive*);
int(archive_read_support_compression_all)(struct archive*);
struct archive*(archive_read_new)();
int(archive_write_add_filter_gzip)(struct archive*);
int(archive_write_add_filter_grzip)(struct archive*);
int(archive_write_add_filter_compress)(struct archive*);
int(archive_write_add_filter_b64encode)(struct archive*);
int(archive_write_add_filter_by_name)(struct archive*,const char*);
int(archive_write_add_filter)(struct archive*,int);
int(archive_write_set_compression_xz)(struct archive*);
const char*(archive_liblz4_version)();
const char*(archive_bzlib_version)();
const char*(archive_liblzma_version)();
const char*(archive_zlib_version)();
const char*(archive_version_details)();
const char*(archive_libzstd_version)();
const char*(archive_version_string)();
int(archive_write_get_bytes_per_block)(struct archive*);
int(archive_version_number)();
struct archive*(archive_write_new)();
int(archive_read_support_filter_by_code)(struct archive*,int);
int(archive_read_support_filter_grzip)(struct archive*);
int(archive_read_open_filename)(struct archive*,const char*,unsigned long);
int(archive_read_open_file)(struct archive*,const char*,unsigned long);
int(archive_read_next_header)(struct archive*,struct archive_entry**);
signed long(archive_read_header_position)(struct archive*);
signed long(archive_seek_data)(struct archive*,signed long,int);
int(archive_read_data_skip)(struct archive*);
int(archive_read_set_filter_option)(struct archive*,const char*,const char*,const char*);
int(archive_read_support_filter_compress)(struct archive*);
int(archive_write_set_format_cpio_odc)(struct archive*);
int(archive_write_add_filter_bzip2)(struct archive*);
int(archive_write_open_memory)(struct archive*,void*,unsigned long,unsigned long*);
int(archive_write_fail)(struct archive*);
int(archive_write_set_bytes_in_last_block)(struct archive*,int);
void(archive_read_extract_set_skip_file)(struct archive*,signed long,signed long);
int(archive_read_support_filter_bzip2)(struct archive*);
int(archive_read_set_passphrase_callback)(struct archive*,void*,const char*(unknown_3)(struct archive*,void*));
int(archive_read_support_filter_lz4)(struct archive*);
int(archive_read_support_filter_gzip)(struct archive*);
int(archive_read_support_compression_xz)(struct archive*);
int(archive_match_include_date)(struct archive*,int,const char*);
int(archive_match_include_file_time_w)(struct archive*,int,const int*);
int(archive_match_include_date_w)(struct archive*,int,const int*);
int(archive_match_include_time)(struct archive*,int,long,long);
int(archive_match_path_unmatched_inclusions_next_w)(struct archive*,const int**);
int(archive_match_path_unmatched_inclusions_next)(struct archive*,const char**);
]])
local library = {}


--====helper safe_clib_index====
		function SAFE_INDEX(clib)
			return setmetatable({}, {__index = function(_, k)
				local ok, val = pcall(function() return clib[k] end)
				if ok then
					return val
				end
			end})
		end
	
--====helper safe_clib_index====

CLIB = SAFE_INDEX(CLIB)library = {
	EntryCopyStat = CLIB.archive_entry_copy_stat,
	EntryMacMetadata = CLIB.archive_entry_mac_metadata,
	EntryCopyMacMetadata = CLIB.archive_entry_copy_mac_metadata,
	EntryDigest = CLIB.archive_entry_digest,
	EntryAclClear = CLIB.archive_entry_acl_clear,
	EntryAclAddEntry = CLIB.archive_entry_acl_add_entry,
	EntryAclAddEntryW = CLIB.archive_entry_acl_add_entry_w,
	EntryAclReset = CLIB.archive_entry_acl_reset,
	EntryAclNext = CLIB.archive_entry_acl_next,
	EntryAclToTextW = CLIB.archive_entry_acl_to_text_w,
	EntryAclToText = CLIB.archive_entry_acl_to_text,
	EntryAclFromTextW = CLIB.archive_entry_acl_from_text_w,
	EntryAclFromText = CLIB.archive_entry_acl_from_text,
	EntryAclTextW = CLIB.archive_entry_acl_text_w,
	EntryAclText = CLIB.archive_entry_acl_text,
	EntryAclTypes = CLIB.archive_entry_acl_types,
	EntryAclCount = CLIB.archive_entry_acl_count,
	EntryAcl = CLIB.archive_entry_acl,
	EntryXattrClear = CLIB.archive_entry_xattr_clear,
	EntryXattrAddEntry = CLIB.archive_entry_xattr_add_entry,
	EntryXattrCount = CLIB.archive_entry_xattr_count,
	EntryXattrReset = CLIB.archive_entry_xattr_reset,
	EntryXattrNext = CLIB.archive_entry_xattr_next,
	EntrySparseClear = CLIB.archive_entry_sparse_clear,
	EntrySparseAddEntry = CLIB.archive_entry_sparse_add_entry,
	EntrySparseCount = CLIB.archive_entry_sparse_count,
	EntrySparseReset = CLIB.archive_entry_sparse_reset,
	EntrySparseNext = CLIB.archive_entry_sparse_next,
	EntryLinkresolverNew = CLIB.archive_entry_linkresolver_new,
	EntryLinkresolverFree = CLIB.archive_entry_linkresolver_free,
	EntryUpdateGnameUtf8 = CLIB.archive_entry_update_gname_utf8,
	EntrySetHardlink = CLIB.archive_entry_set_hardlink,
	EntrySetHardlinkUtf8 = CLIB.archive_entry_set_hardlink_utf8,
	EntryCopyHardlink = CLIB.archive_entry_copy_hardlink,
	EntryUpdateHardlinkUtf8 = CLIB.archive_entry_update_hardlink_utf8,
	EntrySetIno = CLIB.archive_entry_set_ino,
	EntrySetIno64 = CLIB.archive_entry_set_ino64,
	EntrySetLink = CLIB.archive_entry_set_link,
	EntryCopyLink = CLIB.archive_entry_copy_link,
	EntryUpdateLinkUtf8 = CLIB.archive_entry_update_link_utf8,
	EntrySetMode = CLIB.archive_entry_set_mode,
	EntrySetMtime = CLIB.archive_entry_set_mtime,
	EntryUnsetMtime = CLIB.archive_entry_unset_mtime,
	EntrySetPathname = CLIB.archive_entry_set_pathname,
	EntrySetPathnameUtf8 = CLIB.archive_entry_set_pathname_utf8,
	EntryCopyPathnameW = CLIB.archive_entry_copy_pathname_w,
	EntryUpdatePathnameUtf8 = CLIB.archive_entry_update_pathname_utf8,
	EntrySetPerm = CLIB.archive_entry_set_perm,
	EntrySetRdevmajor = CLIB.archive_entry_set_rdevmajor,
	EntrySetRdevminor = CLIB.archive_entry_set_rdevminor,
	EntryUnsetSize = CLIB.archive_entry_unset_size,
	EntryCopySourcepathW = CLIB.archive_entry_copy_sourcepath_w,
	EntrySetSymlink = CLIB.archive_entry_set_symlink,
	EntryCopySymlink = CLIB.archive_entry_copy_symlink,
	EntryCopyUnameW = CLIB.archive_entry_copy_uname_w,
	ReadOpenFilenames = CLIB.archive_read_open_filenames,
	ReadOpenFilenameW = CLIB.archive_read_open_filename_w,
	ReadOpenMemory = CLIB.archive_read_open_memory,
	ReadOpenMemory2 = CLIB.archive_read_open_memory2,
	ReadOpenFd = CLIB.archive_read_open_fd,
	ReadOpen_FILE = CLIB.archive_read_open_FILE,
	ReadNextHeader2 = CLIB.archive_read_next_header2,
	ReadHasEncryptedEntries = CLIB.archive_read_has_encrypted_entries,
	ReadFormatCapabilities = CLIB.archive_read_format_capabilities,
	ReadData = CLIB.archive_read_data,
	EntryMode = CLIB.archive_entry_mode,
	ReadDiskSetSymlinkLogical = CLIB.archive_read_disk_set_symlink_logical,
	EntryMtime = CLIB.archive_entry_mtime,
	ReadDiskSetSymlinkPhysical = CLIB.archive_read_disk_set_symlink_physical,
	ReadDataBlock = CLIB.archive_read_data_block,
	ReadDiskSetSymlinkHybrid = CLIB.archive_read_disk_set_symlink_hybrid,
	EntryMtimeNsec = CLIB.archive_entry_mtime_nsec,
	ReadDiskEntryFromFile = CLIB.archive_read_disk_entry_from_file,
	EntryMtimeIsSet = CLIB.archive_entry_mtime_is_set,
	ReadDataIntoFd = CLIB.archive_read_data_into_fd,
	ReadDiskGname = CLIB.archive_read_disk_gname,
	ReadSetFormatOption = CLIB.archive_read_set_format_option,
	ReadDiskUname = CLIB.archive_read_disk_uname,
	ReadDiskSetStandardLookup = CLIB.archive_read_disk_set_standard_lookup,
	ReadSetOption = CLIB.archive_read_set_option,
	ReadSetOptions = CLIB.archive_read_set_options,
	EntryRdev = CLIB.archive_entry_rdev,
	ReadAddPassphrase = CLIB.archive_read_add_passphrase,
	EntryRdevmajor = CLIB.archive_entry_rdevmajor,
	ReadDiskOpen = CLIB.archive_read_disk_open,
	ReadDiskOpenW = CLIB.archive_read_disk_open_w,
	ReadExtract = CLIB.archive_read_extract,
	ReadDiskDescend = CLIB.archive_read_disk_descend,
	ReadExtract2 = CLIB.archive_read_extract2,
	ReadDiskCanDescend = CLIB.archive_read_disk_can_descend,
	ReadDiskCurrentFilesystem = CLIB.archive_read_disk_current_filesystem,
	ReadExtractSetProgressCallback = CLIB.archive_read_extract_set_progress_callback,
	ReadDiskCurrentFilesystemIsSynthetic = CLIB.archive_read_disk_current_filesystem_is_synthetic,
	ReadDiskCurrentFilesystemIsRemote = CLIB.archive_read_disk_current_filesystem_is_remote,
	ReadDiskSetAtimeRestored = CLIB.archive_read_disk_set_atime_restored,
	ReadClose = CLIB.archive_read_close,
	ReadDiskSetBehavior = CLIB.archive_read_disk_set_behavior,
	ReadFree = CLIB.archive_read_free,
	ReadDiskSetMatching = CLIB.archive_read_disk_set_matching,
	ReadFinish = CLIB.archive_read_finish,
	EntryUid = CLIB.archive_entry_uid,
	ReadDiskSetMetadataFilterCallback = CLIB.archive_read_disk_set_metadata_filter_callback,
	WriteSetBytesPerBlock = CLIB.archive_write_set_bytes_per_block,
	Free = CLIB.archive_free,
	FilterCount = CLIB.archive_filter_count,
	FilterBytes = CLIB.archive_filter_bytes,
	FilterCode = CLIB.archive_filter_code,
	WriteGetBytesInLastBlock = CLIB.archive_write_get_bytes_in_last_block,
	FilterName = CLIB.archive_filter_name,
	WriteSetSkipFile = CLIB.archive_write_set_skip_file,
	PositionCompressed = CLIB.archive_position_compressed,
	WriteSetCompressionBzip2 = CLIB.archive_write_set_compression_bzip2,
	PositionUncompressed = CLIB.archive_position_uncompressed,
	WriteSetCompressionCompress = CLIB.archive_write_set_compression_compress,
	CompressionName = CLIB.archive_compression_name,
	WriteSetCompressionGzip = CLIB.archive_write_set_compression_gzip,
	Compression = CLIB.archive_compression,
	WriteSetCompressionLzip = CLIB.archive_write_set_compression_lzip,
	Errno = CLIB.archive_errno,
	WriteSetCompressionLzma = CLIB.archive_write_set_compression_lzma,
	ErrorString = CLIB.archive_error_string,
	WriteSetCompressionNone = CLIB.archive_write_set_compression_none,
	FormatName = CLIB.archive_format_name,
	WriteSetCompressionProgram = CLIB.archive_write_set_compression_program,
	Format = CLIB.archive_format,
	ClearError = CLIB.archive_clear_error,
	SetError = CLIB.archive_set_error,
	CopyError = CLIB.archive_copy_error,
	FileCount = CLIB.archive_file_count,
	MatchNew = CLIB.archive_match_new,
	MatchFree = CLIB.archive_match_free,
	MatchExcluded = CLIB.archive_match_excluded,
	MatchPathExcluded = CLIB.archive_match_path_excluded,
	WriteAddFilterLrzip = CLIB.archive_write_add_filter_lrzip,
	MatchSetInclusionRecursion = CLIB.archive_match_set_inclusion_recursion,
	MatchExcludePattern = CLIB.archive_match_exclude_pattern,
	MatchExcludePatternW = CLIB.archive_match_exclude_pattern_w,
	MatchExcludePatternFromFile = CLIB.archive_match_exclude_pattern_from_file,
	ReadSupportCompressionBzip2 = CLIB.archive_read_support_compression_bzip2,
	MatchExcludePatternFromFileW = CLIB.archive_match_exclude_pattern_from_file_w,
	ReadSupportCompressionGzip = CLIB.archive_read_support_compression_gzip,
	MatchIncludePattern = CLIB.archive_match_include_pattern,
	ReadSupportCompressionLzip = CLIB.archive_read_support_compression_lzip,
	MatchIncludePatternW = CLIB.archive_match_include_pattern_w,
	ReadSupportCompressionLzma = CLIB.archive_read_support_compression_lzma,
	MatchIncludePatternFromFile = CLIB.archive_match_include_pattern_from_file,
	ReadSupportCompressionNone = CLIB.archive_read_support_compression_none,
	MatchIncludePatternFromFileW = CLIB.archive_match_include_pattern_from_file_w,
	ReadSupportCompressionProgram = CLIB.archive_read_support_compression_program,
	MatchPathUnmatchedInclusions = CLIB.archive_match_path_unmatched_inclusions,
	ReadSupportCompressionProgramSignature = CLIB.archive_read_support_compression_program_signature,
	ReadSupportCompressionRpm = CLIB.archive_read_support_compression_rpm,
	ReadSupportCompressionUu = CLIB.archive_read_support_compression_uu,
	MatchTimeExcluded = CLIB.archive_match_time_excluded,
	ReadSupportFilterAll = CLIB.archive_read_support_filter_all,
	MatchIncludeFileTime = CLIB.archive_match_include_file_time,
	ReadSupportFilterLrzip = CLIB.archive_read_support_filter_lrzip,
	MatchExcludeEntry = CLIB.archive_match_exclude_entry,
	MatchOwnerExcluded = CLIB.archive_match_owner_excluded,
	ReadSupportFilterLzip = CLIB.archive_read_support_filter_lzip,
	MatchIncludeUid = CLIB.archive_match_include_uid,
	ReadSupportFilterLzma = CLIB.archive_read_support_filter_lzma,
	MatchIncludeGid = CLIB.archive_match_include_gid,
	ReadSupportFilterLzop = CLIB.archive_read_support_filter_lzop,
	MatchIncludeUname = CLIB.archive_match_include_uname,
	ReadSupportFilterNone = CLIB.archive_read_support_filter_none,
	MatchIncludeUnameW = CLIB.archive_match_include_uname_w,
	ReadSupportFilterProgram = CLIB.archive_read_support_filter_program,
	MatchIncludeGname = CLIB.archive_match_include_gname,
	ReadSupportFilterProgramSignature = CLIB.archive_read_support_filter_program_signature,
	MatchIncludeGnameW = CLIB.archive_match_include_gname_w,
	ReadSupportFilterRpm = CLIB.archive_read_support_filter_rpm,
	UtilityStringSort = CLIB.archive_utility_string_sort,
	ReadSupportFilterUu = CLIB.archive_read_support_filter_uu,
	ReadSupportFilterXz = CLIB.archive_read_support_filter_xz,
	ReadSupportFilterZstd = CLIB.archive_read_support_filter_zstd,
	ReadSupportFormat_7zip = CLIB.archive_read_support_format_7zip,
	ReadSupportFormatAll = CLIB.archive_read_support_format_all,
	ReadSupportFormatAr = CLIB.archive_read_support_format_ar,
	EntryClone = CLIB.archive_entry_clone,
	ReadSupportFormatByCode = CLIB.archive_read_support_format_by_code,
	EntryFree = CLIB.archive_entry_free,
	ReadSupportFormatCab = CLIB.archive_read_support_format_cab,
	EntryNew = CLIB.archive_entry_new,
	ReadSupportFormatCpio = CLIB.archive_read_support_format_cpio,
	EntryNew2 = CLIB.archive_entry_new2,
	ReadSupportFormatEmpty = CLIB.archive_read_support_format_empty,
	ReadSupportFormatGnutar = CLIB.archive_read_support_format_gnutar,
	ReadSupportFormatIso9660 = CLIB.archive_read_support_format_iso9660,
	EntryAtimeNsec = CLIB.archive_entry_atime_nsec,
	ReadSupportFormatLha = CLIB.archive_read_support_format_lha,
	EntryAtimeIsSet = CLIB.archive_entry_atime_is_set,
	ReadSupportFormatMtree = CLIB.archive_read_support_format_mtree,
	EntryBirthtime = CLIB.archive_entry_birthtime,
	ReadSupportFormatRar = CLIB.archive_read_support_format_rar,
	EntryBirthtimeNsec = CLIB.archive_entry_birthtime_nsec,
	ReadSupportFormatRar5 = CLIB.archive_read_support_format_rar5,
	EntryBirthtimeIsSet = CLIB.archive_entry_birthtime_is_set,
	ReadSupportFormatRaw = CLIB.archive_read_support_format_raw,
	EntryCtime = CLIB.archive_entry_ctime,
	ReadSupportFormatTar = CLIB.archive_read_support_format_tar,
	EntryCtimeNsec = CLIB.archive_entry_ctime_nsec,
	ReadSupportFormatWarc = CLIB.archive_read_support_format_warc,
	EntryCtimeIsSet = CLIB.archive_entry_ctime_is_set,
	ReadSupportFormatXar = CLIB.archive_read_support_format_xar,
	ReadSupportFormatZip = CLIB.archive_read_support_format_zip,
	ReadSupportFormatZipStreamable = CLIB.archive_read_support_format_zip_streamable,
	ReadSupportFormatZipSeekable = CLIB.archive_read_support_format_zip_seekable,
	ReadSetFormat = CLIB.archive_read_set_format,
	ReadAppendFilter = CLIB.archive_read_append_filter,
	EntryFiletype = CLIB.archive_entry_filetype,
	ReadAppendFilterProgram = CLIB.archive_read_append_filter_program,
	EntryFflags = CLIB.archive_entry_fflags,
	ReadAppendFilterProgramSignature = CLIB.archive_read_append_filter_program_signature,
	EntryFflagsText = CLIB.archive_entry_fflags_text,
	ReadSetOpenCallback = CLIB.archive_read_set_open_callback,
	EntryGid = CLIB.archive_entry_gid,
	ReadSetReadCallback = CLIB.archive_read_set_read_callback,
	EntryGnameUtf8 = CLIB.archive_entry_gname_utf8,
	ReadSetSeekCallback = CLIB.archive_read_set_seek_callback,
	EntryGnameW = CLIB.archive_entry_gname_w,
	ReadSetSkipCallback = CLIB.archive_read_set_skip_callback,
	EntryHardlink = CLIB.archive_entry_hardlink,
	ReadSetCloseCallback = CLIB.archive_read_set_close_callback,
	EntryHardlinkW = CLIB.archive_entry_hardlink_w,
	ReadSetSwitchCallback = CLIB.archive_read_set_switch_callback,
	EntryIno = CLIB.archive_entry_ino,
	ReadSetCallbackData = CLIB.archive_read_set_callback_data,
	EntryInoIsSet = CLIB.archive_entry_ino_is_set,
	ReadSetCallbackData2 = CLIB.archive_read_set_callback_data2,
	ReadAddCallbackData = CLIB.archive_read_add_callback_data,
	ReadAppendCallbackData = CLIB.archive_read_append_callback_data,
	ReadPrependCallbackData = CLIB.archive_read_prepend_callback_data,
	ReadOpen1 = CLIB.archive_read_open1,
	ReadOpen = CLIB.archive_read_open,
	ReadOpen2 = CLIB.archive_read_open2,
	ReadDiskNew = CLIB.archive_read_disk_new,
	WriteAddFilterLz4 = CLIB.archive_write_add_filter_lz4,
	WriteAddFilterLzip = CLIB.archive_write_add_filter_lzip,
	WriteAddFilterLzma = CLIB.archive_write_add_filter_lzma,
	WriteAddFilterLzop = CLIB.archive_write_add_filter_lzop,
	WriteAddFilterNone = CLIB.archive_write_add_filter_none,
	WriteAddFilterProgram = CLIB.archive_write_add_filter_program,
	WriteAddFilterUuencode = CLIB.archive_write_add_filter_uuencode,
	WriteAddFilterXz = CLIB.archive_write_add_filter_xz,
	WriteAddFilterZstd = CLIB.archive_write_add_filter_zstd,
	WriteSetFormat = CLIB.archive_write_set_format,
	WriteSetFormatByName = CLIB.archive_write_set_format_by_name,
	WriteSetFormat_7zip = CLIB.archive_write_set_format_7zip,
	WriteSetFormatArBsd = CLIB.archive_write_set_format_ar_bsd,
	WriteSetFormatArSvr4 = CLIB.archive_write_set_format_ar_svr4,
	WriteSetFormatCpio = CLIB.archive_write_set_format_cpio,
	WriteSetFormatCpioBin = CLIB.archive_write_set_format_cpio_bin,
	WriteSetFormatCpioNewc = CLIB.archive_write_set_format_cpio_newc,
	WriteSetFormatCpioPwb = CLIB.archive_write_set_format_cpio_pwb,
	WriteSetFormatGnutar = CLIB.archive_write_set_format_gnutar,
	WriteSetFormatIso9660 = CLIB.archive_write_set_format_iso9660,
	WriteSetFormatMtree = CLIB.archive_write_set_format_mtree,
	WriteSetFormatMtreeClassic = CLIB.archive_write_set_format_mtree_classic,
	WriteSetFormatPax = CLIB.archive_write_set_format_pax,
	WriteSetFormatPaxRestricted = CLIB.archive_write_set_format_pax_restricted,
	WriteSetFormatRaw = CLIB.archive_write_set_format_raw,
	WriteSetFormatShar = CLIB.archive_write_set_format_shar,
	EntryPartialLinks = CLIB.archive_entry_partial_links,
	WriteSetFormatSharDump = CLIB.archive_write_set_format_shar_dump,
	EntryLinkify = CLIB.archive_entry_linkify,
	WriteSetFormatUstar = CLIB.archive_write_set_format_ustar,
	EntryLinkresolverSetStrategy = CLIB.archive_entry_linkresolver_set_strategy,
	WriteSetFormatV7tar = CLIB.archive_write_set_format_v7tar,
	EntryStat = CLIB.archive_entry_stat,
	WriteSetFormatWarc = CLIB.archive_write_set_format_warc,
	EntrySetIsMetadataEncrypted = CLIB.archive_entry_set_is_metadata_encrypted,
	WriteSetFormatXar = CLIB.archive_write_set_format_xar,
	EntrySetIsDataEncrypted = CLIB.archive_entry_set_is_data_encrypted,
	WriteSetFormatZip = CLIB.archive_write_set_format_zip,
	EntryUpdateUnameUtf8 = CLIB.archive_entry_update_uname_utf8,
	WriteSetFormatFilterByExt = CLIB.archive_write_set_format_filter_by_ext,
	EntryCopyUname = CLIB.archive_entry_copy_uname,
	EntrySetUnameUtf8 = CLIB.archive_entry_set_uname_utf8,
	WriteSetFormatFilterByExtDef = CLIB.archive_write_set_format_filter_by_ext_def,
	EntrySetUname = CLIB.archive_entry_set_uname,
	EntrySetUid = CLIB.archive_entry_set_uid,
	WriteZipSetCompressionDeflate = CLIB.archive_write_zip_set_compression_deflate,
	EntryUpdateSymlinkUtf8 = CLIB.archive_entry_update_symlink_utf8,
	WriteZipSetCompressionStore = CLIB.archive_write_zip_set_compression_store,
	EntryCopySymlinkW = CLIB.archive_entry_copy_symlink_w,
	WriteOpen = CLIB.archive_write_open,
	EntrySetSymlinkUtf8 = CLIB.archive_entry_set_symlink_utf8,
	EntrySetSymlinkType = CLIB.archive_entry_set_symlink_type,
	WriteOpen2 = CLIB.archive_write_open2,
	EntryCopySourcepath = CLIB.archive_entry_copy_sourcepath,
	EntrySetSize = CLIB.archive_entry_set_size,
	WriteOpenFd = CLIB.archive_write_open_fd,
	EntrySetRdev = CLIB.archive_entry_set_rdev,
	EntryCopyPathname = CLIB.archive_entry_copy_pathname,
	WriteOpenFilename = CLIB.archive_write_open_filename,
	EntrySetNlink = CLIB.archive_entry_set_nlink,
	EntryCopyLinkW = CLIB.archive_entry_copy_link_w,
	WriteOpenFilenameW = CLIB.archive_write_open_filename_w,
	EntrySetLinkUtf8 = CLIB.archive_entry_set_link_utf8,
	WriteOpenFile = CLIB.archive_write_open_file,
	EntryCopyHardlinkW = CLIB.archive_entry_copy_hardlink_w,
	WriteOpen_FILE = CLIB.archive_write_open_FILE,
	EntryCopyGnameW = CLIB.archive_entry_copy_gname_w,
	WriteHeader = CLIB.archive_write_header,
	EntryCopyGname = CLIB.archive_entry_copy_gname,
	WriteData = CLIB.archive_write_data,
	EntrySetGnameUtf8 = CLIB.archive_entry_set_gname_utf8,
	WriteDataBlock = CLIB.archive_write_data_block,
	EntrySetGname = CLIB.archive_entry_set_gname,
	WriteFinishEntry = CLIB.archive_write_finish_entry,
	EntrySetGid = CLIB.archive_entry_set_gid,
	WriteClose = CLIB.archive_write_close,
	WriteFree = CLIB.archive_write_free,
	EntryCopyFflagsTextW = CLIB.archive_entry_copy_fflags_text_w,
	WriteFinish = CLIB.archive_write_finish,
	EntryCopyFflagsText = CLIB.archive_entry_copy_fflags_text,
	WriteSetFormatOption = CLIB.archive_write_set_format_option,
	EntrySetFflags = CLIB.archive_entry_set_fflags,
	WriteSetFilterOption = CLIB.archive_write_set_filter_option,
	EntrySetFiletype = CLIB.archive_entry_set_filetype,
	WriteSetOption = CLIB.archive_write_set_option,
	EntrySetDevminor = CLIB.archive_entry_set_devminor,
	WriteSetOptions = CLIB.archive_write_set_options,
	EntrySetDevmajor = CLIB.archive_entry_set_devmajor,
	WriteSetPassphrase = CLIB.archive_write_set_passphrase,
	EntrySetDev = CLIB.archive_entry_set_dev,
	EntryUnsetCtime = CLIB.archive_entry_unset_ctime,
	WriteSetPassphraseCallback = CLIB.archive_write_set_passphrase_callback,
	EntrySetCtime = CLIB.archive_entry_set_ctime,
	WriteDiskNew = CLIB.archive_write_disk_new,
	EntryUnsetBirthtime = CLIB.archive_entry_unset_birthtime,
	WriteDiskSetSkipFile = CLIB.archive_write_disk_set_skip_file,
	EntrySetBirthtime = CLIB.archive_entry_set_birthtime,
	WriteDiskSetOptions = CLIB.archive_write_disk_set_options,
	EntryUnsetAtime = CLIB.archive_entry_unset_atime,
	EntrySetAtime = CLIB.archive_entry_set_atime,
	WriteDiskSetStandardLookup = CLIB.archive_write_disk_set_standard_lookup,
	EntryIsEncrypted = CLIB.archive_entry_is_encrypted,
	EntryIsMetadataEncrypted = CLIB.archive_entry_is_metadata_encrypted,
	EntryIsDataEncrypted = CLIB.archive_entry_is_data_encrypted,
	EntryUnameW = CLIB.archive_entry_uname_w,
	EntryUnameUtf8 = CLIB.archive_entry_uname_utf8,
	EntryUname = CLIB.archive_entry_uname,
	EntrySymlinkW = CLIB.archive_entry_symlink_w,
	EntrySymlinkType = CLIB.archive_entry_symlink_type,
	WriteDiskGid = CLIB.archive_write_disk_gid,
	EntrySymlinkUtf8 = CLIB.archive_entry_symlink_utf8,
	EntrySymlink = CLIB.archive_entry_symlink,
	WriteDiskUid = CLIB.archive_write_disk_uid,
	EntryStrmode = CLIB.archive_entry_strmode,
	EntrySizeIsSet = CLIB.archive_entry_size_is_set,
	EntrySize = CLIB.archive_entry_size,
	EntrySourcepathW = CLIB.archive_entry_sourcepath_w,
	EntrySourcepath = CLIB.archive_entry_sourcepath,
	EntryRdevminor = CLIB.archive_entry_rdevminor,
	EntryPerm = CLIB.archive_entry_perm,
	EntryPathnameW = CLIB.archive_entry_pathname_w,
	EntryPathnameUtf8 = CLIB.archive_entry_pathname_utf8,
	EntryPathname = CLIB.archive_entry_pathname,
	EntryNlink = CLIB.archive_entry_nlink,
	EntryIno64 = CLIB.archive_entry_ino64,
	EntryHardlinkUtf8 = CLIB.archive_entry_hardlink_utf8,
	EntryGname = CLIB.archive_entry_gname,
	EntryDevminor = CLIB.archive_entry_devminor,
	EntryDevmajor = CLIB.archive_entry_devmajor,
	EntryDevIsSet = CLIB.archive_entry_dev_is_set,
	EntryDev = CLIB.archive_entry_dev,
	EntryAtime = CLIB.archive_entry_atime,
	EntryClear = CLIB.archive_entry_clear,
	ReadSupportCompressionCompress = CLIB.archive_read_support_compression_compress,
	ReadSupportCompressionAll = CLIB.archive_read_support_compression_all,
	ReadNew = CLIB.archive_read_new,
	WriteAddFilterGzip = CLIB.archive_write_add_filter_gzip,
	WriteAddFilterGrzip = CLIB.archive_write_add_filter_grzip,
	WriteAddFilterCompress = CLIB.archive_write_add_filter_compress,
	WriteAddFilterB64encode = CLIB.archive_write_add_filter_b64encode,
	WriteAddFilterByName = CLIB.archive_write_add_filter_by_name,
	WriteAddFilter = CLIB.archive_write_add_filter,
	WriteSetCompressionXz = CLIB.archive_write_set_compression_xz,
	Liblz4Version = CLIB.archive_liblz4_version,
	BzlibVersion = CLIB.archive_bzlib_version,
	LiblzmaVersion = CLIB.archive_liblzma_version,
	ZlibVersion = CLIB.archive_zlib_version,
	VersionDetails = CLIB.archive_version_details,
	LibzstdVersion = CLIB.archive_libzstd_version,
	VersionString = CLIB.archive_version_string,
	WriteGetBytesPerBlock = CLIB.archive_write_get_bytes_per_block,
	VersionNumber = CLIB.archive_version_number,
	WriteNew = CLIB.archive_write_new,
	ReadSupportFilterByCode = CLIB.archive_read_support_filter_by_code,
	ReadSupportFilterGrzip = CLIB.archive_read_support_filter_grzip,
	ReadOpenFilename = CLIB.archive_read_open_filename,
	ReadOpenFile = CLIB.archive_read_open_file,
	ReadNextHeader = CLIB.archive_read_next_header,
	ReadHeaderPosition = CLIB.archive_read_header_position,
	SeekData = CLIB.archive_seek_data,
	ReadDataSkip = CLIB.archive_read_data_skip,
	ReadSetFilterOption = CLIB.archive_read_set_filter_option,
	ReadSupportFilterCompress = CLIB.archive_read_support_filter_compress,
	WriteSetFormatCpioOdc = CLIB.archive_write_set_format_cpio_odc,
	WriteAddFilterBzip2 = CLIB.archive_write_add_filter_bzip2,
	WriteOpenMemory = CLIB.archive_write_open_memory,
	WriteFail = CLIB.archive_write_fail,
	WriteSetBytesInLastBlock = CLIB.archive_write_set_bytes_in_last_block,
	ReadExtractSetSkipFile = CLIB.archive_read_extract_set_skip_file,
	ReadSupportFilterBzip2 = CLIB.archive_read_support_filter_bzip2,
	ReadSetPassphraseCallback = CLIB.archive_read_set_passphrase_callback,
	ReadSupportFilterLz4 = CLIB.archive_read_support_filter_lz4,
	ReadSupportFilterGzip = CLIB.archive_read_support_filter_gzip,
	ReadSupportCompressionXz = CLIB.archive_read_support_compression_xz,
	MatchIncludeDate = CLIB.archive_match_include_date,
	MatchIncludeFileTimeW = CLIB.archive_match_include_file_time_w,
	MatchIncludeDateW = CLIB.archive_match_include_date_w,
	MatchIncludeTime = CLIB.archive_match_include_time,
	MatchPathUnmatchedInclusionsNextW = CLIB.archive_match_path_unmatched_inclusions_next_w,
	MatchPathUnmatchedInclusionsNext = CLIB.archive_match_path_unmatched_inclusions_next,
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
