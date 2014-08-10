require "net/https"
require "uri"
require 'json'

# You need the following setup:
# - betfair developer account username/password
# - betfair developer application key
# - SSL cert/key setup as per https://api.developer.betfair.com/services/webapps/docs/display/1smk3cen4v3lu3yomq5qye0ni/Non-Interactive+(bot)+login

#usually read from yaml file:
BETFAIR_CONFIG = {}
BETFAIR_CONFIG['cert_file'] = ""
BETFAIR_CONFIG['key_file'] = ""
BETFAIR_CONFIG['username'] = ""
BETFAIR_CONFIG['password'] = ""

# get the keys/certs
cert = File.read("#{BETFAIR_CONFIG['cert_file']}")
key = File.read("#{BETFAIR_CONFIG['key_file']}")

#login
login_uri = URI.parse("https://identitysso.betfair.com/api/certlogin")
http = Net::HTTP.new(login_uri.host, login_uri.port)
http.use_ssl = true
http.cert = OpenSSL::X509::Certificate.new(cert)
http.key = OpenSSL::PKey::RSA.new(key)
http.verify_mode = OpenSSL::SSL::VERIFY_PEER

login_request = Net::HTTP::Post.new(login_uri.request_uri)
login_request.set_form_data({"username" => "#{BETFAIR_CONFIG['username']}", "password" => "#{BETFAIR_CONFIG['password']}"})
login_request["Content-Type"] = "application/x-www-form-urlencoded"
login_request["X-Application"] = "curlCommandLineTest"
login_response = http.request(login_request)    

json_response = JSON.parse(login_response.body)

puts "login success" if json_response["loginStatus"] == "SUCCESS"

session_token = json_response["sessionToken"]
app_key = BETFAIR_CONFIG['app_key']

# do some market/event queries
endpoint = "https://api.betfair.com/exchange/betting/rest/v1.0/"

uri = URI.parse("#{endpoint}listEvents/")
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_PEER

request = Net::HTTP::Post.new(uri.request_uri)
request["Accept"] = "application/json"
request["Content-Type"] = "application/json"
request["X-Application"] = "#{app_key}"
request["X-Authentication"] = "#{session_token}"
request.body = "{\"filter\":{\"competitionIds\":[\"7\"]}}"
response = http.request(request)

puts response.body
puts response.code