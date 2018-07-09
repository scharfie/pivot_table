module PivotTable
  class Grid
    include DataAccessor

    attr_accessor :source_data, :row_name, :column_name, :value_name, :field_name, :hash
    attr_reader :columns, :rows, :data_grid, :configuration

    DEFAULT_OPTIONS = {
      :sort => true,
      :hash => false
    }

    def initialize(opts = {}, &block)
      yield(self) if block_given?
      @configuration = Configuration.new(DEFAULT_OPTIONS.merge(opts))
    end

    def build
      populate_grid
      build_rows
      build_columns
      self
    end

    def build_rows
      @rows = []
      data_grid.each_with_index do |data, index|
        rows << Row.new(
          :header     => row_headers[index],
          :data       => data,
          :hash       => hash,
          :row_name   => row_name,
          :field_name => field_name,
          :value_name => value_name,
          :orthogonal_headers => column_headers
        )
      end
    end

    def build_columns
      @columns = []
      data_grid.transpose.each_with_index do |data, index|
        columns << Column.new(
          :header             => column_headers[index],
          :data               => data,
          :hash               => hash,
          :row_name           => row_name,
          :field_name         => field_name,
          :value_name         => value_name,
          :orthogonal_headers => row_headers
        )
      end
    end

    def column_headers
      @column_headers ||= headers column_name
    end

    def row_headers
      @row_headers ||= headers row_name
    end

    def column_totals
      columns.map { |c| c.total }
    end

    def row_totals
      rows.map { |r| r.total }
    end

    def grand_total
      column_totals.inject(0) { |t, x| t + x }
    end

    def prepare_grid
      @data_grid = []
      row_headers.count.times do
        data_grid << column_headers.count.times.inject([]) { |col| col << nil }
      end
      data_grid
    end

    def populate_grid
      prepare_grid
      row_headers.each_with_index do |row, row_index|
        data_grid[row_index] = build_data_row(row)
      end
      data_grid
    end

    def to_hash(options={})
      result = rows.map { |r| r.to_hash }

      if options[:include_totals]
        result.push(build_total_row.to_hash)
      end

      result
    end

    private

    def headers(method)
      hash = configuration.hash
      hdrs = source_data.collect { |c| read_data_field(c, method, hash) }.uniq
      configuration.sort ? hdrs.sort : hdrs
    end

    def build_total_row
      data = []

      totals = column_totals

      column_headers.each_with_index do |col, index|
        data.push({
          value_name => totals[index]
        })
      end

      Row.new(
        :header     => "Total",
        :data       => data,
        :hash       => hash,
        :row_name   => row_name,
        :field_name => field_name,
        :value_name => value_name,
        :orthogonal_headers => column_headers
      )
    end

    def build_data_row(row)
      current_row = []
      column_headers.each_with_index do |col, col_index|
        current_row[col_index] = find_data_item(row, col)
      end
      current_row
    end

    def find_data_item(row, col)
      source_data.find do |item|
        read_data_field(item, row_name, hash) == row && read_data_field(item, column_name, hash) == col
      end
    end
  end
end
