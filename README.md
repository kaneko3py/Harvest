# Harvest
is simple image/context downloader.

It search and download files/contexts based on css path and url by parameters.
If parameters include plural css path, it is used to find child link page except one of last.

## Requirements
   * Ruby 2.0 > and Rubygems
   * Nokogiri
   * Other dependent gems will be installed

## Usage
    Usage: harvest [options] <baseurl> <pattern> [pattern] [..]
      baseurl         target url   ex)http://abc.com
      pattern         css pattern  ex)article a  ex)img.class
                      *url mattched last pattern will be downloaded
                      *url mattched other pattern find the next page
      -f --folder     set download folder name
      -p --prefix     set prefix to the download file name
      -c --config     use config file which wrote settings
      -h --help       show help



