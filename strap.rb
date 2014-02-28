require 'mechanize'

url='http://tieba.baidu.com/p/1486818761'

agent = Mechanize.new
agent.auth("straprb","123456123456")
page = agent.get(url+'?see_lz=1')
File.open("t.html", "w") do |file|
	loop do
		doc = Nokogiri::HTML(page.body)
		file.puts doc.xpath("//div[@class='d_post_content j_d_post_content ']")
		break if page.links_with(:text => '下一页').length==0
		page=agent.click page.links_with(:text => '下一页')[0]
	end
end