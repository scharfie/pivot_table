module PivotTable
  module DataAccessor
    def read_data_field(x, field, hash)
      hash ? x[field] : x.send(field)
    end
  end
end
