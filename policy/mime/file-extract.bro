
module MIME;

export {
	## The default setting for extracting files to disk.
	const default_write_file = F &redef;

	redef record Info += {
		## The name of the file where this MIME entity is written.
		on_disk_filename: string &optional &log;
		
		## Optionally write the file to disk.  Must be set prior to first 
		## data chunk being seen in an event.
		write_file:       bool    &default=default_write_file;
	
		## Store the file handle here for the file currently being extracted.
		file_handle:      file    &optional;
	}
}

event mime_segment_data(c: connection, length: count, data: string) &priority=4
	{
	if ( c$mime$write_file && c$mime$content_len == 0 )
		{
		c$mime$on_disk_filename = fmt("mimefile.%s-%d", id_string(c$id), c$mime$level);
		c$mime$file_handle = open(c$mime$on_disk_filename);
		}
	}
	
event mime_segment_data(c: connection, length: count, data: string) &priority=-5
	{
	if ( c$mime$write_file && c$mime?$file_handle )
		write_file(c$mime$file_handle, data);
	}
	
event mime_end_entity(c: connection) &priority=-5
	{
	if ( c$mime?$file_handle )
		close(c$mime$file_handle);
	}
	