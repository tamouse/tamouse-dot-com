#!/usr/bin/env ruby
require "rubygems"
require "bundler/setup"
require "sinatra/base"
require "yaml"
require "pony"

module MailHelpers
  def send_contact(params)
    Pony.mail({
      :to => 'tamouse.lists@gmail.com',
      :subject => "Contact from tamouse.com",
      :body => make_message_body(params),
      :via => :smtp,
      :via_options => {
        :address              => 'smtp.gmail.com',
        :port                 => '587',
        :enable_starttls_auto => true,
        :user_name            => 'tamouse.lists',
        :password             => 'nitwood;',
        :authentication       => :plain, # :plain, :login, :cram_md5, no auth by default
        :domain               => "localhost.localdomain" # the HELO domain provided by the client to the server
      }
    })
  end

  def make_message_body(params)
    %Q{
Contact message from tamouse.com site:


Email:    #{params["email"]}
Subject:  #{params["subject"]}

Message:

#{params["message"]}

Sent:     #{Time.now.to_s}
    }
  end
end

class ContactForm < Sinatra::Base
  enable :logging
  set :port, 4568
  set :public_folder, File.dirname(__FILE__) + '/build'
  helpers MailHelpers
  get "/" do
    redirect to("/index.html")
  end
  post "/contact" do
    logger.info params
    send_contact params
    redirect to("/thank_you.html")
  end
end
ContactForm.run!
