# Used in childrens
class ContactImportWorker < Workling::Base

  def import(options)
    begin
      puts "Importing..."
      start = Time.now
      mapping = ImportMapping.new(options[:fields])
      # Do any rows produce errors
      @contacts_with_errors = {}
      Contact.suspended_delta do
        load_from_spreadsheet mapping, options[:filename] do |line_num, contact|
          if contact.valid?
    	      contact.save!
    	      puts "Processed contact: #{line_num-1}"
          else
            puts "Error with contact: #{line_num - 1}"
            @contacts_with_errors[line_num] = contact
          end
        end
      end
      duration = Time.now - start
      unless @contacts_with_errors.blank?
        puts "ERRORS"
        puts @contacts_with_errors
      end
      puts "Importing took #{"%.2f" % duration} seconds"
      #Contact.reindex_core
    rescue Exception => e
      puts $!
      puts e.backtrace
    end
  end
  
  private
  def prepare_for_validation row
    if row["type"] && row["type"].match(/company|corporation|business|organi(s|z)ation/i)
      row["type"] = "organisation"
      #Store organisation name in surname field
      if !row["surname"] && row["forename"]
        row["surname"] = row["forename"]
        row["forename"] = nil
      end
    else
      row["type"] = "person"
    end
    # if row["address1"]
    #   address = ""
    #   5.times do |i|
    #     unless row["address#{i+1}"].blank?
    #       address << ", " unless address.blank?
    #       address << row["address#{i+1}"]
    #       row.delete("address#{i+1}")
    #     end
    #   end
    # end
    row["address"] = Location.new(:address1 => row.delete('address1'), :address2 => row.delete('address2'), :address3 => row.delete('address3'), :address4 => row.delete('address4'), :address5 => row.delete('address5'), :city => row.delete("city"), :country => row["country"], :postcode => row.delete("postcode"))
    if row["phone_number1"]
      phone_numbers = []
      5.times do |i|
        unless row["phone_number#{i+1}"].blank?
          phone_numbers << PhoneNumber.new(:number => row["phone_number#{i+1}"], :type => row["phone_number_type#{i+1}"])
        end
        row.delete("phone_number#{i+1}")
        row.delete("phone_number_type#{i+1}")
      end
      row["phone_numbers"] = phone_numbers
    end
    
    if row["donation_amount1"]
      donations = []
      10.times do |i|
        unless row["donation_amount#{i+1}"].blank?
          donations << Donation.new(:amount => row["donation_amount#{i+1}"].sub(163.chr,'').to_f,
          :date => Date.strptime(row["donation_date#{i+1}"],"%d/%m/%Y"),
          :description => row["donation_description#{i+1}"].toutf8
          )
        end
        row.delete("donation_amount#{i+1}")
        row.delete("donation_date#{i+1}")
        row.delete("donation_description#{i+1}")
      end
      row["donations"] = donations
    end
    row.delete('salutation')
    row            
  end
  
  def create_associated row
    if category_name = row["category"]
      unless category = ContactCategory.all(:conditions => {:name => category_name}).first
        category = ContactCategory.create(:name => category_name)
      end
      row.delete("category")
      row[:category_id] = category.id
    end
    row
  end
  
  def load_from_spreadsheet mapping, filename, &block
    contacts = []
    mapping.load_csv_and_convert_values(filename) do |line_num, row|
      puts "Loading line number #{line_num}"
      row = prepare_for_validation(row)
      row = create_associated(row)
      puts row.inspect
      contact = Contact.new(row)
      yield line_num, contact if block
      contacts << contact
    end
    contacts
  end
end