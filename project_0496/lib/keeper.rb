require_relative '../models/medicare_nursing_homes_runs'
require_relative '../models/usa_administrative_division_states'

class Keeper
  def initialize
    @run_object = RunId.new(MedicareNursingRuns)
    @run_id = @run_object.run_id
  end

  attr_reader :run_id

  def usa_administrative_division_states
    USAStates.all().map { |row| row[:short_name] }
  end

  def insert_records(data_array)
    
  end

  def finish
    @run_object.finish
  end

end