#!/usr/bin/env ruby

require 'pry'
require 'sequel'

FILE = '/usr/local/lan/tms.db'
DB = Sequel.sqlite FILE

class Event < Sequel::Model
end

class Device < Sequel::Model
  one_to_many :interfaces
end

class Interface < Sequel::Model
  many_to_one :device
end

pry.binding
