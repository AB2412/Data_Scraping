# frozen_string_literal: true

class MedicareNursingRuns < ActiveRecord::Base
    establish_connection(Storage[host: :localhost, db: :usa_raw])
  
    self.table_name = 'medicare_nursing_homes_runs'
    self.inheritance_column = :_type_disabled
  end
  