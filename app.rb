require 'json'
require "sinatra"
require 'active_support/all'
require "active_support/core_ext"
require 'sinatra/activerecord'
require 'rake'

require 'twilio-ruby'


get "/" do
  "My Awesome Application".to_s
  #401
end

# ----------------------------------------------------------------------
#     ERRORS
# ----------------------------------------------------------------------

error 401 do 
  "Not allowed!!!"
end

# ----------------------------------------------------------------------
#   METHODS
#   Add any custom methods below
# ----------------------------------------------------------------------

private

# for example 
def square_of int
  int * int
end



# Load environment variables using Dotenv. If a .env file exists, it will
# set environment variables from that file (useful for dev environments)
configure :development do
  require 'dotenv'
  Dotenv.load
end


# enable sessions for this project

enable :sessions

# First you'll need to visit Twillio and create an account 
# you'll need to know 
# 1) your phone number 
# 2) your Account SID (on the console home page)
# 3) your Account Auth Token (on the console home page)
# then add these to the .env file 
# and use 
#   heroku config:set TWILIO_ACCOUNT_SID=XXXXX 
# for each environment variable

# CREATE A CLient
client = Twilio::REST::Client.new "AC3157cd21b96c6f0acb6d118749e10991", "61fe77acb422e0661439b16068ec5522"


# Use this method to check if your ENV file is set up

get "/from" do
  #401
  ENV["TWILIO_NUMBER"]
  #"+14126936852"
end

# Test sending an SMS
# change the to to your number 


get '/send_sms/' do 

  client.account.messages.create(
    :from => ENV["TWILIO_NUMBER"],
    :to => "+14128166195",
    :body => "How's it going? Testing."
  )

  "Sent message".to_s
  
end

# Hook this up to your Webhook for SMS/MMS through the console
=begin
get '/incoming_sms' do

  session["counter"] ||= 0
  count = session["counter"]
  
  sender = params[:From] || ""
  body = params[:Body] || ""
  query = body.downcase.strip

  if session["counter"] < 1
    message = "Thanks for your first message. From #{sender} saying #{body}"
  else
    message = "Thanks for message number #{ count }. From #{sender} saying #{body}"
  end
  
  session["counter"] += 1
  
  twiml = Twilio::TwiML::Response.new do |r|
    r.Message message
  end
  twiml.text

end

=end

get '/incoming_sms' do
  
  session["last_context"] ||= nil
  
  sender = params[:From] || ""
  body = params[:Body] || ""
  body = body.downcase.strip
  
  if body == "hi" or body == "hello" or body == "hey"
    message = get_about_message
  elsif body == "play"
    session["last_context"] = "play"
    session["guess_it"] = rand(1...5)
    message = "Guess what number Tina's favorite number is. It's between 1 and 5"
  elsif session["last_context"] == "play"
    
    # if it's not a number 
    if not body.to_i.to_s == body
      message = "Don't you know what number is? n\ You got one more chance!"
    elsif body.to_i == session["guess_it"]
      message = "Bingo! It is #{session["guess_it"]}"
      session["last_context"] = "correct_answer"
      session["guess_it"] = -1
    else
      message = "Wrong! Try again"
	end
        
  elsif body == "work"
    message = "Tina worked at : 1.Google Partner  2. Nielsen.  3.UBS  Type 1, 2, or 3 to learn more"
	#session["last_context"] = "work" 
	#if session ["last_context"] == "work" && body.to_i == "1"
	#message = "Taipei from 2013 to 2015"
	#else
	#message = "Type again"
	#end
  #elsif session ["last_context"] == "work" && body.to_i == "1"
		#message = "Taipei from 2013 to 2015"
	
	#WorkExperience[body.to_i, -1]
	
	
  elsif body == "what"
    message = "Try ask me work study fun or contact."
  elsif body == "fun"
    message = "Singing, dancing, playing guitar."
  elsif body == "study"
    message = "Integrated Innovation for Products & Services at Carnegie Mellon. Learning Ruby for online prototyping now"
  elsif body == "contact"
   client.account.messages.create(
    :from => ENV["TWILIO_NUMBER"],
    :to => "+14128166195",
   :body => "Hey, you get a new friend! Text back at #{from_number}."
  )

  "Sent message".to_s
  
    #message = "Try ask me work study fun or contact."
  #elsif body == "when"    
    #message = Time.now.strftime( "It's %A %B %e, %Y")
  #elsif body == "where"    
    #message = "I'm in Pittsburgh right now."
  #elsif body == "why"    
    #message = "For educational purposes."
  else 
    message = error_response
    session["last_context"] = "error"
  end
  
  twiml = Twilio::TwiML::Response.new do |r|
    r.Message message
  end
  twiml.text
end

#private 


GREETINGS = ["What's up","Yo", "Hey","Howdy", "Nice meeting you", "Aloha", "Hola", "Bonjour", "Ciao"]

COMMANDS = "hi, work, what, study, fun, play and contact."

def get_commands
  error_prompt = ["Wanna know more about Tina? ", "You can say: ", "Try asking: "].sample
  
  return error_prompt + COMMANDS
end

def get_greeting
  return GREETINGS.sample
end

def get_about_message
  get_greeting + ", I\'m TinaBot 🤖. " +  get_commands
end

def get_help_message
  "You're stuck, eh? " + get_commands
end

def error_response
  error_prompt = ["I didn't catch that.", "Hmmm I don't know that word.", "What did you say to me? "].sample
  error_prompt + " " + get_commands
end