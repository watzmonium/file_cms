root = File.expand_path("../", __FILE__)
files = Dir.glob(root + "/public/data/*").map { |path| File.basename(path)}

text = File.read("#{root}/public/data/changes.txt")

p text