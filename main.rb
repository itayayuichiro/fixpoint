require 'apachelogregex'
require 'optparse'
require 'date'
require 'objspace'

lines = []
format = '%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"'
@logParser = ApacheLogRegex.new(format)
y,m,d=""

@month_master = {
	:Jan => 1,
	:Feb => 2,
	:Mar => 3,
	:Apr => 4,
	:May => 5,
	:Jun => 6,
	:Jul => 7,
	:Aug => 8,
	:Sep => 9,
	:Oct => 10,
	:Nov => 11,
	:Dec => 12
}


def host_analyze(lines)
	puts "###ホストごとの解析###"
	host_hash={}
	lines.each do |line|
		begin
			result = @logParser.parse(line)
			#ホスト別解析
			host = 	result['%h']
			if host_hash.has_key?(host.to_sym)
				host_hash[host.to_sym]=host_hash[host.to_sym] + 1
			else
				host_hash[host.to_sym]=1				
			end
		rescue Exception => e
			puts e
		end
	end
	sort_hash = host_hash.sort{|(k1,v1),(k2,v2)| v2<=>v1}
	sort_hash.each{|hash|
		puts "ホスト名#{hash[0]}:件数#{hash[1]}"
	}
end

def hour_analyze(lines)
	puts "###時間ごとの解析###"
	count = 0
	h = ""
	pre_h = ""
	y,m,d=""
	time_hash = {}
	lines.each do |line|
		begin
			result = @logParser.parse(line)
			#ホスト別解析
			h = result['%t'].split('/')[2].split(':')[1]
			y = result['%t'].split('/')[2].split(':')[0]
			m = result['%t'].split('/')[1]
			d = result['%t'].split('/')[0].gsub("[","")
			y_m_d_h = "#{y}年#{@month_master[m.to_sym]}月#{d}日#{h}時"
			if time_hash.has_key?(y_m_d_h.to_sym)
				time_hash[y_m_d_h.to_sym]=time_hash[y_m_d_h.to_sym] + 1
			else
				time_hash[y_m_d_h.to_sym]=1				
			end
			#時間ごとの解析
		rescue Exception => e
			puts e
		end
	end
	time_hash.each{|k,v|
		puts "#{k}:件数#{v}"
	}
end

opt = OptionParser.new
date_range,start_date,end_date=""
opt.on('-d', '--date ITEM', 'date an item') { |v| date_range=v }
opt.parse(ARGV)
unless date_range==""
	start_date=Date.new(date_range.split(",")[0].split('/')[0].to_i,date_range.split(",")[0].split('/')[1].to_i,date_range.split(",")[0].split('/')[2].to_i)
	end_date=Date.new(date_range.split(",")[1].split('/')[0].to_i,date_range.split(",")[1].split('/')[1].to_i,date_range.split(",")[1].split('/')[2].to_i)
end
ARGV.each do |arg|
	if arg=="-d"
		break
	end
	f = open(arg)
	f.each{|line|
		line_cp = line.clone
		result = @logParser.parse(line)
		y = result['%t'].split('/')[2].split(':')[0]
		m = result['%t'].split('/')[1]
		d = result['%t'].split('/')[0].gsub("[","")
		date = Date.new(y.to_i, @month_master[m.to_sym], d.to_i)
		unless start_date.nil?
			if start_date <= date && end_date >= date || start_date==""
				lines.push(line_cp.chomp!)		
			end
		else
			lines.push(line_cp.chomp!)
		end
	}
end
hour_analyze(lines)
host_analyze(lines)

