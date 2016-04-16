require 'HTTParty'
require 'Nokogiri'
require 'Pry'

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

symb=",;.:_~^ºª´`+*«»'?}=])[({/&%$§#£@!\"\\<>"

prepositions = ["de","e","a","o","da","para","que","na","em","com","do","mais","um","uma","ao","os","no","ou","as","dos","nas","como","das","se","por","aos","sem","nos","ser","falta","ter","entre","lado","menos","nao","so","ate","i","ha","ca","s","c","b","ai","-","ir","ar","esta","pois","depois","2","la","ja","tudo","tu","num","4","pro","ver","ve","etc","apenas","sa","fica","outros","sobretudo","and","tirar","mas","va","nada","ente"]

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

sugg = Nokogiri::HTML(page)

filtered_sugg = []

#Filter suggestions
sugg.css('.suggestion-text').map do |a|
    suggesttion = a.text 
    filtered_sugg.push(suggesttion)
end

################
#########################################
#filter votes
filtered_votes=[]

sugg.css('.suggestion-votes').map do |a|
    vote = a.text 
    filtered_votes.push(vote)
end

#votes array
aux=[]
num="1234567890"

filtered_votes.each do |line|
    nl =""
    line.each_char do |char|
        if num.include? char
            nl+=char
       end
    end
    aux.push(nl.to_i)
end


filtered_votes = aux
#########################################
###################
    
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

#####################
##########################################
suggestions_2=aux

aux=[]

suggestions_2.each do |line|
    nl=line

    #Remove symbols

    nl = clean_str(nl,symb)

    #downcase
    nl= nl.downcase

    aux_1=""

    nl.each_char do |char|
        a=char
        if simplify.has_key?(char)
            a = simplify[char]
        end
        aux_1+=a
    end

    nl=aux_1
    
    aux.push(nl) 
end

suggestions_2=aux

sugg_votes = Hash[suggestions_2.zip(filtered_votes)] 
########################################################
################

#Top 10 words

#full text
aux = ""

suggestions.each do |line|
    aux += line + " " 
end

#Remove symbols

aux = clean_str(aux,symb)

#downcase
suggestions= aux.downcase

aux=""

suggestions.each_char do |char|
    a=char
    if simplify.has_key?(char)
        a = simplify[char]
    end  
    aux+=a
end

text=aux

#remove all spaces
words = text.split(" ")

aux=[]

words.each do |word|
    if (prepositions.include? word) != true
        aux.push(word) 
    end
end

words=aux

#Create Hash with all the words without prepositions
words_freq = Hash.new

words.each do |word|
    value = words_freq[word]
    if value != nil
        words_freq[word]+=1
    #exclude prepositions
        else if value == nil
        words_freq[word]=1 
        end
    end
end

######################################
#######################################################################
#reset values of words_votes
aux=Hash.new
words.each do |key|
    aux[key]=nil 
end

words_votes=aux

words.each do |word|
    sugg_votes.each do |key,value|
        if key.include? word
            if words_votes[word]==nil
                words_votes[word]=value
            else 
                words_votes[word]+=value
            end
        end
    end
end

words_freq = words_freq.sort_by {|key,value|value}.reverse.to_h
sugg_votes = sugg_votes.sort_by {|key,value|value}.reverse.to_h
words_votes = words_votes.sort_by {|key,value|value}.reverse.to_h

Pry.start(binding)