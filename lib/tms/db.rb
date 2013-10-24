module TMS
  class DB

    require 'sequel'
    require 'sqlite3'

    class << self
      def create
        db = Sequel.sqlite(CFG.db, :max_connections => 1, :pool_timeout => 60)
        #db.loggers << Log 
 

        db.create_table :events do
          primary_key :id
          foreign_key :device_id, :devices
          foreign_key :interface_id, :interfaces
          String      :from
          String      :to
          DateTime    :time
          String      :type
          String      :description
          Boolean     :planned
        end unless db.table_exists? :events

        db.create_table :devices do
          primary_key :id
          String      :name
          String      :ip, :unique => true
          DateTime    :seen_first
          DateTime    :seen_last
          Boolean     :up
        end unless db.table_exists? :devices

        db.create_table :interfaces do
          primary_key :id
          foreign_key :device_id, :devices
          String      :name
          String      :description
          FixNum      :index
          DateTime    :seen_first
          DateTime    :seen_last
          Boolean     :up
        end unless db.table_exists? :interfaces

        db.disconnect
      end
    end

    create

    DB_Sequel = Sequel.sqlite(CFG.db, :max_connections => 1, :pool_timeout => 60)

    class Device < Sequel::Model
      one_to_many :interfaces
    end
    
    class Interface < Sequel::Model
       many_to_one :device
    end

    class Event < Sequel::Model
    end

  end
end
