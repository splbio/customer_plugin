class Customer < ActiveRecord::Base
  has_many :projects
  has_and_belongs_to_many :issues, :uniq => true
  
  # name or company is mandatory
  validates_presence_of :name, :if => :company_unsetted
  validates_presence_of :company, :if => :name_unsetted
  validates_uniqueness_of :name, :scope => :company

  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, 
    :allow_nil => true, :allow_blank => true
  #TODO validate website address
  #TODO validate skype_name contact

  attr_accessible :name, :company, :address, :phone, :email, :website, :skype_name
  
   def pretty_name
     result = []
     [self.name, self.company].each do |field|
       result << field unless field.blank?
     end
     
     return result.join(", ")
   end

   # Search for customers with a name or company matching term
   def self.search(term)
     self.order(:id).
       where("LOWER(#{Customer.table_name}.name) LIKE LOWER(:term) " +
             "OR LOWER(#{Customer.table_name}.company) LIKE LOWER(:term) ",
             :term => "%#{term}%")
   end

   private
  
  def name_unsetted
    self.name.blank?
  end
  
  def company_unsetted
    self.company.blank?
  end

  if Rails.env.test?
    def self.generate!(attributes={})
      @generated_name ||= "John Doe 0"
      @generated_name.succ!
      customer = Customer.new(attributes)
      customer.name ||= @generated_name
      yield customer if block_given?
      customer.save!
      customer
    end
  end

  
end
