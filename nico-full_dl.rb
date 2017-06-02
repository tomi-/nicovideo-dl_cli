require 'open-uri'
require 'nokogiri'

current_file_path = File.expand_path($0)
current_file_path = current_file_path.split('/')
current_file_path.pop
exec_dir = current_file_path.join('/')
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

lists = `ls #{exec_dir}/full_dl`
flag = true
lists.split("\n").each do |list|
  page = 1
  link = "http://ch.nicovideo.jp/#{list}/video?rss=2.0&sort=f"
  while flag
    puts link+"&page=#{page}"
    xml = Nokogiri::XML(open(link+"&page=#{page}"))
    dir_name = xml.xpath("//dc:creator").text.gsub(/\s/,"_").gsub(/\//,'_').gsub(/_\[/,'[').gsub(/.*「/,'').gsub(/」.*/,'')

    save = %{#{save_dir}/#{dir_name}}
    Dir.mkdir(%{#{save}}) unless Dir.exist?(%{#{save}})

    xmls = xml.xpath("//item")

    if xmls.nil?
      flag = false
      return
    end

    xmls.each do |xml|
      path = xml.xpath("link").text

      title = xml.xpath("title").text.gsub(/\s/,"_").gsub(/\//,'_').gsub(/_\[/,'[')
      if title.match(/.*#.*/)
        title.match(/.*(#.*)/)[1]
      end

      next if File.exist?(%{#{save}/#{title}.mp4})
      system(%{#{nicovideo_dl} #{path} -u #{mail} -p #{pass} -q -o #{save}/#{title}.mp4})
    end

    if xmls.size == 20
      page += 1
    else
      flag = false
    end
  end
end
