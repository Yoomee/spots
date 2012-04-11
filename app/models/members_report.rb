class MembersReport < Report

  title 'Members report'

  fields :email, :username, :surname, :forename, :created_at, :updated_at

  def rows
    Member.alphabetically.map do |member|
      Row.new(member)
    end
  end

  class Row < Report::Row

    delegate_all_to :@member 

    def initialize(member)
      @member = member
    end

  end

end
