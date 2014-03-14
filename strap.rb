# -*- coding: utf-8 -*-
require 'mechanize'
require 'open-uri'
require 'digest'

def md5(text)
  return Digest::MD5.hexdigest(text.encode('utf-8')).upcase
end

def downPic(url, folder, suf)
  data=open(url) { |f| f.read }
  tail=/\w+$/.match(url)[0]
  body=md5(url)
  fn=suf+body+'.'+tail
  open(folder+fn,"wb") { |f| f.write(data) }
  fn
end

class String
  def improve
    self.encode!('utf-8')
    self.gsub!(/<.?div.*?>/,'')
		puts 'here~'
    self.gsub!(/^第.+章/) { |s| "# "+s }  
  end
end

#puts downPic("http://www.lightnovel.cn/data/attachment/forum/201108/06/155416403099nl3ge9a9g9.jpg","tmp/")

def init
  @agent = Mechanize.new
  @agent.auth("straprb","123456123456")
end

def strap(url, filename)
  page = @agent.get(url+'?see_lz=1')
  folder = md5(url)+'/'
  Dir.mkdir(folder) unless File.exist?(folder)
  Dir.mkdir(folder+"images/") unless File.exist?(folder+"images/")

  buff=''
  File.open(folder+filename+".md", "w") do |file|
    loop do
		#puts 'here!'
      doc = Nokogiri::HTML(page.body)
      buff+=doc.xpath("//div[@class='d_post_content j_d_post_content ']").to_s
      break if page.links_with(:text => '下一页').length==0
      page=@agent.click page.links_with(:text => '下一页')[0]
    end
	buff.encode!('utf-8')
#puts buff
    ctr = 0
    buff.scan(/<img.*?>/).each do |imgl|
#puts 'here!'
      imgl =~ /src="(.+?)"/
      url = $1
      puts "Downloading picture " + url
      link = downPic(folder, url, "images/")
      buff[imgl] = '![Illustration #' + ctr.to_s + '](../' + link + ')'
      ++ctr
    end
=begin
    last=-1
    loop do
      imgl=/<img.*?>/.match(buff[last+1..-1])
      img=/src=".+?"/.match(imgl.to_s)
      t=(buff[last+1..-1]=~/<img.*?>/)
      break if !t
      last+=t+1
      url=img[0].to_s[5..-2]
      puts url
      newLink=downPic(url,folder,"images/")
      buff[imgl.to_s]="[Illustration](../"+newlink+")"
    end
=end
    buff.improve

    file.puts buff
  end

  return folder
end

url='http://tieba.baidu.com/p/927104385'
title="恋爱随意链接【第一卷】"
author="庵田定夏"

init
strap(url, title)
