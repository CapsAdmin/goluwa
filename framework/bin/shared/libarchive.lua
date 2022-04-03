local ffi = require("ffi")
local CLIB = assert(ffi.load("libarchive"))
ffi.cdef([[struct archive {};
struct archive_entry {};
struct archive_acl {};
struct archive_entry_linkresolver {};
int(archive_version_number)();
int(archive_read_support_format_gnutar)(struct archive*);
int(archive_match_include_date)(struct archive*,int,const char*);
void(archive_entry_set_ino64)(struct archive_entry*,signed long);
int(archive_write_set_format_iso9660)(struct archive*);
void(archive_entry_set_gname_utf8)(struct archive_entry*,const char*);
signed long(archive_filter_bytes)(struct archive*,int);
int(archive_write_set_passphrase_callback)(struct archive*,void*,const char*(unknown_3)(struct archive*,void*));
int(archive_write_close)(struct archive*);
int(archive_read_support_format_mtree)(struct archive*);
int(archive_write_set_format_filter_by_ext)(struct archive*,const char*);
int(archive_read_disk_set_metadata_filter_callback)(struct archive*,int(*_metadata_filter_func)(struct archive*,void*,struct archive_entry*),void*);
struct archive_entry*(archive_entry_clone)(struct archive_entry*);
int(archive_read_open_filename_w)(struct archive*,const int*,unsigned long);
int(archive_entry_acl_count)(struct archive_entry*,int);
int(archive_write_set_filter_option)(struct archive*,const char*,const char*,const char*);
void(archive_entry_linkify)(struct archive_entry_linkresolver*,struct archive_entry**,struct archive_entry**);
int(archive_match_include_pattern)(struct archive*,const char*);
int(archive_read_support_format_ar)(struct archive*);
const char*(archive_entry_acl_text)(struct archive_entry*,int);
int(archive_match_exclude_entry)(struct archive*,int,struct archive_entry*);
int(archive_read_open_filenames)(struct archive*,const char**,unsigned long);
int(archive_read_support_compression_lzip)(struct archive*);
int(archive_write_set_format_by_name)(struct archive*,const char*);
int(archive_read_support_format_cpio)(struct archive*);
int(archive_write_zip_set_compression_store)(struct archive*);
const char*(archive_liblz4_version)();
int(archive_free)(struct archive*);
int(archive_match_path_unmatched_inclusions)(struct archive*);
int(archive_write_set_format_ustar)(struct archive*);
int(archive_write_set_format_mtree)(struct archive*);
int(archive_read_support_compression_program_signature)(struct archive*,const char*,const void*,unsigned long);
struct archive*(archive_match_new)();
int(archive_read_support_filter_program_signature)(struct archive*,const char*,const void*,unsigned long);
signed long(archive_entry_uid)(struct archive_entry*);
signed long(archive_position_compressed)(struct archive*);
const char*(archive_entry_copy_fflags_text)(struct archive_entry*,const char*);
int(archive_read_disk_current_filesystem)(struct archive*);
int(archive_write_add_filter_xz)(struct archive*);
int(archive_read_set_callback_data)(struct archive*,void*);
int(archive_match_include_gid)(struct archive*,signed long);
int(archive_read_support_filter_program)(struct archive*,const char*);
signed long(archive_entry_ino)(struct archive_entry*);
void(archive_entry_set_dev)(struct archive_entry*,unsigned long);
void(archive_entry_linkresolver_free)(struct archive_entry_linkresolver*);
int(archive_entry_update_link_utf8)(struct archive_entry*,const char*);
int(archive_match_include_date_w)(struct archive*,int,const int*);
int(archive_read_open_memory)(struct archive*,const void*,unsigned long);
int(archive_entry_xattr_count)(struct archive_entry*);
int(archive_read_disk_set_atime_restored)(struct archive*);
int(archive_utility_string_sort)(char**);
int(archive_write_set_compression_xz)(struct archive*);
int(archive_read_support_format_zip_seekable)(struct archive*);
unsigned int(archive_entry_perm)(struct archive_entry*);
int(archive_read_support_format_empty)(struct archive*);
const char*(archive_entry_fflags_text)(struct archive_entry*);
int(archive_read_support_compression_none)(struct archive*);
int(archive_read_free)(struct archive*);
int(archive_read_disk_current_filesystem_is_synthetic)(struct archive*);
int(archive_read_support_format_raw)(struct archive*);
int(archive_write_set_option)(struct archive*,const char*,const char*,const char*);
int(archive_write_set_format_cpio_newc)(struct archive*);
unsigned long(archive_entry_dev)(struct archive_entry*);
struct archive*(archive_read_disk_new)();
int(archive_match_include_uname)(struct archive*,const char*);
int(archive_read_support_filter_lzop)(struct archive*);
int(archive_read_next_header2)(struct archive*,struct archive_entry*);
int(archive_write_set_format_pax)(struct archive*);
int(archive_write_add_filter_lzma)(struct archive*);
long(archive_read_data)(struct archive*,void*,unsigned long);
int(archive_write_set_options)(struct archive*,const char*);
int(archive_read_support_filter_rpm)(struct archive*);
int(archive_write_finish)(struct archive*);
void(archive_clear_error)(struct archive*);
const char*(archive_entry_sourcepath)(struct archive_entry*);
int(archive_read_disk_set_standard_lookup)(struct archive*);
int(archive_match_owner_excluded)(struct archive*,struct archive_entry*);
const char*(archive_entry_pathname_utf8)(struct archive_entry*);
int(archive_write_open_file)(struct archive*,const char*);
void(archive_read_extract_set_progress_callback)(struct archive*,void(*_progress_func)(void*),void*);
int(archive_read_open_filename)(struct archive*,const char*,unsigned long);
unsigned long(archive_entry_rdevmajor)(struct archive_entry*);
void(archive_entry_set_mode)(struct archive_entry*,unsigned int);
void*(archive_entry_stat)(struct archive_entry*);
int(archive_read_support_compression_program)(struct archive*,const char*);
void(archive_entry_copy_stat)(struct archive_entry*,void*);
int(archive_read_support_filter_lz4)(struct archive*);
int(archive_write_set_compression_bzip2)(struct archive*);
const char*(archive_bzlib_version)();
const char*(archive_filter_name)(struct archive*,int);
int(archive_read_support_compression_lzma)(struct archive*);
int(archive_write_open_filename)(struct archive*,const char*);
int(archive_read_support_format_zip)(struct archive*);
int(archive_write_open_filename_w)(struct archive*,const int*);
int(archive_read_support_format_7zip)(struct archive*);
int(archive_entry_dev_is_set)(struct archive_entry*);
int(archive_match_free)(struct archive*);
const char*(archive_entry_gname_utf8)(struct archive_entry*);
void(archive_entry_linkresolver_set_strategy)(struct archive_entry_linkresolver*,int);
int(archive_entry_update_hardlink_utf8)(struct archive_entry*,const char*);
signed long(archive_seek_data)(struct archive*,signed long,int);
void(archive_entry_set_birthtime)(struct archive_entry*,long,long);
void(archive_read_extract_set_skip_file)(struct archive*,signed long,signed long);
void(archive_entry_copy_sourcepath_w)(struct archive_entry*,const int*);
void(archive_entry_set_pathname)(struct archive_entry*,const char*);
int(archive_read_disk_set_symlink_hybrid)(struct archive*);
const char*(archive_zlib_version)();
int(archive_write_set_compression_compress)(struct archive*);
int(archive_entry_sparse_next)(struct archive_entry*,signed long*,signed long*);
int(archive_read_disk_can_descend)(struct archive*);
void(archive_copy_error)(struct archive*,struct archive*);
int(archive_write_set_compression_lzip)(struct archive*);
int(archive_entry_acl_next)(struct archive_entry*,int,int*,int*,int*,int*,const char**);
int(archive_read_support_format_all)(struct archive*);
int(archive_read_disk_set_symlink_logical)(struct archive*);
int(archive_filter_count)(struct archive*);
int(archive_match_path_unmatched_inclusions_next_w)(struct archive*,const int**);
void(archive_entry_fflags)(struct archive_entry*,unsigned long*,unsigned long*);
void(archive_entry_set_uid)(struct archive_entry*,signed long);
void(archive_entry_set_link_utf8)(struct archive_entry*,const char*);
int(archive_read_support_compression_xz)(struct archive*);
int(archive_filter_code)(struct archive*,int);
int(archive_read_extract2)(struct archive*,struct archive_entry*,struct archive*);
const char*(archive_error_string)(struct archive*);
signed long(archive_read_header_position)(struct archive*);
int(archive_read_add_passphrase)(struct archive*,const char*);
unsigned long(archive_entry_rdev)(struct archive_entry*);
int(archive_write_add_filter)(struct archive*,int);
void(archive_entry_set_gname)(struct archive_entry*,const char*);
int(archive_write_open_memory)(struct archive*,void*,unsigned long,unsigned long*);
signed long(archive_write_disk_gid)(struct archive*,const char*,signed long);
const char*(archive_compression_name)(struct archive*);
int(archive_read_disk_set_matching)(struct archive*,struct archive*,void(*_excluded_func)(struct archive*,void*,struct archive_entry*),void*);
int(archive_read_set_option)(struct archive*,const char*,const char*,const char*);
void(archive_set_error)(struct archive*,int,const char*,...);
int(archive_entry_ctime_is_set)(struct archive_entry*);
int(archive_read_disk_entry_from_file)(struct archive*,struct archive_entry*,int,const void*);
int(archive_read_set_seek_callback)(struct archive*,signed long(unknown_2)(struct archive*,void*,signed long,int));
int(archive_write_set_compression_none)(struct archive*);
unsigned long(archive_entry_rdevminor)(struct archive_entry*);
void(archive_entry_set_filetype)(struct archive_entry*,unsigned int);
long(archive_entry_birthtime)(struct archive_entry*);
void(archive_entry_set_perm)(struct archive_entry*,unsigned int);
int(archive_read_support_filter_compress)(struct archive*);
int(archive_read_support_format_cab)(struct archive*);
int(archive_errno)(struct archive*);
int(archive_read_open_file)(struct archive*,const char*,unsigned long);
void(archive_entry_set_rdevmajor)(struct archive_entry*,unsigned long);
int(archive_read_support_filter_bzip2)(struct archive*);
long(archive_entry_atime_nsec)(struct archive_entry*);
struct archive*(archive_write_new)();
int(archive_entry_atime_is_set)(struct archive_entry*);
void(archive_entry_set_gid)(struct archive_entry*,signed long);
int(archive_write_set_format_warc)(struct archive*);
void(archive_entry_xattr_clear)(struct archive_entry*);
void(archive_entry_copy_hardlink_w)(struct archive_entry*,const int*);
const char*(archive_format_name)(struct archive*);
int(archive_entry_is_encrypted)(struct archive_entry*);
int(archive_read_disk_current_filesystem_is_remote)(struct archive*);
int(archive_write_set_compression_program)(struct archive*,const char*);
struct archive_entry*(archive_entry_new)();
int(archive_write_set_format_7zip)(struct archive*);
int(archive_read_open1)(struct archive*);
int(archive_read_set_options)(struct archive*,const char*);
int(archive_read_data_block)(struct archive*,const void**,unsigned long*,signed long*);
int(archive_match_time_excluded)(struct archive*,struct archive_entry*);
int(archive_entry_sparse_count)(struct archive_entry*);
int(archive_match_path_excluded)(struct archive*,struct archive_entry*);
int(archive_match_path_unmatched_inclusions_next)(struct archive*,const char**);
unsigned int(archive_entry_filetype)(struct archive_entry*);
int(archive_write_add_filter_grzip)(struct archive*);
long(archive_entry_birthtime_nsec)(struct archive_entry*);
int(archive_read_support_format_lha)(struct archive*);
const char*(archive_read_disk_uname)(struct archive*,signed long);
int(archive_write_open)(struct archive*,void*,int(unknown_3)(struct archive*,void*),long(unknown_4)(struct archive*,void*,const void*,unsigned long),int(unknown_5)(struct archive*,void*));
void(archive_entry_set_rdev)(struct archive_entry*,unsigned long);
int(archive_read_append_filter)(struct archive*,int);
struct archive*(archive_read_new)();
void(archive_entry_copy_mac_metadata)(struct archive_entry*,const void*,unsigned long);
int(archive_entry_acl_reset)(struct archive_entry*,int);
int(archive_read_open)(struct archive*,void*,int(unknown_3)(struct archive*,void*),long(unknown_4)(struct archive*,void*,const void**),int(unknown_5)(struct archive*,void*));
struct archive_entry_linkresolver*(archive_entry_linkresolver_new)();
int(archive_entry_sparse_reset)(struct archive_entry*);
const int*(archive_entry_uname_w)(struct archive_entry*);
void(archive_entry_sparse_clear)(struct archive_entry*);
int(archive_entry_xattr_next)(struct archive_entry*,const char**,const void**,unsigned long*);
int(archive_entry_xattr_reset)(struct archive_entry*);
void(archive_entry_copy_gname)(struct archive_entry*,const char*);
struct archive_acl*(archive_entry_acl)(struct archive_entry*);
void(archive_entry_unset_birthtime)(struct archive_entry*);
const int*(archive_entry_acl_text_w)(struct archive_entry*,int);
int(archive_entry_acl_from_text)(struct archive_entry*,const char*,int);
int(archive_write_set_format_shar_dump)(struct archive*);
int(archive_entry_acl_from_text_w)(struct archive_entry*,const int*,int);
char*(archive_entry_acl_to_text)(struct archive_entry*,long*,int);
int*(archive_entry_acl_to_text_w)(struct archive_entry*,long*,int);
int(archive_write_open_FILE)(struct archive*,void*);
struct archive_entry*(archive_entry_partial_links)(struct archive_entry_linkresolver*,unsigned int*);
int(archive_entry_acl_add_entry_w)(struct archive_entry*,int,int,int,int,const int*);
int(archive_entry_acl_add_entry)(struct archive_entry*,int,int,int,int,const char*);
int(archive_write_add_filter_none)(struct archive*);
int(archive_write_add_filter_zstd)(struct archive*);
const void*(archive_entry_mac_metadata)(struct archive_entry*,unsigned long*);
int(archive_read_support_filter_all)(struct archive*);
int(archive_read_support_format_iso9660)(struct archive*);
int(archive_read_support_filter_gzip)(struct archive*);
int(archive_entry_update_uname_utf8)(struct archive_entry*,const char*);
void(archive_entry_copy_uname_w)(struct archive_entry*,const int*);
void(archive_entry_copy_uname)(struct archive_entry*,const char*);
int(archive_match_excluded)(struct archive*,struct archive_entry*);
int(archive_write_set_format_gnutar)(struct archive*);
void(archive_entry_set_uname_utf8)(struct archive_entry*,const char*);
void(archive_entry_set_uname)(struct archive_entry*,const char*);
int(archive_entry_update_symlink_utf8)(struct archive_entry*,const char*);
int(archive_write_set_format_shar)(struct archive*);
void(archive_entry_copy_symlink_w)(struct archive_entry*,const int*);
void(archive_entry_copy_symlink)(struct archive_entry*,const char*);
int(archive_write_free)(struct archive*);
void(archive_entry_set_symlink_utf8)(struct archive_entry*,const char*);
void(archive_entry_set_symlink)(struct archive_entry*,const char*);
void(archive_entry_copy_sourcepath)(struct archive_entry*,const char*);
void(archive_entry_unset_size)(struct archive_entry*);
void(archive_entry_set_size)(struct archive_entry*,signed long);
int(archive_file_count)(struct archive*);
void(archive_entry_set_rdevminor)(struct archive_entry*,unsigned long);
int(archive_entry_update_pathname_utf8)(struct archive_entry*,const char*);
void(archive_entry_copy_pathname_w)(struct archive_entry*,const int*);
const char*(archive_entry_gname)(struct archive_entry*);
void(archive_entry_set_pathname_utf8)(struct archive_entry*,const char*);
void(archive_entry_set_nlink)(struct archive_entry*,unsigned int);
void(archive_entry_unset_mtime)(struct archive_entry*);
void(archive_entry_set_mtime)(struct archive_entry*,long,long);
int(archive_write_disk_set_options)(struct archive*,int);
void(archive_entry_set_ino)(struct archive_entry*,signed long);
int(archive_read_support_compression_bzip2)(struct archive*);
void(archive_entry_copy_link)(struct archive_entry*,const char*);
int(archive_read_support_format_warc)(struct archive*);
void(archive_entry_set_link)(struct archive_entry*,const char*);
void(archive_entry_copy_link_w)(struct archive_entry*,const int*);
void(archive_entry_copy_hardlink)(struct archive_entry*,const char*);
int(archive_write_set_format_mtree_classic)(struct archive*);
int(archive_match_exclude_pattern)(struct archive*,const char*);
int(archive_write_set_format_v7tar)(struct archive*);
int(archive_entry_update_gname_utf8)(struct archive_entry*,const char*);
void(archive_entry_copy_gname_w)(struct archive_entry*,const int*);
void(archive_entry_xattr_add_entry)(struct archive_entry*,const char*,const void*,unsigned long);
int(archive_read_support_format_by_code)(struct archive*,int);
const int*(archive_entry_copy_fflags_text_w)(struct archive_entry*,const int*);
void(archive_entry_set_fflags)(struct archive_entry*,unsigned long,unsigned long);
signed long(archive_position_uncompressed)(struct archive*);
int(archive_write_set_passphrase)(struct archive*,const char*);
void(archive_entry_unset_ctime)(struct archive_entry*);
void(archive_entry_set_ctime)(struct archive_entry*,long,long);
int(archive_read_disk_open_w)(struct archive*,const int*);
void(archive_entry_set_atime)(struct archive_entry*,long,long);
int(archive_entry_is_metadata_encrypted)(struct archive_entry*);
int(archive_entry_is_data_encrypted)(struct archive_entry*);
void(archive_entry_sparse_add_entry)(struct archive_entry*,signed long,signed long);
const char*(archive_entry_uname_utf8)(struct archive_entry*);
const char*(archive_entry_uname)(struct archive_entry*);
int(archive_write_disk_set_skip_file)(struct archive*,signed long,signed long);
const int*(archive_entry_symlink_w)(struct archive_entry*);
const char*(archive_entry_symlink_utf8)(struct archive_entry*);
const char*(archive_entry_strmode)(struct archive_entry*);
const char*(archive_entry_symlink)(struct archive_entry*);
int(archive_match_include_pattern_from_file_w)(struct archive*,const int*,int);
int(archive_read_add_callback_data)(struct archive*,void*,unsigned int);
int(archive_read_support_compression_rpm)(struct archive*);
signed long(archive_entry_size)(struct archive_entry*);
int(archive_read_disk_set_symlink_physical)(struct archive*);
const int*(archive_entry_sourcepath_w)(struct archive_entry*);
const int*(archive_entry_pathname_w)(struct archive_entry*);
int(archive_write_set_format_cpio)(struct archive*);
unsigned int(archive_entry_nlink)(struct archive_entry*);
int(archive_match_include_pattern_from_file)(struct archive*,const char*,int);
int(archive_entry_mtime_is_set)(struct archive_entry*);
long(archive_entry_mtime_nsec)(struct archive_entry*);
long(archive_entry_mtime)(struct archive_entry*);
int(archive_entry_ino_is_set)(struct archive_entry*);
signed long(archive_entry_ino64)(struct archive_entry*);
const int*(archive_entry_hardlink_w)(struct archive_entry*);
const char*(archive_entry_hardlink_utf8)(struct archive_entry*);
int(archive_write_get_bytes_per_block)(struct archive*);
const char*(archive_entry_hardlink)(struct archive_entry*);
const int*(archive_entry_gname_w)(struct archive_entry*);
int(archive_match_include_time)(struct archive*,int,long,long);
void(archive_entry_copy_pathname)(struct archive_entry*,const char*);
int(archive_write_fail)(struct archive*);
signed long(archive_entry_gid)(struct archive_entry*);
int(archive_read_set_switch_callback)(struct archive*,int(unknown_2)(struct archive*,void*,void*));
int(archive_write_set_format_ar_bsd)(struct archive*);
unsigned long(archive_entry_devmajor)(struct archive_entry*);
long(archive_entry_ctime_nsec)(struct archive_entry*);
long(archive_entry_ctime)(struct archive_entry*);
const char*(archive_version_string)();
long(archive_entry_atime)(struct archive_entry*);
struct archive_entry*(archive_entry_new2)(struct archive*);
void(archive_entry_free)(struct archive_entry*);
struct archive_entry*(archive_entry_clear)(struct archive_entry*);
int(archive_match_include_gname_w)(struct archive*,const int*);
int(archive_match_include_gname)(struct archive*,const char*);
int(archive_match_include_pattern_w)(struct archive*,const int*);
void(archive_entry_unset_atime)(struct archive_entry*);
int(archive_match_include_uid)(struct archive*,signed long);
int(archive_match_include_file_time_w)(struct archive*,int,const int*);
int(archive_match_include_file_time)(struct archive*,int,const char*);
int(archive_read_support_filter_lzma)(struct archive*);
int(archive_read_finish)(struct archive*);
int(archive_read_support_compression_compress)(struct archive*);
int(archive_read_prepend_callback_data)(struct archive*,void*);
signed long(archive_write_disk_uid)(struct archive*,const char*,signed long);
void(archive_entry_set_devminor)(struct archive_entry*,unsigned long);
int(archive_read_data_skip)(struct archive*);
int(archive_read_support_compression_gzip)(struct archive*);
int(archive_read_support_format_zip_streamable)(struct archive*);
int(archive_read_support_filter_none)(struct archive*);
int(archive_read_open_memory2)(struct archive*,const void*,unsigned long,unsigned long);
void(archive_entry_acl_clear)(struct archive_entry*);
int(archive_read_support_filter_zstd)(struct archive*);
int(archive_write_add_filter_program)(struct archive*,const char*);
int(archive_write_add_filter_gzip)(struct archive*);
int(archive_write_add_filter_bzip2)(struct archive*);
int(archive_write_add_filter_lzop)(struct archive*);
int(archive_write_set_format_zip)(struct archive*);
int(archive_read_set_filter_option)(struct archive*,const char*,const char*,const char*);
int(archive_compression)(struct archive*);
int(archive_read_open2)(struct archive*,void*,int(unknown_3)(struct archive*,void*),long(unknown_4)(struct archive*,void*,const void**),signed long(unknown_5)(struct archive*,void*,signed long),int(unknown_6)(struct archive*,void*));
int(archive_read_append_callback_data)(struct archive*,void*);
int(archive_write_set_format_xar)(struct archive*);
int(archive_match_exclude_pattern_w)(struct archive*,const int*);
int(archive_read_set_open_callback)(struct archive*,int(unknown_2)(struct archive*,void*));
int(archive_write_set_compression_gzip)(struct archive*);
int(archive_write_set_format_filter_by_ext_def)(struct archive*,const char*,const char*);
int(archive_write_get_bytes_in_last_block)(struct archive*);
int(archive_read_support_format_rar)(struct archive*);
int(archive_write_open_fd)(struct archive*,int);
int(archive_write_add_filter_lz4)(struct archive*);
int(archive_entry_birthtime_is_set)(struct archive_entry*);
int(archive_match_include_uname_w)(struct archive*,const int*);
int(archive_write_set_format_ar_svr4)(struct archive*);
int(archive_write_set_bytes_in_last_block)(struct archive*,int);
unsigned int(archive_entry_mode)(struct archive_entry*);
int(archive_write_set_bytes_per_block)(struct archive*,int);
int(archive_read_next_header)(struct archive*,struct archive_entry**);
int(archive_entry_acl_types)(struct archive_entry*);
const char*(archive_version_details)();
struct archive*(archive_write_disk_new)();
int(archive_read_disk_open)(struct archive*,const char*);
int(archive_read_support_filter_uu)(struct archive*);
void(archive_entry_set_is_metadata_encrypted)(struct archive_entry*,char);
int(archive_read_set_format)(struct archive*,int);
int(archive_read_support_filter_lrzip)(struct archive*);
const char*(archive_liblzma_version)();
int(archive_read_support_compression_uu)(struct archive*);
void(archive_entry_set_is_data_encrypted)(struct archive_entry*,char);
int(archive_read_support_filter_lzip)(struct archive*);
int(archive_read_has_encrypted_entries)(struct archive*);
int(archive_write_add_filter_b64encode)(struct archive*);
int(archive_read_support_format_rar5)(struct archive*);
int(archive_read_append_filter_program_signature)(struct archive*,const char*,const void*,unsigned long);
int(archive_write_add_filter_lzip)(struct archive*);
int(archive_read_set_read_callback)(struct archive*,long(unknown_2)(struct archive*,void*,const void**));
int(archive_read_set_skip_callback)(struct archive*,signed long(unknown_2)(struct archive*,void*,signed long));
int(archive_read_set_close_callback)(struct archive*,int(unknown_2)(struct archive*,void*));
int(archive_entry_size_is_set)(struct archive_entry*);
int(archive_read_support_format_xar)(struct archive*);
int(archive_read_open_fd)(struct archive*,int,unsigned long);
int(archive_read_open_FILE)(struct archive*,void*);
long(archive_write_data)(struct archive*,const void*,unsigned long);
int(archive_read_support_filter_xz)(struct archive*);
int(archive_read_data_into_fd)(struct archive*,int);
int(archive_read_set_format_option)(struct archive*,const char*,const char*,const char*);
const char*(archive_libzstd_version)();
int(archive_read_set_passphrase_callback)(struct archive*,void*,const char*(unknown_3)(struct archive*,void*));
int(archive_format)(struct archive*);
int(archive_read_extract)(struct archive*,struct archive_entry*,int);
int(archive_read_close)(struct archive*);
int(archive_read_support_filter_grzip)(struct archive*);
int(archive_match_exclude_pattern_from_file_w)(struct archive*,const int*,int);
int(archive_write_set_skip_file)(struct archive*,signed long,signed long);
int(archive_read_support_compression_all)(struct archive*);
int(archive_write_add_filter_by_name)(struct archive*,const char*);
int(archive_read_support_format_tar)(struct archive*);
int(archive_write_add_filter_lrzip)(struct archive*);
int(archive_write_finish_entry)(struct archive*);
int(archive_write_add_filter_uuencode)(struct archive*);
int(archive_write_set_format)(struct archive*,int);
void(archive_entry_set_hardlink_utf8)(struct archive_entry*,const char*);
const char*(archive_entry_pathname)(struct archive_entry*);
unsigned long(archive_entry_devminor)(struct archive_entry*);
int(archive_write_set_format_pax_restricted)(struct archive*);
int(archive_write_set_format_raw)(struct archive*);
int(archive_read_set_callback_data2)(struct archive*,void*,unsigned int);
int(archive_write_add_filter_compress)(struct archive*);
int(archive_write_zip_set_compression_deflate)(struct archive*);
int(archive_read_append_filter_program)(struct archive*,const char*);
int(archive_write_header)(struct archive*,struct archive_entry*);
int(archive_read_format_capabilities)(struct archive*);
long(archive_write_data_block)(struct archive*,const void*,unsigned long,signed long);
int(archive_write_disk_set_standard_lookup)(struct archive*);
int(archive_write_set_format_option)(struct archive*,const char*,const char*,const char*);
const char*(archive_read_disk_gname)(struct archive*,signed long);
int(archive_read_disk_descend)(struct archive*);
void(archive_entry_set_devmajor)(struct archive_entry*,unsigned long);
int(archive_read_disk_set_behavior)(struct archive*,int);
int(archive_write_set_compression_lzma)(struct archive*);
void(archive_entry_set_hardlink)(struct archive_entry*,const char*);
int(archive_match_exclude_pattern_from_file)(struct archive*,const char*,int);
]])
local library = {}
library = {
	VersionNumber = CLIB.archive_version_number,
	ReadSupportFormatGnutar = CLIB.archive_read_support_format_gnutar,
	MatchIncludeDate = CLIB.archive_match_include_date,
	EntrySetIno64 = CLIB.archive_entry_set_ino64,
	WriteSetFormatIso9660 = CLIB.archive_write_set_format_iso9660,
	EntrySetGnameUtf8 = CLIB.archive_entry_set_gname_utf8,
	FilterBytes = CLIB.archive_filter_bytes,
	WriteSetPassphraseCallback = CLIB.archive_write_set_passphrase_callback,
	WriteClose = CLIB.archive_write_close,
	ReadSupportFormatMtree = CLIB.archive_read_support_format_mtree,
	WriteSetFormatFilterByExt = CLIB.archive_write_set_format_filter_by_ext,
	ReadDiskSetMetadataFilterCallback = CLIB.archive_read_disk_set_metadata_filter_callback,
	EntryClone = CLIB.archive_entry_clone,
	ReadOpenFilenameW = CLIB.archive_read_open_filename_w,
	EntryAclCount = CLIB.archive_entry_acl_count,
	WriteSetFilterOption = CLIB.archive_write_set_filter_option,
	EntryLinkify = CLIB.archive_entry_linkify,
	MatchIncludePattern = CLIB.archive_match_include_pattern,
	ReadSupportFormatAr = CLIB.archive_read_support_format_ar,
	EntryAclText = CLIB.archive_entry_acl_text,
	MatchExcludeEntry = CLIB.archive_match_exclude_entry,
	ReadOpenFilenames = CLIB.archive_read_open_filenames,
	ReadSupportCompressionLzip = CLIB.archive_read_support_compression_lzip,
	WriteSetFormatByName = CLIB.archive_write_set_format_by_name,
	ReadSupportFormatCpio = CLIB.archive_read_support_format_cpio,
	WriteZipSetCompressionStore = CLIB.archive_write_zip_set_compression_store,
	Liblz4Version = CLIB.archive_liblz4_version,
	Free = CLIB.archive_free,
	MatchPathUnmatchedInclusions = CLIB.archive_match_path_unmatched_inclusions,
	WriteSetFormatUstar = CLIB.archive_write_set_format_ustar,
	WriteSetFormatMtree = CLIB.archive_write_set_format_mtree,
	ReadSupportCompressionProgramSignature = CLIB.archive_read_support_compression_program_signature,
	MatchNew = CLIB.archive_match_new,
	ReadSupportFilterProgramSignature = CLIB.archive_read_support_filter_program_signature,
	EntryUid = CLIB.archive_entry_uid,
	PositionCompressed = CLIB.archive_position_compressed,
	EntryCopyFflagsText = CLIB.archive_entry_copy_fflags_text,
	ReadDiskCurrentFilesystem = CLIB.archive_read_disk_current_filesystem,
	WriteAddFilterXz = CLIB.archive_write_add_filter_xz,
	ReadSetCallbackData = CLIB.archive_read_set_callback_data,
	MatchIncludeGid = CLIB.archive_match_include_gid,
	ReadSupportFilterProgram = CLIB.archive_read_support_filter_program,
	EntryIno = CLIB.archive_entry_ino,
	EntrySetDev = CLIB.archive_entry_set_dev,
	EntryLinkresolverFree = CLIB.archive_entry_linkresolver_free,
	EntryUpdateLinkUtf8 = CLIB.archive_entry_update_link_utf8,
	MatchIncludeDateW = CLIB.archive_match_include_date_w,
	ReadOpenMemory = CLIB.archive_read_open_memory,
	EntryXattrCount = CLIB.archive_entry_xattr_count,
	ReadDiskSetAtimeRestored = CLIB.archive_read_disk_set_atime_restored,
	UtilityStringSort = CLIB.archive_utility_string_sort,
	WriteSetCompressionXz = CLIB.archive_write_set_compression_xz,
	ReadSupportFormatZipSeekable = CLIB.archive_read_support_format_zip_seekable,
	EntryPerm = CLIB.archive_entry_perm,
	ReadSupportFormatEmpty = CLIB.archive_read_support_format_empty,
	EntryFflagsText = CLIB.archive_entry_fflags_text,
	ReadSupportCompressionNone = CLIB.archive_read_support_compression_none,
	ReadFree = CLIB.archive_read_free,
	ReadDiskCurrentFilesystemIsSynthetic = CLIB.archive_read_disk_current_filesystem_is_synthetic,
	ReadSupportFormatRaw = CLIB.archive_read_support_format_raw,
	WriteSetOption = CLIB.archive_write_set_option,
	WriteSetFormatCpioNewc = CLIB.archive_write_set_format_cpio_newc,
	EntryDev = CLIB.archive_entry_dev,
	ReadDiskNew = CLIB.archive_read_disk_new,
	MatchIncludeUname = CLIB.archive_match_include_uname,
	ReadSupportFilterLzop = CLIB.archive_read_support_filter_lzop,
	ReadNextHeader2 = CLIB.archive_read_next_header2,
	WriteSetFormatPax = CLIB.archive_write_set_format_pax,
	WriteAddFilterLzma = CLIB.archive_write_add_filter_lzma,
	ReadData = CLIB.archive_read_data,
	WriteSetOptions = CLIB.archive_write_set_options,
	ReadSupportFilterRpm = CLIB.archive_read_support_filter_rpm,
	WriteFinish = CLIB.archive_write_finish,
	ClearError = CLIB.archive_clear_error,
	EntrySourcepath = CLIB.archive_entry_sourcepath,
	ReadDiskSetStandardLookup = CLIB.archive_read_disk_set_standard_lookup,
	MatchOwnerExcluded = CLIB.archive_match_owner_excluded,
	EntryPathnameUtf8 = CLIB.archive_entry_pathname_utf8,
	WriteOpenFile = CLIB.archive_write_open_file,
	ReadExtractSetProgressCallback = CLIB.archive_read_extract_set_progress_callback,
	ReadOpenFilename = CLIB.archive_read_open_filename,
	EntryRdevmajor = CLIB.archive_entry_rdevmajor,
	EntrySetMode = CLIB.archive_entry_set_mode,
	EntryStat = CLIB.archive_entry_stat,
	ReadSupportCompressionProgram = CLIB.archive_read_support_compression_program,
	EntryCopyStat = CLIB.archive_entry_copy_stat,
	ReadSupportFilterLz4 = CLIB.archive_read_support_filter_lz4,
	WriteSetCompressionBzip2 = CLIB.archive_write_set_compression_bzip2,
	BzlibVersion = CLIB.archive_bzlib_version,
	FilterName = CLIB.archive_filter_name,
	ReadSupportCompressionLzma = CLIB.archive_read_support_compression_lzma,
	WriteOpenFilename = CLIB.archive_write_open_filename,
	ReadSupportFormatZip = CLIB.archive_read_support_format_zip,
	WriteOpenFilenameW = CLIB.archive_write_open_filename_w,
	ReadSupportFormat_7zip = CLIB.archive_read_support_format_7zip,
	EntryDevIsSet = CLIB.archive_entry_dev_is_set,
	MatchFree = CLIB.archive_match_free,
	EntryGnameUtf8 = CLIB.archive_entry_gname_utf8,
	EntryLinkresolverSetStrategy = CLIB.archive_entry_linkresolver_set_strategy,
	EntryUpdateHardlinkUtf8 = CLIB.archive_entry_update_hardlink_utf8,
	SeekData = CLIB.archive_seek_data,
	EntrySetBirthtime = CLIB.archive_entry_set_birthtime,
	ReadExtractSetSkipFile = CLIB.archive_read_extract_set_skip_file,
	EntryCopySourcepathW = CLIB.archive_entry_copy_sourcepath_w,
	EntrySetPathname = CLIB.archive_entry_set_pathname,
	ReadDiskSetSymlinkHybrid = CLIB.archive_read_disk_set_symlink_hybrid,
	ZlibVersion = CLIB.archive_zlib_version,
	WriteSetCompressionCompress = CLIB.archive_write_set_compression_compress,
	EntrySparseNext = CLIB.archive_entry_sparse_next,
	ReadDiskCanDescend = CLIB.archive_read_disk_can_descend,
	CopyError = CLIB.archive_copy_error,
	WriteSetCompressionLzip = CLIB.archive_write_set_compression_lzip,
	EntryAclNext = CLIB.archive_entry_acl_next,
	ReadSupportFormatAll = CLIB.archive_read_support_format_all,
	ReadDiskSetSymlinkLogical = CLIB.archive_read_disk_set_symlink_logical,
	FilterCount = CLIB.archive_filter_count,
	MatchPathUnmatchedInclusionsNextW = CLIB.archive_match_path_unmatched_inclusions_next_w,
	EntryFflags = CLIB.archive_entry_fflags,
	EntrySetUid = CLIB.archive_entry_set_uid,
	EntrySetLinkUtf8 = CLIB.archive_entry_set_link_utf8,
	ReadSupportCompressionXz = CLIB.archive_read_support_compression_xz,
	FilterCode = CLIB.archive_filter_code,
	ReadExtract2 = CLIB.archive_read_extract2,
	ErrorString = CLIB.archive_error_string,
	ReadHeaderPosition = CLIB.archive_read_header_position,
	ReadAddPassphrase = CLIB.archive_read_add_passphrase,
	EntryRdev = CLIB.archive_entry_rdev,
	WriteAddFilter = CLIB.archive_write_add_filter,
	EntrySetGname = CLIB.archive_entry_set_gname,
	WriteOpenMemory = CLIB.archive_write_open_memory,
	WriteDiskGid = CLIB.archive_write_disk_gid,
	CompressionName = CLIB.archive_compression_name,
	ReadDiskSetMatching = CLIB.archive_read_disk_set_matching,
	ReadSetOption = CLIB.archive_read_set_option,
	SetError = CLIB.archive_set_error,
	EntryCtimeIsSet = CLIB.archive_entry_ctime_is_set,
	ReadDiskEntryFromFile = CLIB.archive_read_disk_entry_from_file,
	ReadSetSeekCallback = CLIB.archive_read_set_seek_callback,
	WriteSetCompressionNone = CLIB.archive_write_set_compression_none,
	EntryRdevminor = CLIB.archive_entry_rdevminor,
	EntrySetFiletype = CLIB.archive_entry_set_filetype,
	EntryBirthtime = CLIB.archive_entry_birthtime,
	EntrySetPerm = CLIB.archive_entry_set_perm,
	ReadSupportFilterCompress = CLIB.archive_read_support_filter_compress,
	ReadSupportFormatCab = CLIB.archive_read_support_format_cab,
	Errno = CLIB.archive_errno,
	ReadOpenFile = CLIB.archive_read_open_file,
	EntrySetRdevmajor = CLIB.archive_entry_set_rdevmajor,
	ReadSupportFilterBzip2 = CLIB.archive_read_support_filter_bzip2,
	EntryAtimeNsec = CLIB.archive_entry_atime_nsec,
	WriteNew = CLIB.archive_write_new,
	EntryAtimeIsSet = CLIB.archive_entry_atime_is_set,
	EntrySetGid = CLIB.archive_entry_set_gid,
	WriteSetFormatWarc = CLIB.archive_write_set_format_warc,
	EntryXattrClear = CLIB.archive_entry_xattr_clear,
	EntryCopyHardlinkW = CLIB.archive_entry_copy_hardlink_w,
	FormatName = CLIB.archive_format_name,
	EntryIsEncrypted = CLIB.archive_entry_is_encrypted,
	ReadDiskCurrentFilesystemIsRemote = CLIB.archive_read_disk_current_filesystem_is_remote,
	WriteSetCompressionProgram = CLIB.archive_write_set_compression_program,
	EntryNew = CLIB.archive_entry_new,
	WriteSetFormat_7zip = CLIB.archive_write_set_format_7zip,
	ReadOpen1 = CLIB.archive_read_open1,
	ReadSetOptions = CLIB.archive_read_set_options,
	ReadDataBlock = CLIB.archive_read_data_block,
	MatchTimeExcluded = CLIB.archive_match_time_excluded,
	EntrySparseCount = CLIB.archive_entry_sparse_count,
	MatchPathExcluded = CLIB.archive_match_path_excluded,
	MatchPathUnmatchedInclusionsNext = CLIB.archive_match_path_unmatched_inclusions_next,
	EntryFiletype = CLIB.archive_entry_filetype,
	WriteAddFilterGrzip = CLIB.archive_write_add_filter_grzip,
	EntryBirthtimeNsec = CLIB.archive_entry_birthtime_nsec,
	ReadSupportFormatLha = CLIB.archive_read_support_format_lha,
	ReadDiskUname = CLIB.archive_read_disk_uname,
	WriteOpen = CLIB.archive_write_open,
	EntrySetRdev = CLIB.archive_entry_set_rdev,
	ReadAppendFilter = CLIB.archive_read_append_filter,
	ReadNew = CLIB.archive_read_new,
	EntryCopyMacMetadata = CLIB.archive_entry_copy_mac_metadata,
	EntryAclReset = CLIB.archive_entry_acl_reset,
	ReadOpen = CLIB.archive_read_open,
	EntryLinkresolverNew = CLIB.archive_entry_linkresolver_new,
	EntrySparseReset = CLIB.archive_entry_sparse_reset,
	EntryUnameW = CLIB.archive_entry_uname_w,
	EntrySparseClear = CLIB.archive_entry_sparse_clear,
	EntryXattrNext = CLIB.archive_entry_xattr_next,
	EntryXattrReset = CLIB.archive_entry_xattr_reset,
	EntryCopyGname = CLIB.archive_entry_copy_gname,
	EntryAcl = CLIB.archive_entry_acl,
	EntryUnsetBirthtime = CLIB.archive_entry_unset_birthtime,
	EntryAclTextW = CLIB.archive_entry_acl_text_w,
	EntryAclFromText = CLIB.archive_entry_acl_from_text,
	WriteSetFormatSharDump = CLIB.archive_write_set_format_shar_dump,
	EntryAclFromTextW = CLIB.archive_entry_acl_from_text_w,
	EntryAclToText = CLIB.archive_entry_acl_to_text,
	EntryAclToTextW = CLIB.archive_entry_acl_to_text_w,
	WriteOpen_FILE = CLIB.archive_write_open_FILE,
	EntryPartialLinks = CLIB.archive_entry_partial_links,
	EntryAclAddEntryW = CLIB.archive_entry_acl_add_entry_w,
	EntryAclAddEntry = CLIB.archive_entry_acl_add_entry,
	WriteAddFilterNone = CLIB.archive_write_add_filter_none,
--	WriteAddFilterZstd = CLIB.archive_write_add_filter_zstd,
	EntryMacMetadata = CLIB.archive_entry_mac_metadata,
	ReadSupportFilterAll = CLIB.archive_read_support_filter_all,
	ReadSupportFormatIso9660 = CLIB.archive_read_support_format_iso9660,
	ReadSupportFilterGzip = CLIB.archive_read_support_filter_gzip,
	EntryUpdateUnameUtf8 = CLIB.archive_entry_update_uname_utf8,
	EntryCopyUnameW = CLIB.archive_entry_copy_uname_w,
	EntryCopyUname = CLIB.archive_entry_copy_uname,
	MatchExcluded = CLIB.archive_match_excluded,
	WriteSetFormatGnutar = CLIB.archive_write_set_format_gnutar,
	EntrySetUnameUtf8 = CLIB.archive_entry_set_uname_utf8,
	EntrySetUname = CLIB.archive_entry_set_uname,
	EntryUpdateSymlinkUtf8 = CLIB.archive_entry_update_symlink_utf8,
	WriteSetFormatShar = CLIB.archive_write_set_format_shar,
	EntryCopySymlinkW = CLIB.archive_entry_copy_symlink_w,
	EntryCopySymlink = CLIB.archive_entry_copy_symlink,
	WriteFree = CLIB.archive_write_free,
	EntrySetSymlinkUtf8 = CLIB.archive_entry_set_symlink_utf8,
	EntrySetSymlink = CLIB.archive_entry_set_symlink,
	EntryCopySourcepath = CLIB.archive_entry_copy_sourcepath,
	EntryUnsetSize = CLIB.archive_entry_unset_size,
	EntrySetSize = CLIB.archive_entry_set_size,
	FileCount = CLIB.archive_file_count,
	EntrySetRdevminor = CLIB.archive_entry_set_rdevminor,
	EntryUpdatePathnameUtf8 = CLIB.archive_entry_update_pathname_utf8,
	EntryCopyPathnameW = CLIB.archive_entry_copy_pathname_w,
	EntryGname = CLIB.archive_entry_gname,
	EntrySetPathnameUtf8 = CLIB.archive_entry_set_pathname_utf8,
	EntrySetNlink = CLIB.archive_entry_set_nlink,
	EntryUnsetMtime = CLIB.archive_entry_unset_mtime,
	EntrySetMtime = CLIB.archive_entry_set_mtime,
	WriteDiskSetOptions = CLIB.archive_write_disk_set_options,
	EntrySetIno = CLIB.archive_entry_set_ino,
	ReadSupportCompressionBzip2 = CLIB.archive_read_support_compression_bzip2,
	EntryCopyLink = CLIB.archive_entry_copy_link,
	ReadSupportFormatWarc = CLIB.archive_read_support_format_warc,
	EntrySetLink = CLIB.archive_entry_set_link,
	EntryCopyLinkW = CLIB.archive_entry_copy_link_w,
	EntryCopyHardlink = CLIB.archive_entry_copy_hardlink,
	WriteSetFormatMtreeClassic = CLIB.archive_write_set_format_mtree_classic,
	MatchExcludePattern = CLIB.archive_match_exclude_pattern,
	WriteSetFormatV7tar = CLIB.archive_write_set_format_v7tar,
	EntryUpdateGnameUtf8 = CLIB.archive_entry_update_gname_utf8,
	EntryCopyGnameW = CLIB.archive_entry_copy_gname_w,
	EntryXattrAddEntry = CLIB.archive_entry_xattr_add_entry,
	ReadSupportFormatByCode = CLIB.archive_read_support_format_by_code,
	EntryCopyFflagsTextW = CLIB.archive_entry_copy_fflags_text_w,
	EntrySetFflags = CLIB.archive_entry_set_fflags,
	PositionUncompressed = CLIB.archive_position_uncompressed,
	WriteSetPassphrase = CLIB.archive_write_set_passphrase,
	EntryUnsetCtime = CLIB.archive_entry_unset_ctime,
	EntrySetCtime = CLIB.archive_entry_set_ctime,
	ReadDiskOpenW = CLIB.archive_read_disk_open_w,
	EntrySetAtime = CLIB.archive_entry_set_atime,
	EntryIsMetadataEncrypted = CLIB.archive_entry_is_metadata_encrypted,
	EntryIsDataEncrypted = CLIB.archive_entry_is_data_encrypted,
	EntrySparseAddEntry = CLIB.archive_entry_sparse_add_entry,
	EntryUnameUtf8 = CLIB.archive_entry_uname_utf8,
	EntryUname = CLIB.archive_entry_uname,
	WriteDiskSetSkipFile = CLIB.archive_write_disk_set_skip_file,
	EntrySymlinkW = CLIB.archive_entry_symlink_w,
	EntrySymlinkUtf8 = CLIB.archive_entry_symlink_utf8,
	EntryStrmode = CLIB.archive_entry_strmode,
	EntrySymlink = CLIB.archive_entry_symlink,
	MatchIncludePatternFromFileW = CLIB.archive_match_include_pattern_from_file_w,
	ReadAddCallbackData = CLIB.archive_read_add_callback_data,
	ReadSupportCompressionRpm = CLIB.archive_read_support_compression_rpm,
	EntrySize = CLIB.archive_entry_size,
	ReadDiskSetSymlinkPhysical = CLIB.archive_read_disk_set_symlink_physical,
	EntrySourcepathW = CLIB.archive_entry_sourcepath_w,
	EntryPathnameW = CLIB.archive_entry_pathname_w,
	WriteSetFormatCpio = CLIB.archive_write_set_format_cpio,
	EntryNlink = CLIB.archive_entry_nlink,
	MatchIncludePatternFromFile = CLIB.archive_match_include_pattern_from_file,
	EntryMtimeIsSet = CLIB.archive_entry_mtime_is_set,
	EntryMtimeNsec = CLIB.archive_entry_mtime_nsec,
	EntryMtime = CLIB.archive_entry_mtime,
	EntryInoIsSet = CLIB.archive_entry_ino_is_set,
	EntryIno64 = CLIB.archive_entry_ino64,
	EntryHardlinkW = CLIB.archive_entry_hardlink_w,
	EntryHardlinkUtf8 = CLIB.archive_entry_hardlink_utf8,
	WriteGetBytesPerBlock = CLIB.archive_write_get_bytes_per_block,
	EntryHardlink = CLIB.archive_entry_hardlink,
	EntryGnameW = CLIB.archive_entry_gname_w,
	MatchIncludeTime = CLIB.archive_match_include_time,
	EntryCopyPathname = CLIB.archive_entry_copy_pathname,
	WriteFail = CLIB.archive_write_fail,
	EntryGid = CLIB.archive_entry_gid,
	ReadSetSwitchCallback = CLIB.archive_read_set_switch_callback,
	WriteSetFormatArBsd = CLIB.archive_write_set_format_ar_bsd,
	EntryDevmajor = CLIB.archive_entry_devmajor,
	EntryCtimeNsec = CLIB.archive_entry_ctime_nsec,
	EntryCtime = CLIB.archive_entry_ctime,
	VersionString = CLIB.archive_version_string,
	EntryAtime = CLIB.archive_entry_atime,
	EntryNew2 = CLIB.archive_entry_new2,
	EntryFree = CLIB.archive_entry_free,
	EntryClear = CLIB.archive_entry_clear,
	MatchIncludeGnameW = CLIB.archive_match_include_gname_w,
	MatchIncludeGname = CLIB.archive_match_include_gname,
	MatchIncludePatternW = CLIB.archive_match_include_pattern_w,
	EntryUnsetAtime = CLIB.archive_entry_unset_atime,
	MatchIncludeUid = CLIB.archive_match_include_uid,
	MatchIncludeFileTimeW = CLIB.archive_match_include_file_time_w,
	MatchIncludeFileTime = CLIB.archive_match_include_file_time,
	ReadSupportFilterLzma = CLIB.archive_read_support_filter_lzma,
	ReadFinish = CLIB.archive_read_finish,
	ReadSupportCompressionCompress = CLIB.archive_read_support_compression_compress,
	ReadPrependCallbackData = CLIB.archive_read_prepend_callback_data,
	WriteDiskUid = CLIB.archive_write_disk_uid,
	EntrySetDevminor = CLIB.archive_entry_set_devminor,
	ReadDataSkip = CLIB.archive_read_data_skip,
	ReadSupportCompressionGzip = CLIB.archive_read_support_compression_gzip,
	ReadSupportFormatZipStreamable = CLIB.archive_read_support_format_zip_streamable,
	ReadSupportFilterNone = CLIB.archive_read_support_filter_none,
	ReadOpenMemory2 = CLIB.archive_read_open_memory2,
	EntryAclClear = CLIB.archive_entry_acl_clear,
--	ReadSupportFilterZstd = CLIB.archive_read_support_filter_zstd,
	WriteAddFilterProgram = CLIB.archive_write_add_filter_program,
	WriteAddFilterGzip = CLIB.archive_write_add_filter_gzip,
	WriteAddFilterBzip2 = CLIB.archive_write_add_filter_bzip2,
	WriteAddFilterLzop = CLIB.archive_write_add_filter_lzop,
	WriteSetFormatZip = CLIB.archive_write_set_format_zip,
	ReadSetFilterOption = CLIB.archive_read_set_filter_option,
	Compression = CLIB.archive_compression,
	ReadOpen2 = CLIB.archive_read_open2,
	ReadAppendCallbackData = CLIB.archive_read_append_callback_data,
	WriteSetFormatXar = CLIB.archive_write_set_format_xar,
	MatchExcludePatternW = CLIB.archive_match_exclude_pattern_w,
	ReadSetOpenCallback = CLIB.archive_read_set_open_callback,
	WriteSetCompressionGzip = CLIB.archive_write_set_compression_gzip,
	WriteSetFormatFilterByExtDef = CLIB.archive_write_set_format_filter_by_ext_def,
	WriteGetBytesInLastBlock = CLIB.archive_write_get_bytes_in_last_block,
	ReadSupportFormatRar = CLIB.archive_read_support_format_rar,
	WriteOpenFd = CLIB.archive_write_open_fd,
	WriteAddFilterLz4 = CLIB.archive_write_add_filter_lz4,
	EntryBirthtimeIsSet = CLIB.archive_entry_birthtime_is_set,
	MatchIncludeUnameW = CLIB.archive_match_include_uname_w,
	WriteSetFormatArSvr4 = CLIB.archive_write_set_format_ar_svr4,
	WriteSetBytesInLastBlock = CLIB.archive_write_set_bytes_in_last_block,
	EntryMode = CLIB.archive_entry_mode,
	WriteSetBytesPerBlock = CLIB.archive_write_set_bytes_per_block,
	ReadNextHeader = CLIB.archive_read_next_header,
	EntryAclTypes = CLIB.archive_entry_acl_types,
	VersionDetails = CLIB.archive_version_details,
	WriteDiskNew = CLIB.archive_write_disk_new,
	ReadDiskOpen = CLIB.archive_read_disk_open,
	ReadSupportFilterUu = CLIB.archive_read_support_filter_uu,
	EntrySetIsMetadataEncrypted = CLIB.archive_entry_set_is_metadata_encrypted,
	ReadSetFormat = CLIB.archive_read_set_format,
	ReadSupportFilterLrzip = CLIB.archive_read_support_filter_lrzip,
	LiblzmaVersion = CLIB.archive_liblzma_version,
	ReadSupportCompressionUu = CLIB.archive_read_support_compression_uu,
	EntrySetIsDataEncrypted = CLIB.archive_entry_set_is_data_encrypted,
	ReadSupportFilterLzip = CLIB.archive_read_support_filter_lzip,
	ReadHasEncryptedEntries = CLIB.archive_read_has_encrypted_entries,
	WriteAddFilterB64encode = CLIB.archive_write_add_filter_b64encode,
--	ReadSupportFormatRar5 = CLIB.archive_read_support_format_rar5,
	ReadAppendFilterProgramSignature = CLIB.archive_read_append_filter_program_signature,
	WriteAddFilterLzip = CLIB.archive_write_add_filter_lzip,
	ReadSetReadCallback = CLIB.archive_read_set_read_callback,
	ReadSetSkipCallback = CLIB.archive_read_set_skip_callback,
	ReadSetCloseCallback = CLIB.archive_read_set_close_callback,
	EntrySizeIsSet = CLIB.archive_entry_size_is_set,
	ReadSupportFormatXar = CLIB.archive_read_support_format_xar,
	ReadOpenFd = CLIB.archive_read_open_fd,
	ReadOpen_FILE = CLIB.archive_read_open_FILE,
	WriteData = CLIB.archive_write_data,
	ReadSupportFilterXz = CLIB.archive_read_support_filter_xz,
	ReadDataIntoFd = CLIB.archive_read_data_into_fd,
	ReadSetFormatOption = CLIB.archive_read_set_format_option,
--	LibzstdVersion = CLIB.archive_libzstd_version,
	ReadSetPassphraseCallback = CLIB.archive_read_set_passphrase_callback,
	Format = CLIB.archive_format,
	ReadExtract = CLIB.archive_read_extract,
	ReadClose = CLIB.archive_read_close,
	ReadSupportFilterGrzip = CLIB.archive_read_support_filter_grzip,
	MatchExcludePatternFromFileW = CLIB.archive_match_exclude_pattern_from_file_w,
	WriteSetSkipFile = CLIB.archive_write_set_skip_file,
	ReadSupportCompressionAll = CLIB.archive_read_support_compression_all,
	WriteAddFilterByName = CLIB.archive_write_add_filter_by_name,
	ReadSupportFormatTar = CLIB.archive_read_support_format_tar,
	WriteAddFilterLrzip = CLIB.archive_write_add_filter_lrzip,
	WriteFinishEntry = CLIB.archive_write_finish_entry,
	WriteAddFilterUuencode = CLIB.archive_write_add_filter_uuencode,
	WriteSetFormat = CLIB.archive_write_set_format,
	EntrySetHardlinkUtf8 = CLIB.archive_entry_set_hardlink_utf8,
	EntryPathname = CLIB.archive_entry_pathname,
	EntryDevminor = CLIB.archive_entry_devminor,
	WriteSetFormatPaxRestricted = CLIB.archive_write_set_format_pax_restricted,
	WriteSetFormatRaw = CLIB.archive_write_set_format_raw,
	ReadSetCallbackData2 = CLIB.archive_read_set_callback_data2,
	WriteAddFilterCompress = CLIB.archive_write_add_filter_compress,
	WriteZipSetCompressionDeflate = CLIB.archive_write_zip_set_compression_deflate,
	ReadAppendFilterProgram = CLIB.archive_read_append_filter_program,
	WriteHeader = CLIB.archive_write_header,
	ReadFormatCapabilities = CLIB.archive_read_format_capabilities,
	WriteDataBlock = CLIB.archive_write_data_block,
	WriteDiskSetStandardLookup = CLIB.archive_write_disk_set_standard_lookup,
	WriteSetFormatOption = CLIB.archive_write_set_format_option,
	ReadDiskGname = CLIB.archive_read_disk_gname,
	ReadDiskDescend = CLIB.archive_read_disk_descend,
	EntrySetDevmajor = CLIB.archive_entry_set_devmajor,
	ReadDiskSetBehavior = CLIB.archive_read_disk_set_behavior,
	WriteSetCompressionLzma = CLIB.archive_write_set_compression_lzma,
	EntrySetHardlink = CLIB.archive_entry_set_hardlink,
	MatchExcludePatternFromFile = CLIB.archive_match_exclude_pattern_from_file,
}
library.e = {
	H_INCLUDED = 1,
	VERSION_NUMBER = 3003004,
	VERSION_ONLY_STRING = "3.3.4dev",
	VERSION_STRING = "libarchive 3.3.4dev",
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
	FORMAT_RAR_V5 = 851969,
	FORMAT_7ZIP = 917504,
	FORMAT_WARC = 983040,
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
	READDISK_RESTORE_ATIME = 1,
	READDISK_HONOR_NODUMP = 2,
	READDISK_MAC_COPYFILE = 4,
	READDISK_NO_TRAVERSE_MOUNTS = 8,
	READDISK_NO_XATTR = 16,
	READDISK_NO_ACL = 32,
	READDISK_NO_FFLAGS = 64,
	MATCH_MTIME = 256,
	MATCH_CTIME = 512,
	MATCH_NEWER = 1,
	MATCH_OLDER = 2,
	MATCH_EQUAL = 16,
}
library.clib = CLIB
return library
