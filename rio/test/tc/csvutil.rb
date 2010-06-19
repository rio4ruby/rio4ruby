#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)+'/../'
  $:.unshift File.expand_path('../lib/')
end

module CSV_Util
  def records_to_rows(records)
    n_records = records.size
    rows = []
    head = records[0]
    (1...n_records).each do |n|
      record = records[n]
      row = {}
      (0...record.size).each do |ncol|
        row[head[ncol]] = row[ncol]
      end
      rows << row
    end
    rows
  end
  def records_to_strings(records,fs=',')
    records.map { |values| values.join(fs) }
  end
  def records_to_string(records,fs=',',rs=$/)
    records_to_strings(records,fs).join(rs) + rs
  end
  def strings_to_string(strings,rs=$/)
    strings.join(rs) + rs
  end
  def strings_to_lines(strings,rs=$/)
    strings.map { |s| s + rs }
  end
  def create_test_csv_records(n_rows,n_cols,header=true)
    records = []
    
    records << (0...n_cols).map { |n| %{Head#{n}} } if header
    
    (0...n_rows).each do |nrow|
      records << (0...n_cols).map { |n| %{Dat#{nrow}#{n}} }
    end
    records
  end

  def tcsv_gen_header_fields(n_cols)
    (0...n_cols).map { |n| %{Head#{n}} }
  end
  def tcsv_gen_data_fields(nrow,n_cols)
    (0...n_cols).map { |n| %{Dat#{nrow}#{n}} }
  end
  def tcsv_gen_recs(n_rows,n_cols,header=true)
    recs = []
    recs << tcsv_gen_header_fields(n_cols) if header
    (0...n_rows).each do |nrow|
      recs << tcsv_gen_data_fields(nrow,n_cols)
    end
    recs
  end


  def tcsv_rec_strings(recs,fs,qc)
    tcsv_rec_lines(recs,fs,"",qc).map{ |s| s.chomp }
  end

  def tcsv_rec_lines(recs,fs,rs,qc)
    lines = []
    recs.each do |rec|
      lines << ::CSV.generate_line(rec,{:col_sep => fs, 
                            :row_sep => rs, 
                            :quote_char => qc}).chomp + $/
    end
    lines
  end

  def create_test_csv_file(frio,n_rows,n_cols,fs,rs,qc,header=true)
    records = tcsv_gen_recs(n_rows,n_cols,header)
    lines = tcsv_rec_lines(records,fs,rs,qc)
    strings = tcsv_rec_strings(records,fs,qc)
    string = lines.join()
    frio < string
    [records,strings,lines,string]
  end

  def create_test_csv_data(frio,n_rows,n_cols,fs,rs,header=true)
    records = create_test_csv_records(n_rows,n_cols,header)
    strings = records_to_strings(records,fs)
    lines = strings_to_lines(strings,rs)
    string = strings_to_string(strings,rs)
    frio < string
    [records,strings,lines,string]
  end

end
