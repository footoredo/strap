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
  def improve!(title, author)
    self.encode!('utf-8')
    self.gsub!(/<.?div.*?>/,'')
    #self.gsub!(/^第.+章/) { |s| "# "+s }  
    #self.replace("%"+title+"\n%"+author+"\n\n"+self)
  end
end

#puts downPic("http://www.lightnovel.cn/data/attachment/forum/201108/06/155416403099nl3ge9a9g9.jpg","tmp/")

def init
  @agent = Mechanize.new
  @agent.auth("straprb","123456123456")
end

def strap(url, filename, author='Anonymous')
  page = @agent.get(url+'?see_lz=1')
  folder = md5(url)+'/'
  Dir.mkdir(folder) unless File.exist?(folder)
  Dir.mkdir(folder+"images/") unless File.exist?(folder+"images/")

  buff=''
  File.open(folder+filename+".html", "w") do |file|
    loop do
		#puts 'here!'
      doc = Nokogiri::HTML(page.body)
#File.open("t.html","w") { |t| t.puts doc }
      doc = Nokogiri::HTML(doc.to_s.gsub('<!--','').gsub('-->',''))
      now = doc.xpath('//div[@class="d_post_content j_d_post_content "]').to_html.to_s
      buff += now
      break if page.links_with(:text => '下一页').length==0
      page=@agent.click page.links_with(:text => '下一页')[0]
    end
#puts buff
    buff.encode!('utf-8')
    buff.scan(/<img.*?>/).each do |imgl|
#puts 'here!'
      imgl =~ /src="(.+?)"/
      url = $1
      puts "Downloading picture " + url
      link = downPic(url, folder, "images/")
      buff[imgl] = '<img src="' + link + '">'
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
    buff.improve!(filename, author)

    file.puts buff
  end

  return folder
end

url='http://tieba.baidu.com/p/1338331600'
title="【第一卷】魔法科高校の劣等生 01 入学编 上"
author="佐岛勤"

init
strap(url, title, author)
