#!/usr/bin/env ruby
require 'rubygems'
require 'curb'
require 'grit'
{:master=>"http://connect.facebook.net/en_US/all.js", :latest=>'http://beta.facebook.com/assets.php/en_US/all.js'}.each_pair do |branch, source|
  `git checkout #{branch}`
  `git pull origin #{branch}`
  
  repo = Grit::Repo.new(".")
  
  
  request = Curl::Easy.http_get(source)
  
  data = request.body_str
  
  revision = data.to_a[0].match(/v([0-9])+/)
  puts revision
  
  c = Curl::Easy.new("http://closure-compiler.appspot.com/compile?output_format=text")
  postfields = []
  postfields << Curl::PostField.content('js_code', data)
  postfields << Curl::PostField.content('compilation_level', "WHITESPACE_ONLY")
  postfields << Curl::PostField.content('output_info','compiled_code')
  postfields << Curl::PostField.content('output_format','text')
  postfields << Curl::PostField.content('formatting','pretty_print')
  c.http_post(*postfields)
  str = c.body_str
  File.open('all.js', 'w') {|f| f.write(str.gsub("  ","\t")) }
  
  
  repo.add('all.js')
  repo.commit_index('Revision '+revision.to_s)
  `git push`
end