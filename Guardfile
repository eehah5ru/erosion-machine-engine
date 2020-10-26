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

HOST_NAME = "https://dev.eeefff.org"

BASE_FF_PLUGIN_DIR = '../erosion-machine-tester'

JS_DEST_DIR = "#{BASE_FF_PLUGIN_DIR}/content_scripts"

CSS_DEST_DIR = "#{BASE_FF_PLUGIN_DIR}/content_css"

# install production files to ff plugin
def install src_file_path, dst_file_name
  STDERR.puts "installing #{src_file_path} -> #{JS_DEST_DIR}/#{dst_file_name}"

  `cp #{src_file_path} #{JS_DEST_DIR}/#{dst_file_name}`
end

# build production ready js files
def elm_app_build
  STDERR.puts "running elm-app build"

  `elm-app build`
end

group :js do
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

    #
    # elm-app build rules
    #
    watch(/src\/.+\.js$/) { |m| elm_app_build }
    watch(/src\/.+\.elm$/) { |m| elm_app_build }
  end
end

group :tester do
  guard :shell do
    # directories ["/Users/eehah5ru/it/websites/eeefff-org/_site/css"]

    watch(/erosion-machine-timeline\.css/) {|m|
      css = File.read(m[0]).gsub("HOST_NAME", HOST_NAME)

      f_name = File.basename(m[0])

      File.open("#{CSS_DEST_DIR}/#{f_name}", 'w') do |f|
        f.puts css
      end
    }
  end
end
