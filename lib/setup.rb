require 'rubygems'
require 'bundler/setup'
require 'active_record'
require 'csv'
require 'pry'

class Setup
  attr_accessor :options

  def initialize(options)
    @options = options
    db_connect
  end

  def db_tables
    @options.each do |option|
      create_table(option[:schema][:table_name], option[:schema][:columns])
    end
  end

  def load_data
    @options.each do |option|
      ActiveRecord::Base.transaction do
        CSV.foreach(option[:data_file]) do |data_row|
          # using ActiveRecord#create is slow. It's faster to do raw inserts wrapped in a transaction.
          ActiveRecord::Base.connection.execute insert_statement(option[:schema], data_row)
        end
      end
    end
  end

  private

  def create_table(table_name, columns)
    ActiveRecord::Base.connection.instance_eval do
      create_table(table_name, id: false) do |t|
        next unless columns.is_a? Array
        columns.each do |column|
          if column.is_a? Hash
            t.send(column.values.last, column.keys.first)
          else
            t.string column
          end
        end
      end
    end
  end

  def insert_statement(schema, data_row)
    cols = schema[:columns].collect{|a| a.is_a?(String) ? a : a.keys}.flatten
    %Q[INSERT INTO `#{schema[:table_name]}` (`#{cols.join('`, `')}`) VALUES ("#{data_row.join('", "')}")]
  end

  def db_connect
    ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'
  end
end
