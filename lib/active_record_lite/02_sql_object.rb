require_relative 'db_connection'
require_relative '01_mass_object'
require 'active_support/inflector'

class MassObject
  def self.parse_all(results)
    results.map { |result| self.new(result) }
  end
end

class SQLObject < MassObject
  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || self.name.underscore.pluralize
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
      SELECT #{table_name}.*
      FROM #{ table_name }
    SQL
    parse_all(results)
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL, id)
      SELECT #{ table_name }.*
      FROM #{ table_name }
      WHERE #{ table_name }.id = ?
    SQL
    result.empty? ? nil : parse_all(result).first
  end

  def insert
    variables = self.class.attributes
    question_mark_string = (['?'] * variables.count).join(', ')
    DBConnection.execute(<<-SQL, *attribute_values )
      INSERT INTO #{ self.class.table_name } (#{ variables.join(', ') })
      VALUES (#{ question_mark_string })
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def save
    self.id.nil? ? insert : update
  end

  def update
    variables = self.class.attributes.map { |var| "#{var} = ?" }.join(', ')
    DBConnection.execute(<<-SQL, *attribute_values, id)
      UPDATE #{ self.class.table_name }
      SET #{ variables }
      WHERE #{ self.class.table_name }.id = ?
    SQL
  end

  def attribute_values
    self.class.attributes.map do |variable|
      self.send(variable)
    end
  end
end
