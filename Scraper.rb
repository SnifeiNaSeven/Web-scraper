require 'HTTParty'
require 'Nokogiri'
require 'JSON'
require 'Pry'
require 'csv'

page = HTTParty.get('http://oquefaltaemcoimbra.pt/')

Pry.start(binding)

