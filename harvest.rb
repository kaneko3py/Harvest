#!/usr/bin/env ruby
# coding: utf-8

# Harvest
# is auto image/script/content downloder, auto find these and download
# 2015-03-19 ko.kaneko
require "optparse"
require "uri"
require "fileutils"
require "time"
require "open-uri"
require "nokogiri"

class Harvest
    DOWNLOAD_FOLDER = 'downloads'
    MAX_RETRY = 5

    def self.execute(argv)
        begin
            @options = argv.getopts("f:p:c:h","folder:","prefix:","config:","help")
            @options["folder"] ||= @options["f"]
            @options["prefix"] ||= @options["p"]
            @options["config"] ||= @options["c"]
            @options["help"] ||= @options["h"]
        rescue
            return showHelp
        end
        @baseurl ,*@patterns = argv

        # if config option is set
        if (@options["config"])
            argv.clear
            argv << "--folder" << @options["folder"] if @options["folder"]
            argv << "--prefix" << @options["prefix"] if @options["prefix"]
            argv << @baseurl
            begin
                file = File.open(File.dirname(__FILE__) + "/#{@options["config"]}","r")
                file.read.split(/\n/).reject(&:empty?).each {|conf|
                    argv << conf
                }
            rescue
                puts '* failed to read a conf file'
                return
            end
            # re-execute using new argv from config file
            execute argv
            return
        end
        # if help option is set or argv is less
        if (@options["help"] || argv.length < 2)
            return showHelp
        end

        # start search and download process
        puts "open: \"#{@baseurl}\""
        search @baseurl
        puts "folder: \"#{@downloadfolder||"none"}\" "
        puts "end"
    end

    def self.showHelp()
        puts DATA.read
        return
    end

    def self.getFullUrl(url, pairent_url)
        return ""  if url.nil?
    	return url if url =~ /^http/
    	if url =~ /^\//
        	return pairent_url.slice(/^https?:\/\/[^\/]*/) + url
    	else
    		return pairent_url.slice(/^https?:\/\/.*\//) + url
    	end
    end

    def self.getDownloadFolder
        return @downloadfolder unless @downloadfolder.nil?

        # Make folder
        if (@options["folder"])
            @downloadfolder = File.dirname(__FILE__) + "/#{DOWNLOAD_FOLDER}/#{@options['folder']}"
        else
            folder = @baseurl.scan(/\/([^\/]*)\/[^\/]*$/)[0][0]
            folder = @baseurl.scan(/\/([^\/]*)$/)[0][0] if folder.empty?
            @downloadfolder = File.dirname(__FILE__) + "/#{DOWNLOAD_FOLDER}/#{folder}"
        end
        FileUtils.mkdir_p @downloadfolder

        return @downloadfolder
    end

    def self.search(url, tier=0)
        # Open page and search pattern
        begin
        	html =Nokogiri::HTML(open(url))
        rescue
            retry_cnt ||= 0
            if retry_cnt < MAX_RETRY
                retry_cnt += 1
                retry
            end
            return puts "* not valid url"
        end
        elements = html.css(@patterns[tier])
        return puts "* no elements matched pattern" if elements.empty?

        elements.each do |element|
            el_url = getFullUrl(element["href"] || element["src"], url)
            if tier < @patterns.length - 1
                # Search
                puts "#{">" * (tier+1)}dive: \"#{el_url}\" "
                search(el_url, tier + 1)
            else
                # Download
                @dl_cnt = (@dl_cnt || 0) +1
                unless el_url.empty?
                    puts "download: \"#{el_url}\" "
                    path = File.join getDownloadFolder, if (@options["prefix"])
                                                            @options["prefix"] + format("%04d", @dl_cnt) + File.extname(el_url)
                                                        else
                                                            File.basename(el_url)
                                                        end
                    begin
                        data = open(el_url).read
                    rescue
                        puts "* download failed"
                    end
                else
                    data = element.text
                    path = File.join getDownloadFolder, (@options["prefix"] || "content_") + format("%04d", @dl_cnt)
                    puts "download: \"content -> #{data[0,40].gsub(/\n/,' ')}\" "
                end
                open(path, "w") do |f|
                    f.write(data)
                end
            end
        end
    end
end

# main
Harvest::execute ARGV

__END__
Usage: harvest [options] <baseurl> <pattern> [pattern] [..]
  baseurl         target url   ex)http://abc.com
  pattern         css pattern  ex)article a  ex)img.class
                  *url mattched last pattern will be downloaded
                  *url mattched other pattern find the next page
  -f --folder     set download folder name
  -p --prefix     set prefix to the download file name
  -c --config     use config file which wrote settings
  -h --help       show help
