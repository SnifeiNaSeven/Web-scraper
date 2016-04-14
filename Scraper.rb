require 'HTTParty'
require 'Nokogiri'
require 'Pry'

def clean_str(str,sym_str)
    out= ""
    str.each_char do |char|
        if sym_str.include? char 
            out +=  " "
        else
            out += char
        end
    end
    return out
end

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

#Top 10 words

#full text
aux = ""

suggestions.each do |line|
    aux += line + " " 
end

#Need to remove symbols like ",","!","#"...

symb=",;.:_~^ºª´`+*«»'?}=])[({/&%$§#£@!\"\\<>"

aux = clean_str(aux,symb)


aux = aux.split(" ")
words = Hash.new

aux.each do |word|
    value = words[word]
    if value != nil
        words[word]+=1
    else
        words[word]=1
    end
end

words_freq = words.sort_by {|key,value|value}

words_freq = words_freq.reverse!.to_h

Pry.start(binding) 