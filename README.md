# Harvest
Harvest is simple downloader for web contents like image, article and file.

It searches and downloads contents based on css path and url by command-line parameters.
If parameters include some css path, these are used to find child page link, but the last one
is used to find download contents.

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
    -l --list       use list file which wrote target urls
    -i --info       show process of searching files
    -h --help       show help



