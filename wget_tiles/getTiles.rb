#!/bin/ruby

URL_BASE="http://c.tile.openstreetmap.org" #/13/6857/3348.png


class Tile
	attr_accessor :l, :x, :y
  
  def output
    puts "#{l}, #{x}, #{y}"
  end

	def url
		URL_BASE + "/#{self.l}/#{self.x}/#{self.y}.png"
	end

	def set_by_path str
		strs = (str.split(".")[1]).split("/")
    self.l = strs[1].to_i
    self.x = strs[2].to_i
    self.y = strs[3].to_i
	end

	def get_path
    "./#{self.l}/#{self.x}/#{self.y}.png"
	end

  def get_dir
    "./#{self.l}/#{self.x}"
  end

  def wget_cmd
    "mkdir -p #{self.get_dir} && wget -O #{self.get_path} #{self.url}"
  end
end




puts "Getting Tile names"
$pre_file_list=`cd ../generated_tiles ; find -name "*.png"`
if $pre_file_list.size > 1000
  f=File.open("filelist.txt", "w")
  f.write($pre_file_list)
  f.close
end

$files_list=File.read("filelist.txt")

$files=$files_list.split("\n")

$tiles=$files.map{|f| t=Tile.new; t.set_by_path f; t}


$tiles.each{|t| 
  if t.l<=8
    puts t.wget_cmd 
    `#{t.wget_cmd}`
  end
}



