module PivotTable
  module CellCollection

    ACCESSORS = [:header, :row_name, :data, :hash, :field_name, :value_name, :orthogonal_headers]

    ACCESSORS.each do |a|
      self.send(:attr_accessor, a)
    end

    def initialize(options = {})
      ACCESSORS.each do |a|
        self.send("#{a}=", options[a]) if options.has_key?(a)
      end
    end

    def total
      data.inject(0) do |t, x| 
        if x
          value = read_data_field(x, value_name, hash) 
        end

        t + (value || 0)
      end
    end

    def read_data_field(x, field, hash)
      hash ? x[field] : x.send(field)
    end

  private

    def find_data by_header_name
      data[
        orthogonal_headers.find_index{|header| by_header_name.to_s == header.to_s}
      ] rescue nil
    end

  end
end
