# Harvest
is simple image/context downloader.

It searches and downloads files/contexts based on css path and url by command-line parameters.
If parameters include some css path, these are used to find child page link, but the last one 
is used to find download files/contexts.

## Requirements
   * Ruby 2.0 > and Rubygems
   * Nokogiri
   * Other dependent gems will be installed

## Usage
    Usage: harvest [options] <baseurl> <pattern> [pattern] [..]
      baseurl         target url   ex)http://abc.com
      pattern         css path     ex)article a  ex)img.class
                      *url mattched last pattern will be downloaded
                      *url mattched other pattern find the next page
      -f --folder     set download folder name
      -p --prefix     set prefix to the download file name
      -c --config     use config file which wrote settings
      -h --help       show help



