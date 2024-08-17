class MedicareNursing < ActiveRecord::Base
  establish_connection(Storage[host: :localhost, db: :usa_raw])

  self.table_name = 'medicare_nursing_homes'
  self.inheritance_column = :_type_disabled
end
