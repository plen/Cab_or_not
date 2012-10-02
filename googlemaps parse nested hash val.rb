require 'open-uri'
require 'rubygems'
require 'json'

class Hash
  # http://qugstart.com/blog/uncategorized/ruby-multi-level-nested-hash-value/
  # Fetch a nested hash value
  def hash_val(*attrs)
    attr_count = attrs.size
    current_val = self
    for i in 0..(attr_count-1)
      attr_name = attrs[i]
      return current_val[attr_name] if i == (attr_count-1)
      return nil if current_val[attr_name].nil?
      current_val = current_val[attr_name]
    end
    return nil
  end
end

def distance_calculator(start, destination)
  #http://forrst.com/posts/Read_JSON_data_using_Ruby-13V
  url = "http://maps.googleapis.com/maps/api/distancematrix/json?origins=#{start}&destinations=#{destination}&mode=driving&sensor=false"
  
  # i want to obtain the values of "distance"->"value" and "duration"->"value"
  # i seem to get "rows" as an array of 1 string element. that's difficult to parse.
  # has something messed up the structure of the array/json?t 
  
  buffer = open(url).read
  result = JSON.parse(buffer)
  # puts result.inspect
  

  result['rows'].first.each do |value|

    puts value[1].first['duration']['value']
    puts value[1].first['distance']['value']
  end

  # elements_array = result.hash_val('rows')
  # 
  # puts elements_array[0][0]
  # 
  # puts buffer[0]
  # puts result[0]
  # 
  # Process.exit[0]
end

puts "Where are you now? (separate words by +)"
start = "kallang+singapore"

puts "Where are you going? (separate words by +)"
destination = "orchard+singapore"

distance_calculator(start, destination)

# Google's json response
# {
#    "destination_addresses" : [ "Orchard, Singapore" ],
#    "origin_addresses" : [ "Kallang, Singapore" ],
#    "rows" : [
#       {
#          "elements" : [
#             {
#                "distance" : {
#                   "text" : "6.3 km",
#                   "value" : 6338
#                },
#                "duration" : {
#                   "text" : "12 mins",
#                   "value" : 711
#                },
#                "status" : "OK"
#             }
#          ]
#       }
#    ],
#    "status" : "OK"
# }