require 'csv'

if !ARGV.empty?
  def string_to_index(str)
    offset = 'A'.ord - 1
    str.chars.inject(0) { |x, c| x * 26 + c.ord - offset } - 1
  end

  file = ARGV[0]
  cols = ARGV[1].split('_').map { |str| string_to_index(str) }
  category = ARGV[2].split('_')

  arr_of_rows = CSV.read(file, col_sep: "\;", liberal_parsing: { double_quote_outside_quote: true })

  cleaned_rows = arr_of_rows.map do |answers|
    answers.select.with_index { |_value, index| cols.include?(index) }
  end

  head = cleaned_rows[0]
  content = cleaned_rows[1..-1]

  output = content.flat_map do |rows|
    rows.map.with_index do |row, index|
      ['', category[index], row, row]
    end
  end

  CSV.open('dist/output.csv', 'wb') do |csv|
    csv << %w[id category title body]
    output.each do |row|
      csv << row
    end
  end

  head.each.with_index do |head, index|
    puts "Using #{category[index]} instead of #{head}"
  end

  puts "\n"
  puts '#################################################'
  puts "Writed to the file with #{output.count + 1} lines"
  puts '#################################################'
else
  puts 'Use the following parameter to generate a CSV file'
  puts 'ruby main.rb <absolute-path-to-csv> <COLUMN-A_COLUM-B_COLUMN-ETC...> <CATEGORY-1_CATEGORY-2_CATEGORY-ETC...>'
end
