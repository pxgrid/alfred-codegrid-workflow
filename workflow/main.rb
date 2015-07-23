# encoding: utf-8

require 'rubygems' unless defined? Gem # rubygems is only needed in 1.8
require_relative "bundle/bundler/setup"
require "alfred"
require "unicode"
require "uri"
require 'json'
require 'net/http'

Alfred.with_friendly_error do |alfred|
  fb = alfred.feedback

  app_uri = "https://app.codegrid.net/"
  query = ARGV[0].to_s.strip.force_encoding('UTF-8')
  escaped_query = URI.escape(Unicode::nfkc(query))
  api_uri =  URI.parse("#{app_uri}api/search?q="+escaped_query)

  icon = {
    :unlock => {
      :type => "default",
      :name => "icon-unlock.png"
    },
    :lock => {
      :type => "default",
      :name => "icon.png"
    }
  }

  default_item = {
    :uid      => "",
    :title    => "見つかりませんでした",
    :subtitle => "別の検索条件でお探しください",
    :arg      => app_uri,
    :icon     => icon[:lock]
  }

  https = Net::HTTP.new(api_uri.host, api_uri.port)
  https.use_ssl = true
  res = https.start {
    https.get(api_uri.request_uri)
  }

  if res.code == '200'
    result = JSON.parse(res.body)
    if result.length != 0
      result.each do | item |
        fb.add_item({
          :uid      => item["slug"],
          :title    => "#{item['title']}",
          :subtitle => "【#{item['series']['title']}】 #{item['description']}",
          :arg      => "https://app.codegrid.net/entry/#{item['slug']}",
          :icon     => item["expose"] == true ? icon[:unlock] : icon[:lock]
        })
      end
    else
      fb.add_item(default_item)
    end
    puts fb.to_xml()
  else
    fb.add_item(default_item)
    puts fb.to_xml()
  end

end
