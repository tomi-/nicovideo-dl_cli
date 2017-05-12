require 'open-uri'
require 'nokogiri'

exec_dir = `pwd`
exec_dir.rstrip!
nicovideo_dl = exec_dir+'/nicovideo-dl'

mail = nil
pass = nil
save_dir = nil

File.foreach(exec_dir+"/env") do |env|
    env.each_line do |labmen|
      if mail.nil?
        mail = labmen.strip
        next
      end
      if pass.nil?
        pass = labmen.strip
        next
      end
      if save_dir.nil?
        save_dir = labmen.strip
        next
      end
    end
end

lists = `ls #{exec_dir}/schedule`
lists.split("\n").each do |list|
  xml = Nokogiri::XML(open("http://ch.nicovideo.jp/#{list}/video?rss=2.0"))
  dir_name = xml.xpath("//dc:creator").text.gsub(/\s/,"_").gsub(/\//,'_').gsub(/_\[/,'[').gsub(/.*「/,'').gsub(/」.*/,'')

  Dir.mkdir(%{#{save_dir}}) unless Dir.exist?(%{#{save_dir}})
  xml = xml.xpath("//item").first
  next if xml.nil?
  title = xml.xpath("title").text.gsub(/\s/,"_").gsub(/\//,'_').gsub(/_\[/,'[')
  path = xml.xpath("link").text

  next if File.exist?(%{#{save_dir}/#{title}.mp4})
  #puts %{#{nicovideo_dl} #{path} -u #{mail} -p #{pass} -q -o #{save_dir}/#{title}.mp4}
  system(%{#{nicovideo_dl} #{path} -u #{mail} -p #{pass} -q -o #{save_dir}/#{title}.mp4})
end
