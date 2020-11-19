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


#
# settings for eeefff.org website
#

# js
EEEFFF_ORG_JS_DIR = '~/it/websites/eeefff-org/js'

# js files prefix
EEEFFF_JS_FILE_PREFIX = 'op-erosion-machine-'

#
# dirs for FF plugin
#

# base dir
BASE_FF_PLUGIN_DIR = '../erosion-machine-tester'

# js
FF_PLUGIN_JS_DEST_DIR = "#{BASE_FF_PLUGIN_DIR}/content_scripts"

# css
FF_PLUGIN_CSS_DEST_DIR = "#{BASE_FF_PLUGIN_DIR}/content_css"

#
# install production files to specified path
#
def install base_dir, src_file_path, dst_file_name, prefix: ''
  STDERR.puts "installing #{src_file_path} -> #{base_dir}/#{prefix}#{dst_file_name}"

  `cp #{src_file_path} #{base_dir}/#{prefix}#{dst_file_name}`
end

#
# build production ready js files using elm-app tool
#
def elm_app_build
  STDERR.puts "running elm-app build"

  `elm-app build`
end

#
# watch js files
# - install them to FF plugin
# - install them to eeefff.org website
#
group :js do
  guard :shell do
    #
    # runtime
    #
    watch(/build\/static\/js\/runtime~main.+\.js$/) {|m|
      # install to FF plugin
      install FF_PLUGIN_JS_DEST_DIR, m[0], 'runtime-main.js'

      # install to eeefff.org
      install EEEFFF_ORG_JS_DIR, m[0], 'runtime-main.js', prefix: EEEFFF_JS_FILE_PREFIX
    }

    #
    # vendors
    #
    watch(/build\/static\/js\/vendors~main.+\.js$/) {|m|
      # install to FF plugin
      install FF_PLUGIN_JS_DEST_DIR, m[0], 'vendors-main.js'

      # install to eeefff.org
      install EEEFFF_ORG_JS_DIR, m[0], 'vendors-main.js', prefix: EEEFFF_JS_FILE_PREFIX
    }

    #
    # main
    #
    watch(/build\/static\/js\/main.+chunk\.js$/) {|m|
      # install to FF plugin
      install FF_PLUGIN_JS_DEST_DIR, m[0], 'main-chunk.js'

      # install to eeefff.org
      install EEEFFF_ORG_JS_DIR, m[0], 'main-chunk.js', prefix: EEEFFF_JS_FILE_PREFIX
    }

    #
    # elm-app build rules
    #
    watch(/src\/.+\.js$/) { |m| elm_app_build }
    watch(/src\/.+\.elm$/) { |m| elm_app_build }
  end
end

#
# watch eeefff.org erosion machine's css file
# - install it to FF plugin
# - install it for elm local dev env
#
# run group with -w parameter:
# guard -g tester -w ~/it/websites/eeefff-org/_site/css
#
group :css do
  guard :shell do
    # directories ["/Users/eehah5ru/it/websites/eeefff-org/_site/css"]

    watch(/erosion-machine-timeline\.css/) {|m|
      # read css and resolve HOST_NAME placeholder
      css = File.read(m[0]).gsub("HOST_NAME", HOST_NAME)

      f_name = File.basename(m[0])

      # write css for FF plugin
      File.open("#{FF_PLUGIN_CSS_DEST_DIR}/#{f_name}", 'w') do |f|
        f.puts css
      end

      # write css for elm dev env
      File.open("src/#{f_name}", 'w') do |f|
        f.puts css
      end
    }
  end
end
