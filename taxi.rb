# in version 2, need start/end point, maybe day of week to know what taxi rate is applicable
# a well-formed Google Maps API request: http://maps.googleapis.com/maps/api/distancematrix/json?origins=yew+tee+station+singapore&destinations=clarke+quay+station+singapore&mode=driving&sensor=false
require 'open-uri'
require 'rubygems'
require 'json/pure'

def prompt
  print ">>"
end

# converts a regular string with spaces into a string separated by "+"
def string_output(string)
  return string.gsub /\s/, "+"
end

def bus_fare_rate_calculation
  bus_fare_per_km = 0.1
  # http://www.publictransport.sg/publish/etc/medialib/test2.Par.85467.File.dat/Fare%20revision%202011%20Press%20release%20v20-f[1].pdf
end

# obtains the distance between 2 points in km as well as the driving time in minutes
def distance_calculator(start, destination)
  #http://forrst.com/posts/Read_JSON_data_using_Ruby-13V
  url = "http://maps.googleapis.com/maps/api/distancematrix/json?origins=#{start}&destinations=#{destination}&mode=driving&sensor=false"
  
  buffer = open(url).read
  result = JSON.parse(buffer)
  
  duration = result["rows"].first["elements"].first["duration"]["value"]
  distance = result["rows"].first["elements"].first["distance"]["value"]
  return duration.to_f/60, distance.to_f/1000
end

# determines taxi fare per km rate based on distance travelled and if a taxi was booked
def taxi_fare_rate_calculation(distance_travelled, booking_fee)
  
  #basic flag down fee is $2.8
  flag_down_fee = 2.8
  hour = Time.new.hour
  
  # if booking fee exists, how much is it depends on what time of day it is.
  if booking_fee
    case hour
      when 7..9
        flag_down_fee = 3.5 + 2.8
        
      when 17..23
        flag_down_fee = 3.5 + 2.8
    end
  end
  
  case hour
    when 7..9
      taxi_fare_per_km = (1.35 * flag_down_fee.to_f) / distance_travelled.to_f + (1.35 * 0.519480519)
  
    when 10..16
      taxi_fare_per_km = (flag_down_fee.to_f / (distance_travelled.to_f - 1)) + 0.519480519
      
    when 17..19
      taxi_fare_per_km = (1.35 * flag_down_fee.to_f) / distance_travelled.to_f + (1.35 * 0.519480519)
      
    when 20..23
      taxi_fare_per_km = (flag_down_fee.to_f / (distance_travelled.to_f - 1)) + 0.519480519
      
    when 0..5
      taxi_fare_per_km = (1.5 * flag_down_fee.to_f) / distance_travelled.to_f + (1.5 * 0.519480519)
      
    when 6
      taxi_fare_per_km = (flag_down_fee.to_f / (distance_travelled.to_f - 1)) + 0.519480519
  end
  
  return taxi_fare_per_km
end

# calculates the traveling time by both bus and taxi and returns them
def traveling_time(distance)
  
  hour = Time.new.hour
  bus_speed = 0
  taxi_speed = 0
  
  # vehicle speeds depend on time of day
  case hour
    when 5..8
      bus_speed = 0.6 # km/minute 30km/hour
      
    when 9..13
      bus_speed = 0.5
    
    when 14..16
      bus_speed = 0.6
    
    when 17..20
      bus_speed = 0.4
    
    when 21..23
      bus_speed = 0.8
      
    when 0..4
      bus_speed = 0.000001
  end

  case hour
    when 5..8
      taxi_speed = 0.9 # km/minute 30km/hour
      
    when 9..13
      taxi_speed = 0.8
    
    when 14..16
      taxi_speed = 0.9
    
    when 17..20
      taxi_speed = 0.6
    
    when 21..23
      taxi_speed = 0.9
      
    when 0..4
      taxi_speed = 1.0
  end
  
  time_taken_in_bus = distance.to_f / bus_speed.to_f
  time_taken_in_taxi = distance.to_f / taxi_speed.to_f
  return time_taken_in_bus #, time_taken_in_taxi
end


# takes the given arguments and presents a recommendation on whether to take a bus or taxi
def evaluate(time_in_bus, time_in_taxi, salary_per_minute, distance_travelled, taxi_fare_per_km, bus_fare_per_km, misery_tax)

# comparison formula
# obtains Left-Hand Side and Right-Hand Side of inequality and compares them

  # LHS of inequality
  # the value of your time is how much your work pays you if you were working
  value_of_time_lost = (time_in_bus.to_f - time_in_taxi.to_f) * salary_per_minute

  # RHS of inequality
  extra_cost_of_taxi_ride = distance_travelled.to_f * (taxi_fare_per_km - bus_fare_per_km) - misery_tax.to_f
  
  # time taken for both rides as well as the distance travelled
  puts "A taxi ride would take #{time_in_taxi.to_i} minutes while a bus ride would take #{time_in_bus.to_i} minutes."
  puts "The entire journey for both would be #{distance_travelled} km."
  
  # Too late at night. Forget about any comparison. Cab it.
  if (0..4) === Time.new.hour
    puts "It's too late for a bus. This argument is moot. Take a taxi. Good night."
    Process.exit(0)
  end

  if value_of_time_lost < extra_cost_of_taxi_ride
      puts "The taxi ride costs \$#{extra_cost_of_taxi_ride - value_of_time_lost} more than your time is worth."
      puts "Taking a taxi isn't worth it. Suck it up and take public transport like a man."
    end
  
    if value_of_time_lost > extra_cost_of_taxi_ride
      puts "The value of your time is worth \$#{value_of_time_lost - extra_cost_of_taxi_ride} more than a taxi ride."
      puts "Take a taxi. You deserve it."
    end
    Process.exit[0]
end


# Main

# How much is your time worth?
puts "How much is your monthly salary? (plus bonuses)"
prompt; salary_per_month =  gets.chomp

# from version 1 when I still couldn't implement the Google Maps API
# puts "How far away is your destination? (in km)"
# prompt; distance_travelled =  gets.chomp

puts "What is your starting point?"
prompt; input_s = gets.chomp
start_point = string_output(input_s)

puts "What is your destination?"
prompt; input_e = gets.chomp
end_point = string_output(input_e)
duration_of_taxi_journey, distance_travelled = distance_calculator(start_point, end_point)

puts "How many dollars would you pay to avoid public transport on your daily commute. $0-5"
prompt; misery_tax = gets.chomp

puts "Are you going to book a taxi? (Y/N)"
prompt; answer = gets.chomp
if answer == "Y"
  booking = true
end



duration_of_bus_journey = traveling_time(distance_travelled.to_f)
evaluate(duration_of_bus_journey, duration_of_taxi_journey, salary_per_month.to_f/(60 * 8 * 22), distance_travelled, taxi_fare_rate_calculation(distance_travelled, booking), bus_fare_rate_calculation, misery_tax)

