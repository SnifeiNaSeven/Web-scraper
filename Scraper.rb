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

#Remove symbols
symb=",;.:_~^ºª´`+*«»'?}=])[({/&%$§#£@!\"\\<>"

aux = clean_str(aux,symb)

#downcase
text= aux.downcase

simplify={
    "ç"=>"c",
    "é"=>"e",
    "è"=>"e",
    "ê"=>"e",
    "ã"=>"a",
    "â"=>"a",
    "á"=>"a",
    "à"=>"a",
    "î"=>"i",
    "í"=>"i",
    "ì"=>"e",
    "õ"=>"o",
    "ô"=>"o",
    "ó"=>"o",
    "ò"=>"o",
    "û"=>"u",
    "ú"=>"u",
    "ù"=>"u",
    }

aux=""

text.each_char do |char|
    if simplify.has_key?(char)
        char = simplify[char]
    end    
    aux+=char
end

text= aux

    
#remove all spaces
text = text.split(" ")

    words = text

#Create Hash with all the words without prepositions
words_freq = Hash.new

prepositions = ["de","e","a","o","da","para","que","na","em","com","do","mais","um","uma","ao","os","no","ou","as","dos","nas","como","das","se","por","aos","sem","nos","ser","falta","ter","entre","lado","menos","nao","so","ate"]

words.each do |word|
    value = words_freq[word]
    if (prepositions.include? word) != true && value != nil
        words_freq[word]+=1
    #exclude prepositions
        else if value == nil
        words_freq[word]=1 
        end
    end
end

words_freq = words_freq.sort_by {|key,value|value}.to_h

#words_freq = words_freq.reverse!.to_h

words_freq.each do |key,value|
    puts "#{key}: #{value}" 
end
#Pry.start(binding)