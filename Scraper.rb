require 'HTTParty'
require 'Nokogiri'
require 'Pry'

page = HTTParty.get('http://oquefaltaemcoimbra.pt/')

parse_page = Nokogiri::HTML(page)

filtered = []

#Filter suggestions
parse_page.css('.suggestion-text').map do |a|
    suggesttion = a.text 
    filtered.push(suggesttion)
end

aux = []

filtered.each do |line|
    nl =""
    line.each_char do |char|
       if char != "\n"
            nl+=char
       else
           break 
       end
        
    end
    aux.push(nl)
end

suggestions = aux

Pry.start(binding)  