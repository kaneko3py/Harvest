# coding: utf-8

# Harvest
# is auto image/script/content downloder, auto find these and download
# 2015-03-19 ko.kaneko
require "uri"
require "fileutils"
require "time"
require "open-uri"
require "nokogiri"

class Harvest
    DOWNLOAD_FOLDER = 'downloads'
    MAX_RETRY = 5

    def self.execute(argv)
        if argv.length < 2
            puts <<-EOS
Usage: harvest baseurl pattern [pattern] [pattern] [..]
  -baseurl        target url   ex)http://abc.com
  -pattern        css pattern  ex)article a  ex)img.class
                  *url mattched last pattern will be downloaded
                  *url mattched other pattern find the next page
EOS
            return
        end
        @baseurl ,*@patterns = argv

        puts "open: \"#{@baseurl}\""
        search @baseurl
        puts "folder: \"#{@downloadfolder||"none"}\" "
        puts "end"
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
        folder = @baseurl.scan(/\/([^\/]*)\/[^\/]*$/)[0][0]
        folder = @baseurl.scan(/\/([^\/]*)$/)[0][0] if folder.empty?
        @downloadfolder = File.dirname(__FILE__) + "/#{DOWNLOAD_FOLDER}/#{folder}"
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
                puts "dive: \"#{el_url}\" "
                search(el_url, tier + 1)
            else
                # Download
                unless el_url.empty?
                    puts "download: \"#{el_url}\" "
                    path = File.join getDownloadFolder, File.basename(el_url)
                    data = open(el_url).read
                else
                    data = element.text
                    path = File.join getDownloadFolder, "content_" + Time.now.strftime("%Y%m%d%H%M%S.%3N")
                    puts "download: \"content -> #{data[0,20]}\" "
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

