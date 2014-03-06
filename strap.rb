require 'mechanize'
require 'open-uri'
require 'digest'

def downPic(url, suf)
	data=open(url) { |f| f.read }
	tail=/\w+$/.match(url)[0]
	body=Digest::MD5.hexdigest(url.encode('utf-8')).upcase
	fn=suf+body+'.'+tail
	open("tmp/"+fn,"wb") { |f| f.write(data) }
	fn
end

#puts downPic("http://www.lightnovel.cn/data/attachment/forum/201108/06/155416403099nl3ge9a9g9.jpg","tmp/")

url='http://tieba.baidu.com/p/1486818761'
filename="我的青春恋爱喜剧果然坑爹了[第一卷]"

agent = Mechanize.new
agent.auth("straprb","123456123456")
page = agent.get(url+'?see_lz=1')
buff=''
File.open("tmp/"+filename+".html", "w") do |file|
	loop do
		doc = Nokogiri::HTML(page.body)
		buff+=doc.xpath("//div[@class='d_post_content j_d_post_content ']").to_s
		break if page.links_with(:text => '下一页').length==0
		page=agent.click page.links_with(:text => '下一页')[0]
	end
	last=-1
	loop do
		imgl=/<img.*?>/.match(buff[last+1..-1])
		img=/src=".+?"/.match(imgl.to_s)
		t=(buff[last+1..-1]=~/<img.*?>/)
		break if !t
		last+=t+1
		url=img[0].to_s[5..-2]
		puts url
		newLink=downPic(url,"images/")
		buff[imgl.to_s]="<img src=\""+newLink+"\">"
	end
	file.puts buff
end
