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

def fix_str(str)
    #Remove symbols
    symb=",;.:_~^ºª´`+*«»'?}=])[({/&%$§#£@!\\<>"

    aux = clean_str(str,symb)

    #downcase
    str= str.downcase

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

    str.each_char do |char|
        if simplify.has_key?(char)
            char = simplify[char]
        end    
        aux+=char
    end

    str= aux
    return str
end

page = HTTParty.get('http://oquefaltaemcoimbra.pt/')

sugg = Nokogiri::HTML(page)

filtered_sugg = []

#Filter suggestions
sugg.css('.suggestion-text').map do |a|
    suggesttion = a.text 
    filtered_sugg.push(suggesttion)
end

#filter votes
filtered_votes=[]

sugg.css('.suggestion-votes').map do |a|
    vote = a.text 
    filtered_votes.push(vote)
end

#votes array
aux_1=[]
num="1234567890"

filtered_votes.each do |line|
    nl =""
    line.each_char do |char|
        if num.include? char
            nl+=char
       end
    end
    aux_1.push(nl.to_i)
end


filtered_votes = aux_1
#suggestions array

suggestions=filtered_sugg
aux=[]

suggestions.each do |line|
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

suggestions=aux

sugg_votes = Hash[suggestions.zip(filtered_votes)] 

#Top 10 words

#full text
aux = ""

suggestions.each do |line|
    aux += line + " " 
end

text=fix_str(aux)

#remove all spaces
words = text.split(" ")

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
sugg_votes = sugg_votes.sort_by {|key,value|value}.to_h

#words_votes



#words_freq = words_freq.reverse!.to_h
sugg_votes.each do |key,value|
    puts "#{key}: #{value}" 
end

Pry.start(binding)