module PivotTable
  class Row
    include CellCollection
    include DataAccessor

    def to_hash
      hash = {
        row_name => header
      }

      orthogonal_headers.each_with_index do |header, index|
        row = data[index]
        hash[header] = row ? read_data_field(row, field_name, hash) : nil
      end

      hash
    end

    def to_a
      to_hash.values
    end

    def column_data(column_header, field=field_name)
      result = find_data(column_header)

      if result && field
        result = read_data_field(result, field, hash)
      end

      result
    end
  end
end
