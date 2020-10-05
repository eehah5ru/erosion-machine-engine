# A sample Guardfile
# More info at https://github.com/guard/guard#readme

## Uncomment and set this to only include directories you want to watch
# directories %w(engine/build)
#  .select{|d| Dir.exist?(d) ? d : UI.warning("Directory #{d} does not exist")}

## Note: if you are using the `directories` clause above and you are not
## watching the project directory ('.'), then you will want to move
## the Guardfile to a watched dir and symlink it back, e.g.
#
#  $ mkdir config
#  $ mv Guardfile config/
#  $ ln -s config/Guardfile .
#
# and, you'll have to watch "config/Guardfile" instead of "Guardfile"

# Add files and commands to this file, like the example:
#   watch(%r{file/path}) { `command(s)` }
#

DEST_DIR = '../erosion-machine-tester/content_scripts/'

def install src_file_path, dst_file_name
  `cp #{src_file_path} #{DEST_DIR}/#{dst_file_name}`
end

guard :shell do
  #
  # runtime
  #
  watch(/build\/static\/js\/runtime~main.+\.js$/) {|m|  install m[0], 'runtime-main.js'}

  #
  # vendors
  #
  watch(/build\/static\/js\/vendors~main.+\.js$/) {|m|  install m[0], 'vendors-main.js'}

  #
  # main
  #
  watch(/build\/static\/js\/main.+chunk\.js$/) {|m|  install m[0], 'main-chunk.js'}

end
