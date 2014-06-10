---
project: minizip
tagline: ZIP reader & writer
---

## `local zip = require'minizip'`

Supports creating, reading, writing, appending, and listing a ZIP file. Advanced use of this module requires an understanding of the [ZIP file format].

## Features

  * encryption and decryption with a password
  * reading and writing of large (> 4G) files
  * copying files between two zip files without decompression/compression steps

## `zip.open(filename[, mode]) -> z`

Opens a ZIP file for reading or writing, depending on the mode argument:

  * `"r"` - open for reading (listing and decompressing an existing ZIP archive)
  * `"w"` - open for writing (creating a new ZIP archive)
  * `"a"` - open for appending (adding more files to an existing archive)

If the file is opened for reading, only the reading methods are available in the zip object, and similarly, if the file was opened for writing, only the writing methods are available. Deleting files is not supported, but see `z:copy_from_zip()`.

## `z:close([global_comment])`

Close the ZIP file. If the file was opened for writing, a global comment can also be specified.

## `z:add_file(filename | options_t)`

Add a new file to a ZIP archive that was opened for writing, and set it as the current file. After this, you can write the file contents with `z:write()` and finally close it with `z:close_file()` (or `z:close_file_raw()` if opened in raw mode). Options can be specified with `options_t`:

  * `filename` - the path and file name - to add an empty directory, suffix the name with a slash (`/`) character
  * `date` - an optional file date in `os.date'*t'` format
  * `comment` - an optional comment string
  * `password` - an optional password string to encrypt the file with
  * `raw` - raw mode (boolean); in this mode:
    * `method` must also be set to indicate the compression method used (zee zlib spec for details)
    * `z:write()` must be used to write data in compressed form
    * the file must be closed with `z:close_file_raw()` to which you must pass the uncompressed file size and the CRC checksum, or you'll get an invalid ZIP file.
  * `zip64` - (boolean); enable support for files larger than 4G (disabled by default because the default `zip` and `unzip` unix commands doesn't support it)

There are other options which require an understanding of the ZIP file format to be used. See the source code for the full list and the description and default value of each.

## `z:write(s)`

Append a string to the current file contents.

## `z:close_file()`

Close the current file.

## `z:close_file_raw(uncompressed_size, crc)`

Close the current file that was opened in raw mode with `z:add_file()`.

## `z:archive(options_t, data[, size])`

Add a new file to the archive (shortcut for the sequence `z:add_file()`, `z:write()`, `z:close_file()`).

## `z:copy_from_zip(z[, buf_size])`

Copy the current file from a zip object that was opened for reading, into the `self` zip object which it was opened for writing. The file is copied in `raw` mode to avoid decompressing and compressing back the data. This can be used to implement deleting files from a ZIP archive. `buf_size` is the size of the buffer used for transferring the data (defaults to 4096).

## `z:get_global_info()`

Return a table containing global info for a ZIP file that was opened for reading.

## `z:first_file()`

Set the first file in the ZIP catalog as the current file.

## `z:next_file()`

Set the next file in the ZIP catalog as the current file.

## `z:locate_file(filename[, case_insensitive]) -> true | false`

Locate a file in the ZIP catalog by name and if found, set it as the current file. Return true if found, false if not.

## `z:get_file_pos() -> zpos`

Get an object representing the position of the current file in the ZIP catalog that can be later used to set the current file to.

## `z:goto_file_pos(zpos)`

Set the current file to `zpos`.

## `z:get_file_info() -> info_t`

Return a table that contains information about the current file such as filename, uncompressed size and date.

## `z:open_file([password])`

Open the current file for reading, optionally specifying a password if the file is encrypted. After opening, call `z:read_cdata()` to read the file contents, and `z:close_file()` to close the file so you can open another one.

## `z:read_cdata(buf, size) -> size`

Read more bytes from the currently opened file into a buffer. Return the number of bytes actually read.

## `z:read(size) -> s`

Read more bytes from the currently opened file into a string.

## `z:tell() -> n`

Return the current position in uncompressed data.

## `z:eof() -> true | false`

Check for EOF in current file opened for reading.

## `z:get_offset() -> n`

Get the current file offset.

## `z:set_offset(n)`

Set the current file offset.

## `z:files() -> iterator() -> info_t`

List files in archive, returning the file info table for each file. On each iteration, the file is set as the current file so `z:open_file()` can be used to read the file contents.

## `z:extract(filepath) -> s`

Extract a file from the ZIP archive and return its contents as a string. This is a shortcut for the sequence `z:open_file()`, `z:read()`, `z:close_file()`.

[ZIP file format]: http://www.pkware.com/documents/casestudies/APPNOTE.TXT
